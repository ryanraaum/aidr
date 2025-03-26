test_that("tobasictext removes html markup", {
  expect_equal(tobasictext("<b>bold</b>"), "bold")
})

test_that("tobasictext removes excess whitespace", {
  expect_equal(tobasictext("one \n       two"), "one two")
})

test_that("tobasictext removes double slash escapes", {
  expect_equal(tobasictext("big \\& bold"), "big & bold")
})
