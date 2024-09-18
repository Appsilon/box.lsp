# box.lsp 0.1.3

* Added a check for `box.lsp` before loading the box.lsp languageserver options. This was causing CI and Docker builds to fail.

# box.lsp 0.1.2

* Fixed critical bug that causes `languageserver` to crash: Handle long function signatures spanning across multiple lines. (@Gotfrid #23)

# box.lsp 0.1.1

* Fixed one unit test on Windows that returns a different length of values.

# box.lsp 0.1.0

First release.
