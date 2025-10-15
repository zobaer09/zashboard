#' Initialize a new Zashboard spec folder
#'
#' Copies the packaged template `zashboard.yml` into a new directory and
#' writes a minimal `manifest.json` derived from it. Nothing destructive:
#' the target directory must be empty unless `overwrite = TRUE`.
#'
#' @param path Directory to create/populate.
#' @param overwrite Logical; if `TRUE`, allows writing into a non-empty dir. Default `FALSE`.
#' @return Invisibly returns the normalized target directory path.
#' @export
#' @examples
#' \donttest{
#' dir_out <- zashboard_init(file.path(tempdir(), "my-zashboard"), overwrite = TRUE)
#' list.files(dir_out)
#' }
zashboard_init <- function(path, overwrite = FALSE) {
  stopifnot(is.character(path), length(path) == 1L)
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  
  # Dir checks
  if (dir.exists(path)) {
    has_files <- length(list.files(path, all.files = TRUE, no.. = TRUE)) > 0L
    if (has_files && !isTRUE(overwrite)) {
      stop("Target directory already exists and is not empty: '", path,
           "'. Use overwrite = TRUE or choose a new path.", call. = FALSE)
    }
  } else {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
  
  # Locate template (installed or dev fallback)
  tpl_dir <- system.file("templates", package = "zashboard")
  if (!nzchar(tpl_dir)) {
    maybe <- file.path(getwd(), "inst", "templates")
    if (dir.exists(maybe)) tpl_dir <- maybe
  }
  tpl <- file.path(tpl_dir, "zashboard.yml")
  if (!file.exists(tpl)) stop("Template 'zashboard.yml' not found in package.", call. = FALSE)
  
  # Copy spec
  spec_out <- file.path(path, "zashboard.yml")
  ok <- file.copy(tpl, spec_out, overwrite = TRUE)
  if (!isTRUE(ok)) stop("Failed to copy template to: ", spec_out, call. = FALSE)
  
  # Build a minimal manifest.json (no external deps)
  sp  <- zashboard_read_validate(spec_out)
  man <- zashboard_as_manifest(sp)
  
  esc_json <- function(x) {
    x <- as.character(x)
    x <- gsub("\\\\", "\\\\\\\\", x)
    x <- gsub('"', '\\"', x)
    x
  }
  charts_json <- if (length(man$charts)) {
    paste0(
      "[",
      paste0(vapply(man$charts, function(ch) {
        paste0('{"id":"', esc_json(ch$id %||% ""), '","type":"', esc_json(ch$type %||% ""), '"}')
      }, character(1)), collapse = ","),
      "]"
    )
  } else "[]"
  
  filters_json <- if (length(man$filters)) {
    paste0("[", paste0('"', esc_json(man$filters), '"', collapse = ","), "]")
  } else "[]"
  
  datasets_json <- if (length(man$datasets)) {
    paste0("[", paste0('"', esc_json(man$datasets), '"', collapse = ","), "]")
  } else "[]"
  
  manifest_json <- paste0(
    '{',
    '"spec_version":"', esc_json(man$spec_version %||% "1"), '",',
    '"datasets":', datasets_json, ',',
    '"charts":',   charts_json,   ',',
    '"filters":',  filters_json,
    '}'
  )
  
  con <- file(file.path(path, "manifest.json"), open = "wb", encoding = "UTF-8")
  on.exit(close(con), add = TRUE)
  writeLines(enc2utf8(manifest_json), con = con, useBytes = TRUE)
  
  invisible(path)
}

# tiny base-R helper (avoid rlang)
`%||%` <- function(x, y) if (is.null(x) || length(x) == 0L) y else x
