#' Read a Zashboard spec (YAML or list)
#'
#' Loads a dashboard spec from a YAML file path or accepts a pre-parsed list.
#' This is a safe loader: expressions are not evaluated; only data is read.
#'
#' @param spec Character path to a YAML file, or a list. If `NULL`, the package
#'   template is used: `system.file("templates","zashboard.yml", package = "zashboard")`.
#' @return A named list representing the spec.
#' @export
zashboard_read_spec <- function(spec = NULL) {
  # Resolve default template path if spec is NULL
  if (is.null(spec)) {
    tpl <- system.file("templates", "zashboard.yml", package = "zashboard")
    if (!nzchar(tpl) || !file.exists(tpl)) {
      stop("Template spec not found in the installed package (inst/templates/zashboard.yml).", call. = FALSE)
    }
    spec <- tpl
  }
  
  # Accept list input (already parsed)
  if (is.list(spec)) {
    return(spec)
  }
  
  # Accept file path input
  if (is.character(spec) && length(spec) == 1L) {
    if (!file.exists(spec)) stop("Spec file not found: ", spec, call. = FALSE)
    # Safe YAML read (no expression evaluation)
    if (!requireNamespace("yaml", quietly = TRUE)) {
      stop("Package 'yaml' is required but not installed.", call. = FALSE)
    }
    out <- yaml::read_yaml(spec, eval.expr = FALSE)
    if (!is.list(out)) stop("Spec must parse to a list structure.", call. = FALSE)
    return(out)
  }
  
  stop("`spec` must be NULL, a list, or a single character file path.", call. = FALSE)
}

#' Validate a Zashboard spec (light V1 checks)
#'
#' Validates the minimal V1 shape aligned with the starter template:
#' - top-level `datasets` (named list)
#' - optional `filters` (list)
#' - `charts` (list of chart configs, each with `id` and `type`)
#' - `layout` (list)
#'
#' This is intentionally light-weight for V1. Stricter schema checks can be added later.
#'
#' @param spec A list as returned by [zashboard_read_spec()].
#' @return Invisibly returns `spec` if validation passes; otherwise throws an error.
#' @export
zashboard_validate_spec <- function(spec) {
  if (!is.list(spec)) stop("`spec` must be a list; call zashboard_read_spec() first.", call. = FALSE)
  
  # Required: datasets (named list)
  if (is.null(spec$datasets) || !is.list(spec$datasets) || is.null(names(spec$datasets))) {
    stop("Spec must contain a named list 'datasets'.", call. = FALSE)
  }
  
  # Required: charts (list) with id + type per element
  if (is.null(spec$charts) || !is.list(spec$charts) || length(spec$charts) == 0) {
    stop("Spec must contain 'charts' as a non-empty list.", call. = FALSE)
  }
  for (i in seq_along(spec$charts)) {
    ch <- spec$charts[[i]]
    if (!is.list(ch) || is.null(ch$id) || is.null(ch$type)) {
      stop(sprintf("charts[[%d]] must have at least 'id' and 'type'.", i), call. = FALSE)
    }
  }
  
  # Required: layout (list)
  if (is.null(spec$layout) || !is.list(spec$layout)) {
    stop("Spec must contain 'layout' as a list.", call. = FALSE)
  }
  
  # Optional: filters (list)
  if (!is.null(spec$filters) && !is.list(spec$filters)) {
    stop("'filters' must be a list when present.", call. = FALSE)
  }
  
  invisible(spec)
}
