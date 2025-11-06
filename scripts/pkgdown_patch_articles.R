# scripts/pkgdown_patch_articles.R
if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)
stopifnot(file.exists("_pkgdown.yml"))
if (!requireNamespace("yaml", quietly = TRUE)) stop("Package 'yaml' is required.")

cfg <- yaml::read_yaml("_pkgdown.yml")
if (is.null(cfg)) cfg <- list()

# Disable Quarto articles (we only use Rmd here)
cfg$quarto <- FALSE

# Ensure articles list contains our Rmd vignette
cfg$articles <- list(
  list(
    title    = "Getting started",
    contents = c("getting-started")
  )
)

yaml::write_yaml(cfg, "_pkgdown.yml")
message("Patched _pkgdown.yml: quarto: false; articles: getting-started")
