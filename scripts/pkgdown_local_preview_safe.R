# Safe pkgdown preview:
# - Forces quarto: false
# - Indexes Rmd vignettes explicitly
# - Builds in-process (new_process = FALSE) to avoid callr errors on Windows

if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)
if (!requireNamespace("pkgdown", quietly = TRUE)) stop("Please install 'pkgdown' first.", call. = FALSE)

dest <- "site"

# Collect Rmd vignette slugs (filenames without extension)
rmd_slugs <- character()
if (dir.exists("vignettes")) {
  vn <- list.files("vignettes", pattern = "\\.Rmd$", full.names = FALSE)
  rmd_slugs <- sub("\\.Rmd$", "", vn)
}

override <- list(
  destination = dest,
  quarto = FALSE,
  articles = if (length(rmd_slugs)) list(list(title = "Articles", contents = rmd_slugs)) else list()
)

# Build site in-process. If articles still cause trouble, retry without articles.
build_try <- try(
  pkgdown::build_site(preview = interactive(), override = override,
                      new_process = FALSE, devel = TRUE, lazy = FALSE),
  silent = TRUE
)

if (inherits(build_try, "try-error")) {
  message("Retrying without articles due to an error: ", conditionMessage(attr(build_try, "condition")))
  override$articles <- list()
  pkgdown::build_site(preview = interactive(), override = override,
                      new_process = FALSE, devel = TRUE, lazy = FALSE)
}

cat("Local site built at: ", normalizePath(dest, winslash = "/"), "\n")
