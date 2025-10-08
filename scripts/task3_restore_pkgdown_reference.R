# scripts/task3_restore_pkgdown_reference.R
# Restore the pkgdown reference "Build" section, then rebuild site to 'site/'.

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
need(c("yaml","devtools","pkgdown","roxygen2"))

cfg_path <- "_pkgdown.yml"
stopifnot(file.exists(cfg_path))
cfg <- yaml::read_yaml(cfg_path)
if (is.null(cfg$reference)) cfg$reference <- list()

# remove any existing "Build" section
cfg$reference <- Filter(function(x) is.null(x$title) || !identical(x$title, "Build"), cfg$reference)

# append our Build section
cfg$reference <- append(cfg$reference, list(list(
  title = "Build",
  contents = as.list(c("build_static","build_shiny","build_shinylive","build_quarto"))
)))

yaml::write_yaml(cfg, cfg_path)

# re-document to ensure Rd/NAMESPACE are current
devtools::document()

# build site to 'site/' locally (keeps gh-pages workflow separate)
pkgdown::build_site(preview = FALSE, override = list(destination = "site"))

# snapshot any doc deps
renv::snapshot(prompt = FALSE)

cat("\n✅ Restored pkgdown reference and rebuilt site to 'site/index.html'.\n")
