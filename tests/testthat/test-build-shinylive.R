test_that("build_shinylive writes index.html and app.json", {
  out <- file.path(tempdir(), paste0("zash-shinylive-", as.integer(runif(1, 1, 1e9))))
  res <- build_shinylive(out_dir = out, overwrite = FALSE)
  expect_true(dir.exists(res))
  expect_true(file.exists(file.path(res, "index.html")))
  expect_true(file.exists(file.path(res, "app.json")))
  # shallow content checks
  html <- paste(readLines(file.path(res, "index.html"), warn = FALSE), collapse = "\n")
  json <- paste(readLines(file.path(res, "app.json"), warn = FALSE), collapse = "\n")
  expect_true(grepl("<title>", html, fixed = TRUE))
  expect_true(grepl('"charts":\\[', json))
})
