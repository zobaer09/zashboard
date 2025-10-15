test_that("build_quarto writes _quarto.yml and index.qmd", {
  out <- file.path(tempdir(), paste0("zash-quarto-", as.integer(runif(1, 1, 1e9))))
  res <- build_quarto(out_dir = out, overwrite = FALSE, render = FALSE)
  expect_true(dir.exists(res))
  expect_true(file.exists(file.path(res, "_quarto.yml")))
  expect_true(file.exists(file.path(res, "index.qmd")))
  expect_true(file.exists(file.path(res, "app.json")))
})

test_that("build_quarto can render when Quarto is installed", {
  # Skip unless BOTH are available
  testthat::skip_if_not_installed("quarto")
  testthat::skip_if_not(nzchar(Sys.which("quarto")), "Quarto CLI not on PATH")
  
  out <- file.path(tempdir(), paste0("zash-quarto-rend-", as.integer(runif(1, 1, 1e9))))
  res <- build_quarto(out_dir = out, overwrite = FALSE, render = TRUE)
  expect_true(dir.exists(file.path(res, "_site")))
  expect_true(file.exists(file.path(res, "_site", "index.html")))
})

