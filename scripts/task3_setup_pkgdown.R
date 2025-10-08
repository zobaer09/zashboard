# scripts/task3_setup_pkgdown.R
# Goal: polish DESCRIPTION, add package doc, configure pkgdown, and build a minimal site.

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
need(c("desc","usethis","devtools","pkgdown","roxygen2"))

# ---- DESCRIPTION polish (idempotent) ----
library(desc)
d <- desc::desc(file = "DESCRIPTION")

# Ensure baseline fields
d$set("Package", "zashboard")
d$set("Title", "Build Dashboards from One Spec as Static HTML, Shiny, or Shinylive")
d$set("Description", paste0(
  "Zashboard lets you define a single dashboard spec and build it into three targets: ",
  "static HTML, a Shiny app, or a Shinylive app. It includes light semantics for measures ",
  "and relationships, supports cross-filtering in Shiny and safe interactivity in static builds, ",
  "theming with 'bslib', and data sources via DuckDB/Arrow or Microsoft SQL Server (DBI/ODBC)."
))
d$set("License", "MIT + file LICENSE")
d$set("Encoding", "UTF-8")
d$set("Roxygen", "list(markdown = TRUE)")
d$set("RoxygenNote", as.character(packageVersion("roxygen2")))
d$set("URL", "https://github.com/zobaer09/zashboard")
d$set("BugReports", "https://github.com/zobaer09/zashboard/issues")
d$set("Depends", "R (>= 4.3)")

# Imports (keep minimal; expand later as features land)
imports <- c("yaml","cli","tibble","shiny","bslib","htmltools","DBI","duckdb","arrow")
for (pkg in imports) d$set_dep(pkg, type = "Imports")

# Suggests (tools used in dev/docs/tests)
d$set_dep("testthat", type = "Suggests", version = ">= 3.0.0")
d$set_dep("pkgdown",  type = "Suggests")
d$set_dep("knitr",    type = "Suggests")
d$set_dep("rmarkdown",type = "Suggests")
d$set("VignetteBuilder", "knitr")
d$set("Config/testthat/edition", "3")

d$write(file = "DESCRIPTION")

# ---- Minimal package doc: R/zzz.R (safe add) ----
if (!dir.exists("R")) dir.create("R")
if (!file.exists("R/zzz.R")) {
  writeLines(c(
    "#' Zashboard",
    "#'",
    "#' Build dashboards from a single spec to static HTML, Shiny, or Shinylive.",
    "#' @keywords internal",
    '"_PACKAGE"'
  ), "R/zzz.R", useBytes = TRUE)
}

# ---- _pkgdown.yml config (safe, small) ----
if (!file.exists("_pkgdown.yml")) {
  writeLines(c(
    "template:",
    "  bootstrap: 5",
    "",
    "url: https://zobaer09.github.io/zashboard/",
    "",
    "home:",
    "  title: Zashboard",
    "  description: Build dashboards from one spec as static HTML, Shiny, or Shinylive.",
    "",
    "navbar:",
    "  structure:",
    "    left: [reference, articles]",
    "    right: [github]",
    "  components:",
    "    github:",
    "      icon: fab fa-github",
    "      href: https://github.com/zobaer09/zashboard",
    "",
    "reference:",
    "  - title: Spec I/O",
    "    contents:",
    "      - has_concept('spec-io')",
    "  - title: Build",
    "    contents:",
    "      - has_concept('build')"
  ), "_pkgdown.yml", useBytes = TRUE)
}

# ---- Document & build site locally (no preview) ----
need(c("pkgdown","roxygen2","devtools"))
devtools::document()
# Build a minimal site into docs/ (no vignettes needed for now)
pkgdown::build_site(preview = FALSE)

# ---- Optional: set up GitHub Pages workflow (idempotent) ----
# This creates a GitHub Action to deploy the site to GitHub Pages.
# You can comment these two lines if you prefer to commit 'docs/' directly.
if (!file.exists(".github/workflows/pkgdown.yaml")) {
  usethis::use_pkgdown_github_pages()
}

cat("\n✅ Task 3 complete: DESCRIPTION polished, package doc in place, pkgdown configured, site built to docs/.\n")
