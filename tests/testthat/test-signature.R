test_that("signature works with box-attached functions", {
  testthat::skip_on_cran()
  skip("SKIP. Erratic, inconsistent.")
  client <- language_client()

  temp_file <- withr::local_tempfile(fileext = ".R")
  writeLines(
    c(
      "box::use(stringr[str_count, str_match])",
      "str_count(",
      "str_match('foo', "
    ),
    temp_file
  )

  client %>% did_save(temp_file)

  result <- client %>% respond_signature(
    temp_file, c(1, 10),
    retry_when = function(result) {
      result$signatures %>%
        length() == 0
    }
  )
  expect_length(result$signatures, 1)
  expect_match(result$signatures[[1]]$label, "str_count\\(.*")
  expect_equal(result$signatures[[1]]$documentation$kind, "markdown")

  result <- client %>% respond_signature(temp_file, c(2, 17))
  expect_length(result$signatures, 1)
  expect_match(result$signatures[[1]]$label, "str_match\\(.*")
  expect_equal(result$signatures[[1]]$documentation$kind, "markdown")
})
