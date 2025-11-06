# Shiny demo using only built-in data: datasets::mtcars
# No CSVs. No external deps beyond shiny + bslib.

library(shiny)
library(bslib)

dat <- datasets::mtcars
dat$cyl  <- factor(dat$cyl)         # nicer labels
dat$gear <- factor(dat$gear)

ui <- page_fluid(
  theme = bs_theme(version = 5),
  title = "mtcars demo (built-in data)",
  layout_sidebar(
    sidebar = sidebar(
      selectInput("cyl",  "Cylinders", choices = c("All", levels(dat$cyl)), selected = "All"),
      selectInput("gear", "Gears",     choices = c("All", levels(dat$gear)), selected = "All")
    ),
    layout_columns(
      col_widths = c(6, 6),
      card(
        card_header("Average MPG by Cylinders"),
        plotOutput("bar_mpg_cyl", height = 320)
      ),
      card(
        card_header("HP vs MPG (filtered)"),
        plotOutput("scatter_hp_mpg", height = 320)
      )
    )
  )
)

server <- function(input, output, session){
  
  filtered <- reactive({
    x <- dat
    if (input$cyl  != "All") x <- x[x$cyl  == input$cyl, ]
    if (input$gear != "All") x <- x[x$gear == input$gear, ]
    x
  })
  
  output$bar_mpg_cyl <- renderPlot({
    # compute mean mpg by cyl on full data (so bars are stable while you filter scatter)
    means <- tapply(dat$mpg, dat$cyl, mean)
    par(mar = c(5, 4, 2, 1))
    barplot(means, ylab = "Average MPG", xlab = "Cylinders", main = "Average MPG by Cylinders")
  })
  
  output$scatter_hp_mpg <- renderPlot({
    x <- filtered()
    par(mar = c(5, 4, 2, 1))
    plot(x$hp, x$mpg,
         xlab = "Horsepower (hp)",
         ylab = "Miles per gallon (mpg)",
         main = paste(
           "HP vs MPG",
           if (input$cyl  != "All") paste0(" — cyl=", input$cyl)  else "",
           if (input$gear != "All") paste0(" / gear=", input$gear) else ""
         ),
         pch = 19, cex = 1.2)
    grid()
  })
}

shinyApp(ui, server)
