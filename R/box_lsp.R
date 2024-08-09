#' @import box
NULL

#' @import purrr
NULL

#' Box::use Document Parser
#'
#' Custom \{languageserver\} parser hook for \{box\} modules.
#'
#' @param expr An R expression to evaluate
#' @param action A list of action functions from `languageserver:::parse_expr()`.
#' @returns Used for side-effects provided by the `action` list of functions.
#'
#' @export
box_use_parser <- function(expr, action) {
  call <- match.call(box::use, expr)
  packages <- unlist(lapply(call[-1], function(x) {
    # this is for the last blank in box::use(something, )
    if (x == "") {
      return()
    }

    # this is for a whole package attached box::use(dplyr)
    if (typeof(x) == "symbol") {
      # attempts to get package$func to work
      # nolint start
      # action$assign(symbol = paste0(as.character(x), "$", getNamespaceExports(as.character(x))), value = NULL)
      # action$assign(symbol = getNamespaceExports(as.character(x)), value = NULL)
      # return()
      # nolint end
      return(as.character(x))
    }

    # this is for a whole module attached box::use(app/logic/utils)
    if (as.character(x[[1]]) == "/") {
      y <- x[[length(x)]]

      # this case is for app/logic/module_one
      if (length(y) == 1) {
        action$assign(symbol = as.character(y), value = NULL)
      }

      # this case is for app/logic/module_two[...]
      if (length(y) == 3 && y[[3]] == "...") {
        # import box module, iterate over its namespace and assign
      }

      # this case is for app/logic/module_three[a, b, c]
      lapply(y[-c(1, 2)], function(z) {
        action$assign(symbol = as.character(z), value = NULL)
      })

      return()
    }

    # for box::use(dplyr[<assign list>])
    if (x[[1]] == "[") {
      # for box::use(dplyr[alias = a])
      # Does not seem to be needed
      # nolint start
      # action$assign(symbol = names(x) %>% purrr::keep(~. != ""), value = NULL)
      # nolint end

      # for box::use(dplyr[a, b, c])
      lapply(as.character(x)[-c(1, 2)], function(y) {
        if (y != "...") {
          action$assign(symbol = as.character(y), value = NULL)
        }
      })

      # for box::use(dplyr[a, b, ...])
      if (x[[length(x)]] == "...") {
        as.character(x[[2]])
      }
    }
  }))
  action$update(packages = packages)
}
