test_that("manifest builds from template and validates", {
  man <- zashboard_manifest()  # read -> as_manifest -> validate
  expect_type(man, "list")
  expect_true(all(c("datasets","charts","layout") %in% names(man)))
  # charts have unique ids
  ids <- vapply(man$charts, `[[`, character(1), "id")
  expect_false(anyDuplicated(ids) > 0)
})

test_that("duplicate chart ids are rejected with helpful message", {
  man <- zashboard_as_manifest()
  # If template only has one chart, duplicate it; else force a dup id
  if (length(man$charts) == 1L) {
    man$charts <- c(man$charts, man$charts)  # duplicate the same chart
  } else {
    man$charts[[2]]$id <- man$charts[[1]]$id
  }
  expect_error(zashboard_validate_manifest(man), "duplicated|chart id", ignore.case = TRUE)
})
