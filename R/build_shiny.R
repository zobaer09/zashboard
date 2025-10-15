#' Build a Shiny app from the spec
#'
#' Creates and returns a shiny.appobj without launching it.
#'
#' @param spec Path to a YAML file or a list already parsed; if NULL, the
#'   packaged template is used.
#' @param launch Logical; if TRUE, run the app after creation (defaults FALSE).
#' @param ... Not used currently; reserved for future extensions.
#' @return A shiny.appobj.
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
