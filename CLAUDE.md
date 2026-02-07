# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About This Package

**aidr** is a personal R utility package containing commonly reused functions. It's a standard R package with roxygen2 documentation and testthat tests.

## Package Architecture

The package has two main functional categories:

1. **Missing data management** (`R/manage_missing.R`): Functions for handling NA, NULL, and empty values
   - Non-vectorized predicates: `this_exists()`, `this_is_singular()`
   - Vectorized replacement functions: `this_or_empty_string()`, `this_or_default_value()`, `this_or_na()`
   - Internal helpers use `.singular_` and `.vectorized_` prefixes (not exported)

2. **Text munging** (`R/text_munging.R`): Text cleaning utilities
   - `tobasictext()`: Removes HTML, cleans whitespace using stringr and rvest

## Development Commands

### Documentation
```r
# Generate documentation from roxygen2 comments
devtools::document()
```

### Testing
```r
# Run all tests
devtools::test()

# Run tests for a specific file
testthat::test_file("tests/testthat/test-manage_missing.R")
```

### Building and Checking
```r
# Check package (runs tests, documentation checks, etc.)
devtools::check()

# Install package locally
devtools::install()

# Load package for interactive development
devtools::load_all()
```

### README
The README.md is generated from README.Rmd:
```r
# After editing README.Rmd, regenerate README.md
knitr::knit("README.Rmd")
```

## Key Conventions

- All exported functions are documented with roxygen2 comments including `@param`, `@returns`, `@export`, and `@examples`
- Internal helper functions start with `.` prefix and are not exported
- Tests use testthat 3rd edition
- Dependencies: rvest (HTML parsing), stringr (text manipulation)
