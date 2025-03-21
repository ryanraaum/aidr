test_that("this_exists finds true things", {
  expect_true(this_exists(4))
  expect_true(this_exists(c(2,4,6)))
  expect_true(this_exists(list(2,4,6)))
  expect_true(this_exists(TRUE))
  expect_true(this_exists(FALSE))
  expect_true(this_exists("a word"))
})

test_that("this_exists finds false things", {
  expect_false(this_exists(c()))
  expect_false(this_exists(list()))
  expect_false(this_exists(NULL))
  expect_false(this_exists(NA))
  expect_false(this_exists(c(NULL, NULL)))
  expect_false(this_exists(c(NA, NA)))
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
