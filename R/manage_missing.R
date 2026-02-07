
## not vectorized; always returns a single value

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
#' @export
#'
#' @examples
#' # these are TRUE
#' this_exists(4)
#' #> [1] TRUE
#' this_exists(TRUE)
#' #> [1] TRUE
#' this_exists(FALSE)
#' #> [1] TRUE
#' this_exists("a word")
#' #> [1] TRUE
#' this_exists(c("a", "b"))
#' #> [1] TRUE
#' this_exists(0)
#' #> [1] TRUE
#'
#' # these are FALSE
#' this_exists(c())
#' #> [1] FALSE
#' this_exists(list())
#' #> [1] FALSE
#' this_exists(NULL)
#' #> [1] FALSE
#' this_exists(NA)
#' #> [1] FALSE
this_exists <- function(x) {
  !(all(is.na(x)) || all(is.null(x)) || length(x) == 0)
}

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
#' @export
#'
#' @examples
#' # these are TRUE
#' this_is_singular("a")
#' #> [1] TRUE
#' this_is_singular(c("a", "a"))
#' #> [1] TRUE
#' this_is_singular(list("a", "a"))
#' #> [1] TRUE
#'
#' # these are FALSE
#' this_is_singular(c("a", "b"))
#' #> [1] FALSE
#' this_is_singular(c("a", NA))
#' #> [1] FALSE
#' this_is_singular(list("a", NULL))
#' #> [1] FALSE
this_is_singular <- function(x) {
  if (any(is.na(x)) || any(is.null(x))) { return(FALSE) }
  length(unique(x)) == 1
}

## these are vectorized; they return a value for each entry in a input vector

# Internal non-vectorized helper: return x if it exists, else default_value
.singular_this_or_set_default <- function(x, default_value) {
  if(this_exists(x)) { return(x) }
  default_value
}

# Internal vectorized wrapper (initial Vectorize version, overwritten below)
.vectorized_this_or_set_default <- Vectorize(.singular_this_or_set_default,
                                             USE.NAMES = FALSE)

# Internal vectorized wrapper with length recycling for default_value
# Handles single default_value recycling and element-wise vector defaults
.vectorized_this_or_set_default <- function(x, default_value) {
  # Recycle single default_value to match length of x
  if (length(default_value) != length(x)) {
    if (length(default_value) == 1) { default_value = rep(default_value,
                                                          times=length(x))}
  }
  mapply(.singular_this_or_set_default, x, default_value, USE.NAMES = FALSE)
}


#' Returns given object if it exists, otherwise empty string
#'
#' @param x An object, list, or vector
#'
#' @returns Character string or character vector. If `x` is a vector or list,
#'   returns a character vector with NAs/NULLs replaced by empty strings.
#'   Lists are simplified to character vectors. Vectorized to handle vectors
#'   element-wise.
#' @export
#'
#' @examples
#' one_string <- "hello"
#' two_strings <- c(one_string, one_string)
#'
#' # returns the given object
#' this_or_empty_string(one_string)
#' #> [1] "hello"
#' this_or_empty_string(two_strings)
#' #> [1] "hello" "hello"
#'
#' # returns an empty string ("")
#' this_or_empty_string(NA)
#' #> [1] ""
#' this_or_empty_string(NULL)
#' #> [1] ""
#'
#' # returns c("", "") - function is vectorized
#' this_or_empty_string(c(NA, NA))
#' #> [1] "" ""
#'
#' # Mixed NA and valid values
#' this_or_empty_string(c("a", NA, "b"))
#' #> [1] "a" ""  "b"
#'
#' # List input simplified to character vector
#' this_or_empty_string(list("a", NULL, "b"))
#' #> [1] "a" ""  "b"
this_or_empty_string <- function(x) {
  if (length(x) > 1) { return(.vectorized_this_or_set_default(x, ""))}
  .singular_this_or_set_default(x, "")
}

#' Returns given object if it exists, otherwise a provided default value
#'
#' @param x An object, list, or vector
#' @param default_value A default value to use when object does not exist.
#'   Can be a single value (recycled for all NAs) or a vector matching
#'   the length of `x` for element-wise defaults.
#'
#' @returns Object or default value. If `x` is a vector, returns a vector
#'   with NAs/NULLs replaced by corresponding default values. Vectorized
#'   to handle vectors element-wise.
#'
#' @details
#' This function is vectorized. When `x` has multiple elements:
#' \itemize{
#'   \item If `default_value` has length 1, it is recycled for all NA positions
#'   \item If `default_value` matches length of `x`, values are applied element-wise
#'   \item Mixed vectors of valid values and NAs are supported
#' }
#'
#' @export
#'
#' @examples
#' one_string <- "hello"
#' two_strings <- c(one_string, one_string)
#'
#' # returns the given object
#' this_or_default_value(one_string, "default")
#' #> [1] "hello"
#' this_or_default_value(two_strings, "default")
#' #> [1] "hello" "hello"
#'
#' # returns the provided default value ("default" here)
#' this_or_default_value(NA, "default")
#' #> [1] "default"
#' this_or_default_value(NULL, "default")
#' #> [1] "default"
#'
#' # returns c("default", "default") - function is vectorized
#' this_or_default_value(c(NA, NA), "default")
#' #> [1] "default" "default"
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
this_or_default_value <- function(x, default_value) {
  if (length(x) > 1) { return(.vectorized_this_or_set_default(x, default_value))}
  .singular_this_or_set_default(x, default_value)
}

# Internal non-vectorized helper: return x if it exists, else NA
.singular_this_or_na <- function(x) {
  ifelse(this_exists(x), x, NA)
}

# Internal vectorized wrapper using Vectorize
.vectorized_this_or_na <- Vectorize(.singular_this_or_na, USE.NAMES=FALSE)

#' Returns given object if it exists, otherwise NA
#'
#' @param x An object, list, or vector
#'
#' @returns Original value if it exists, otherwise NA. If `x` is a vector,
#'   returns a vector with NAs/NULLs replaced by NA (effectively no change
#'   for NA values). Vectorized to handle vectors element-wise.
#' @export
#'
#' @examples
#' one_string <- "hello"
#' two_strings <- c(one_string, one_string)
#'
#' # returns the given object
#' this_or_na(one_string)
#' #> [1] "hello"
#' this_or_na(two_strings)
#' #> [1] "hello" "hello"
#'
#' # returns NA
#' this_or_na(NA)
#' #> [1] NA
#' this_or_na(NULL)
#' #> [1] NA
#'
#' # returns c(NA, NA) - function is vectorized
#' this_or_na(c(NA, NA))
#' #> [1] NA NA
#'
#' # Mixed NA and valid values
#' this_or_na(c("a", NA, "b"))
#' #> [1] "a" NA  "b"
this_or_na <- function(x) {
  if (length(x) > 1) { return(.vectorized_this_or_na(x)) }
  .singular_this_or_na(x)
}

