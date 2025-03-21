
## not vectorized; always returns a single value

this_exists <- function(x) {
  !(all(is.na(x)) || all(is.null(x)) || length(x) == 0)
}

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

this_or_empty_string <- function(x) {
  if (length(x) > 1) { return(.vectorized_this_or_empty_string(x))}
  .singular_this_or_empty_string(x)
}
