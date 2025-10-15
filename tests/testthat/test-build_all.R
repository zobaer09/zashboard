test_that("build_all returns paths and a shiny app", {
  # Shiny is required for the app object
  testthat::skip_if_not_installed("shiny")
  
  res <- build_all(overwrite = TRUE, render_quarto = FALSE)
  
  expect_true(dir.exists(res$static_dir))
  expect_true(file.exists(file.path(res$static_dir, "index.html")))
  
  expect_true(dir.exists(res$shinylive_dir))
  expect_true(file.exists(file.path(res$shinylive_dir, "index.html")))
  expect_true(file.exists(file.path(res$shinylive_dir, "app.json")))
  
  expect_true(dir.exists(res$quarto_dir))
  expect_true(file.exists(file.path(res$quarto_dir, "_quarto.yml")))
  expect_true(file.exists(file.path(res$quarto_dir, "index.qmd")))
  
  expect_true(inherits(res$shiny_app, "shiny.appobj"))
})
