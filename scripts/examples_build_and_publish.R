if (file.exists("renv/activate.R")) source("renv/activate.R")
devtools::document(); pkgload::load_all(quiet = TRUE)

build_four <- function(spec_path, name) {
  base <- file.path(getwd(), "examples_out", name)
  dir.create(base, recursive = TRUE, showWarnings = FALSE)

  static_dir    <- zashboard::build_static   (spec_path, out_dir = file.path(base, "static"),    overwrite = TRUE)
  shinylive_dir <- zashboard::build_shinylive(spec_path, out_dir = file.path(base, "shinylive"), overwrite = TRUE)
  quarto_dir    <- zashboard::build_quarto   (spec_path, out_dir = file.path(base, "quarto"),    overwrite = TRUE, render = FALSE)
  shiny_app     <- zashboard::build_shiny    (spec_path)

  list(static_dir = static_dir, shinylive_dir = shinylive_dir,
       quarto_dir = quarto_dir, shiny_app = shiny_app)
}

b_air   <- build_four("inst/examples/airquality/airquality.yml", "airquality")
b_tg    <- build_four("inst/examples/toothgrowth/toothgrowth.yml", "toothgrowth")
b_c2    <- build_four("inst/examples/co2/co2.yml", "co2")
b_iris  <- build_four("inst/examples/iris/iris.yml", "iris")

# Render Quarto (optional now; useful if you want a little site per example)
quarto::quarto_render(b_air$quarto_dir)
quarto::quarto_render(b_tg$quarto_dir)
quarto::quarto_render(b_c2$quarto_dir)
quarto::quarto_render(b_iris$quarto_dir)

# Publish static pages under docs/
publish <- function(b, name) {
  dest <- file.path("docs", "examples", name, "static")
  dir.create(dest, recursive = TRUE, showWarnings = FALSE)
  file.copy(list.files(b$static_dir, full.names = TRUE), dest, recursive = TRUE, overwrite = TRUE)
}

publish(b_air,  "airquality")
publish(b_tg,   "toothgrowth")
publish(b_c2,   "co2")
publish(b_iris, "iris")

message("All done. Open docs/examples/<name>/static/index.html or commit & push docs/.")
