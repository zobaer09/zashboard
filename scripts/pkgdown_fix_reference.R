# scripts/pkgdown_fix_reference.R
if (file.exists("renv/activate.R")) try(source("renv/activate.R"), silent = TRUE)
stopifnot(file.exists("_pkgdown.yml"))
if (!requireNamespace("yaml", quietly = TRUE)) stop("Package 'yaml' is required.")

cfg <- yaml::read_yaml("_pkgdown.yml")
if (is.null(cfg)) cfg <- list()

cfg$reference <- list(
  list(title = "Build targets",
       contents = c("build_all", "build_static", "build_shiny", "build_shinylive", "build_quarto")),
  list(title = "Spec & validation",
       contents = c("zashboard_read_spec", "zashboard_read_validate",
                    "zashboard_validate_spec", "zashboard_spec")),
  list(title = "Manifest",
       contents = c("zashboard_as_manifest", "zashboard_validate_manifest",
                    "zashboard_manifest")),
  list(title = "Data connectors",
       contents = c("zashboard_connect_duckdb", "zashboard_execute_sql",
                    "zashboard_connect_arrow", "zashboard_execute_collect",
                    "zashboard_disconnect", "zashboard_connect_mssql")),
  list(title = "Theming",
       contents = c("zashboard_theme")),
  list(title = "Scaffolding",
       contents = c("zashboard_init"))
)

yaml::write_yaml(cfg, "_pkgdown.yml")
message("Updated _pkgdown.yml reference (now includes build_all).")
