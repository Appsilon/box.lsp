# box.lsp 0.1.3

This bugfix release addresses a bug that causes R CMD Check in CI and Docker builds to fail.

# box.lsp 0.1.2

This bugfix release addresses a critical bug that causes `languageserver` to crash.

# box.lsp 0.1.1

This addresses one CRAN Package Check error.

# box.lsp 0.1.0 Resubmission

> If there are references describing the methods in your package, please add these in the description field of your DESCRIPTION file

There are no references to include regarding this package.

> \dontrun{} should only be used if the example really cannot be executed
(e.g. because of missing additional software, missing API keys, ...) by
the user. That's why wrapping examples in \dontrun{} adds the comment
("# Not run:") as a warning for the user. Does not seem necessary.
Please replace \dontrun with \donttest.
Functions which are supposed to only run interactively (e.g. shiny)
should be wrapped in if(interactive()). Please replace /dontrun{} with
if(interactive()){} if possible, then users can see that the functions
are not intended for use in scripts / functions that are supposed to run
non interactively.

`\dontrun` replaced with `if(interactive())` in `box.lsp::use_box_lsp` and `\donttest` in `box.lsp::box_use_parser`.

> Please ensure that your functions do not write by default or in your
examples/vignettes/tests in the user's home filespace (including the
package directory and getwd()). This is not allowed by CRAN policies.
Please omit any default path in writing functions. In your
examples/vignettes/tests you can write to tempdir().
-> R/utils.R and your tests

All examples that could write in the user's filespace are blocked by using `if(interactive())`. Tests are using `withr::temp*` or `withr::local*` functions to prevent that. `box.lsp::use_box_lsp` still has the default path set, but to prevent from writing anything by accident it now requires a confirmation from the user (with default set to No).

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.
