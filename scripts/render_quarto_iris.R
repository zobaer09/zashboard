if (file.exists("renv/activate.R")) source("renv/activate.R")
spec <- system.file("examples/iris/iris.yml", package = "zashboard", mustWork = TRUE)
dir  <- zashboard::build_quarto(spec = spec, overwrite = TRUE)
if (requireNamespace("quarto", quietly = TRUE) && quarto::quarto_is_installed()) {
  quarto::quarto_render(dir)
  browseURL(file.path(dir, "_site", "index.html"))
} else {
  message("Quarto CLI not found; open:\n  ", file.path(dir, "_quarto.yml"),
          "\n  ", file.path(dir, "index.qmd"))
}
