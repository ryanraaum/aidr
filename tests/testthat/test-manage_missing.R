
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
