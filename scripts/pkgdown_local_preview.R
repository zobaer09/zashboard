# Local pkgdown preview that writes to 'site/' (not 'docs/')
if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)

if (!requireNamespace("pkgdown", quietly = TRUE)) {
  stop("Package 'pkgdown' is required. Install it in this project, then re-run this script.")
}

# Build site into 'site/' so it won't conflict with GitHub Pages 'docs/'
dest <- "site"

# If you ever want to clean the local site first, run:
# pkgdown::clean_site(override = list(destination = dest))  # <-- destructive; run only if you want a clean rebuild

pkgdown::build_site(
  preview   = interactive(),
  override  = list(destination = dest)
)

idx <- file.path(dest, "index.html")
if (!file.exists(idx)) stop("pkgdown didn't create: ", idx)
message("Local pkgdown site: ", normalizePath(idx, winslash = "/"))
