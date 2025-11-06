# Minimal Shiny app using the example CSV.
library(shiny)
library(bslib)
library(readr)
library(dplyr)

path <- system.file("examples/retail/retail.csv", package = "zashboard", mustWork = TRUE)
sales <- readr::read_csv(path, show_col_types = FALSE)
sales$date <- as.Date(sales$date)

ui <- page_fluid(
  theme = bslib::bs_theme(version = 5),
  layout_sidebar(
    sidebar = sidebar(
      selectInput("category", "Category", choices = c("All", sort(unique(sales$category))), selected = "All"),
      selectInput("region", "Region", choices = c("All", sort(unique(sales$region))), selected = "All")
    ),
    layout_columns(
      col_widths = c(6, 6),
      card(
        card_header("Sales by Category"),
        plotOutput("bar_cat", height = 320)
      ),
      card(
        card_header("Sales Over Time"),
        plotOutput("line_time", height = 320)
      )
    )
  )
)

server <- function(input, output, session){
  filtered <- reactive({
    out <- sales
    if (input$category != "All") out <- filter(out, category == input$category)
    if (input$region   != "All") out <- filter(out, region   == input$region)
    out
  })
  
  output$bar_cat <- renderPlot({
    df <- sales %>%
      group_by(category) %>% summarise(sales = sum(sales), .groups = "drop")
    par(mar = c(6, 4, 2, 1))
    barplot(df$sales, names.arg = df$category, las = 2, main = "Total Sales by Category", ylab = "Sales")
  })
  
  output$line_time <- renderPlot({
    df <- filtered() %>%
      group_by(date) %>% summarise(sales = sum(sales), .groups = "drop")
    plot(df$date, df$sales, type = "l", lwd = 2, xlab = "Date", ylab = "Sales",
         main = paste0("Sales Over Time",
                       if (input$category != "All") paste0(" — ", input$category) else "",
                       if (input$region   != "All") paste0(" / ", input$region)   else ""))
  })
}

shinyApp(ui, server)
