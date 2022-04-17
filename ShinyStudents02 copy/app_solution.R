# Our first shiny app
# A scatterplot with a few choices
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

# --- User Interface (shows the plot)
myUi <- fluidPage(
  sidebarLayout(
    # Inputs
    sidebarPanel(
      h2("Student grades"),
      p("This app helps to study correlations among student grades."),
      selectInput(inputId = "x", 
                  label = "X-axis:",
                  choices = c("arts","econ","math","stats")
      ),
      selectInput(inputId = "y", 
                  label = "Y-axis:",
                  choices = c("arts","econ","math","stats"),
                  selected = "math"
      ),
      selectInput(inputId = "c", 
                  label = "Color:",
                  choices = c("gender","country")
      ),
      selectInput(inputId = "s", 
                  label = "Shape:",
                  choices = c("gender","country")
      ),
      sliderInput(inputId = "size",
                  label = "Size",
                  min = 1, max = 10,
                  step = 1, value = 3 
      )
    ),    # End of sidebarPanel
    
    # Outputs
    mainPanel(
      plotOutput(outputId = "myPlot")
    )    # end of  mainPanel
    
  )      # end of sidebarLayout
)        # end of fluidPage

# --- Server (creates the plot)
myServer <- function(input, output) {
  output$myPlot <- renderPlot({
    ggplot(data = grade, 
           aes_string(x = input$x, y = input$y, col = input$c, shape = input$s)) +
      geom_point(size=input$size) + 
      xlim(2.5,6.5) + ylim(2.5,6.5) + coord_fixed()
  })    # end of renderPlot
}       # end of function

# Create a Shiny app 
shinyApp(ui = myUi, server = myServer)

# Now ...
# - Make the font size smaller in the title.
# - Add a copyright notice. It is OK if you use your name.
# - In selectInput for the Y-axis use the option
#   selected = "math" 
#   to create a more realistic default plot. 
#   Hint: don't forget the comma!
# - Add an option to select a variable for the shape
