# scripts/task24_patch_readme_quickstart.R
add <- "\n## Quickstart (4 targets with mtcars)\n\n```r\nlibrary(zashboard)\nspec <- system.file('examples/mtcars/mtcars.yml', package = 'zashboard', mustWork = TRUE)\nstatic_dir <- build_static(spec, overwrite = TRUE)\nsl_dir     <- build_shinylive(spec, overwrite = TRUE)\nqdir       <- file.path(tempdir(), 'zash-mtcars-quarto'); build_quarto(spec, out_dir = qdir, overwrite = TRUE)\n# shiny::runApp(build_shiny(spec))  # run interactively\n``` \n"
p <- "README.md"
txt <- if (file.exists(p)) readLines(p, warn = FALSE) else character()
if (!grepl("Quickstart \\(4 targets with mtcars\\)", paste(txt, collapse = "\n"))) {
  writeLines(c(txt, add), p)
  message("Appended Quickstart to README.md")
} else {
  message("README.md already contains Quickstart; no change.")
}
