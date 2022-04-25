#
#    Student project in the course
#    "Programming with advanced computer languages"
#
#    shiny app



# 1 - Environment preparation ---------------------------------------------
rm(list = ls())
Sys.setenv(LANG = "en")
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
graphics.off()

# Load packages
# (or install them, if not installed already)
packages <- c(
  "shiny",
  "ggplot2",
  "data.table",
  "todor" #helps with code organization
) 
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {install.packages(packages[!installed_packages])}
lapply(packages, library, character.only = TRUE)




# 2 - Data import ---------------------------------------------------------
data <- fread('./data/shiny_data.csv')



# TODO
# DATA
#   more variables
#   correlation
#   lag DV
# GUI
#   gui for DV
#   gui for country selection (incl. search), also on world map
#   gui for time frame
#   gui for time lag
#   gui for resetting filters
# OUTPUT
#   plot for IV vs time for each country
#   plot for DV vs time for each country
#   IV DV correlation for each country
#   IV DV correlation across all selected countries
# PLOT STYLING
#   make the plots pretty
# DOCUMENTATION
#   github
#   code cleanup
# FANCY THINGS
#   alternative gui options
#   dynamic web design and other fancy stuff









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
