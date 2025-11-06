# scripts/site_build_and_publish.R
if (file.exists("renv/activate.R")) source("renv/activate.R")

# 1) Build vignettes (so Articles are fresh)
devtools::build_vignettes()

# 2) Make 'docs/' an empty pkgdown destination (it will be re-created)
pkgdown::clean_site(force = TRUE)

# 3) Build the pkgdown site into docs/
pkgdown::build_site(preview = FALSE)  # destination defaults to 'docs'

# 4) Publish all examples (static, shinylive, quarto) into docs/examples/
source("scripts/examples_publish_all.R")

# 5) Ensure GitHub Pages serves assets (no Jekyll mangling)
if (!file.exists(file.path("docs", ".nojekyll"))) writeLines("", file.path("docs", ".nojekyll"))

message("Done: site built to docs/ and demos published under docs/examples/.")
