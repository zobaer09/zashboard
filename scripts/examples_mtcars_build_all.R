# scripts/examples_mtcars_build_all.R
# Build all four targets for the MTCars example from a single YAML spec.

if (file.exists("renv/activate.R")) source("renv/activate.R")

message("=== Building MTCars example (all 4 targets) ===")

# Locate spec whether installed or in-source
spec_path <- if (file.exists("inst/examples/mtcars/mtcars.yml")) {
  normalizePath("inst/examples/mtcars/mtcars.yml", winslash = "/", mustWork = TRUE)
} else {
  p <- system.file("examples/mtcars/mtcars.yml", package = "zashboard", mustWork = TRUE)
  normalizePath(p, winslash = "/", mustWork = TRUE)
}

out_base <- normalizePath("examples_out", winslash = "/", mustWork = FALSE)
dir.create(out_base, showWarnings = FALSE)

static_dir    <- file.path(out_base, "mtcars-static")
shinylive_dir <- file.path(out_base, "mtcars-shinylive")
quarto_dir    <- file.path(out_base, "mtcars-quarto")

# 1) Static HTML (safe, no server)
static_out <- zashboard::build_static(
  spec = spec_path,
  out_dir = static_dir,
  overwrite = TRUE,
  title = "MTCars — Static"
)

# 2) Shinylive (Shiny in the browser)
shinylive_out <- zashboard::build_shinylive(
  spec = spec_path,
  out_dir = shinylive_dir,
  overwrite = TRUE
)

# 3) Quarto project (don’t render by default to keep fast)
quarto_out <- zashboard::build_quarto(
  spec = spec_path,
  out_dir = quarto_dir,
  overwrite = TRUE
)

# 4) Shiny app object (server-backed)
shiny_app <- zashboard::build_shiny(spec = spec_path)

cat("\n=== Artifacts ===\n")
cat(sprintf("- Static     : %s/index.html\n", static_out))
cat(sprintf("- Shinylive  : %s/index.html\n", shinylive_out))
cat(sprintf("- Quarto     : %s/_quarto.yml\n", quarto_out))
cat("  (Render with Quarto if installed; see scripts/render_quarto_mtcars.R)\n")
cat(sprintf("- Shiny app  : %s (class: %s)\n",
            if (inherits(shiny_app, "shiny.appobj")) "shiny.appobj" else "<unexpected>",
            paste(class(shiny_app), collapse = "/")))
