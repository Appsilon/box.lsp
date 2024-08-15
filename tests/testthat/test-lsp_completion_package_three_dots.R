test_that("completion of package attached three dots works", {
  testthat::skip_on_cran()
  testthat::skip_if(testthat::is_checking())
  client <- language_client()

  temp_file <- withr::local_tempfile(fileext = ".R")
  writeLines(
    c(
      "box::use(stringr[...])",
      "str_c",
      "str_m"
    ),
    temp_file
  )

  client %>% did_save(temp_file)

  result <- client %>% respond_completion(
    temp_file, c(1, 5),
    retry_when = function(result) result$items %>% keep(~ .$label == "str_count") %>% length() == 0
  )
  expect_length(result$items %>% keep(~ .$label == "str_count"), 1)

  result <- client %>% respond_completion(
    temp_file, c(2, 5),
    retry_when = function(result) result$items %>% keep(~ .$label == "str_match") %>% length() == 0
  )
  expect_length(result$items %>% keep(~ .$label == "str_match"), 1)
})
