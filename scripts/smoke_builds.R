# scripts/smoke_builds.R
# Quick end-to-end smoke for zashboard build targets.

if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)

cat("=== Zashboard smoke builds ===\n")

# Static
cat("\n[1/3] static ... ")
static_dir <- try(build_static(overwrite = TRUE), silent = TRUE)
if (inherits(static_dir, "try-error")) {
  cat("FAIL\n"); print(static_dir)
} else {
  idx <- file.path(static_dir, "index.html")
  cat("OK -> ", idx, "\n", sep = "")
}

# Shinylive
cat("[2/3] shinylive ... ")
shinylive_dir <- try(build_shinylive(overwrite = TRUE), silent = TRUE)
if (inherits(shinylive_dir, "try-error")) {
  cat("FAIL\n"); print(shinylive_dir)
} else {
  idx <- file.path(shinylive_dir, "index.html")
  appjson <- file.path(shinylive_dir, "app.json")
  cat("OK -> ", idx, " & ", appjson, "\n", sep = "")
}

# Quarto (no render)
cat("[3/3] quarto (no render) ... ")
quarto_dir <- try(build_quarto(overwrite = TRUE, render = FALSE), silent = TRUE)
if (inherits(quarto_dir, "try-error")) {
  cat("FAIL\n"); print(quarto_dir)
} else {
  qy <- file.path(quarto_dir, "_quarto.yml")
  qx <- file.path(quarto_dir, "index.qmd")
  cat("OK -> ", qy, " & ", qx, "\n", sep = "")
}

# Shiny app object
cat("\nShiny app object ... ")
app <- try(build_shiny(launch = FALSE), silent = TRUE)
if (inherits(app, "try-error")) {
  cat("FAIL\n"); print(app)
} else {
  cat("OK (class: ", paste(class(app), collapse = "/"), ")\n", sep = "")
}

cat("\nDone.\n")
