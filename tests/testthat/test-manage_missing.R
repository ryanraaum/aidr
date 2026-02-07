
test_that("this_exists finds true things", {
  expect_true(this_exists(4))
  expect_true(this_exists(c(2,4,6)))
  expect_true(this_exists(list(2,4,6)))
  expect_true(this_exists(TRUE))
  expect_true(this_exists(FALSE))
  expect_true(this_exists("a word"))
  expect_true(this_exists(c("a", "b"))) # single response regardless of length of input
  expect_true(this_exists(0))
})

test_that("this_exists finds false things", {
  expect_false(this_exists(c()))
  expect_false(this_exists(list()))
  expect_false(this_exists(NULL))
  expect_false(this_exists(NA))
  expect_false(this_exists(c(NULL, NULL)))
  expect_false(this_exists(c(NA, NA)))
})

test_that("this_is_singular finds true things", {
  expect_true(this_is_singular("a"))
  expect_true(this_is_singular(1))
  expect_true(this_is_singular(c("a", "a")))
  expect_true(this_is_singular(c(1,1)))
  expect_true(this_is_singular(list("a", "a")))
  expect_true(this_is_singular(c(TRUE,TRUE)))
})

test_that("this_is_singular finds false things", {
  expect_false(this_is_singular(c("a", "b")))
  expect_false(this_is_singular(c("a", NA)))
  expect_false(this_is_singular(list("a", NULL)))
  expect_false(this_is_singular(c(1,2)))
  expect_false(this_is_singular(c(TRUE,FALSE)))
})

test_that("this_is_singular handles missing and null", {
  # and by "handles", we're going with: returns FALSE
  expect_false(this_is_singular(NA))
  expect_false(this_is_singular(NULL))
})

test_that("this_or_empty_string returns this", {
  one_string <- "hello"
  two_strings <- c(one_string, one_string)
  expect_equal(this_or_empty_string(one_string), one_string)
  expect_equal(this_or_empty_string(two_strings), two_strings)
})

test_that("this_or_empty_string returns empty string when appropriate", {
  expect_equal(this_or_empty_string(NA), "")
  expect_equal(this_or_empty_string(NULL), "")
  expect_equal(this_or_empty_string(c(NA, NA)), c("", ""))
  expect_equal(this_or_empty_string(list(NULL, NULL)), c("", ""))
})

test_that("this_or_default_value returns this", {
  one_string <- "hello"
  two_strings <- c(one_string, one_string)
  expect_equal(this_or_default_value(one_string, "default"), one_string)
  expect_equal(this_or_default_value(two_strings, "default"), two_strings)
})

test_that("this_or_default_value returns default value when appropriate", {
  expect_equal(this_or_default_value(NA, "default"), "default")
  expect_equal(this_or_default_value(NULL, "default"), "default")
  expect_equal(this_or_default_value(c(NA, NA), "default"), c("default", "default"))
  expect_equal(this_or_default_value(list(NULL, NULL), "default"), c("default", "default"))
})


test_that("this_or_na returns this", {
  one_string <- "hello"
  two_strings <- c(one_string, one_string)
  expect_equal(this_or_na(one_string), one_string)
  expect_equal(this_or_na(two_strings), two_strings)
})

test_that("this_or_na returns NA when appropriate", {
  expect_equal(this_or_na(NA), NA)
  expect_equal(this_or_na(NULL), NA)
  expect_equal(this_or_na(c(NA, NA)), c(NA, NA))
})

# Edge case tests: mixed NA vectors
test_that("this_or_empty_string handles mixed NA vectors", {
  expect_equal(this_or_empty_string(c("a", NA, "b")), c("a", "", "b"))
})

test_that("this_or_default_value handles mixed NA vectors", {
  expect_equal(this_or_default_value(c("a", NA, "b"), "def"),
               c("a", "def", "b"))
})

test_that("this_or_na handles mixed NA vectors", {
  expect_equal(this_or_na(c("a", NA, "b")), c("a", NA, "b"))
})

# Edge case tests: vector length mismatches
test_that("this_or_default_value recycles single default for vectors", {
  expect_equal(this_or_default_value(c(NA, NA, NA), "default"),
               c("default", "default", "default"))
})

test_that("this_or_default_value handles vector defaults matching length", {
  expect_equal(this_or_default_value(c(NA, NA), c("d1", "d2")),
               c("d1", "d2"))
})

test_that("this_or_default_value with mixed input and vector defaults", {
  expect_equal(this_or_default_value(c("a", NA), c("d1", "d2")),
               c("a", "d2"))
})

# Edge case tests: list handling
test_that("this_or_empty_string simplifies lists as documented", {
  result <- this_or_empty_string(list("a", NULL, "b"))
  expect_equal(result, c("a", "", "b"))
  expect_type(result, "character")
})

# Validation tests: mismatched length errors
test_that("this_or_default_value errors on mismatched vector lengths", {
  expect_error(
    this_or_default_value(c(NA, NA, NA), c("a", "b")),
    "must have length 1.*or match length"
  )

  expect_error(
    this_or_default_value(c(NA, NA), c("a", "b", "c")),
    "must have length 1.*or match length"
  )

  expect_error(
    this_or_default_value(c(NA, NA, NA, NA), c("a", "b")),
    "must have length 1.*or match length"
  )
})

# Length-1 list simplification tests
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
  expect_false(is.list(result))
})

test_that("this_or_na simplifies length-1 lists", {
  result <- this_or_na(list("hello"))
  expect_equal(result, "hello")
  expect_type(result, "character")
  expect_false(is.list(result))
})

test_that("this_or_empty_string simplifies length-1 lists with NULL", {
  result <- this_or_empty_string(list(NULL))
  expect_equal(result, "")
  expect_type(result, "character")
  expect_false(is.list(result))
})
