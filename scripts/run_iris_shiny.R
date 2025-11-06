if (file.exists("renv/activate.R")) source("renv/activate.R")

spec <- system.file("examples/iris/iris.yml", package = "zashboard")
if (is.null(spec) || identical(spec, "")) {
  spec <- normalizePath("inst/examples/iris/iris.yml")
}

attach_data_pkgs_from_spec <- function(spec_path) {
  `%||%` <- function(a,b) if (is.null(a) || length(a) == 0) b else a
  sp <- yaml::read_yaml(spec_path)
  if (!is.list(sp$datasets)) return(invisible())
  pkgs <- unique(vapply(sp$datasets, function(d) d$package %||% "", character(1)))
  pkgs <- pkgs[pkgs != ""]
  if ("datasets" %in% pkgs && !"package:datasets" %in% search()) library(datasets)
  for (p in pkgs[pkgs != "datasets"]) {
    if (!requireNamespace(p, quietly = TRUE)) stop("Data package '", p, "' not installed")
    if (!paste0("package:", p) %in% search()) library(p, character.only = TRUE)
  }
}
attach_data_pkgs_from_spec(spec)
shim_package_symbols_from_spec(spec)

app <- zashboard::build_shiny(spec)
shiny::runApp(app)
