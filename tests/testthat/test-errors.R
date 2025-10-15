test_that("manifest errors are aggregated and clearly labeled", {
  man <- list(
    spec_version = "1",
    datasets = c("d1", "d1"),  # duplicate
    charts = list(list(id = "", type = ""), list(id = "ok", type = "")),
    layout = NULL
  )
  expect_error(zashboard_validate_manifest(man), "Manifest validation failed")
  expect_error(zashboard_validate_manifest(man), "(duplicated|layout|type|id)", ignore.case = TRUE)
})

test_that("spec validation aggregates missing fields", {
  sp <- list()  # nothing
  expect_error(zashboard_validate_spec(sp), "Spec validation failed")
  expect_error(zashboard_validate_spec(sp), "datasets|charts|layout")
})
