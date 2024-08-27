#' Configures a project to use \{box.lsp\}
#'
#' @param file_path File name to append `{box.lsp}` configuration lines.
#' @returns Writes configuration lines to `file_path`.
#'
#' @examples
#' if (interactive()) {
#'   use_box_lsp()
#' }
#'
#' @export
use_box_lsp <- function(file_path = ".Rprofile") {
  response <- readline(
    glue::glue("Would you like to create or modify the `{file_path}` file? (yes/No) ")
  )
  response <- substr(response, 1, 1)
  if (!(response == "Y" || response == "y")) {
    cli::cli_abort("`{file_path}` file creation/modification cancelled!")
  }

  rprofile <- fs::path_package("box.lsp", "Rprofile.R")
  to_write <- readLines(rprofile)

  tryCatch({
    if (file.exists(file_path)) {
      cli::cli_alert_info(
        "{file_path} exists. Will append {{box.lsp}} configuration lines to the file."
      )
      write("", file = file_path, append = TRUE)
    }
    write(to_write, file = file_path, append = TRUE)
    cli::cli_alert_success(
      c(
        "{{box.lsp}} configuration written to {file_path}. Please check the changes made. ",
        "A restart of your editor may be necessary for the changes to take effect."
      )
    )
  }, error = function(e) {
    cli::cli_abort(e)
  })
}
