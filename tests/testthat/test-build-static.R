test_that("build_static writes index.html to a fresh dir", {
  out <- file.path(tempdir(), paste0("zash-static-", as.integer(runif(1, 1, 1e9))))
  res <- build_static(out_dir = out, overwrite = FALSE)
  expect_true(dir.exists(res))
  expect_true(file.exists(file.path(res, "index.html")))
  # basic content check
  txt <- paste(readLines(file.path(res, "index.html"), warn = FALSE), collapse = "\n")
  expect_true(grepl("<title>", txt, fixed = TRUE))
})
