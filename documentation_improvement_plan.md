# Documentation Improvement Plan

## Executive Summary

Analysis of aidr package documentation reveals one **critical error**, several missing behavior details, and opportunities to enhance clarity for users. While all exported functions have basic roxygen2 documentation, many lack important details about vectorization, edge cases, and return values.

## Current State

- **6 exported functions:** All have @param, @returns, @export, and @examples
- **5 internal helpers:** None have documentation (acceptable per conventions, but could benefit from inline comments)
- **Code coverage:** 100%
- **Documentation completeness:** ~60% (basic structure present, details lacking)

---

## Issues by Severity

### CRITICAL (Must Fix)

#### 1. **Wrong documentation in `this_or_na()`** (Line 131)
**Current:** "Returns given object if it exists, otherwise empty string"
**Actual behavior:** Returns NA, not empty string
**Impact:** Misleading to users

**Fix:**
```r
#' Returns given object if it exists, otherwise NA
```

---

### HIGH PRIORITY (Important Details Missing)

#### 2. **`tobasictext()` - Incomplete transformation documentation** (Lines 2-11)
**Current issues:**
- Generic description: "Clean up text that has extra whitespace and html elements"
- @param just says "Input text"
- @returns just says "Text"
- Example doesn't show expected output
- Missing edge case: empty strings → NA behavior
- No mention of transformation steps

**Proposed improvements:**
```r
#' Clean and normalize text by removing HTML, escapes, and excess whitespace
#'
#' Performs a series of transformations to convert HTML-formatted text into
#' clean, readable plain text. Useful for processing web-scraped content or
#' cleaning up text with inconsistent formatting.
#'
#' @param txt Character string or vector containing text to clean. May include
#'   HTML tags, backslash escapes, and irregular whitespace.
#'
#' @returns Character string or vector with transformations applied. Returns
#'   `NA_character_` if input is empty string or whitespace-only. Vectorized
#'   to handle character vectors element-wise.
#'
#' @details
#' Transformation pipeline:
#' 1. Squishes whitespace (collapses multiple spaces, tabs, newlines to single space)
#' 2. Removes backslash escapes (e.g., `\\&` becomes `&`)
#' 3. Parses as minimal HTML document
#' 4. Extracts text content (strips all HTML tags)
#'
#' @export
#'
#' @examples
#' # Combined HTML, whitespace, and formatting cleanup
#' x <- "<p>This is some text.\n                    This is <b>bold!</b></p>"
#' tobasictext(x)
#' #> [1] "This is some text. This is bold!"
#'
#' # Empty or whitespace-only strings return NA
#' tobasictext("")
#' #> [1] NA
#' tobasictext("   \n\t   ")
#' #> [1] NA
#'
#' # Nested HTML tags
#' tobasictext("<div><p><b>nested</b> text</p></div>")
#' #> [1] "nested text"
```

#### 3. **`this_or_default_value()` - Missing vector recycling documentation** (Lines 98-123)
**Current issues:**
- No mention of vector recycling behavior (lines 64-69 in source)
- No examples with mixed NA/value vectors
- No examples showing vector-length default values

**Proposed additions to @details and @examples:**
```r
#' @details
#' This function is vectorized. When `x` has multiple elements:
#' - If `default_value` has length 1, it is recycled for all NA positions
#' - If `default_value` matches length of `x`, values are applied element-wise
#' - Mixed vectors of valid values and NAs are supported
#'
#' @examples
#' # Existing examples...
#'
#' # Mixed NA and valid values
#' this_or_default_value(c("a", NA, "b"), "default")
#' #> [1] "a"       "default" "b"
#'
#' # Vector recycling: single default for all NAs
#' this_or_default_value(c(NA, NA, NA), "default")
#' #> [1] "default" "default" "default"
#'
#' # Element-wise defaults matching vector length
#' this_or_default_value(c(NA, NA), c("first", "second"))
#' #> [1] "first"  "second"
#'
#' # Mixed input with vector defaults
#' this_or_default_value(c("keep", NA), c("d1", "d2"))
#' #> [1] "keep" "d2"
```

#### 4. **`this_or_empty_string()` - Missing vectorization details** (Lines 72-96)
**Current issues:**
- @returns doesn't mention vectorization
- No examples with mixed NA/value vectors
- List behavior not clearly documented

**Proposed additions:**
```r
#' @returns Character string or character vector. If `x` is a vector or list,
#'   returns a character vector with NAs/NULLs replaced by empty strings.
#'   Lists are simplified to vectors.
#'
#' @examples
#' # Existing examples...
#'
#' # Mixed NA and valid values
#' this_or_empty_string(c("a", NA, "b"))
#' #> [1] "a" ""  "b"
#'
#' # List input simplified to character vector
#' this_or_empty_string(list("a", NULL, "b"))
#' #> [1] "a" ""  "b"
```

