test_that("zashboard_theme returns a bslib theme when available", {
  testthat::skip_if_not_installed("bslib")
  th <- zashboard_theme()
  expect_true(inherits(th, "bs_theme"))
})

test_that("build_shiny uses a theme when bslib is installed", {
  testthat::skip_if_not_installed("shiny")
  testthat::skip_if_not_installed("bslib")
  app <- build_shiny(launch = FALSE)  # no explicit theme -> auto theme
  expect_true(inherits(app, "shiny.appobj"))
})
