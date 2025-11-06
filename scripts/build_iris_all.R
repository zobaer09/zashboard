if (file.exists("renv/activate.R")) source("renv/activate.R")
devtools::document(); devtools::install(quiet = TRUE)

source("scripts/_spec_helpers.R")

spec <- resolve_spec("examples/iris/iris.yml")

# Make both attachment and shim available (covers both code paths)
attach_data_pkgs_from_spec(spec)
shim_package_symbols_from_spec(spec)

static_dir    <- zashboard::build_static(spec = spec, overwrite = TRUE)
shinylive_dir <- zashboard::build_shinylive(spec = spec, overwrite = TRUE)
quarto_dir    <- zashboard::build_quarto(spec = spec, overwrite = TRUE)
shiny_app     <- zashboard::build_shiny(spec = spec)

cat("\n=== iris build outputs ===\n",
    "static   : ", static_dir,    "\n",
    "shinylive: ", shinylive_dir, "\n",
    "quarto   : ", quarto_dir,    "\n",
    "shiny    : shiny.appobj\n",  sep = "")
