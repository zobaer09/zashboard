# Quick check that the vignette is installed and discoverable

pkg <- "zashboard"

# Where installed vignettes live:
doc_dir <- system.file("doc", package = pkg)
cat("Installed doc dir:", if (nzchar(doc_dir)) doc_dir else "<none>", "\n")

has_html <- nzchar(doc_dir) && file.exists(file.path(doc_dir, "getting-started.html"))
cat("getting-started.html present?", has_html, "\n")

# Discover via tools API:
vigs <- browseVignettes(pkg)
visible <- length(vigs[[pkg]]) > 0
cat("browseVignettes() shows entries?", visible, "\n")

if (!has_html || !visible) {
  cat("\nHints:\n",
      "- Ensure knitr and rmarkdown are installed in this project.\n",
      "- Reinstall with vignettes: devtools::install(build_vignettes = TRUE)\n",
      "- Vignette chunks are non-evaluating by default (fast build).\n", sep = "")
}
