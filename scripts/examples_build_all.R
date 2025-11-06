# scripts/examples_build_all.R
dir.create("examples_out", showWarnings = FALSE)
spec <- system.file("examples/mtcars/mtcars.yml", package = "zashboard", mustWork = TRUE)

# persistent output dirs
static_dir   <- file.path("examples_out", "mtcars-static")
shinylive_dir<- file.path("examples_out", "mtcars-shinylive")
quarto_dir   <- file.path("examples_out", "mtcars-quarto")

cat("\n=== Building MTCars example (all targets) ===\n")
zashboard::build_static(spec, out_dir = static_dir, overwrite = TRUE)
zashboard::build_shinylive(spec, out_dir = shinylive_dir, overwrite = TRUE)
zashboard::build_quarto(spec, out_dir = quarto_dir, overwrite = TRUE)

cat("\nArtifacts:\n",
    "- Static     :", normalizePath(file.path(static_dir, "index.html"), winslash = "/"), "\n",
    "- Shinylive  :", normalizePath(file.path(shinylive_dir, "index.html"), winslash = "/"), "\n",
    "- Quarto     :", normalizePath(file.path(quarto_dir, "_quarto.yml"), winslash = "/"), "\n",
    "  (Render with: quarto::quarto_render('", normalizePath(quarto_dir, winslash="/"), "'))\n", sep = "")
