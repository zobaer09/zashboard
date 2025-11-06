# scripts/task24_make_mtcars_vignette.R
dir.create("vignettes", showWarnings = FALSE, recursive = TRUE)

v <- paste0(
  "---\n",
  'title: "MTCars walkthrough (4 targets)"\n',
  "output:\n",
  "  rmarkdown::html_vignette:\n",
  "    df_print: paged\n",
  "vignette: >\n",
  "  %\\VignetteIndexEntry{MTCars walkthrough (4 targets)}\n",
  "  %\\VignetteEngine{knitr::rmarkdown}\n",
  "  %\\VignetteEncoding{UTF-8}\n",
  "---\n\n",
  "```{r, include=FALSE}\n",
  'knitr::opts_chunk$set(collapse = TRUE, comment = "#>")\n',
  "```\n\n",
  "This vignette shows how one Zashboard spec builds four targets: static HTML, a Shiny app, a Shinylive app, and a Quarto site - using only the built-in datasets::mtcars.\n\n",
  "```{r}\n",
  "library(zashboard)\n",
  'spec <- system.file(\"examples/mtcars/mtcars.yml\", package = \"zashboard\", mustWork = TRUE)\n',
  "```\n\n",
  "## Static HTML\n\n",
  "```{r}\n",
  "static_dir <- zashboard::build_static(spec, overwrite = TRUE)\n",
  "static_dir\n",
  "```\n\n",
  "## Shinylive\n\n",
  "```{r}\n",
  "sl_dir <- zashboard::build_shinylive(spec, overwrite = TRUE)\n",
  "sl_dir\n",
  "```\n\n",
  "## Shiny app\n\n",
  "Run this part interactively.\n\n",
  "```{r eval=FALSE}\n",
  "# app <- zashboard::build_shiny(spec)\n",
  "# shiny::runApp(app)\n",
  "```\n\n",
  "## Quarto project\n\n",
  "```{r}\n",
  'qdir <- file.path(tempdir(), \"zash-mtcars-quarto\")\n',
  "zashboard::build_quarto(spec, out_dir = qdir, overwrite = TRUE)\n",
  "qdir\n",
  "```\n\n",
  "That is it - one spec, four targets.\n"
)

writeLines(v, "vignettes/mtcars-walkthrough.Rmd", useBytes = TRUE)
message("Wrote vignettes/mtcars-walkthrough.Rmd")

