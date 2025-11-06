# Task 22: bump to 0.1.0, fix DESCRIPTION text, stamp NEWS date.
# Defaults to DRY-RUN. Set ZASH_DRYRUN=0 to apply.

dry_run <- identical(Sys.getenv("ZASH_DRYRUN", "1"), "1")
today   <- format(Sys.Date(), "%Y-%m-%d")
target_version <- "0.1.0"

msg <- function(...) cat(sprintf(...), "\n")
if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)
if (!requireNamespace("desc", quietly = TRUE)) install.packages("desc")

stopifnot(file.exists("DESCRIPTION"), file.exists("NEWS.md"))

d <- desc::desc("DESCRIPTION")
old_version <- d$get("Version")[[1]]

# --- 1) DESCRIPTION: Version, Date, Description field (CRAN-friendly) ----------
new_desc <- paste(
  "Build production dashboards from a single declarative spec into four targets:",
  "static HTML, a Shiny app, a Shinylive app, and a Quarto site.",
  "Includes helpers for local analytics (DuckDB, Arrow) and Microsoft SQL Server",
  "through DBI/ODBC, plus theming via bslib and simple build automation."
)

msg("Current version: %s  ->  Target: %s  (dry-run = %s)", old_version, target_version, dry_run)

if (!dry_run) {
  d$set("Version", target_version)
  d$set("Date", today) # optional; harmless if present
  d$set("Description", new_desc)
  # Make sure Encoding and Depends are fine
  d$set("Encoding", "UTF-8")
  if (!"R (>= 4.3)" %in% d$get_deps()$version[d$get_deps()$package == "R"]) {
    d$set_dep("R", type = "Depends", version = ">= 4.3")
  }
  d$write()
}

# --- 2) NEWS.md: stamp date for 0.1.0 section ---------------------------------
news <- readLines("NEWS.md", warn = FALSE, encoding = "UTF-8")
pat  <- sprintf("^#\\s*zashboard\\s+%s\\s*\\(unreleased\\)", gsub("\\.", "\\\\.", target_version))
if (any(grepl(pat, tolower(news)))) {
  news <- sub("\\(unreleased\\)", paste0("(", today, ")"), news)
  if (!dry_run) writeLines(news, "NEWS.md", useBytes = TRUE)
} else {
  msg("Note: did not find a 0.1.0 (unreleased) header in NEWS.md; leaving as-is.")
}

# Speed: prefer binaries; allow skipping installs completely on CI/Windows
if (!dry_run) {
  options(
    repos = c(CRAN = "https://cloud.r-project.org"),
    pkgType = "win.binary",
    install.packages.compile.from.source = "never"
  )
  if (!requireNamespace("devtools", quietly = TRUE)) {
    install.packages("devtools", type = "win.binary")
  }
  devtools::document()
  
  # Skip heavy install unless explicitly enabled
  if (!identical(Sys.getenv("ZASH_SKIP_INSTALL", "1"), "1")) {
    devtools::install(build_vignettes = TRUE, upgrade = "never", quiet = TRUE)
  }
}

# Prefer the fast (warning-free) preflight
msg("Running release preflight (FAST mode)...")
system2("Rscript", c("scripts/release_check.R"), env = c("ZASH_FAST=1"))


msg("\nDone. %s", if (dry_run) "DRY RUN (no files changed)." else "Applied changes.")
