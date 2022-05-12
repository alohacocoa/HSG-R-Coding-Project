#
#    Student project in the course
#    "Programming with advanced computer languages"
#
#    R script


# Environment preparation -------------------------------------------------
# Clear memory, set language to English, set WD to the path of this R script
rm(list = ls())
Sys.setenv(LANG = "en")
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load packages
# (or install them, if not installed already)
packages <- c(
  "tidyr",
  "dplyr",
  "data.table",
  "wbstats",
  "stringr",
  "ggplot2",
  "shiny",
  "DT",
  "shinythemes",
  "shinyWidgets",
  "ggthemes"
)
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {install.packages(packages[!installed_packages])}
lapply(packages, library, character.only = TRUE)
rm(list = c("packages", "installed_packages"))


# Data download -----------------------------------------------------------
#Based on our examination of NAs we define the indicators we want to use
#The selection is based on the "indicator_id" column
my_indicators <- c(
  unemployment_rate = "SL.UEM.TOTL.ZS",
  GDP_growth_pc = "NY.GDP.PCAP.KD.ZG",
  current_health_expenditure_as_prcnt_of_GDP = "SH.XPD.CHEX.GD.ZS",
  GINI = "SI.POV.GINI"
  )

#We download the desired data from world bank
d <- wbstats::wb_data(
  indicator = my_indicators,
  start_date = 2000,
  end_date = 2020,
  country = "all" #including regional aggregated data
) %>% select(date, country, names(my_indicators))

countrylist <- wbstats::wb_countries()
d <- merge(x = d, y = countrylist[ , c("country", "region")], by = "country", all.x=TRUE)



# Drop NAs ----------------------------------------------------------------
#Drop countries that have less than 15 complete cases
#Complete cases meaning that there are no missing values
# d <- d %>%
#   tidyr::drop_na() %>% ## i disabled this because I need to sort out the regional numbers
#   group_by(country) %>%
#   mutate(n=n()) %>%
#   filter(n>=5) %>%
#   ungroup() %>%
#   select(-n)
# 
# sum(length(unique(d$country))) # We have 266 regional data with at least 15 complete years between 2000-2020
#the above line is no longer accurate as "drop_na()" is not active
#maybe we can also forget about dropping NAs? shouldn't cost us any points I think

regionlist <- unique(subset(d, region=="Aggregates")$country)
countries <- unique(d$country) #countries including regions
countrylist <- countries[!(countries %in% regionlist)] #specific country names

# Sidebar (user interface) ----------------------------------------------------------
myUi <- fluidPage(

  # Uniform color background
 # setBackgroundColor(
 #   color = c("Silver"),
 #   gradient = c("linear"),
 #   direction = c("bottom"),
 #   shinydashboard = FALSE
 # ), test

 #Journal theme from bootswatch
theme = shinytheme("journal"),

  titlePanel(title=
             div(
               style="overflow: auto",
               h1("Do you know your country?", style="float: left"),
               img(src="hsg.png", height=50, style="float: right")
               ),
             div(style="clear:both")
    ),
 sidebarLayout(
   # Inputs
   sidebarPanel(
     sliderInput("slider", label = "Date Range", #David: is there particular reason why put these two on one line and didn't write "inputId"? if not then that's fine
                 min = min(d$date),
                 max = max(d$date),
                 value=c(min(d$date),max(d$date)),
                 timeFormat="%Y",
                 sep = ""
     ),

     selectInput(inputId = "y",
                 label = "Data",
                 choices = c("GDP Growth" = "GDP_growth_pc",
                             "Unemployment Rate" = "unemployment_rate",
                            "Health Expenditure Ratio" = "current_health_expenditure_as_prcnt_of_GDP",
                            "Gini Index" = "GINI"),
                 selected = "GDP Growth"
     ),

     selectInput(inputId = "r",
                 label = "Regions",
                 choices = regionlist,
                 selected = "World",
                 multiple = TRUE
     ),

     selectInput(inputId = "c",
                 label = "Country",
                 choices = countrylist,
                 selected = c("China","Mexico"),
                 multiple = TRUE
     ),

     # Data Download Button
     downloadButton("downloadData", "Download Data")

   ),    # End of sidebarPanel


# Main panel (output) --------------------------------------------------
   # Outputs
   mainPanel(
     tabsetPanel(type = "tabs",
                 tabPanel("Plot",
                          plotOutput("myPlot"),
                          downloadButton("downloadPlot",
                                         "Download Graph")
                          ),
                 tabPanel("Summary",
                          verbatimTextOutput("summary")
                          )
                 ),


   )    # end of  mainPanel
 )      # end of sidebarLayout
)        # end of fluidPage



# Server ------------------------------------------------------------------

myServer <- function(input, output) {
  d_filtered <- reactive({ # David: why are curly brackets here necessary?
    selectedc <- c(input$r, input$c)
    # Filter the data and summarise
    d %>% filter(country %in% selectedc)
  })

  plotInput = function() {
  ggplot(data = d_filtered(), aes_string(x = "date", y = input$y, col = "country")) + geom_line(size=2) +
    labs(x ="Year") +
    coord_cartesian(xlim=input$slider)
  }

 # Generate a summary of the data ----
 output$summary <- renderPrint({
   summary(d_filtered())
 })

 # Generate a plot of the data ----
 output$myPlot <- renderPlot({
   print(plotInput())
  })

 # Download dataset as csv
 output$downloadData <- downloadHandler(
   filename = function() {
     paste(input$y, ".csv", sep = "")
   },
   content = function(file) {
     write.csv(d_filtered(), file, row.names = FALSE)
   })

 # Download graph as png
 output$downloadPlot <- downloadHandler(
   filename = function() {
     paste(input$y, ".png", sep = "")
   },
   content = function(file) {
     ggsave(file, plot = plotInput())
   })
}       # end of function


# Shiny function call -----------------------------------------------------
# Create a Shiny app
shinyApp(ui = myUi, server = myServer)


