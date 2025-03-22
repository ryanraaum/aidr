
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
this_exists(NULL) # but this does not
#> [1] FALSE
this_exists(c()) # neither does this (is empty)
#> [1] FALSE
this_exists(list()) # nor this
#> [1] FALSE
this_exists(c(1, NA, 2)) # is 
#> [1] TRUE
```
