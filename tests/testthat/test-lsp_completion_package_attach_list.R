test_that("completion of package attached function list works", {
  testthat::skip_on_cran()
  client <- language_client()

  temp_file <- withr::local_tempfile(fileext = ".R")
  writeLines(
    c(
      "box::use(stringr[str_count, str_match])",
      "str_c",
      "str_co",
      "str_m"
    ),
    temp_file
  )

  client %>% did_save(temp_file)

  result <- client %>% respond_completion(
    temp_file, c(1, 5),
    retry_when = function(result) result$items %>% keep(~ .$label == "str_count") %>% length() == 0
  )
  expect_length(result$items %>% keep(~ .$label == "str_c"), 1)
  expect_length(result$items %>% keep(~ .$label == "str_conv"), 0)
  expect_length(result$items %>% keep(~ .$label == "str_count"), 1)

  result <- client %>% respond_completion(
    temp_file, c(2, 6),
    retry_when = function(result) result$items %>% keep(~ .$label == "str_count") %>% length() == 0
  )
  expect_length(result$items %>% keep(~ .$label == "str_c"), 0)
  expect_length(result$items %>% keep(~ .$label == "str_conv"), 0)
  expect_length(result$items %>% keep(~ .$label == "str_count"), 1)

  result <- client %>% respond_completion(
    temp_file, c(3, 5),
    retry_when = function(result) result$items %>% keep(~ .$label == "str_match") %>% length() == 0
  )
  expect_length(result$items %>% keep(~ .$label == "str_match"), 1)
  expect_length(result$items %>% keep(~ .$label == "str_match_all"), 0)
})

test_that("completion of package attached function with alias works", {
  client <- language_client()

  temp_file <- withr::local_tempfile(fileext = ".R")
  writeLines(
    c(
      "box::use(stringr[alias = str_count])",
      "al"
    ),
    temp_file
  )

  client %>% did_save(temp_file)

  result <- client %>% respond_completion(
    temp_file, c(1, 2),
    retry_when = function(result) result$items %>% keep(~ .$label == "alias") %>% length() == 0
  )
  expect_length(result$items %>% keep(~ .$label == "alias"), 1)
})

test_that("completion of package attach list does not return non-attached functions", {
  client <- language_client()

  temp_file <- withr::local_tempfile(fileext = ".R")
  writeLines(
    c(
      "box::use(stringr[str_count, str_match])",
      "str_e"
    ),
    temp_file
  )

  client %>% did_save(temp_file)

  result <- client %>% respond_completion(
    temp_file, c(1, 5)
  )

  expect_length(result$items %>% keep(~ .$label == "str_extract"), 0)
})
