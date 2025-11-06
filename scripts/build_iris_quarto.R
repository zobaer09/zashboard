if (file.exists("renv/activate.R")) source("renv/activate.R")

spec <- system.file("examples/iris/iris.yml", package = "zashboard")
if (is.null(spec) || identical(spec, "")) {
  spec <- normalizePath("inst/examples/iris/iris.yml")
}

dir <- zashboard::build_quarto(spec = spec, overwrite = TRUE)
cat("Quarto project at:\n  ", dir, "\nRender with:\n  quarto::quarto_render('", dir, "')\n", sep = "")
