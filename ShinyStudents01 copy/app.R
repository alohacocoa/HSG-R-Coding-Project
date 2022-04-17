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

# --- User Interface (shows the plot)
myUi <- fluidPage(
  sidebarLayout(
    
    # Inputs
    sidebarPanel(
      h1("Student grades"),
      p("This app helps to study correlations among student grades."),
      selectInput(inputId = "xChoice", 
                  label = "Variable on the X-axis:",
                  choices = c("arts","econ","math","stats")
      ),
      selectInput(inputId = "yChoice", 
                  label = "Variable on the Y-axis:",
                  choices = c("arts","econ","math","stats")
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
           aes_string(x = input$xChoice, y = input$yChoice)) +
           geom_point() + 
           xlim(2.5,6.5) + ylim(2.5,6.5) + coord_fixed()
  })    # end of renderPlot
}       # end of function

# Create a Shiny app 
shinyApp(ui = myUi, server = myServer)
