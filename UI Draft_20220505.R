#
#    Student project in the course
#    "Programming with advanced computer languages"
#
#    R script


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
  "shiny",
  "ggplot2",
  "DT"
) 
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {install.packages(packages[!installed_packages])}
lapply(packages, library, character.only = TRUE)
rm(list = c("packages", "installed_packages"))

#Upon initial examination of the data we found that some variables had a lot of NAs
#We want and need as few NAs as possible in our data
#Therefore, before making our selection, we first examine the sum of all NAs per variable
#The code below implements this

#Looking for indicators of interest
NA_check <- rbind(
  filter(wbstats::wb_search("corporate"), str_detect(indicator, "tax")),
  filter(wbstats::wb_search("unemployment"), str_detect(indicator, "total")),
  filter(wbstats::wb_search("GDP"), str_detect(indicator, "growth"))
)

#Calculating number of missing values
n <- 1
NA_check$total_non_NA <- NA
for(i in NA_check$indicator_id){
  NA_check[n,"total_non_NA"] <- sum(
    !is.na(
      wb_data(indicator=i, start_date=2000, end_date=2022)[,i]
    )
  )
  if(n==1){
    print("Calculating sum of non-missing values for all selected variables")
    print("Writing sum to NA_check$total_NA")}
  print(paste0("Progress... ", sprintf("%.0f", n/length(NA_check$indicator_id)*100), "%"))
  if(n==length(NA_check$indicator_id))
  {print("Sums of all non-missing values have been calculated")}
  n <- n+1
}
rm(list = c("n", "i"))

#We can now look at our variable list sorted by number of non-missing values
View(arrange(NA_check, desc(total_non_NA)))

#Based on our examination of NAs above we define the indicators we want to use
#The selection is based on the "indicator_id" column
my_indicators <- c(
  unemployment_rate = "SL.UEM.TOTL.ZS",
  GDP_growth_pc = "NY.GDP.PCAP.KD.ZG"
)

#Finally we download the desired data from world bank
d <- wbstats::wb_data(
  indicator = my_indicators,
  start_date = 2000,
  end_date = 2020
) %>% select(date, country, names(my_indicators))

#Only include complete cases (countries with no NAs for all variables)
#As we set the range to 2000 - 2020, complete cases will have 21 observations
d <- d %>%
  tidyr::drop_na() %>%
  group_by(country) %>%
  mutate(n=n()) %>%
  filter(n==21) %>%
  ungroup() %>%
  select(-n)

sum(length(unique(d$country))) #We have 168 countries with complete data for 2000-2020

#Save to "data" folder
#dir.create('./data/')
#data.table::fwrite(d, './data/shiny_data.csv')
#read.csv("./data/shiny_data.csv")
library(shiny)
library(DT)
# --- User Interface (shows the plot)
myUi <- fluidPage(
  sidebarLayout(
    # Inputs
    sidebarPanel(
      h2("Do you know about your country?"),
      # p("Select your data to display"),
      sliderInput(inputId = "x", 
                  label = "Time Frame",
                  min = 2000, max = 2018,
                  value = 2010, step = 1
      ),
      selectInput(inputId = "y", 
                  label = "Data",
                  choices = c("GDP Growth" = "GDP_growth_pc", "Unemployment Rate" = "unemployment_rate"),
                  selected = "GDP Growth"
      ),
      selectInput(inputId = "c", 
                  label = "Country",
                  choices = unique(d$country),
                  selected = c("Denmark","China"),
                  multiple = TRUE
      )
      
    ),    # End of sidebarPanel
    # Outputs
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Plot", plotOutput("myPlot")),
                  tabPanel("Summary", verbatimTextOutput("summary")),
                  tabPanel("Table", tableOutput("table")))
    )    # end of  mainPanel
  )      # end of sidebarLayout
)        # end of fluidPage


# --- Server (creates the plot)
myServer <- function(input, output) {
  dselectedcountry <- reactive({
    subset(d, country == input$c)
  })
  output$table = DT::renderDataTable({
    dselectedcountry
  })
  output$myPlot <- renderPlot({
    dselectedcountry <- subset(d, country=input$c)
    ggplot(data = dselectedcountry, aes(x = date, y = input$y)) + geom_point() + xlab("Year") + ylab(input$y)
  })    # end of renderPlot
}       # end of function

# Create a Shiny app 
shinyApp(ui = myUi, server = myServer)
       
