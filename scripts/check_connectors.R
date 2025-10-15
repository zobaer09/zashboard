# scripts/check_connectors.R
check_pkg <- function(p) {
  ok <- requireNamespace(p, quietly = TRUE)
  ver <- tryCatch(as.character(utils::packageVersion(p)), error = function(e) NA_character_)
  list(ok = ok, version = ver)
}

cat("=== Zashboard connector deps ===\n")
for (p in c("DBI","duckdb","arrow")) {
  info <- check_pkg(p)
  cat(sprintf("%-7s : %s %s\n", p, if (info$ok) "INSTALLED" else "missing", if (info$ok) paste0("(v", info$version, ")") else ""))
}

cat("\n=== Smoke tests ===\n")

# DuckDB smoke
if (requireNamespace("DBI", quietly = TRUE) && requireNamespace("duckdb", quietly = TRUE)) {
  cat("- DuckDB   : ")
  ok <- try({
    con <- zashboard_connect_duckdb()
    on.exit(zashboard_disconnect(con), add = TRUE)
    DBI::dbExecute(con$handle, "create table t(x integer);")
    DBI::dbExecute(con$handle, "insert into t values (1), (2);")
    ans <- zashboard_execute_sql(con, "select sum(x) as s from t")
    stopifnot(is.data.frame(ans), "s" %in% names(ans), ans$s[[1]] == 3L)
    TRUE
  }, silent = TRUE)
  cat(if (isTRUE(ok)) "OK\n" else "FAIL\n")
} else {
  cat("- DuckDB   : skipped (pkg missing)\n")
}

# Arrow smoke (single-file Parquet)
if (requireNamespace("arrow", quietly = TRUE)) {
  cat("- Arrow    : ")
  ok <- try({
    td <- tempfile("zash-arrow-"); dir.create(td)
    fp <- file.path(td, "data.parquet")
    arrow::write_parquet(data.frame(a = 1:3, b = c("u","v","w")), fp)
    acon <- zashboard_connect_arrow(fp)
    on.exit(zashboard_disconnect(acon), add = TRUE)
    df <- zashboard_execute_collect(acon)
    stopifnot(is.data.frame(df), nrow(df) == 3L, all(c("a","b") %in% names(df)))
    TRUE
  }, silent = TRUE)
  cat(if (isTRUE(ok)) "OK\n" else "FAIL\n")
} else {
  cat("- Arrow    : skipped (pkg missing)\n")
}

cat("\nTips:\n")
cat("  * Prefer Windows binaries to avoid long source builds:\n")
cat("    options(repos = c(CRAN = 'https://cloud.r-project.org'),\n")
cat("            pkgType = 'win.binary',\n")
cat("            install.packages.compile.from.source = 'never')\n")
cat("  * Install only what you need for local testing:\n")
cat("    renv::install(c('DBI','duckdb','arrow'))\n")
