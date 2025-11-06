spec <- "inst/examples/iris/iris.yml"
base <- file.path(getwd(), "examples_out", "iris")
dir.create(base, recursive = TRUE, showWarnings = FALSE)

static_dir    <- zashboard::build_static(spec,    out_dir = file.path(base, "static"),    overwrite = TRUE)
shinylive_dir <- zashboard::build_shinylive(spec, out_dir = file.path(base, "shinylive"), overwrite = TRUE)
quarto_dir    <- zashboard::build_quarto(spec,    out_dir = file.path(base, "quarto"),    overwrite = TRUE)

if (nzchar(quarto::quarto_path())) try(quarto::quarto_render(quarto_dir), silent = TRUE)

cat("\nSTATIC    :", static_dir,
    "\nSHINYLIVE :", shinylive_dir,
    "\nQUARTO    :", quarto_dir, "\n")

browseURL(file.path(static_dir, "index.html"))
browseURL(file.path(shinylive_dir, "index.html"))
browseURL(file.path(quarto_dir, "_site", "index.html"))
