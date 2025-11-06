# scripts/run_crossfilter_demo.R
# Launch the tiny cross-filter Shiny demo from the installed package contents.

path <- system.file("examples/crossfilter", package = "zashboard", mustWork = TRUE)
message("Launching cross-filter demo from: ", path)
shiny::runApp(path, display.mode = "normal")