# scripts/task3_fix_roxygen_and_build.R
# Fix roxygen, build pkgdown to a separate 'site/' folder, then snapshot renv.

if (file.exists("renv/activate.R")) source("renv/activate.R")
options(
  repos = c(CRAN = "https://cloud.r-project.org"),
  pkgType = "win.binary",
  install.packages.compile.from.source = "never"
)
Sys.setenv(R_REMOTES_NO_ERRORS_FROM_WARNINGS = "true")

need <- function(pkgs) {
  miss <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(miss)) renv::install(miss)
}

need(c("roxygen2","devtools","pkgdown"))

# 1) Re-document (will fail if a roxygen block still lacks @name)
devtools::document()

# 2) Build site to 'site/' (avoid touching 'docs/')
#    Using 'override' to set destination without editing _pkgdown.yml.
pkgdown::build_site(
  preview   = FALSE,
  override  = list(destination = "site")
)

# 3) Snapshot renv (new doc/build deps, if any)
renv::snapshot(prompt = FALSE)

cat("\n✅ Roxygen fixed and site built to 'site/index.html'.\n")
