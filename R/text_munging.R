
#' Clean up text that has extra whitespace and html elements
#'
#' @param txt Input text
#'
#' @returns Text
#' @export
#'
#' @examples
#' x <- ("<p>This is some text.\n                    This is <b>bold!</b></p>")
#' tobasictext(x)
tobasictext <- function(txt) {
  txt |>
    stringr::str_squish() |>
    stringr::str_replace_all("\\\\", "") |>
    rvest::minimal_html() |>
    rvest::html_text2()
}
