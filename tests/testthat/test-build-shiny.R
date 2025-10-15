test_that("build_shiny returns a shiny.appobj without launching", {
  testthat::skip_if_not_installed("shiny")
  app <- build_shiny(launch = FALSE)
  expect_true(inherits(app, "shiny.appobj"))
})
