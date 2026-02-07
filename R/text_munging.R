
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
#' \enumerate{
#'   \item Squishes whitespace (collapses multiple spaces, tabs, newlines to single space)
#'   \item Removes backslash escapes (e.g., `\\&` becomes `&`)
#'   \item Parses as minimal HTML document
#'   \item Extracts text content (strips all HTML tags)
#' }
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
#'
#' # Multiple types of whitespace
#' tobasictext("a\n\nb\t\tc    d")
#' #> [1] "a b c d"
tobasictext <- function(txt) {
  txt |>
    stringr::str_squish() |>
    stringr::str_replace_all("\\\\", "") |>
    rvest::minimal_html() |>
    rvest::html_text2()
}
