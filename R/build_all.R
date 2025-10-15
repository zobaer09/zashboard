#' Build all Zashboard targets at once
#'
#' Runs \code{build_static()}, \code{build_shiny()}, \code{build_shinylive()},
#' and \code{build_quarto()} and returns their outputs in a named list.
#'
#' @param overwrite Logical; pass to builders to allow reusing their default dirs.
#' @param render_quarto Logical; if \code{TRUE}, try to render the Quarto site
#'   (will only render when both {quarto} R pkg and Quarto CLI are available).
#'   Default \code{FALSE} to keep CRAN and CI fast.
#' @return A named list with elements:
#'   \itemize{
#'     \item{\code{static_dir}}{ Path to static HTML output directory.}
#'     \item{\code{shinylive_dir}}{ Path to Shinylive output directory.}
#'     \item{\code{quarto_dir}}{ Path to Quarto project directory.}
#'     \item{\code{shiny_app}}{ A \code{shiny.appobj}.}
#'   }
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
