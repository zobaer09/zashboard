#' Build all Zashboard targets
#'
#' Generates the static site, Shinylive bundle, and a Quarto project
#' from a Zashboard spec.
#'
#' @param spec Path to a YAML spec file **or** a pre-parsed list with the same
#'   structure. If `NULL`, the package template spec is used.
#' @param overwrite Logical; if `TRUE`, overwrite any existing output
#'   directories. Default `FALSE`.
#' @param render_quarto Logical; if `TRUE`, also render the Quarto project
#'   after generating it. Default `FALSE` (recommended in CI).
#' @param targets Character vector of targets to build. Valid values include
#'   `"static"`, `"shinylive"`, and `"quarto"`. Use to build a subset
#'   (e.g., `targets = c("static","quarto")`). If `NULL`, builds all.
#' @param ... Reserved for future extensions; currently unused.
#'
#' @return Invisibly, a list with elements `static_dir`, `shinylive_dir`,
#'   `quarto_dir`, and `shiny_app` (the last may be `NULL` when not built).
#' @export

build_all <- function(
    spec = NULL,
    targets = c("static","shiny","shinylive","quarto"),
    render_quarto = FALSE,
    overwrite = FALSE,
    ...
) {
  targets <- unique(match.arg(targets, several.ok = TRUE))
  out <- list()
  
  if ("static" %in% targets) {
    out$static_dir <- build_static(spec = spec, overwrite = overwrite, ...)
  }
  
  if ("shiny" %in% targets) {
    out$shiny_app <- build_shiny(spec = spec, ...)
  }
  
  if ("shinylive" %in% targets) {
    out$shinylive_dir <- build_shinylive(spec = spec, overwrite = overwrite, ...)
  }
  
  if ("quarto" %in% targets) {
    out$quarto_dir <- build_quarto(spec = spec, overwrite = overwrite, render_quarto = render_quarto, ...)
  }
  
  invisible(out)
}

