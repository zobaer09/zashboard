# Launch the retail example app from the installed package resources.
if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)
app_dir <- system.file("examples/retail", package = "zashboard", mustWork = TRUE)
shiny::runApp(appDir = app_dir, launch.browser = TRUE, display.mode = "normal")
