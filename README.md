# box_lsp
Custom language server parser for box modules

This repository is intended for *development purposes only*. It is structured as an R package, but, as of this time, there is *no intention to publish* it on CRAN. The R package restructure is merely being used for the development tools (`{devtools}`, `{usethis}`, `{testthat}`, et al). It may later on become part of `{rhino}` or `{languageserver}` itself.

The code is based on initial work by [Pavel Demin](https://github.com/Gotfrid).

## What Works

| `box::use()`              | Code completion | Param completion | Tooltip help | As of version | Notes |
|---------------------------|:-:|:-:|:-:|--------:|:-:|
| `pkg[...]`                | &check; |   |   | 0.0.0.9001 |   |
| `pkg[attach_list]`        |   |   |   |         |   |
| `pkg`                     |   |   |   |         |   |
| `prefix/mod[...]`         |   |   |   |         |   |
| `prefix/mod[attach_list]` |   |   |   |         |   |
| `alias = pkg`             |   |   |   |         |   |
| `alias = prefix/mod`      |   |   |   |         |   |
| `pkg[alias = fun]`        |   |   |   |         |   |
| `prefix/mod[alias = fun]` |   |   |   |         |   |

## How to use

1. Copy the contents of `Rprofile.R` to your project's `.Rprofile`.
2. Restart the R session to load `.Rprofile`.

## How to develop

1. Ensure all `Imports` and `Suggests` packages are installed.
2. Set `R_LANGSVR_LOG=./lsp.log` in `.Renviron` to start logging
3. Restart R session to load `.Rprofile` and `.Renviron`
4. `devtools::load_all()` to load all development functions.
5. TODO...
