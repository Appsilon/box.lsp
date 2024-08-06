# box_lsp
Custom language server parser for box modules

This repository is intended for *development purposes only*. It is structured as an R package, but, as of this time, there is *no intention to publish* it on CRAN. The R package restructure is merely being used for the development tools (`{devtools}`, `{usethis}`, `{testthat}`, et al). It may later on become part of `{rhino}` or `{languageserver}` itself.

The code is based on initial work by [Pavel Demin](https://github.com/Gotfrid).

## What Works

| `box::use()`              | Code completion | Param completion | Tooltip help | As of version | Notes |
|---------------------------|:-:|:-:|:-:|--------:|:-:|
| `pkg[...]`                | &check; |   |   | 0.0.0.9001 |   |
| `pkg[attach_list]`        | &check; |   |   | 0.0.0.9002 |   |
| `pkg`                     |   |   |   |         |   |
| `prefix/mod[...]`         |   |   |   |         |   |
| `prefix/mod[attach_list]` |   |   |   |         |   |
| `alias = pkg`             |   |   |   |         |   |
| `alias = prefix/mod`      |   |   |   |         |   |
| `pkg[alias = fun]`        | &check; |   |   | 0.0.0.9002 |   |
| `prefix/mod[alias = fun]` |   |   |   |         |   |

## How to use

1. Copy the contents of `inst/Rprofile.R` to your project's `.Rprofile`.
2. Restart the R session to load `.Rprofile`.

## How to develop

1. Ensure all `Imports` and `Suggests` packages are installed.
2. Set `R_LANGSVR_LOG=./lsp.log` in `.Renviron` to start logging
3. Restart R session to load `.Rprofile` and `.Renviron`
4. `devtools::load_all()` to load all development functions.

### Dev work on `box_use_parser()`

```R
action <- list(
  assign = function(symbol, value) {
    cat(paste("ASSIGN: ", symbol, value, "\n"))
  },
  update = function(packages) {
    cat(paste("Packages: ", packages, "\n"))
  }
)

content <- c("box::use(stringr, dplyr[alias = filter, mutate], xml2[...])", "filt", "stringr$str_c")
expr <- parse(text = content, keep.source = TRUE)
box_use_parser(expr, action)
```

### Dev work on completion

Lines count from zero.

```R
client <- language_client()

temp_file <- withr::local_tempfile(fileext = ".R")
writeLines(
  c(
    "box::use(stringr[...])",
    "str_c",
    "str_m"
  ),
  temp_file
)

client %>% did_save(temp_file)

client %>% respond_completion(
  temp_file, c(1, 8))
```
