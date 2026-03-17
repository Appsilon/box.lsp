# Changelog

## box.lsp 0.1.3

CRAN release: 2024-09-19

- Added a check for `box.lsp` before loading the box.lsp languageserver
  options. This was causing CI and Docker builds to fail.

## box.lsp 0.1.2

CRAN release: 2024-09-16

- Fixed critical bug that causes `languageserver` to crash: Handle long
  function signatures spanning across multiple lines.
  ([@Gotfrid](https://github.com/Gotfrid)
  [\#23](https://github.com/Appsilon/box.lsp/issues/23))

## box.lsp 0.1.1

CRAN release: 2024-09-10

- Fixed one unit test on Windows that returns a different length of
  values.

## box.lsp 0.1.0

CRAN release: 2024-09-02

First release.
