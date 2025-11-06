# Robust launcher for the built-in mtcars demo.
# Tries installed package files; if not installed, runs from local source tree.

if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)

find_app_dir <- function() {
  # 1) try installed path
  app_dir <- try(system.file("examples/mtcars", package = "zashboard", mustWork = TRUE), silent = TRUE)
  if (!inherits(app_dir, "try-error") && nzchar(app_dir)) return(app_dir)
  
  # 2) fallback to local source path
  local_dir <- file.path(getwd(), "inst", "examples", "mtcars")
  if (dir.exists(local_dir)) return(local_dir)
  
  stop("Example app not found in installed package or local 'inst/examples/mtcars'.", call. = FALSE)
}

shiny::runApp(find_app_dir(), launch.browser = TRUE)
