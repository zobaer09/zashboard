if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)

# Ensure we use dev code, not an installed copy
if (requireNamespace("pkgload", quietly = TRUE)) {
  try(pkgload::unload("zashboard"), silent = TRUE)
  pkgload::load_all(export_all = FALSE, helpers = FALSE, quiet = TRUE)
}

f <- get("build_static", envir = asNamespace("zashboard"))
src <- paste(deparse(body(f)), collapse = "\n")

cat("Contains 'seq_along(charts)' :", grepl("seq_along\\(charts\\)", src), "\n")
cat("Contains 'vapply(charts'     :", grepl("vapply\\(charts", src), "\n")

# Save full body so we can inspect if needed
dir.create("ci-logs", showWarnings = FALSE)
writeLines(src, "ci-logs/build_static_body.txt", useBytes = TRUE)
cat("Wrote full body to ci-logs/build_static_body.txt\n")
