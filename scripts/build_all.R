#!/usr/bin/env Rscript
# Build all Zashboard targets and print their locations.

quiet_require <- function(p) suppressPackageStartupMessages(require(p, character.only = TRUE))
msg <- function(...) cat(sprintf(...), "\n")
nl  <- function(x) normalizePath(x, winslash = "/", mustWork = FALSE)

# 1) Activate this project's renv (if present)
if (file.exists("renv/activate.R")) {
  try(source("renv/activate.R"), silent = TRUE)
}

# 2) Load package: prefer dev source in the repo via pkgload::load_all()
loaded_dev <- FALSE
if (file.exists("DESCRIPTION") && requireNamespace("pkgload", quietly = TRUE)) {
  try({
    pkgload::load_all(export_all = FALSE, helpers = FALSE, quiet = TRUE)
    loaded_dev <- TRUE
  }, silent = TRUE)
}

if (!loaded_dev) {
  if (!quiet_require("zashboard")) {
    stop("Package 'zashboard' is not installed in this project. ",
         "Run devtools::install() and retry.", call. = FALSE)
  }
}

# 3) Ensure build_all is exported/available
exports <- try(getNamespaceExports("zashboard"), silent = TRUE)
if (inherits(exports, "try-error") || !("build_all" %in% exports)) {
  stop("Function 'build_all()' is not exported. ",
       "Run devtools::document(); devtools::install() and try again.", call. = FALSE)
}

# 4) Build (no Quarto render for speed/portability)
res <- zashboard::build_all(overwrite = TRUE, render_quarto = FALSE)

# 5) Sanity checks
ok <- TRUE
check_file <- function(path, what) {
  if (!file.exists(path)) { msg("✖ Missing %s: %s", what, nl(path)); return(FALSE) }
  TRUE
}

ok <- ok & check_file(file.path(res$static_dir,    "index.html"), "static index.html")
ok <- ok & check_file(file.path(res$shinylive_dir, "index.html"), "shinylive index.html")
ok <- ok & check_file(file.path(res$shinylive_dir, "app.json"),   "shinylive app.json")
ok <- ok & check_file(file.path(res$quarto_dir,    "_quarto.yml"), "quarto _quarto.yml")
ok <- ok & check_file(file.path(res$quarto_dir,    "index.qmd"),   "quarto index.qmd")

# 6) Pretty print results
msg("\n=== zashboard::build_all() outputs ===")
msg("static_dir   : %s", nl(res$static_dir))
msg("shinylive_dir: %s", nl(res$shinylive_dir))
msg("quarto_dir   : %s", nl(res$quarto_dir))
msg("shiny_app    : %s", paste(class(res$shiny_app), collapse = ", "))

# 7) Optionally open static site
open <- identical(Sys.getenv("ZASH_OPEN", "1"), "1") && interactive()
if (open) {
  idx <- file.path(res$static_dir, "index.html")
  if (file.exists(idx)) utils::browseURL(idx)
}

if (!ok) quit(status = 1L) else msg("\nOK: all outputs generated.")
