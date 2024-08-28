test_that("completion of whole package attached works", {
  testthat::skip_on_cran()
  skip("SKIP. Not implemented.")
  client <- language_client()

  temp_file <- withr::local_tempfile(fileext = ".R")
  writeLines(
    c(
      "box::use(stringr)",
      "stringr$str_c",
      "str_c",
      "stringr$str_x",
      "dplyr$fil"
    ),
    temp_file
  )

  client %>% did_save(temp_file)

  result <- client %>% respond_completion(
    temp_file, c(1, 14),
    retry_when = function(result) {
      result$items %>%
        keep(~ .$label == "str_count") %>%
        length() == 0
    }
  )

  expect_length(result$items %>% keep(~ .$label == "str_count"), 1)
})
