# Getting started with shiny
# milan.kuzmanivic@student.unisg.ch and peter.gruber@usi.ch
# 2017-04-16

# FIRST: set the working directory!
# Type ctrl-L to clear the console

# Uncomment the following three lines to install the packages
# install.packages("shiny")
# install.packages("rsconnect")

library(shiny)
library(ggplot2)
#library(rsconnect)
rm(list = ls())
graphics.off()


ui <- fluidPage(
    mainPanel(
      plotOutput(outputId = "myPlot1"),
      plotOutput(outputId = "myPlot2")
    )
)

server <- function(input, output) {
  # Some fake data
  Xdata <- c(2.8, 4.5, 4.7, 5.9, 6.5, 5.8, 6.4, 6.3, 4.8, 3.3)
  Ydata <- c(6.1, 5.6, 5.5, 4.4, 3.9, 4.2, 4.3, 3.6, 5.6, 6.4)
  myData <- data.frame(Xdata,Ydata)
  output$myPlot1 <- renderPlot({
    ggplot(data = myData, aes_string(x = Xdata, y = Ydata)) +
      geom_point(size=3, color="red") + xlab("x") + ylab("y")
  })
  output$myPlot2 <- renderPlot({
    ggplot(data = myData, aes_string(x = Xdata, y = Ydata)) +
      geom_point(size=3, color="blue") + xlab("x") + ylab("y")
  })
}

# Create a Shiny app 
shinyApp(ui = ui, server = server)

