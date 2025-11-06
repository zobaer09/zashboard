# Zashboard

<!-- badges: start -->
[![R-CMD-check](https://github.com/zobaer09/zashboard/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/zobaer09/zashboard/actions/workflows/R-CMD-check.yaml)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.md)
[Docs](https://zobaer09.github.io/zashboard/)
<!-- badges: end -->


[![R-CMD-check](https://github.com/zobaer09/zashboard/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/zobaer09/zashboard/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://img.shields.io/badge/docs-pkgdown-blue.svg)](https://zobaer09.github.io/zashboard/)

Zashboard: define one dashboard spec, build **four** targets — static HTML, a Shiny app, a Shinylive app, and a Quarto site.

This repository contains a starter spec and scaffolding for the Zashboard R package.

- One spec builds static HTML, Shiny, Shinylive, and Quarto.
- Light semantic layer for relationships and measures.
- Optional client-side analytics via DuckDB WASM or Arrow JS for static dashboards.
- Optional micro backend later for sensitive aggregates.

See [SPEC.md](SPEC.md) and [CHECKLIST.md](CHECKLIST.md) to begin.

## Spec (v1)

Minimal top-level keys: **datasets** (named list), **charts** (list with `id` and `type`), **layout** (list).  
See the help page in R: `?zashboard_spec`  
Online docs: <https://zobaer09.github.io/zashboard/reference/zashboard_spec.html>

Quick check:

```r
sp <- zashboard_read_validate()   # loads the template shipped in the package
```

## Quickstart (4 targets with mtcars)

```r
library(zashboard)
spec <- system.file('examples/mtcars/mtcars.yml', package = 'zashboard', mustWork = TRUE)
static_dir <- build_static(spec, overwrite = TRUE)
sl_dir     <- build_shinylive(spec, overwrite = TRUE)
qdir       <- file.path(tempdir(), 'zash-mtcars-quarto'); build_quarto(spec, out_dir = qdir, overwrite = TRUE)
# shiny::runApp(build_shiny(spec))  # run interactively
``` 


## Installation

Zashboard targets OS **Windows 10/11** and **R ≥ 4.3**. Use `renv` (recommended), or install directly:

```r
# Stable (GitHub):
if (!requireNamespace("pak", quietly = TRUE)) install.packages("pak")
pak::pak("zobaer09/zashboard")

# Or with renv inside your project:
renv::install("zobaer09/zashboard")
```

## Quick start

A minimal, practical example using built-in **mtcars** data. It builds **four targets**:
**static HTML**, **Shiny app**, **Shinylive**, and a **Quarto** project.

```r
library(zashboard)

# 1) Use the packaged example spec
spec <- system.file("examples/mtcars/mtcars.yml", package = "zashboard", mustWork = TRUE)

# 2) Build all targets (skip Quarto rendering by default for speed)
out <- build_all(spec = spec, overwrite = TRUE, render_quarto = FALSE)
out

# 3) What you get:
# - Static:     file.path(out$static_dir,    "index.html")
# - Shinylive:  file.path(out$shinylive_dir, "index.html")  # + app.json
# - Quarto:     file.path(out$quarto_dir,    c("_quarto.yml", "index.qmd"))
# - Shiny app:  out$shiny_app   # a shiny.appobj (run via shiny::runApp(out$shiny_app))

# Open the static dashboard in your browser
browseURL(file.path(out$static_dir, "index.html"))
```

> **Tip:** To render the Quarto site locally, set `render_quarto = TRUE`,
or run `quarto::quarto_render(out$quarto_dir)` after installing Quarto.

## How people use Zashboard

- **Static dashboards** for safe sharing (no server) with pre-aggregated data.
- **Shiny apps** when you need cross-filtering and server compute.
- **Shinylive** for running Shiny **entirely in the browser**.
- **Quarto** to stitch dashboards, prose, and code into a site.

See the articles: **Getting started** and **MTCars walkthrough**.

### Demos
- **Iris** — [Static](https://zobaer09.github.io/zashboard/examples/iris/static/index.html) · [Shinylive](https://zobaer09.github.io/zashboard/examples/iris/shinylive/index.html) · [Quarto](https://zobaer09.github.io/zashboard/examples/iris/quarto/index.html)
- **Airquality** — [Static](https://zobaer09.github.io/zashboard/examples/airquality/static/index.html) · [Shinylive](https://zobaer09.github.io/zashboard/examples/airquality/shinylive/index.html) · [Quarto](https://zobaer09.github.io/zashboard/examples/airquality/quarto/index.html)
- **ToothGrowth** — [Static](https://zobaer09.github.io/zashboard/examples/toothgrowth/static/index.html) · [Shinylive](https://zobaer09.github.io/zashboard/examples/toothgrowth/shinylive/index.html) · [Quarto](https://zobaer09.github.io/zashboard/examples/toothgrowth/quarto/index.html)
- **CO2** — [Static](https://zobaer09.github.io/zashboard/examples/co2/static/index.html) · [Shinylive](https://zobaer09.github.io/zashboard/examples/co2/shinylive/index.html) · [Quarto](https://zobaer09.github.io/zashboard/examples/co2/quarto/index.html)
