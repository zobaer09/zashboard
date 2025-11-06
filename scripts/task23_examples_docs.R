# scripts/task23_examples_docs.R
# Adds vignettes/mtcars-example.Rmd and wires it into _pkgdown.yml → builds site

if (!requireNamespace("yaml", quietly = TRUE)) install.packages("yaml")

dir.create("vignettes", showWarnings = FALSE)

vign <- '---
title: "Example: mtcars across all four targets"
output:
  rmarkdown::html_vignette:
    df_print: paged
vignette: >
  %\\VignetteIndexEntry{Example: mtcars across all four targets}
  %\\VignetteEngine{knitr::rmarkdown}
  %\\VignetteEncoding{UTF-8}
---

```{r, include=FALSE}
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
```
