# 'box::use' Document Parser

Custom {languageserver} parser hook for {box} modules.

## Usage

``` r
box_use_parser(expr, action)
```

## Arguments

- expr:

  An R expression to evaluate

- action:

  A list of action functions from `languageserver:::parse_expr()`.

## Value

Used for side-effects provided by the `action` list of functions.

## Examples

``` r
# \donttest{
  action <- list(
   assign = function(symbol, value) {
     cat(paste("ASSIGN: ", symbol, value, "\n"))
   },
   update = function(packages) {
     cat(paste("Packages: ", packages, "\n"))
   },
   parse = function(x) {
     cat(paste("Parse: ", names(x), x, "\n"))
   },
   parse_args = function(x) {
     cat(paste("Parse Args: ", names(x), x, "\n"))
   }
 )
  box_use_parser(expr = expression(box::use(fs)), action = action)
#> Packages:  fs 
# }
```
