# scripts/task27_update_readme.R
# Safely augment README.md: add badges, install, and a mtcars quick start.
# - Non-destructive: inserts after the first H1, appends if anchors missing.
# - Idempotent: re-running won’t duplicate sections.

readme_path <- "README.md"
stopifnot(file.exists(readme_path))
txt <- readLines(readme_path, warn = FALSE)

# helpers
has_line <- function(pat) any(grepl(pat, txt, fixed = TRUE))
insert_after_h1 <- function(block) {
  h1 <- grep("^#\\s", txt)
  if (length(h1) == 0L) return(c(block, "", txt))
  i <- h1[1]
  c(txt[seq_len(i)], "", block, "", txt[(i+1L):length(txt)])
}

# --- Badges block (after title) ---
badge_block <- c(
  "<!-- badges: start -->",
  # R-CMD-check
  sprintf("[![R-CMD-check](https://github.com/%s/%s/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/%s/%s/actions/workflows/R-CMD-check.yaml)",
          "zobaer09","zashboard","zobaer09","zashboard"),
  # Lifecycle
  "[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html)",
  # MIT license
  "[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.md)",
  # pkgdown site
  "[Docs](https://zobaer09.github.io/zashboard/)",
  "<!-- badges: end -->"
)

if (!has_line("<!-- badges: start -->")) {
  txt <- insert_after_h1(badge_block)
}

# --- Installation section ---
install_anchor <- "## Installation"
if (!has_line(install_anchor)) {
  install_block <- c(
    install_anchor,
    "",
    "Zashboard targets OS **Windows 10/11** and **R ≥ 4.3**. Use `renv` (recommended), or install directly:",
    "",
    "```r",
    "# Stable (GitHub):",
    "if (!requireNamespace(\"pak\", quietly = TRUE)) install.packages(\"pak\")",
    "pak::pak(\"zobaer09/zashboard\")",
    "",
    "# Or with renv inside your project:",
    "renv::install(\"zobaer09/zashboard\")",
    "```"
  )
  txt <- c(txt, "", install_block)
}

# --- Quick start (mtcars) ---
qs_anchor <- "## Quick start"
if (!has_line(qs_anchor)) {
  quick_block <- c(
    qs_anchor,
    "",
    "A minimal, practical example using built-in **mtcars** data. It builds **four targets**:",
    "**static HTML**, **Shiny app**, **Shinylive**, and a **Quarto** project.",
    "",
    "```r",
    "library(zashboard)",
    "",
    "# 1) Use the packaged example spec",
    "spec <- system.file(\"examples/mtcars/mtcars.yml\", package = \"zashboard\", mustWork = TRUE)",
    "",
    "# 2) Build all targets (skip Quarto rendering by default for speed)",
    "out <- build_all(spec = spec, overwrite = TRUE, render_quarto = FALSE)",
    "out",
    "",
    "# 3) What you get:",
    "# - Static:     file.path(out$static_dir,    \"index.html\")",
    "# - Shinylive:  file.path(out$shinylive_dir, \"index.html\")  # + app.json",
    "# - Quarto:     file.path(out$quarto_dir,    c(\"_quarto.yml\", \"index.qmd\"))",
    "# - Shiny app:  out$shiny_app   # a shiny.appobj (run via shiny::runApp(out$shiny_app))",
    "",
    "# Open the static dashboard in your browser",
    "browseURL(file.path(out$static_dir, \"index.html\"))",
    "```",
    "",
    "> **Tip:** To render the Quarto site locally, set `render_quarto = TRUE`,",
    "or run `quarto::quarto_render(out$quarto_dir)` after installing Quarto."
  )
  txt <- c(txt, "", quick_block)
}

# --- “How people use it” teaser (we’ll expand later) ---
use_anchor <- "## How people use Zashboard"
if (!has_line(use_anchor)) {
  use_block <- c(
    use_anchor,
    "",
    "- **Static dashboards** for safe sharing (no server) with pre-aggregated data.",
    "- **Shiny apps** when you need cross-filtering and server compute.",
    "- **Shinylive** for running Shiny **entirely in the browser**.",
    "- **Quarto** to stitch dashboards, prose, and code into a site.",
    "",
    "See the articles: **Getting started** and **MTCars walkthrough**."
  )
  txt <- c(txt, "", use_block)
}

writeLines(txt, readme_path)
cat("README.md updated.\n")