#### 5. **`this_or_na()` - Missing vectorization details** (Lines 131-155)
Similar to `this_or_empty_string()`, add:
```r
#' @returns Original value if it exists, otherwise NA. If `x` is a vector,
#'   returns a vector with NAs/NULLs replaced by NA (effectively no change
#'   for NA values).
#'
#' @examples
#' # Existing examples...
#'
#' # Mixed NA and valid values
#' this_or_na(c("a", NA, "b"))
#' #> [1] "a" NA  "b"
```

---

### MEDIUM PRIORITY (Clarity Improvements)

#### 6. **`this_exists()` - Could be more descriptive** (Lines 4-27)
**Current:** "Test if an object exists"
**Enhancement:**
```r
#' Test if an object exists (is not NA, NULL, or empty)
#'
#' Returns a single logical value indicating whether an object has content.
#' Useful as a universal "has value" check that handles NA, NULL, and empty
#' vectors/lists consistently. Always returns a single TRUE/FALSE regardless
#' of input length.
#'
#' @param x Any object to test (vector, list, scalar, etc.)
#'
#' @returns Single logical value: `TRUE` if object has content (including
#'   FALSE, 0, or empty strings), `FALSE` if object is NA, NULL, or has
#'   zero length.
```

#### 7. **`this_is_singular()` - Clarify "singular" meaning** (Lines 29-51)
**Current:** "Tests if all entries in a list or vector are the same"
**Enhancement:**
```r
#' Test if all entries in a vector or list are identical (singular)
#'
#' Returns TRUE only if all elements are the same AND there are no NA or NULL
#' values present. Useful for validating that a vector contains a single
#' repeated value.
#'
#' @param x A vector or list to test
#'
#' @returns Single logical value: `TRUE` if all elements are identical with
#'   no NAs/NULLs, `FALSE` otherwise (including when NAs/NULLs are present).
```

---

### LOW PRIORITY (Nice to Have)

#### 8. **Internal helper functions - Add inline comments**
While internal functions (`.` prefix) don't need full roxygen docs, brief inline comments would help maintainers:

```r
# Internal non-vectorized helper: return x if it exists, else default_value
.singular_this_or_set_default <- function(x, default_value) {
  if(this_exists(x)) { return(x) }
  default_value
}

# Internal vectorized wrapper with length recycling for default_value
.vectorized_this_or_set_default <- function(x, default_value) {
  # Recycle single default_value to match length of x
  if (length(default_value) != length(x)) {
    if (length(default_value) == 1) {
      default_value = rep(default_value, times=length(x))
    }
  }
  mapply(.singular_this_or_set_default, x, default_value, USE.NAMES = FALSE)
}
```

#### 9. **Add package-level documentation**
Consider adding a package documentation file (`R/aidr-package.R`):

```r
#' @keywords internal
"_PACKAGE"

#' aidr: Personal R Utilities for Missing Data and Text Cleaning
#'
#' A collection of commonly reused utility functions for:
#' - Managing missing data (NA, NULL, empty values)
#' - Text munging (cleaning HTML and whitespace)
#'
#' @section Missing Data Functions:
#' - `this_exists()`: Universal existence check
#' - `this_is_singular()`: Test if all values are identical
#' - `this_or_empty_string()`: Replace missing with ""
#' - `this_or_default_value()`: Replace missing with custom default
#' - `this_or_na()`: Normalize missing to NA
#'
#' @section Text Munging Functions:
#' - `tobasictext()`: Clean HTML, escapes, and whitespace
#'
#' @docType package
#' @name aidr-package
NULL
```

---

## Implementation Order

1. **Fix critical error** (Issue #1): `this_or_na()` title - 2 minutes
2. **High priority** (Issues #2-5): Add missing behavior details - 30 minutes
3. **Medium priority** (Issues #6-7): Enhance descriptions - 15 minutes
4. **Low priority** (Issues #8-9): Internal comments and package docs - 20 minutes

**Total estimated time:** ~70 minutes

---

## Verification Steps

After making changes:

```r
# 1. Regenerate documentation
devtools::document()

# 2. Check for documentation warnings
devtools::check()

# 3. Preview rendered help
?this_or_default_value
?tobasictext

# 4. Verify examples run without errors
devtools::run_examples()
```

---

## Files to Modify

1. `R/manage_missing.R` - Update roxygen blocks for 5 exported functions + add inline comments
2. `R/text_munging.R` - Update roxygen block for 1 exported function
3. `R/aidr-package.R` - Create new file for package-level documentation (optional)

---

## Expected Outcomes

- ✅ **Accuracy:** All documentation matches actual behavior
- ✅ **Completeness:** All edge cases and vectorization behavior documented
- ✅ **Usability:** Users can understand functions without reading source code
- ✅ **Examples:** All examples show expected output with `#>` comments
- ✅ **Discoverability:** Package-level docs help users find relevant functions
