test_that("tobasictext removes html markup", {
  expect_equal(tobasictext("<b>bold</b>"), "bold")
})

test_that("tobasictext removes excess whitespace", {
  expect_equal(tobasictext("one \n       two"), "one two")
})

test_that("tobasictext removes double slash escapes", {
  expect_equal(tobasictext("big \\& bold"), "big & bold")
})

# Combined operations (actual documented example)
test_that("tobasictext handles combined HTML, whitespace, and escapes", {
  input <- "<p>This is some text.\n                    This is <b>bold!</b></p>"
  expected <- "This is some text. This is bold!"
  expect_equal(tobasictext(input), expected)
})

# Edge cases
test_that("tobasictext handles empty and whitespace-only strings", {
  # Empty strings become NA after minimal_html processing
  expect_equal(tobasictext(""), NA_character_)
  expect_equal(tobasictext("   \n\t   "), NA_character_)
})

test_that("tobasictext handles nested HTML tags", {
  expect_equal(tobasictext("<div><p><b>text</b></p></div>"), "text")
})

# Complex real-world scenarios
test_that("tobasictext handles multiple types of whitespace", {
  expect_equal(tobasictext("a\n\nb\t\tc    d"), "a b c d")
})

test_that("tobasictext handles mixed escapes and HTML", {
  # Backslash escapes are removed, then HTML entities are parsed by rvest
  expect_equal(tobasictext("<b>\\&nbsp;</b>"), " ")
})

# Vectorization tests
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
  expect_equal(result, c("text", NA_character_, "plain"))
  expect_length(result, 3)
})

test_that("tobasictext vectorization with mixed content", {
  input <- c(
    "<p>First paragraph</p>",
    "",
    "<div><b>nested</b> content</div>",
    "plain text"
  )
  result <- tobasictext(input)
  expect_equal(result, c("First paragraph", NA_character_, "nested content", "plain text"))
  expect_length(result, 4)
})
