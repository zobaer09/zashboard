# scripts/ci_local_check.R
# Run R CMD check locally, capture logs, and summarize failures.

if (file.exists("renv/activate.R")) source("renv/activate.R")
options(
  repos = c(CRAN = "https://cloud.r-project.org"),
  pkgType = "win.binary",
  install.packages.compile.from.source = "never"
)

need <- function(pkgs) {
  miss <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(miss)) renv::install(miss)
}
need(c("rcmdcheck","devtools"))

dir.create("ci-logs", showWarnings = FALSE)
res <- rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"),
                            error_on = "never",
                            check_dir = "ci-logs")

# Save human-readable summaries
cat(res$summary, file = "ci-logs/summary.txt")
cat(paste(res$errors, collapse = "\n\n---\n\n"), file = "ci-logs/errors.txt")
cat(paste(res$warnings, collapse = "\n\n---\n\n"), file = "ci-logs/warnings.txt")
cat(paste(res$notes, collapse = "\n\n---\n\n"), file = "ci-logs/notes.txt")

cat("\n✅ Local check finished. See files in ci-logs/: summary.txt, errors.txt, warnings.txt, notes.txt\n")
