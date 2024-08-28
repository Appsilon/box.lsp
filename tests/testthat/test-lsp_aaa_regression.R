test_that("Completion of attached package functions works", {
  testthat::skip_on_cran()
  client <- language_client()

  temp_file <- withr::local_tempfile(fileext = ".R")
  writeLines(
    c(
      "library(jsonlite)",
      "require('xml2')",
      "fromJS",
      "read_xm"
    ),
    temp_file
  )

  client %>% did_save(temp_file)

  result <- client %>% respond_completion(
    temp_file,
    c(2, 6),
    retry_when = function(result) result$items %>% keep(~ .$label == "fromJSON") %>% length() == 0
  )
  expect_length(result$items %>% keep(~ .$label == "fromJSON"), 1)

  result <- client %>% respond_completion(
    temp_file,
    c(3, 7),
    retry_when = function(result) result$items %>% keep(~ .$label == "read_xml") %>% length() == 0
  )
  expect_length(result$items %>% keep(~ .$label == "read_xml"), 1)
})
