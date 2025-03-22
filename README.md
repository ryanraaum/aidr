
<!-- README.md is generated from README.Rmd. Please edit that file -->

# aidr

<!-- badges: start -->
<!-- badges: end -->

The goal of aidr is to collect together a set of R functions that I
otherwise keep on recreating in most projects.

## Installation

You can install the development version of aidr from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("ryanraaum/aidr")
```

## Usage

There are a few different categories of functions in the package, listed
below.

### Dealing with missing data of various sorts

``` r
library(aidr)

this_exists("this does exist")
#> [1] TRUE
this_exists(c(1, 2)) # so does this
#> [1] TRUE
this_exists(NA) # but this does not
#> [1] FALSE
this_exists(NULL) # this also does not
#> [1] FALSE
this_exists(c()) # neither does this (is empty)
#> [1] FALSE
this_exists(list()) # nor this
#> [1] FALSE
this_exists(c(1, 2, NA)) # BUT this does (vector has at least one non-NA)
#> [1] TRUE

this_is_singular(1) # TRUE
#> [1] TRUE
this_is_singular(c(1, 1)) # TRUE, only one unique value
#> [1] TRUE
this_is_singular(c(1, 2)) # FALSE
#> [1] FALSE
this_is_singular(c(1, NA)) # anything with missing data is FALSE
#> [1] FALSE

this_or_empty_string("this")
#> [1] "this"
this_or_empty_string(NA)
#> [1] ""
this_or_empty_string(NULL)
#> [1] ""
this_or_empty_string(c("this", NA))
#> [1] "this" ""

this_or_na("this")
#> [1] "this"
this_or_na(NA)
#> [1] NA
this_or_na(NULL)
#> [1] NA
this_or_na(c("this", NA))
#> [1] "this" NA
```
