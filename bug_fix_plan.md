# Bug Fix Plan

## Executive Summary

Analysis of the aidr package code has identified **3 confirmed bugs** ranging from critical to minor severity. All bugs relate to edge cases in vectorization, type handling, and input validation.

## Confirmed Bugs

### BUG #1: `tobasictext()` Not Vectorized Despite Documentation Claims ⚠️ CRITICAL

**Location:** `R/text_munging.R`, lines 45-51

**Issue:**
The function documentation (line 12-13) states:
> "Vectorized to handle character vectors element-wise"

However, testing reveals:
```r
tobasictext(c("text1", "text2"))
# Error in read_xml(...): `x` must be a single string, not a character vector
```

**Root Cause:**
The `rvest::minimal_html()` function in the pipeline (line 49) only accepts single strings, not character vectors. While `stringr::str_squish()` and `stringr::str_replace_all()` are vectorized, the pipeline breaks at the HTML parsing step.

**Impact:**
- **Severity:** Critical
- Users expecting vectorized behavior will get errors
- Documentation is misleading
- Could break existing code that passes vectors

**Proposed Fix:**
Two options:

**Option A: Make it truly vectorized**
```r
tobasictext <- function(txt) {
  # Handle NULL/NA
  if (is.null(txt)) return(NA_character_)

  # Vectorize the entire pipeline
  vapply(txt, function(single_txt) {
    if (is.na(single_txt)) return(NA_character_)

    single_txt |>
      stringr::str_squish() |>
      stringr::str_replace_all("\\\\", "") |>
      rvest::minimal_html() |>
      rvest::html_text2()
  }, character(1), USE.NAMES = FALSE)
}
```

**Option B: Remove vectorization claim and enforce single string**
```r
tobasictext <- function(txt) {
  # Validate input
  if (is.null(txt)) return(NA_character_)
  if (length(txt) != 1) {
    stop("`txt` must be a single string, not a character vector of length ",
         length(txt), ". Use lapply() or sapply() for vectorization.")
  }

  txt |>
    stringr::str_squish() |>
    stringr::str_replace_all("\\\\", "") |>
    rvest::minimal_html() |>
    rvest::html_text2()
}
```

**Recommendation:** Option A (make it vectorized) because:
- More user-friendly
- Matches documentation intent
- Consistent with other package functions that are vectorized
- Simple to implement with vapply

**Tests to Add:**
```r
test_that("tobasictext is vectorized for character vectors", {
  input <- c("<b>first</b>", "<i>second</i>", "third")
  result <- tobasictext(input)
  expect_equal(result, c("first", "second", "third"))
  expect_length(result, 3)
})

test_that("tobasictext handles NULL input", {
  expect_equal(tobasictext(NULL), NA_character_)
})

test_that("tobasictext handles NA in vectors", {
  input <- c("<b>text</b>", NA, "plain")
  result <- tobasictext(input)
  expect_equal(result[2], NA_character_)
})
```

---

### BUG #2: Silent Recycling in `this_or_default_value()` with Mismatched Lengths ⚠️ MEDIUM

**Location:** `R/manage_missing.R`, lines 93-100

**Issue:**
When `default_value` length doesn't match `x` length and isn't 1, the function silently recycles via `mapply()`:

```r
this_or_default_value(c(NA, NA, NA), c("a", "b"))
# Warning: longer argument not a multiple of length of shorter
# Result: "a" "b" "a"
```

**Root Cause:**
The logic only handles the case where `default_value` has length 1:
```r
if (length(default_value) != length(x)) {
  if (length(default_value) == 1) {
    default_value = rep(default_value, times=length(x))
  }
  # Falls through to mapply if length > 1 but not matching
}
mapply(.singular_this_or_set_default, x, default_value, USE.NAMES = FALSE)
```

**Impact:**
- **Severity:** Medium
- Produces warning but continues execution
- Likely user error goes undetected
- Surprising behavior (silent recycling of c("a", "b") to c("a", "b", "a"))
- Documentation says "vector matching the length of `x`" but doesn't specify what happens otherwise

**Proposed Fix:**
Add validation to catch mismatched lengths:

```r
.vectorized_this_or_set_default <- function(x, default_value) {
  # Validate and handle default_value length
  if (length(default_value) != length(x)) {
    if (length(default_value) == 1) {
      # Recycle single default_value to match length of x
      default_value <- rep(default_value, times = length(x))
    } else {
      # Mismatched lengths - this is likely a user error
      stop(
        "`default_value` must have length 1 (recycled) or match length of `x` (",
        length(x), "), not length ", length(default_value)
      )
    }
  }
  mapply(.singular_this_or_set_default, x, default_value, USE.NAMES = FALSE)
}
```

