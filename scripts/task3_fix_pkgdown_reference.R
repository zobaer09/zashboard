# scripts/task3_fix_pkgdown_reference.R
# Ensure pkgdown reference index lists public API functions, then rebuild to 'site/'.

if (file.exists("renv/activate.R")) source("renv/activate.R")
options(
  repos = c(CRAN = "https://cloud.r-project.org"),
  pkgType = "win.binary",
  install.packages.compile.from.source = "never"
)

if (!requireNamespace("yaml", quietly = TRUE)) renv::install("yaml")
if (!requireNamespace("pkgdown", quietly = TRUE)) renv::install("pkgdown")
if (!requireNamespace("devtools", quietly = TRUE)) renv::install("devtools")
if (!requireNamespace("roxygen2", quietly = TRUE)) renv::install("roxygen2")

cfg_path <- "_pkgdown.yml"
stopifnot(file.exists(cfg_path))
cfg <- yaml::read_yaml(cfg_path)

# If no 'reference' key yet, start with an empty list
if (is.null(cfg$reference)) cfg$reference <- list()

# Remove any existing 'Build' section (optional cleanup)
cfg$reference <- Filter(function(x) is.null(x$title) || !identical(x$title, "Build"), cfg$reference)

# Append the Build section listing public API topics
cfg$reference <- append(cfg$reference, list(list(
  title = "Build",
  contents = as.list(c("build_static", "build_shiny", "build_shinylive", "build_quarto"))
)))

yaml::write_yaml(cfg, cfg_path)

# Re-document (ensures Rd topics are current)
devtools::document()

# Rebuild site to 'site/' (avoid touching 'docs/')
pkgdown::build_site(preview = FALSE, override = list(destination = "site"))

# Snapshot any new doc deps
if (requireNamespace("renv", quietly = TRUE)) renv::snapshot(prompt = FALSE)

cat("\n✅ pkgdown reference fixed. Site rebuilt at 'site/index.html'.\n")
