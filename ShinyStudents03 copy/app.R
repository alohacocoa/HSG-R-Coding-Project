# Our first shiny app - A scatterplot with a few choices
# milan.kuzmanivic@student.unisg.ch and peter.gruber@usi.ch
# 2017-04-16

# FIRST: set the working directory!
# Type ctrl-L to clear the console
rm(list = ls())
Sys.setenv(LANG = "en")
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
graphics.off()

# --- Setup
packages <- c(
  "shiny",
  "ggplot2",
  "todor"
) 
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {install.packages(packages[!installed_packages])}
lapply(packages, library, character.only = TRUE) 

data <- fread('./data/shiny_data.csv')







# TODO TASKS (in this R file only)
# DATA
  # add time lag variable which lags the DV by x years
  # add correlation variable btw IV and DV
# GUI
  # add multiple choice GUI element for dependent variable selection
  # add multiple choice GUI element for country selection (maybe with text search bar)
  # add range selector GUI element for time frame selection
  # add range selection GUI element for time lag (i.e. x years)
# PLOTS
  # add plot for IV (= corporate income tax) vs. time 
  # add plot for DV vs. time
  # compute correlation btw DV and IV in time sample and display number
  # create the above three for every country selected, i.e. n of plots = n of selected countries x 2
  # compute correlation across sample of all selected countries and display it somewhere in big font
# OTHER THINGS
  # style the plots nicely
  # write text on the shiny app that explains what it does and how to use it
  # write documentation on github
# MORE THAN IS ASKED FOR
  # give different GUI layout options for the user




# display only every third year on x axis in plots (see link below)
# https://stackoverflow.com/questions/58470039/need-help-displaying-every-10th-year-on-x-axis-ggplot-graph











load("Student.RData")

ui <- fluidPage(
  sidebarLayout(
    
    # Inputs
    sidebarPanel(
      selectInput(inputId = "x", 
                  label = "X-axis:",
                  choices = colnames(grade[,3:6]), 
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
