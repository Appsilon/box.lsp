#' @import box
NULL

#' @import purrr
NULL

# stash
# nolint start
# box_use_parser <- function(expr, action) {
#   fun <- if (requireNamespace("box", quietly = TRUE)) box::use else
#     function(...) NULL
#   call <- match.call(fun, expr, expand.dots = FALSE)
#
#   if(!isTRUE(call$character.only)) {
#     packages <- vapply(
#       call[["..."]],
#       function(item) {
#         item <- as.character(item)
#         if (item[1] == "[" && grepl("\\.\\.\\.", item[3])) {
#           return(item[2])
#         } else {
#           return("")
#         }
#       },
#       character(1L)
#     )
#     packages <- purrr::keep(packages, ~. != "")
#     action$update(packages = packages)
#
#     test_value <- "function(x, y) { \"A \" }"
#     action$assign(symbol = "module$fun", value = "function(x, y) { \"A \" }")
#     action$parse(test_value)
#   }
# }
# nolint end

options(languageserver.trace = TRUE)
options(languageserver.debug = TRUE)
