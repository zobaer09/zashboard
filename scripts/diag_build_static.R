if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)

# Try to load your dev code (so we inspect the dev namespace)
if (requireNamespace("pkgload", quietly = TRUE)) {
  pkgload::load_all(export_all = FALSE, helpers = FALSE, quiet = TRUE)
}

cat("=== Which build_static are we using? ===\n")
obj <- get("build_static", envir = asNamespace("zashboard"))
src <- paste(deparse(body(obj)), collapse = "\n")

has_old <- grepl("charts\\[\\[seq_along\\(charts\\)\\]\\]\\$id", src, fixed = TRUE)
has_new <- grepl("vapply\\(charts", src, fixed = TRUE)

cat("Contains old pattern (charts[[seq_along(charts)]]$id):", has_old, "\n")
cat("Contains new pattern (vapply(charts...)):", has_new, "\n")

cat("\n--- First 20 lines of body(build_static) ---\n")
cat(paste(utils::capture.output(print(obj))[1:20], collapse = "\n"), "\n")
