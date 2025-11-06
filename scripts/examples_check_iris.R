if (file.exists("renv/activate.R")) source("renv/activate.R")
source("scripts/_spec_helpers.R")

spec <- resolve_spec("examples/iris/iris.yml")
attach_data_pkgs_from_spec(spec)
shim_package_symbols_from_spec(spec)

static_dir    <- zashboard::build_static(spec = spec, overwrite = TRUE)
shinylive_dir <- zashboard::build_shinylive(spec = spec, overwrite = TRUE)
quarto_dir    <- zashboard::build_quarto(spec = spec, overwrite = TRUE)

res <- data.frame(
  target = c("static_html","static_png1","static_png2",
             "shinylive_html","shinylive_json","quarto_yml","quarto_qmd"),
  path = c(
    file.path(static_dir, "index.html"),
    file.path(static_dir, "assets", "petal_len_by_species.png"),
    file.path(static_dir, "assets", "sepal_scatter.png"),
    file.path(shinylive_dir, "index.html"),
    file.path(shinylive_dir, "app.json"),
    file.path(quarto_dir, "_quarto.yml"),
    file.path(quarto_dir, "index.qmd")
  ),
  exists = FALSE
)
res$exists <- file.exists(res$path)
print(res, row.names = FALSE)
