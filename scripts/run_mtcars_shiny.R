# Robust resolver: installed path, else source tree
resolve_spec <- function() {
  p <- tryCatch(system.file("examples/mtcars/mtcars.yml",
                            package = "zashboard", mustWork = TRUE),
                error = function(e) "")
  if (!nzchar(p) || !file.exists(p)) {
    cand <- file.path("inst", "examples", "mtcars", "mtcars.yml")
    if (file.exists(cand)) p <- normalizePath(cand, winslash = "/", mustWork = TRUE)
  }
  if (!nzchar(p) || !file.exists(p)) {
    stop("Couldn't find mtcars.yml in installed package or source tree.")
  }
  p
}

spec_path <- resolve_spec()
app <- zashboard::build_shiny(spec_path)  # shiny.appobj
cat("Starting Shiny app… Press Ctrl+C to stop.\n")
shiny::runApp(app, launch.browser = TRUE)

