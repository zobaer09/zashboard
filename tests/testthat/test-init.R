test_that("zashboard_init scaffolds spec + manifest", {
  td <- file.path(tempdir(), paste0("zash-init-", as.integer(runif(1, 1, 1e9))))
  out <- zashboard_init(td, overwrite = FALSE)
  
  expect_true(dir.exists(out))
  expect_true(file.exists(file.path(out, "zashboard.yml")))
  expect_true(file.exists(file.path(out, "manifest.json")))
  
  js <- paste(readLines(file.path(out, "manifest.json"), warn = FALSE), collapse = "\n")
  expect_true(grepl('"charts":\\[', js))
})

test_that("zashboard_init refuses to write into a non-empty dir without overwrite", {
  td <- file.path(tempdir(), paste0("zash-init-deny-", as.integer(runif(1, 1, 1e9))))
  dir.create(td, recursive = TRUE, showWarnings = FALSE)
  writeLines("x", file.path(td, "keep.txt"))
  expect_error(zashboard_init(td, overwrite = FALSE), "not empty")
})
