#' Build a Shiny app
#'
#' Reads and validates a Zashboard spec and constructs a minimal Shiny app.
#' If `{bslib}` is available, a Bootstrap 5 theme is applied; otherwise
#' a base `fluidPage()` is used. The app is returned (not launched).
#'
#' @inheritParams zashboard_read_spec
#' @param title Optional title for the app window; defaults to `spec$title` or "Zashboard".
#' @param theme Optional bslib theme object. If `NULL` and `{bslib}` is installed,
#'   a default `bslib::bs_theme()` is used.
#' @param launch Logical; if `TRUE`, calls `shiny::runApp(app)`; default `FALSE`.
#' @param ... Reserved for future options.
#' @return A `shiny.appobj`. If `launch = TRUE`, the app is run and its return value is passed through.
#' @export
#' @examples
#' \donttest{
#' app <- build_shiny()  # returns a shiny.appobj
#' # shiny::runApp(app)  # (not run)
#' }
build_shiny <- function(spec = NULL, title = NULL, theme = NULL, launch = FALSE, ...) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required to build the Shiny app. Please install it.", call. = FALSE)
  }
  
  `%||%` <- function(x, y) if (is.null(x) || length(x) == 0L) y else x
  
  sp <- zashboard_read_validate(spec)
  
  # pick a title
  title <- as.character(title %||% sp$title %||% "Zashboard")
  
  # choose page constructor (use zashboard_theme() by default if available)
  if (is.null(theme)) theme <- zashboard_theme()
  page_fun <- if (!is.null(theme) && requireNamespace("bslib", quietly = TRUE)) {
    function(...) bslib::page_fluid(..., theme = theme)
  } else {
    shiny::fluidPage
  }
  
  
  # summarize charts
  items <- character(0)
  if (length(sp$charts)) {
    items <- vapply(sp$charts, function(ch) {
      id   <- as.character(ch$id   %||% "")
      type <- as.character(ch$type %||% "")
      paste0(id, " (", type, ")")
    }, character(1))
  }
  
  ui <- page_fun(
    shiny::tags$head(shiny::tags$title(title)),
    shiny::h1(title),
    shiny::p(shiny::strong("Datasets:"), length(sp$datasets %||% list()),
             shiny::HTML("&nbsp;"), shiny::strong("Charts:"), length(sp$charts %||% list())),
    if (length(items)) {
      shiny::tagList(
        shiny::h3("Charts"),
        shiny::tags$ul(lapply(items, function(x) shiny::tags$li(x)))
      )
    } else {
      shiny::p("No charts defined yet.")
    }
  )
  
  server <- function(input, output, session) {
    # placeholder for future cross-filtering wiring
    # keeps a minimal reactive, but does nothing heavy (CRAN friendly)
    shiny::observe(NULL)
  }
  
  app <- shiny::shinyApp(ui = ui, server = server)
  
  if (isTRUE(launch)) {
    return(shiny::runApp(app))
  }
  app
}
