# scripts/task28_add_recipes_vignette.R
# Creates vignettes/recipes.Rmd and ensures _pkgdown.yml lists it under Articles.

dir.create("vignettes", showWarnings = FALSE)
recipes_path <- "vignettes/recipes.Rmd"

recipes_rmd <- paste0(
  "---\n",
  "title: \"Zashboard recipes\"\n",
  "output:\n",
  "  rmarkdown::html_vignette:\n",
  "    df_print: paged\n",
  "vignette: >\n",
  "  %\\VignetteIndexEntry{Zashboard recipes}\n",
  "  %\\VignetteEngine{knitr::rmarkdown}\n",
  "  %\\VignetteEncoding{UTF-8}\n",
  "---\n\n",
  "```{r, include=FALSE}\n",
  "knitr::opts_chunk$set(collapse = TRUE, comment = \"#>\")\n",
  "```\n\n",
  "This page shows **practical copy-paste patterns** using only built-in R data.\n\n",
  "> We keep long operations as `eval = FALSE` so vignettes remain CRAN-friendly.\n",
  "> Run the chunks interactively to see the outputs.\n\n",
  
  "## Recipe 1 — CSV → Static HTML\n\n",
  "Write `mtcars` to a CSV and point a minimal spec to it, then build **static HTML**.\n\n",
  "```{r eval=FALSE}\n",
  "library(zashboard)\n",
  "csv <- tempfile(fileext = \".csv\")\n",
  "write.csv(mtcars, csv, row.names = FALSE)\n\n",
  "spec <- list(\n",
  "  title = \"CSV → Static demo\",\n",
  "  datasets = list(\n",
  "    cars = list(type = \"csv\", path = csv)\n",
  "  ),\n",
  "  charts = list(\n",
  "    list(id = \"mpg_by_cyl\", title = \"Average MPG by cylinders\",\n",
  "         type = \"bar\", dataset = \"cars\", x = \"cyl\", y = \"mean(mpg)\")\n",
  "  ),\n",
  "  layout = list(rows = c(\"mpg_by_cyl\")),\n",
  "  theme = list(bootswatch = \"cosmo\")\n",
  ")\n\n",
  "out_dir <- zashboard::build_static(spec = spec, overwrite = TRUE)\n",
  "browseURL(file.path(out_dir, \"index.html\"))\n",
  "```\n\n",
  
  "## Recipe 2 — DuckDB → Shiny (query + app)\n\n",
  "```{r eval=FALSE}\n",
  "library(zashboard); library(DBI); library(duckdb)\n",
  "con <- DBI::dbConnect(duckdb::duckdb())\n",
  "on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)\n",
  "DBI::dbWriteTable(con, \"mtcars\", mtcars, overwrite = TRUE)\n",
  "res <- zashboard::zashboard_execute_sql(list(type=\"duckdb\", handle=con),\n",
  "  \"SELECT cyl, AVG(mpg) AS avg_mpg FROM mtcars GROUP BY cyl ORDER BY cyl;\")\n",
  "head(res)\n\n",
  "spec <- system.file(\"examples/mtcars/mtcars.yml\", package=\"zashboard\", mustWork=TRUE)\n",
  "app <- zashboard::build_shiny(spec = spec)\n",
  "# shiny::runApp(app)\n",
  "```\n\n",
  
  "## Recipe 3 — Parquet (Arrow) → Shinylive bundle\n\n",
  "```{r eval=FALSE}\n",
  "library(zashboard); library(arrow)\n",
  "pq <- file.path(tempdir(), \"mtcars.parquet\")\n",
  "arrow::write_parquet(mtcars, pq)\n",
  "dir <- zashboard::build_shinylive(overwrite = TRUE)\n",
  "list.files(dir)\n",
  "file.edit(file.path(dir, \"app.json\"))\n",
  "browseURL(file.path(dir, \"index.html\"))\n",
  "```\n\n",
  
  "## Bonus — Quarto site from one spec\n\n",
  "```{r eval=FALSE}\n",
  "library(zashboard)\n",
  "spec <- system.file(\"examples/mtcars/mtcars.yml\", package=\"zashboard\", mustWork=TRUE)\n",
  "qdir <- zashboard::build_quarto(spec = spec, overwrite = TRUE)\n",
  "list.files(qdir)\n",
  "# quarto::quarto_render(qdir)\n",
  "```\n"
)

writeLines(recipes_rmd, recipes_path)

# ---------- update _pkgdown.yml (ensure articles lists include recipes) ----------
stopifnot(file.exists("_pkgdown.yml"))
cfg <- yaml::read_yaml("_pkgdown.yml")

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

# Accept either a flat character vector or list-of-groups
norm_articles <- function(art) {
  if (is.null(art)) return(list())
  if (is.character(art)) return(list(list(title = "Articles", contents = as.list(art))))
  art
}

cfg$articles <- norm_articles(cfg$articles)

ensure_group <- function(cfg, gtitle, slugs) {
  idx <- which(vapply(cfg$articles, function(x) identical(x$title, gtitle), logical(1)))
  if (length(idx) == 0) {
    cfg$articles <- append(cfg$articles, list(list(title = gtitle, contents = as.list(slugs))))
  } else {
    old <- cfg$articles[[idx]]$contents %||% list()
    vec <- unique(c(unlist(old, use.names = FALSE), slugs))
    cfg$articles[[idx]]$contents <- as.list(vec)
  }
  cfg
}

cfg <- ensure_group(cfg, "Getting started", c("getting-started"))
cfg <- ensure_group(cfg, "Walkthroughs",    c("mtcars-walkthrough", "recipes"))

yaml::write_yaml(cfg, "_pkgdown.yml")
cat("✓ Added vignettes/recipes.Rmd and updated _pkgdown.yml articles.\n")
