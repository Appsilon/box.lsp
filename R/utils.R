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
  rprofile <- fs::path_package("box.lsp", "Rprofile.R")
  to_write <- readLines(rprofile)

  tryCatch({
    if (file.exists(file_path)) {
      response <- readline(
        cli::cli(
          cli::cli_alert(
            c(
              "`{file_path}` exists. Lines will be added to the end of this file. ",
              "Would you like to continue (yes/No)"
            ),
            wrap = TRUE
          )
        )
      )
      response <- substr(response, 1, 1)
      if (!(response == "Y" || response == "y")) {
        cli::cli_inform("`{file_path}` file append cancelled.")
        return(invisible(NULL))
      }

      cli::cli_alert_info(
        "Appending {{box.lsp}} configuration lines to the `{file_path}`."
      )
      write("", file = file_path, append = TRUE)
    } else {
      response <- readline(
        cli::cli(
          cli::cli_alert(
            "Would you like to create `{file_path}` with {{box_lsp}} configuration? (yes/No)",
            wrap = TRUE
          )
        )
      )
      response <- substr(response, 1, 1)
      if (!(response == "Y" || response == "y")) {
        cli::cli_inform("`{file_path}` file creation cancelled.")
        return(invisible(NULL))
      }

      cli::cli_alert_info(
        "Creating `{file_path}` with {{box.lsp}} configuration."
      )
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
