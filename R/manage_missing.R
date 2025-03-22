
## not vectorized; always returns a single value

#' Test if an object exists
#'
#' @param x Any object
#'
#' @returns TRUE or FALSE
#' @export
#'
#' @examples
#' # these are TRUE
#' this_exists(4)
#' this_exists(TRUE)
#' this_exists(FALSE)
#' this_exists("a word")
#' this_exists(c("a", "b"))
#' this_exists(0)
#'
#' # these are FALSE
#' this_exists(c())
#' this_exists(list())
#' this_exists(NULL)
#' this_exists(NA)
this_exists <- function(x) {
  !(all(is.na(x)) || all(is.null(x)) || length(x) == 0)
}

#' Tests if all entries in a list or vector are the same
#'
#' Only returns TRUE if there are no NA's or NULL's in the list or vector
#'
#' @param x A vector or list
#'
#' @returns TRUE or FALSE
#' @export
#'
#' @examples
#' # these are TRUE
#' this_is_singular("a")
#' this_is_singular(c("a", "a"))
#' this_is_singular(list("a", "a"))
#'
#' # these are FALSE
#' this_is_singular(c("a", "b"))
#' this_is_singular(c("a", NA))
#' this_is_singular(list("a", NULL))
this_is_singular <- function(x) {
  if (any(is.na(x)) || any(is.null(x))) { return(FALSE) }
  length(unique(x)) == 1
}

## these are vectorized; they return a value for each entry in a input vector

.singular_this_or_empty_string <- function(x) {
  if(this_exists(x)) { return(x) }
  ""
}

.vectorized_this_or_empty_string <- Vectorize(.singular_this_or_empty_string,
                                              USE.NAMES = FALSE)

#' Returns given object if it exists, otherwise empty string
#'
#' @param x An object, list, or vector
#'
#' @returns Object or empty string ("")
#' @export
#'
#' @examples
#' one_string <- "hello"
#' two_strings <- c(one_string, one_string)
#'
#' # returns the given object
#' this_or_empty_string(one_string)
#' this_or_empty_string(two_strings)
#'
#' # returns an empty string ("")
#' this_or_empty_string(NA)
#' this_or_empty_string(NULL)
#'
#' # returns c("", "") - function is vectorized
#' this_or_empty_string(c(NA, NA))
this_or_empty_string <- function(x) {
  if (length(x) > 1) { return(.vectorized_this_or_empty_string(x))}
  .singular_this_or_empty_string(x)
}

.singular_this_or_na <- function(x) {
  ifelse(this_exists(x), x, NA)
}

.vectorized_this_or_na <- Vectorize(.singular_this_or_na, USE.NAMES=FALSE)

#' Returns given object if it exists, otherwise empty string
#'
#' @param x An object, list, or vector
#'
#' @returns Object or NA
#' @export
#'
#' @examples
#' one_string <- "hello"
#' two_strings <- c(one_string, one_string)
#'
#' # returns the given object
#' this_or_na(one_string)
#' this_or_na(two_strings)
#'
#' # returns NA
#' this_or_na(NA)
#' this_or_na(NULL)
#'
#' # returns c(NA, NA) - function is vectorized
#' this_or_na(c(NA, NA))
this_or_na <- function(x) {
  if (length(x) > 1) { return(.vectorized_this_or_na(x)) }
  .singular_this_or_na(x)
}

