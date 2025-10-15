test_that("DuckDB connector runs a real SQL query and returns results", {
  testthat::skip_if_not_installed("duckdb")
  testthat::skip_if_not_installed("DBI")
  
  con <- zashboard_connect_duckdb()
  on.exit(zashboard_disconnect(con), add = TRUE)
  
  # create a small table and query
  df <- data.frame(x = 1:5, y = c(2,2,2,2,10))
  DBI::dbWriteTable(con$handle, "t1", df, overwrite = TRUE)
  
  res <- zashboard_execute_sql(con, "select count(*) as n, sum(y) as s from t1 where x >= 3")
  expect_s3_class(res, "data.frame")
  expect_identical(nrow(res), 1L)
  expect_true(all(c("n","s") %in% names(res)))
  expect_identical(as.integer(res$n[[1]]), 3L)
  expect_identical(as.integer(res$s[[1]]), 14L)
})

test_that("Arrow connector can collect data (if installed)", {
  testthat::skip_if_not_installed("arrow")
  
  tmpdir <- file.path(tempdir(), paste0("zash-arrow-", as.integer(runif(1, 1, 1e9))))
  dir.create(tmpdir, recursive = TRUE, showWarnings = FALSE)
  
  # write a small parquet file
  df <- data.frame(a = 1:3, b = c("u","v","w"))
  f <- file.path(tmpdir, "data.parquet")
  arrow::write_parquet(df, f)
  
  con <- zashboard_connect_arrow(f)
  on.exit(zashboard_disconnect(con), add = TRUE)
  
  out <- zashboard_execute_collect(con)
  expect_s3_class(out, "data.frame")
  expect_identical(nrow(out), 3L)
  expect_true(all(c("a","b") %in% names(out)))
})

test_that("MSSQL connector errors clearly when no details are provided", {
  # No packages required to check the message; but if DBI/odbc absent,
  # the message should reflect that.
  has_db <- requireNamespace("DBI", quietly = TRUE)
  has_odbc <- requireNamespace("odbc", quietly = TRUE)
  
  if (!(has_db && has_odbc)) {
    expect_error(zashboard_connect_mssql(), "Packages 'DBI' and 'odbc' are required", fixed = TRUE)
  } else {
    expect_error(zashboard_connect_mssql(), "Provide either a DSN or a full ODBC connection string", fixed = TRUE)
  }
})
