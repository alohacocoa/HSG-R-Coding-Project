# Our first shiny app - A scatterplot with a few choices
# milan.kuzmanivic@student.unisg.ch and peter.gruber@usi.ch
# 2017-04-16

# FIRST: set the working directory!
# Type ctrl-L to clear the console
rm(list = ls())
graphics.off()

# --- Setup
library(shiny)
library(ggplot2)
load("Student.RData")

ui <- fluidPage(
  sidebarLayout(
    
    # Inputs
    sidebarPanel(
      selectInput(inputId = "x", 
                  label = "X-axis:",
                  choices = c("math", "stats", "econ", "arts"), 
                  selected = "imdb_num_votes"),
      selectInput(inputId = "y", 
                  label = "Y-axis:",
                  choices = c("math", "stats", "econ", "arts"), 
                  selected = "stats"),
      selectInput(inputId = "c",
                  label = "Color by:",
                  choices = c("gender", "country"),
                  selected = "gender"),
      
      sliderInput(inputId = "s",
                  label = "Size:",
                  min = 1,max = 12,
                  step = 1,
                  value = 2),
      
      sliderInput(inputId = "a",
                   label = "Alpha:",
                   min = 0, max = 1,
                   step = 0.05,
                   value = 0.7),
      
      numericInput(inputId = "n",
                   label = "Sample size:",
                   min = 1, max = nrow(grade),
                   step = 1,
                   value = 50)
    ),
    
    # Outputs
    mainPanel(
      plotOutput(outputId = "scatterplot"),
      textOutput(outputId = "correlation")
    )
    
  )
)

server <- function(input, output) {
  output$scatterplot <- renderPlot({
    ggplot(data = grade[1:input$n,], aes_string(x = input$x, y = input$y, col = input$c)) +
      geom_point(size = input$s, alpha=input$a)
  })
  output$correlation <- renderText({
    ro <- round(cor(grade[1:input$n,input$x], grade[1:input$n,input$y]),4)
    paste0("The correlation between ", input$x, " and ", input$y, " = ", ro)
    
  })
  
  
}

# Create a Shiny app 
shinyApp(ui = ui, server = server)
