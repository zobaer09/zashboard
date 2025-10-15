#' Construct a normalized manifest from a spec
#'
#' Creates a small, predictable structure from a Zashboard spec with the
#' minimum fields we care about in v1. This does not modify the spec on disk.
#'
#' @inheritParams zashboard_read_spec
#' @return A list with fields: `spec_version`, `datasets`, `charts`, `filters`, `layout`.
#' @export
zashboard_as_manifest <- function(spec = NULL) {
  sp <- zashboard_read_validate(spec)
  
  # Normalize datasets to a character vector of names
  datasets <- names(sp$datasets) %||% character()
  
  # Normalize charts to list(id, type) per chart
  charts <- lapply(sp$charts, function(ch) {
    list(
      id   = as.character(ch$id %||% NA_character_),
      type = as.character(ch$type %||% NA_character_)
    )
  })
  
  # Filters are optional; keep only the names if present
  filters <- if (!is.null(sp$filters)) names(sp$filters) else character()
  
  list(
    spec_version = "1",
    datasets     = unname(datasets),
    charts       = charts,
    filters      = unname(filters),
    layout       = sp$layout
  )
}

#' Validate a manifest (light schema checks)
#'
#' Ensures the manifest shape is compatible with v1 expectations.
#' - `datasets`: character vector (unique)
#' - `charts`: non-empty list, each item has scalar `id` and `type` strings; `id`s unique
#' - `filters`: character vector when present
#' - `layout`: a list
#'
#' @param manifest A list like the result of [zashboard_as_manifest()].
#' @return Invisibly returns `manifest` if valid; otherwise throws an error.
#' @export
zashboard_validate_manifest <- function(manifest) {
  errs <- character()
  
  add_err <- function(...) { errs <<- c(errs, paste0(...)) }
  
  if (!is.list(manifest)) add_err("manifest must be a list")
  
  # datasets
  if (is.null(manifest$datasets)) {
    add_err("datasets is required")
  } else {
    ds <- manifest$datasets
    if (!is.character(ds)) add_err("datasets must be a character vector of names")
    if (length(ds) && anyDuplicated(ds)) add_err("datasets contain duplicated names: ", paste(unique(ds[duplicated(ds)]), collapse = ", "))
  }
  
  # charts
  ch <- manifest$charts
  if (is.null(ch) || !is.list(ch) || length(ch) == 0L) {
    add_err("charts must be a non-empty list")
  } else {
    # every chart must have scalar id and type
    ids <- character()
    for (i in seq_along(ch)) {
      x <- ch[[i]]
      if (!is.list(x)) { add_err("charts[[", i, "]] must be a list"); next }
      if (is.null(x$id)  || length(x$id)  != 1L || !is.character(x$id)  || !nzchar(x$id))  add_err("charts[[", i, "]] must have a non-empty character 'id'")
      if (is.null(x$type)|| length(x$type)!= 1L || !is.character(x$type)|| !nzchar(x$type)) add_err("charts[[", i, "]] must have a non-empty character 'type'")
      ids <- c(ids, as.character(x$id %||% ""))
    }
    if (length(ids) && anyDuplicated(ids)) {
      add_err("chart id(s) duplicated: ", paste(unique(ids[duplicated(ids)]), collapse = ", "))
    }
  }
  
  # layout
  if (is.null(manifest$layout) || !is.list(manifest$layout)) add_err("layout must be a list")
  
  # filters (optional)
  if (!is.null(manifest$filters) && !is.character(manifest$filters)) add_err("filters must be a character vector when present")
  
  if (length(errs)) {
    zashboard_abort(errs, "Manifest validation failed")
  }
  invisible(manifest)
}

#' Read → manifest → validate
#'
#' Convenience wrapper that reads a spec, converts to a manifest, validates it,
#' and returns the manifest.
#'
#' @inheritParams zashboard_read_spec
#' @return The validated manifest (list).
#' @export
zashboard_manifest <- function(spec = NULL) {
  man <- zashboard_as_manifest(spec)
  zashboard_validate_manifest(man)
}

# ---- internal formatting helper ---------------------------------------------

#' Format a vector of error messages
#' @param errs character vector
#' @keywords internal
zashboard_format_errors <- function(errs) {
  errs <- unique(as.character(errs))
  paste0(
    "Manifest validation failed:\n",
    paste0(" - ", errs, collapse = "\n")
  )
}

# tiny base-R helper (avoid rlang): x %||% y
`%||%` <- function(x, y) if (is.null(x) || length(x) == 0L) y else x
