# scripts/task25_cran_preflight.R
if (file.exists("renv/activate.R")) source("renv/activate.R")
cat("=== Zashboard CRAN preflight ===\n")

# 0) Quick doc refresh (fast)
if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
devtools::document(quiet = TRUE)

# 1) Build vignettes to inst/doc (keeps CRAN happy)
devtools::build_vignettes()

# 2) Full CRAN-ish check; logs to release-logs/
dir.create("release-logs", showWarnings = FALSE)
res <- devtools::check(args = c("--as-cran"), document = FALSE, check_dir = "release-logs")

# 3) Summarize results
log <- tryCatch({
  # rcmdcheck object
  cand <- list.files("release-logs", pattern = "00check\\.log$", recursive = TRUE, full.names = TRUE)
  cand[1]
}, error = function(e) NA_character_)

if (!is.na(log) && file.exists(log)) {
  txt <- readLines(log, warn = FALSE)
  cat("\n--- 00check.log summary ---\n")
  show <- grep("Status:|NOTE|WARNING|ERROR", txt, value = TRUE)
  if (length(show)) writeLines(show) else cat("(no summary lines found)\n")
}

# 4) Sanity: vignettes present?
has_getting <- file.exists("inst/doc/getting-started.html")
has_mtcars  <- file.exists("inst/doc/mtcars-walkthrough.html")
cat("\nVignette HTML present in inst/doc/:",
    "\n  getting-started:", has_getting,
    "\n  mtcars-walkthrough:", has_mtcars, "\n")

# 5) Optional rhub preflight (skips if rhub not installed)
if (requireNamespace("rhub", quietly = TRUE)) {
  cat("\nSubmitting lightweight rhub preflight (no manual):\n")
  try({
    rhub::check_for_cran(
      show_status = FALSE,
      env_vars = c("_R_CHECK_FORCE_SUGGESTS_" = "false")
    )
  }, silent = TRUE)
} else {
  cat("\nTip: install.packages('rhub') for cross-platform checks.\n")
}

cat("\n=== Done. Address WARNINGs/ERRORs before submitting to CRAN. ===\n")
