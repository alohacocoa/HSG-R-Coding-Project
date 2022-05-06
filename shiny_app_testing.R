library(shiny)


# Define UI ---------------------------------------------------------------
ui <- fluidPage(
  titlePanel("titlePanel"),
  
  sidebarLayout(
    position = "right",
    
    sidebarPanel("sidebarPanel inside sidebarLayout",
                 p("paragraphs", style = "color: blue"),
                 img(src = "hsg.jpg") #img files must be in "www" folder, but file path does not include "www"
                 ),
    mainPanel("mainPanel inside sidebarLayout")
  )
)

# Define server logic -----------------------------------------------------
server <- function(input, output) {
  
}

# Run the app -------------------------------------------------------------
shinyApp(ui = ui, server = server)

  