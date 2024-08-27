#' @import box
NULL

get_box_module_exports <- function(declaration, alias = "", caller = globalenv()) {
  if (is.call(declaration)) {
    declaration
  } else if (is.character(declaration)) {
    declaration <- rlang::parse_expr(declaration)
  }
  parse_spec <- get0("parse_spec", envir = base::loadNamespace("box"))
  find_mod <- get0("find_mod.box$mod_spec", envir = base::loadNamespace("box"))
  load_mod <- get0("load_mod.box$mod_info", envir = base::loadNamespace("box"))
  namespace_info <- get0("namespace_info", envir = base::loadNamespace("box"))

  if (any(sapply(list(parse_spec, find_mod, load_mod, namespace_info), is.null))) {
    stop("box.linters couldn't load box functions")
  }

  spec <- parse_spec(declaration, alias)
  info <- find_mod(spec, caller)
  mod_ns <- load_mod(info)
  func_names <- namespace_info(mod_ns, "exports")

  lapply(func_names, function(func_name) {
    signature <- deparse(mod_ns[[func_name]])[[1]]
    names(signature) <- func_name
    signature
  })
}

process_module <- function(sym_name, signature, action) {
  tmp_name <- "temp_func"
  empty <- "{ }"
  tmp_sig <- paste(tmp_name, "<-", signature, empty)
  func_sig <- parse(text = tmp_sig, keep.source = TRUE)[[1]]

  action$assign(symbol = as.character(sym_name), value = func_sig[[3L]])
  action$parse(func_sig[[3L]])
}

#' 'box::use' Document Parser
#'
#' Custom \{languageserver\} parser hook for \{box\} modules.
#'
#' @param expr An R expression to evaluate
#' @param action A list of action functions from `languageserver:::parse_expr()`.
#' @returns Used for side-effects provided by the `action` list of functions.
#'
#' @examples
#' \donttest{
#'   action <- list(
#'    assign = function(symbol, value) {
#'      cat(paste("ASSIGN: ", symbol, value, "\n"))
#'    },
#'    update = function(packages) {
#'      cat(paste("Packages: ", packages, "\n"))
#'    },
#'    parse = function(x) {
#'      cat(paste("Parse: ", names(x), x, "\n"))
#'    },
#'    parse_args = function(x) {
#'      cat(paste("Parse Args: ", names(x), x, "\n"))
#'    }
#'  )
#'   box_use_parser(expr = expression(box::use(fs)), action = action)
#' }
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
        box_exports <- get_box_module_exports(x)
        lapply(box_exports, function(box_export) {
          sym_name <- names(box_export)
          signature <- box_export

          process_module(sym_name, signature, action)
        })
      }

      attached_functions <- as.list(y[-c(1, 2)])
      # this case is for app/logic/module_three[a, b, c]
      lapply(seq_along(attached_functions), function(z) {
        box_exports <- get_box_module_exports(x)
        box_exports <- unlist(box_exports)

        this_function <- attached_functions[[z]]
        this_alias <- rlang::names2(attached_functions)[[z]]

        signature <- box_exports[[this_function]]
        sym_name <- ifelse(this_alias == "", this_function, this_alias)

        process_module(sym_name, signature, action)
      })

      return()
    }

    # for box::use(dplyr[<assign list>])
    if (x[[1]] == "[") {
      attached_functions <- as.list(x[-c(1, 2)])
      lapply(seq_along(attached_functions), function(y) {
        this_function <- attached_functions[[y]]
        this_alias <- rlang::names2(attached_functions)[[y]]

        if (this_function != "...") {
          namespaced_function <- paste0(as.character(x[[2]]), "::", this_function)
          signature <- deparse(eval(parse(text = namespaced_function, keep.source = TRUE)))[[1]]
          sym_name <- ifelse(this_alias == "", this_function, this_alias)

          process_module(sym_name, signature, action)
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
