---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->



# aidr

<!-- badges: start -->
<!-- badges: end -->

**aidr** is a personal R utility package containing commonly reused functions for managing missing data and cleaning text. It provides a consistent, intuitive API for handling NA, NULL, and empty values, along with tools for normalizing messy text data.

## Why aidr?

R's native handling of missing data can be inconsistent and verbose. This package provides:

- **Universal existence checking** that works consistently across NA, NULL, and empty vectors
- **Vectorized fallback functions** for replacing missing values with defaults
- **Robust text cleaning** for HTML-formatted or irregularly spaced text
- **Consistent behavior** across scalars, vectors, and lists

Perfect for data cleaning pipelines, web scraping workflows, and reducing boilerplate in data analysis scripts.

## Installation

You can install the development version of aidr from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("ryanraaum/aidr")
```

## Features

### Missing Data Management

- `this_exists()` - Universal existence check (not NA, NULL, or empty)
- `this_is_singular()` - Test if all elements are identical
- `this_or_empty_string()` - Replace missing values with `""`
- `this_or_default_value()` - Replace missing values with custom defaults
- `this_or_na()` - Normalize missing values to NA

### Text Munging

- `tobasictext()` - Clean HTML, remove escapes, normalize whitespace

## Usage


``` r
# Load development version for accurate examples
devtools::load_all(quiet = TRUE)
```

### Checking for existence

`this_exists()` provides a universal check that handles NA, NULL, and empty values consistently:


``` r
# These exist (return TRUE)
this_exists("hello")
#> [1] TRUE
this_exists(c(1, 2))
#> [1] TRUE
this_exists(FALSE)  # FALSE is a real value!
#> [1] TRUE
this_exists(0)      # So is zero
#> [1] TRUE

# These don't exist (return FALSE)
this_exists(NA)
#> [1] FALSE
this_exists(NULL)
#> [1] FALSE
this_exists(c())
#> [1] FALSE
this_exists(list())
#> [1] FALSE

# Vectors with at least one non-NA value exist
this_exists(c(1, 2, NA))
#> [1] TRUE
```

### Testing for singular values

`this_is_singular()` checks if all elements are identical (with no NAs or NULLs):


``` r
this_is_singular(1)
#> [1] TRUE
this_is_singular(c(1, 1))      # All same
#> [1] TRUE
this_is_singular(c("a", "a"))  # Works with any type
#> [1] TRUE

this_is_singular(c(1, 2))      # Different values
#> [1] FALSE
this_is_singular(c(1, NA))     # NA present
#> [1] FALSE
```

### Replacing missing values

The `this_or_*()` family provides vectorized fallback behavior:

#### Replace with empty string


``` r
this_or_empty_string("hello")
#> [1] "hello"
this_or_empty_string(NA)
#> [1] ""
this_or_empty_string(NULL)
#> [1] ""

# Vectorized - works element-wise
this_or_empty_string(c("hello", NA, "world"))
#> [1] "hello" ""      "world"

# Lists are simplified to character vectors
this_or_empty_string(list("a", NULL, "b"))
#> [1] "a" ""  "b"
```

#### Replace with custom default


``` r
this_or_default_value("hello", "default")
#> [1] "hello"
this_or_default_value(NA, "default")
#> [1] "default"
this_or_default_value(NULL, "default")
#> [1] "default"

# Vectorized with single default (recycled)
this_or_default_value(c("hello", NA, "world"), "MISSING")
#> [1] "hello"   "MISSING" "world"

# Element-wise defaults (matching length)
this_or_default_value(c(NA, NA), c("first", "second"))
#> [1] "first"  "second"

# Mixed values with vector defaults
this_or_default_value(c("keep", NA), c("d1", "d2"))
#> [1] "keep" "d2"
```

#### Normalize to NA


``` r
this_or_na("hello")
#> [1] "hello"
this_or_na(NULL)     # NULL becomes NA
#> [1] NA
this_or_na(c("hello", NA, "world"))
#> [1] "hello" NA      "world"
```

### Cleaning text

`tobasictext()` cleans HTML-formatted or messily spaced text:


``` r
# Remove HTML tags
tobasictext("<p>This is <b>bold</b> text</p>")
#> [1] "This is bold text"

# Normalize whitespace
tobasictext("lots    of     spaces")
#> [1] "lots of spaces"
tobasictext("multiple\n\nlines\n\nhere")
#> [1] "multiple lines here"

# Combined: HTML + whitespace + escapes
messy <- "<p>This is some text.\n                    This is <b>bold!</b></p>"
tobasictext(messy)
#> [1] "This is some text. This is bold!"

# Vectorized
tobasictext(c("<b>first</b>", "<i>second</i>", "plain"))
#> [1] "first"  "second" "plain"
```

## Real-World Examples

### Data cleaning pipeline


``` r
# Clean survey data with missing responses
survey_data %>%
  mutate(
    # Replace empty responses with "No response"
    comment = this_or_default_value(comment, "No response"),
    # Normalize missing ages
    age = this_or_na(age),
    # Clean HTML from text fields
    description = tobasictext(description)
  )
```

### Web scraping workflow


``` r
# Extract and clean web data
page_data <- html_nodes(page, ".article") %>%
  map_df(~ list(
    title = .x %>% html_node(".title") %>% html_text() %>% tobasictext(),
    author = .x %>% html_node(".author") %>% html_text() %>% this_or_default_value("Unknown")
  ))
```

### Defensive programming


``` r
# Safe configuration with fallbacks
config_value <- function(key, default = NULL) {
  value <- Sys.getenv(key)
  this_or_default_value(value, default)
}

api_key <- config_value("API_KEY", "test_key")
```

