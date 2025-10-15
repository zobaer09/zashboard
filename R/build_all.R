#' Build all Zashboard targets at once
#'
#' Runs build_static(), build_shiny(), build_shinylive(), and build_quarto()
#' and returns their outputs in a named list.
#'
#' @param overwrite Logical; passed to the builders. Default TRUE.
#' @param render_quarto Logical; if TRUE, try to render the Quarto site
#'   (only when both the quarto R package and the Quarto CLI are available).
#'   Default FALSE to keep CRAN and CI fast.
#' @return A named list with elements described below.
#' \describe{
#'   \item{static_dir}{Path to the static HTML output directory.}
#'   \item{shinylive_dir}{Path to the Shinylive output directory.}
#'   \item{quarto_dir}{Path to the Quarto project directory.}
#'   \item{shiny_app}{A shiny.appobj returned by build_shiny().}
#' }
#' @export

build_all <- function(overwrite = TRUE, render_quarto = FALSE) {
  static_dir    <- build_static(overwrite = overwrite)
  shiny_app     <- build_shiny(launch = FALSE)
  shinylive_dir <- build_shinylive(overwrite = overwrite)
  quarto_dir    <- build_quarto(overwrite = overwrite, render = isTRUE(render_quarto))
  
  list(
    static_dir    = static_dir,
    shiny_app     = shiny_app,
    shinylive_dir = shinylive_dir,
    quarto_dir    = quarto_dir
  )
}
