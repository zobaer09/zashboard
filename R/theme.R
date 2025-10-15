#' Default Zashboard theme (Bootstrap 5 via bslib)
#'
#' Returns a reasonable default Bootstrap 5 theme when \pkg{bslib} is available.
#' If \pkg{bslib} is not installed, returns \code{NULL} so callers can fall back.
#'
#' @param version Bootstrap major version; default 5.
#' @param bootswatch Optional Bootswatch theme name (e.g., "cosmo"). Default \code{NULL}.
#' @param ... Passed through to \code{bslib::bs_theme()} if available (e.g., \code{primary = "#0d6efd"}).
#' @return A \code{bslib::bs_theme} object when available, otherwise \code{NULL}.
#' @export
zashboard_theme <- function(version = 5, bootswatch = NULL, ...) {
  if (!requireNamespace("bslib", quietly = TRUE)) {
    return(NULL)
  }
  bslib::bs_theme(version = version, bootswatch = bootswatch, ...)
}
