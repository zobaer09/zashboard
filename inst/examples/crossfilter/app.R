# inst/examples/crossfilter/app.R
# Tiny Shiny cross-filter demo (mtcars + brush-linked summary).

library(shiny)
library(bslib)

kpi_card <- function(title, value) {
  div(
    style = "border-radius:14px;border:1px solid #e5e7eb;background:#ffffff;padding:14px;margin-bottom:10px;box-shadow:0 1px 2px rgba(0,0,0,.05);",
    div(style="font-size:12px;color:#6b7280;margin-bottom:4px;", title),
    div(style="font-size:22px;font-weight:700;", value)
  )
}

ui <- fluidPage(
  theme = bs_theme(bootswatch = "cosmo"),
  titlePanel("Zashboard cross-filter (mtcars)"),
  fluidRow(
    column(
      width = 3,
      wellPanel(
        helpText("Brush points on the scatter; KPIs and bar chart update on the brushed subset (falling back to the current filters if nothing is brushed)."),
        checkboxGroupInput(
          "cyl", "Cylinders", choices = sort(unique(mtcars$cyl)),
          selected = sort(unique(mtcars$cyl))
        ),
        sliderInput(
          "hp", "Horsepower range", min(mtcars$hp), max(mtcars$hp),
          value = range(mtcars$hp), step = 5
        )
      ),
      # KPI cards (update reactively)
      uiOutput("kpis")
    ),
    column(
      width = 9,
      tabsetPanel(
        type = "pills",
        tabPanel("Scatter", plotOutput("scatter", height = 320, brush = "brush")),
        tabPanel("Summary", plotOutput("bars", height = 320)),
        tabPanel("Rows", tableOutput("rows"))
      )
    )
  )
)

server <- function(input, output, session) {
  # Filtered by side controls
  filtered <- reactive({
    req(input$cyl, input$hp)
    subset(mtcars, cyl %in% input$cyl & hp >= input$hp[1] & hp <= input$hp[2])
  })
  
  output$scatter <- renderPlot({
    df <- filtered()
    op <- par(mar = c(4, 4, 1, 1)); on.exit(par(op), add = TRUE)
    plot(df$wt, df$mpg, pch = 19, cex = 1.1,
         xlab = "Weight (1000 lbs)", ylab = "MPG")
    grid()
  })
  
  # Selected = brushed points if present, else current filtered()
  selected <- reactive({
    df <- filtered()
    br <- input$brush
    if (!is.null(br)) {
      brushedPoints(df, br, xvar = "wt", yvar = "mpg")
    } else {
      df
    }
  })
  
  # KPI cards from selected subset
  output$kpis <- renderUI({
    df <- selected()
    n <- nrow(df)
    avg_mpg <- if (n) round(mean(df$mpg), 1) else NA
    avg_hp  <- if (n) round(mean(df$hp), 0) else NA
    
    tagList(
      kpi_card("Rows selected", if (n) format(n, big.mark = ",") else "0"),
      kpi_card("Avg MPG (selected)", if (!is.na(avg_mpg)) avg_mpg else "—"),
      kpi_card("Avg HP (selected)",  if (!is.na(avg_hp))  avg_hp  else "—")
    )
  })
  
  # Mean MPG by cylinders on selected subset
  output$bars <- renderPlot({
    df <- selected()
    op <- par(mar = c(4, 4, 1, 1)); on.exit(par(op), add = TRUE)
    if (!nrow(df)) { plot.new(); text(0.5, 0.5, "No rows selected", cex = 1.2); return() }
    m <- tapply(df$mpg, df$cyl, mean)
    barplot(m, xlab = "Cylinders", ylab = "Mean MPG")
    grid()
  })
  
  # Show top selected rows for transparency
  output$rows <- renderTable({
    head(selected()[, c("mpg", "cyl", "hp", "wt")], 10)
  }, striped = TRUE, bordered = TRUE, hover = TRUE)
}

shinyApp(ui, server)