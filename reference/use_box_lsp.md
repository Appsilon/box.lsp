# Configures a project to use {box.lsp}

Configures a project to use {box.lsp}

## Usage

``` r
use_box_lsp(file_path = ".Rprofile")
```

## Arguments

- file_path:

  File name to append `{box.lsp}` configuration lines.

## Value

Writes configuration lines to `file_path`.

## Examples

``` r
if (interactive()) {
  use_box_lsp()
}
```
