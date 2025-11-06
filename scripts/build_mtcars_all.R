library(datasets)

# Build all four targets from the mtcars spec using the DEV namespace.
if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)
if (requireNamespace("pkgload", quietly = TRUE)) {
  try(pkgload::unload("zashboard"), silent = TRUE)
  pkgload::load_all(export_all = FALSE, helpers = FALSE, quiet = TRUE)
}

spec_path <- "inst/examples/mtcars/mtcars.yml"

res <- build_all(
  spec = spec_path,
  targets = c("static","shiny","shinylive","quarto"),
  overwrite = TRUE,
  render_quarto = FALSE
)

cat("\n=== mtcars build outputs ===\n")
cat("static   :", res$static_dir,   "\n")
cat("shinylive:", res$shinylive_dir, "\n")
cat("quarto   :", res$quarto_dir,   "\n")
cat("shiny    :", class(res$shiny_app), "\n")
