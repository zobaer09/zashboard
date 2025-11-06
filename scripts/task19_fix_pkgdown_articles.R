# Make pkgdown use only Rmd vignettes and index them.

if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)
if (!requireNamespace("yaml", quietly = TRUE)) {
  stop("Please install 'yaml' first: renv::install('yaml')", call. = FALSE)
}
stopifnot(file.exists("_pkgdown.yml"))

# Collect all Rmd vignettes by slug (filename without extension)
rmds <- character()
if (dir.exists("vignettes")) {
  vn <- list.files("vignettes", pattern = "\\.Rmd$", full.names = FALSE)
  rmds <- sub("\\.Rmd$", "", vn)
}

cfg <- yaml::read_yaml("_pkgdown.yml")
if (is.null(cfg)) cfg <- list()

# Disable Quarto articles to avoid qmd indexing
cfg$quarto <- FALSE

# Build articles index from the actual Rmd files (if any)
if (length(rmds)) {
  cfg$articles <- list(
    list(
      title    = "Articles",
      contents = rmds
    )
  )
} else {
  # No Rmd vignettes found; ensure articles section is empty
  cfg$articles <- list()
}

yaml::write_yaml(cfg, "_pkgdown.yml")
message("Patched _pkgdown.yml: quarto: false; articles: ", if (length(rmds)) paste(rmds, collapse = ", ") else "<none>")
