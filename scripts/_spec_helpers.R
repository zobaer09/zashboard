# scripts/_spec_helpers.R
`%||%` <- function(a,b) if (is.null(a) || length(a) == 0) b else a

# Find spec either in the installed package or in your source tree
resolve_spec <- function(rel_path) {
  inst <- system.file(rel_path, package = "zashboard")
  if (!is.null(inst) && !identical(inst, "")) return(inst)
  normalizePath(file.path("inst", rel_path), mustWork = TRUE)
}

# Attach any "datasets" packages referenced by the spec (e.g., 'datasets')
attach_data_pkgs_from_spec <- function(spec_path) {
  sp <- yaml::read_yaml(spec_path)
  if (!is.list(sp$datasets)) return(invisible())
  pkgs <- unique(vapply(sp$datasets, function(d) d$package %||% "", character(1)))
  pkgs <- pkgs[pkgs != ""]
  for (p in pkgs) {
    if (!requireNamespace(p, quietly = TRUE)) stop("Data package '", p, "' not installed")
    if (!paste0("package:", p) %in% search()) library(p, character.only = TRUE)
  }
}

# SHIM: create a symbol named like the package that points to its namespace
# This makes code that (incorrectly) does get("datasets") succeed.
shim_package_symbols_from_spec <- function(spec_path) {
  sp <- yaml::read_yaml(spec_path)
  if (!is.list(sp$datasets)) return(invisible())
  pkgs <- unique(vapply(sp$datasets, function(d) d$package %||% "", character(1)))
  pkgs <- pkgs[pkgs != ""]
  for (p in pkgs) {
    assign(p, asNamespace(p), envir = .GlobalEnv)
  }
  invisible(pkgs)
}
