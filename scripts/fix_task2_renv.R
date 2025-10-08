# scripts/fix_task2_renv.R
# Safely bring renv to "up to date" and silence Arrow's tzdb warning.

if (file.exists("renv/activate.R")) source("renv/activate.R")

# Prefer Windows binaries; avoid compiling from source
options(
  repos = c(CRAN = "https://cloud.r-project.org"),
  pkgType = "win.binary",
  install.packages.compile.from.source = "never"
)
Sys.setenv(R_REMOTES_NO_ERRORS_FROM_WARNINGS = "true")

# 1) Ensure core deps present (adds tzdb to quiet Arrow timezone warning)
core <- c("arrow","duckdb","DBI","shiny","bslib","htmltools","pak","tibble","tzdb")
missing_core <- core[!vapply(core, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_core)) renv::install(missing_core)

# 2) Install any packages referenced by the project (DESCRIPTION, R/, tests/, vignettes/, etc.)
deps <- tryCatch(renv::dependencies(".", progress = FALSE), error = function(e) NULL)
if (!is.null(deps) && nrow(deps)) {
  pkgs <- sort(unique(deps$Package))
  pkgs <- setdiff(pkgs, c("zashboard"))  # don't try to install the package itself
  still_missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(still_missing)) renv::install(still_missing)
}

# 3) Hydrate project library from cache (safe and fast if files already cached)
try(renv::hydrate(), silent = TRUE)

# 4) Snapshot lockfile
renv::snapshot(prompt = FALSE)

# 5) Show final status
cat("\n--- renv::status() ---\n")
print(tryCatch(renv::status(), error = function(e) e))
