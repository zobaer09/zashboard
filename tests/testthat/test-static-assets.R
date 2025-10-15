test_that("build_static copies assets and links them", {
  out <- file.path(tempdir(), paste0("zash-static-assets-", as.integer(runif(1, 1, 1e9))))
  res <- build_static(out_dir = out, overwrite = FALSE)
  
  expect_true(dir.exists(file.path(res, "assets")))
  expect_true(file.exists(file.path(res, "assets", "zashboard.css")))
  expect_true(file.exists(file.path(res, "assets", "zashboard.js")))
  
  html <- paste(readLines(file.path(res, "index.html"), warn = FALSE), collapse = "\n")
  expect_true(grepl("assets/zashboard.css", html, fixed = TRUE))
  expect_true(grepl("assets/zashboard.js",  html, fixed = TRUE))
})
