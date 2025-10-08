# scripts/bootstrap_dev.R
# Purpose: Install core dev deps, set up testthat (edition 3), MIT license (if missing),
# add GitHub Actions R CMD check (if missing), and snapshot renv.

# Ensure renv is active
if (file.exists("renv/activate.R")) source("renv/activate.R")

# Prefer fast installs with pak if available
.pkgs <- c(
  # Dev workflow
  "devtools", "roxygen2", "testthat", "pkgdown", "usethis", "desc",
  # Core tidy
  "cli", "fs", "glue", "yaml", "tibble", "dplyr", "tidyr", "purrr", "readr", "stringr",
  # Data + DB
  "DBI", "odbc", "duckdb", "arrow",
  # UI
  "shiny", "bslib", "htmltools"
)

install_pkgs <- function(pkgs) {
  if (requireNamespace("pak", quietly = TRUE)) {
    pak::pkg_install(pkgs, ask = FALSE)
  } else {
    install.packages(pkgs, quiet = TRUE)
  }
}

install_pkgs(.pkgs)

# testthat (edition 3) — idempotent
if (!file.exists("tests/testthat.R")) {
  usethis::use_testthat(edition = 3)
}

# MIT License — only if missing (keeps repo non-destructive)
if (!file.exists("LICENSE.md")) {
  # Use your name for copyright; change if you prefer
  usethis::use_mit_license(name = "Zobaer Ahmed")
}

# Make sure build ignores are sane (idempotent)
usethis::use_build_ignore(c("_starter", "site", "docs", "scripts"))

# Add standard R CMD check workflow if missing
if (!dir.exists(".github")) dir.create(".github")
if (!dir.exists(".github/workflows")) dir.create(".github/workflows", recursive = TRUE)
if (!file.exists(".github/workflows/R-CMD-check.yaml") &&
    !file.exists(".github/workflows/check-standard.yaml")) {
  usethis::use_github_action_check_standard()
}

# Snapshot renv
renv::snapshot(prompt = FALSE)
cat("\n✅ Bootstrap complete. You can now commit/push and check GitHub Actions.\n")
