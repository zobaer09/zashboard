#!/usr/bin/env Rscript
# Pre-push safety net: runs fast local checks so CI won't fail on push.

msg <- function(...) cat(sprintf(...), "\n")
ok  <- TRUE

# 1) Activate renv if present
if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)

# 2) Document (exports + Rd)
if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
msg("• Documenting...")
tryCatch({
  devtools::document()
  TRUE
}, error = function(e) {
  msg("✖ document() failed: %s", e$message); ok <<- FALSE; FALSE
})

# 3) Quick unit tests
if (!requireNamespace("testthat", quietly = TRUE)) install.packages("testthat")
msg("• Running tests...")
tryCatch({
  testthat::test_dir("tests", reporter = "summary")
  TRUE
}, error = function(e) {
  msg("✖ tests failed: %s", e$message); ok <<- FALSE; FALSE
})

# 4) Pkgdown reference sanity (ensures new topics like build_all are listed)
msg("• Ensuring _pkgdown.yml reference is up to date...")
tryCatch({
  source("scripts/pkgdown_fix_reference.R", local = new.env())
  TRUE
}, error = function(e) {
  msg("✖ pkgdown_fix_reference failed: %s", e$message); ok <<- FALSE; FALSE
})

# 5) “Four targets” wording checker
msg("• Checking docs wording (four targets)...")
tryCatch({
  source("scripts/task13_check_targets.R", local = new.env())
  TRUE
}, error = function(e) {
  msg("✖ wording check script failed: %s", e$message); ok <<- FALSE; FALSE
})

# 6) Local R CMD check (fast, with logs)
msg("• Local R CMD check (as-cran, summarized)...")
tryCatch({
  source("scripts/ci_local_check.R", local = new.env())
  # consider warnings as failure for pre-push
  warn_file <- "ci-logs/warnings.txt"
  if (file.exists(warn_file) && length(readLines(warn_file, warn = FALSE)) > 0) {
    msg("✖ R CMD check has warnings (see %s).", normalizePath(warn_file, winslash = "/"))
    ok <<- FALSE
  }
  TRUE
}, error = function(e) {
  msg("✖ local R CMD check failed: %s", e$message); ok <<- FALSE; FALSE
})

# 7) Done
if (ok) {
  msg("\n✅ Pre-push check: PASS — safe to push.")
  quit(status = 0L)
} else {
  msg("\n❌ Pre-push check: FAIL — fix issues above before pushing.")
  quit(status = 1L)
}
