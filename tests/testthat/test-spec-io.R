test_that("template spec loads and validates", {
  # Use installed template
  path <- system.file("templates", "zashboard.yml", package = "zashboard")
  expect_true(nzchar(path), info = "Template zashboard.yml should be installed in inst/templates/")
  sp <- zashboard_read_spec(path)
  expect_type(sp, "list")
  expect_true("datasets" %in% names(sp))
  expect_true("charts"   %in% names(sp))
  expect_true("layout"   %in% names(sp))
  expect_invisible(zashboard_validate_spec(sp))
})

test_that("invalid spec is rejected with helpful message", {
  # Make datasets a *named* list so it passes the first gate,
  # then intentionally omit 'charts' to trigger the charts error.
  bad <- list(
    datasets = list(sample = list()),  # named entry
    layout   = list()                  # present but empty is fine for this check
  )
  expect_error(zashboard_validate_spec(bad), "charts", fixed = FALSE)
})


test_that("read+validate wrapper returns a list", {
  sp <- zashboard_read_validate()  # defaults to the installed template
  expect_type(sp, "list")
  expect_true(all(c("datasets","charts","layout") %in% names(sp)))
})

test_that("read+validate fails when a key is missing", {
  tpl <- zashboard_read_spec()
  tpl$charts <- NULL  # remove a required field intentionally
  expect_error(zashboard_validate_spec(tpl), "charts")
})
