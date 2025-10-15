# Zashboard

[![R-CMD-check](https://github.com/zobaer09/zashboard/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/zobaer09/zashboard/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/zobaer09/zashboard/actions/workflows/pkgdown.yaml/badge.svg)](https://zobaer09.github.io/zashboard/)

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
