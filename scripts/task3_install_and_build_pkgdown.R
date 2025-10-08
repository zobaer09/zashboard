# scripts/task3_install_and_build_pkgdown.R
# Install local package and build pkgdown to 'site/'.

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
need(c("devtools","pkgload","pkgdown","roxygen2"))

# 1) Re-document (keeps Rd/NAMESPACE consistent)
devtools::document()

# 2) If package is loaded in this session, unload it to allow install
if ("zashboard" %in% loadedNamespaces()) {
  pkgload::unload("zashboard")
}

# 3) Install the local package into the active renv library
devtools::install(dependencies = FALSE, upgrade = "never", quiet = TRUE)

# Sanity: verify the install path exists
stopifnot(nzchar(system.file(package = "zashboard")))

# 4) Build pkgdown site to 'site/' to avoid touching 'docs/'
pkgdown::build_site(preview = FALSE, override = list(destination = "site"))

# 5) Snapshot (records pkgdown/devtools etc.)
renv::snapshot(prompt = FALSE)

cat("\n✅ Installed local package and built site to 'site/index.html'.\n")
