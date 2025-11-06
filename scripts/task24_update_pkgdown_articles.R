# scripts/task24_update_pkgdown_articles.R  (safe version)
stopifnot(file.exists("_pkgdown.yml"))
cfg <- yaml::read_yaml("_pkgdown.yml")

arts <- cfg$articles
if (is.null(arts)) arts <- list()

# helper to read the "name" from each entry (supports "name:" objects or plain strings)
entry_name <- function(e) if (is.character(e)) e else (e$name %||% "")
`%||%` <- function(a,b) if (is.null(a) || length(a)==0) b else a  # local, just for this script

have <- vapply(arts, entry_name, character(1))

# ensure both vignettes are listed if they exist
add_entry <- function(arts, nm, title = NULL) {
  if (!any(have == nm)) {
    arts <- c(arts, list(if (is.null(title)) nm else list(name = nm, title = title)))
  }
  arts
}

if (file.exists("vignettes/getting-started.Rmd"))
  arts <- add_entry(arts, "getting-started", "Getting started")

if (file.exists("vignettes/mtcars-walkthrough.Rmd"))
  arts <- add_entry(arts, "mtcars-walkthrough", "MTCars walkthrough (4 targets)")

cfg$articles <- arts
yaml::write_yaml(cfg, "_pkgdown.yml")
cat("Updated _pkgdown.yml. Articles now:",
    paste(vapply(cfg$articles, entry_name, character(1)), collapse = ", "), "\n")

