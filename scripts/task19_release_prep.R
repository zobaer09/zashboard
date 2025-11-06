# scripts/task19_release_prep.R
# Prepare a CRAN-style release bump. Defaults to dry-run (shows what would change).

bump_release <- function(target_version = "0.1.0", dry_run = TRUE) {
  if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)
  if (!requireNamespace("desc", quietly = TRUE)) install.packages("desc")
  if (!file.exists("DESCRIPTION")) stop("No DESCRIPTION found.", call. = FALSE)
  if (!file.exists("NEWS.md")) stop("No NEWS.md found at repo root.", call. = FALSE)
  
  d <- desc::desc("DESCRIPTION")
  old_version <- d$get("Version")
  today <- format(Sys.Date(), "%Y-%m-%d")
  
  cat("Current Version:", old_version, "\n")
  cat("Target  Version:", target_version, "\n")
  cat("Dry run        :", dry_run, "\n\n")
  
  # 1) Update DESCRIPTION (Version + Date)
  if (!dry_run) {
    d$set("Version", target_version)
    d$set("Date", today)  # optional; harmless for CRAN
    d$write()
  }
  
  # 2) Update NEWS.md header date (replace `(unreleased)` with date)
  news <- readLines("NEWS.md", warn = FALSE, encoding = "UTF-8")
  pat  <- sprintf("^#\\s*zashboard\\s+%s\\s*\\(unreleased\\)", gsub("\\.", "\\\\.", target_version))
  if (any(grepl(pat, news))) {
    news <- sub("\\(unreleased\\)", paste0("(", today, ")"), news)
    if (!dry_run) writeLines(news, "NEWS.md", useBytes = TRUE)
  }
  
  # 3) Optional: ensure pkgdown will show News (automatic with NEWS.md)
  # Nothing to do here; keeping this comment as a reminder.
  
  # 4) Summarize
  cat("Planned changes:\n")
  cat(" - DESCRIPTION: Version ", old_version, " → ", target_version, if (!dry_run) " [APPLIED]" else " [DRY-RUN]", "\n", sep = "")
  cat(" - NEWS.md:     Stamp date for ", target_version, " = ", today, if (!dry_run) " [APPLIED]" else " [DRY-RUN]", "\n", sep = "")
  invisible(list(old = old_version, new = target_version, date = today, dry_run = dry_run))
}

# Convenience: run as a script with optional env var ZASH_DRYRUN (default "1")
if (identical(environmentName(topenv()), "R_GlobalEnv")) {
  # If sourced interactively, do nothing. Run bump_release() manually.
} else {
  # If executed via Rscript, honor env var
  dr <- identical(Sys.getenv("ZASH_DRYRUN", "1"), "1")
  bump_release(dry_run = dr)
}
