### From REditors/languageserver/tests/testthat/helper-utils.R
# nolint start
suppressPackageStartupMessages({
  library(magrittr)
  library(mockery)
  library(purrr)
  library(fs)
})



# a hack to make withr::defer_parent to work, see https://github.com/r-lib/withr/issues/123
defer <- withr::defer

# code largely taken from languageserver/tests/testthat/helper-utils.R
language_client <- function(working_dir = getwd(), diagnostics = FALSE, capabilities = NULL) {
  withr::local_dir(working_dir)
  withr::local_file(".Rprofile", {
    if (testthat::is_checking()) {
      parser_code <- c(
        "box_use_parser <-",
        deparse(box.lsp::box_use_parser)
      )
      rprofile <- readLines(fs::path_package("box.lsp", "Rprofile.R"))

    } else {
      source(fs::path(rprojroot::find_package_root_file(), "R", "box_lsp.R"), local = TRUE)
      parser_code <- c(
        "box_use_parser <-",
        deparse(box_use_parser)
      )

      rprofile <- readLines(fs::path(rprojroot::find_package_root_file(), "inst", "Rprofile.R"))
      rprofile <- sub("box.lsp::", "", rprofile)
    }

    write(parser_code, ".Rprofile", append = TRUE)
    write(rprofile, ".Rprofile", append = TRUE)

    readLines(".Rprofile")
  })

  if (nzchar(Sys.getenv("R_LANGSVR_LOG"))) {
    script <- sprintf(
      "options(languageserver.formatting_style = NULL); languageserver::run(debug = '%s')",
      normalizePath(Sys.getenv("R_LANGSVR_LOG"), "/", mustWork = FALSE))
  } else {
    script <- "options(languageserver.formatting_style = NULL); languageserver::run()"
  }

  client <- languageserver:::LanguageClient$new(
    file.path(R.home("bin"), "R"), c("--no-echo", "-e", script))

  client$notification_handlers <- list(
    `textDocument/publishDiagnostics` = function(self, params) {
      uri <- params$uri
      diagnostics <- params$diagnostics
      self$diagnostics$set(uri, diagnostics)
    }
  )

  client$start(working_dir = working_dir, capabilities = capabilities)
  client$catch_callback_error <- FALSE
  # initialize request
  data <- client$fetch(blocking = TRUE)
  client$handle_raw(data)
  client %>% notify("initialized")
  client %>% notify(
    "workspace/didChangeConfiguration", list(settings = list(diagnostics = diagnostics)))
  withr::defer_parent({
    client %>% respond("shutdown", NULL, retry = FALSE)
    if (client$process$is_alive()) {
      if (identical(Sys.getenv("R_COVR"), "true")) {
        client$process$wait()
      } else {
        client$process$wait(1000)
        client$process$kill()
      }
    }
  })
  client
}


notify <- function(client, method, params = NULL) {
  client$deliver(languageserver:::Notification$new(method, params))
  invisible(client)
}


did_open <- function(client, path, uri = languageserver:::path_to_uri(path), text = NULL, languageId = NULL) {
  if (is.null(text)) {
    text <- stringi::stri_read_lines(path)
  }
  text <- paste0(text, collapse = "\n")

  if (is.null(languageId)) {
    languageId <- if (languageserver:::is_rmarkdown(uri)) "rmd" else "r"
  }

  notify(
    client,
    "textDocument/didOpen",
    list(
      textDocument = list(
        uri = uri,
        languageId = languageId,
        version = 1,
        text = text
      )
    )
  )
  Sys.sleep(0.5)
  invisible(client)
}


did_save <- function(client, path, uri = languageserver:::path_to_uri(path), text = NULL) {
  includeText <- tryCatch(
    client$ServerCapabilities$textDocumentSync$save$includeText,
    error = function(e) FALSE
  )
  if (includeText) {
    if (is.null(text)) {
      text <- stringi::stri_read_lines(path)
    }
    text <- paste0(text, collapse = "\n")
    params <- list(textDocument = list(uri = uri), text = text)
  } else {
    params <- list(textDocument = list(uri = uri))
  }
  notify(
    client,
    "textDocument/didSave",
    params)
  Sys.sleep(0.5)
  invisible(client)
}


respond <- function(client, method, params, timeout, allow_error = FALSE,
                    retry = TRUE, retry_when = function(result) length(result) == 0) {
  if (missing(timeout)) {
    if (Sys.getenv("R_COVR", "") == "true") {
      # we give more time to covr
      timeout <- 30
    } else {
      timeout <- 10
    }
  }
  storage <- new.env(parent = .GlobalEnv)
  cb <- function(self, result, error = NULL) {
    if (is.null(error)) {
      storage$done <- TRUE
      storage$result <- result
    } else if (allow_error) {
      storage$done <- TRUE
      storage$result <- error
    }
  }

  start_time <- Sys.time()
  remaining <- timeout
  client$deliver(client$request(method, params), callback = cb)
  if (method == "shutdown") {
    # do not expect the server returns anything
    return(NULL)
  }
  while (!isTRUE(storage$done)) {
    if (remaining < 0) {
      fail("timeout when obtaining response")
      return(NULL)
    }
    data <- client$fetch(blocking = TRUE, timeout = remaining)
    if (!is.null(data)) client$handle_raw(data)
    remaining <- (start_time + timeout) - Sys.time()
  }
  result <- storage$result
  if (retry && retry_when(result)) {
    remaining <- (start_time + timeout) - Sys.time()
    if (remaining < 0) {
      fail("timeout when obtaining desired response")
      return(NULL)
    }
    Sys.sleep(0.2)
    return(Recall(client, method, params, remaining, allow_error, retry, retry_when))
  }
  return(result)
}


respond_completion <- function(client, path, pos, ..., uri = languageserver:::path_to_uri(path)) {
  respond(
    client,
    "textDocument/completion",
    list(
      textDocument = list(uri = uri),
      position = list(line = pos[1], character = pos[2])
    ),
    ...
  )
}

respond_signature <- function(client, path, pos, ..., uri = languageserver:::path_to_uri(path)) {
  respond(
    client,
    "textDocument/signatureHelp",
    list(
      textDocument = list(uri = uri),
      position = list(line = pos[1], character = pos[2])
    ),
    ...
  )
}
# nolint end