**Tests to Add:**
```r
test_that("this_or_default_value errors on mismatched vector lengths", {
  expect_error(
    this_or_default_value(c(NA, NA, NA), c("a", "b")),
    "must have length 1.*or match length"
  )

  expect_error(
    this_or_default_value(c(NA, NA), c("a", "b", "c")),
    "must have length 1.*or match length"
  )
})
```

---

### BUG #3: Length-1 Lists Not Simplified to Character Vectors ⚠️ MINOR

**Location:** `R/manage_missing.R`, lines 140-143 (and similar in `this_or_default_value`, `this_or_na`)

**Issue:**
Length-1 lists are not simplified, creating inconsistent behavior:

```r
this_or_empty_string(list("hello"))
# Returns: list("hello")  [still a list!]

this_or_empty_string(list("hello", "world"))
# Returns: c("hello", "world")  [character vector]
```

**Root Cause:**
The vectorization check `if (length(x) > 1)` treats length-1 lists as scalars:
```r
this_or_empty_string <- function(x) {
  if (length(x) > 1) {
    return(.vectorized_this_or_set_default(x, ""))  # Uses mapply, which simplifies
  }
  .singular_this_or_set_default(x, "")  # Returns x as-is if it exists
}
```

Length-1 lists go through `.singular_this_or_set_default()`, which just returns the list unchanged. Length-2+ lists go through `mapply()`, which simplifies them.

**Impact:**
- **Severity:** Minor
- Inconsistent return types (list vs character vector)
- Documentation claims "Lists are simplified to character vectors" but this only happens for length > 1
- Could cause downstream type errors in user code

**Proposed Fix:**
Modify the vectorization check to treat all lists as vectors:

```r
this_or_empty_string <- function(x) {
  # Treat lists as vectors regardless of length for consistent simplification
  if (length(x) > 1 || is.list(x)) {
    return(.vectorized_this_or_set_default(x, ""))
  }
  .singular_this_or_set_default(x, "")
}
```

Apply same fix to `this_or_default_value()` and `this_or_na()`.

**Tests to Add:**
```r
test_that("this_or_empty_string simplifies length-1 lists", {
  result <- this_or_empty_string(list("hello"))
  expect_equal(result, "hello")
  expect_type(result, "character")
  expect_false(is.list(result))
})

test_that("this_or_default_value simplifies length-1 lists", {
  result <- this_or_default_value(list(NA), "default")
  expect_equal(result, "default")
  expect_type(result, "character")
})

test_that("this_or_na simplifies length-1 lists", {
  result <- this_or_na(list("hello"))
  expect_equal(result, "hello")
  expect_type(result, "character")
})
```

---

## Implementation Priority

1. **BUG #1 (Critical)** - Fix `tobasictext()` vectorization - **~30 minutes**
2. **BUG #2 (Medium)** - Add validation for mismatched lengths - **~15 minutes**
3. **BUG #3 (Minor)** - Fix length-1 list simplification - **~20 minutes**

**Total estimated time:** ~65 minutes

---

## Implementation Order

### Phase 1: Fix Critical Bug
1. Update `tobasictext()` to be truly vectorized
2. Add tests for vectorization
3. Run `devtools::test()` to ensure existing tests pass
4. Run `devtools::check()` to validate

### Phase 2: Fix Medium Priority Bug
1. Add validation to `.vectorized_this_or_set_default()`
2. Add tests for mismatched length errors
3. Update documentation if needed
4. Run tests

### Phase 3: Fix Minor Bug
1. Update `this_or_empty_string()`, `this_or_default_value()`, `this_or_na()`
2. Add tests for length-1 list simplification
3. Run tests

### Phase 4: Verification
1. Run full test suite: `devtools::test()`
2. Run examples: `devtools::run_examples()`
3. Run package check: `devtools::check()`
4. Verify 100% code coverage maintained: `covr::package_coverage()`

---

## Files to Modify

1. **R/text_munging.R** - Fix `tobasictext()` vectorization
2. **R/manage_missing.R** - Fix length validation and list simplification
3. **tests/testthat/test-text_munging.R** - Add vectorization tests
4. **tests/testthat/test-manage_missing.R** - Add validation and list tests

---

## Expected Outcomes

- ✅ **Bug-free:** All 3 confirmed bugs fixed
- ✅ **Tested:** New tests verify fixes and prevent regression
- ✅ **Documented:** Behavior matches documentation
- ✅ **Robust:** Better input validation prevents user errors
- ✅ **Consistent:** Predictable behavior across all edge cases
- ✅ **Coverage:** Maintain 100% code coverage

---

## Risk Assessment

**Low Risk Changes:**
- Bug #1 fix is isolated to one function
- Bug #2 adds validation without changing happy-path behavior
- Bug #3 affects edge case only (length-1 lists)

**Breaking Changes:**
- Bug #2 will break code that relies on silent recycling (but this is buggy code)
- Should be acceptable since it prevents incorrect behavior

**Mitigation:**
- Comprehensive test coverage
- All existing tests must pass
- Documentation clearly explains expected behavior
