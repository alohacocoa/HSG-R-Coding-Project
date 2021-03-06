#
#    Student project in the course
#    "8,789: Programming with Advanced Computer Languages"
#
#    R script: app source code


# 1) Environment preparation -------------------------------------------------
# Clear memory
rm(list = ls())
# Set language to English
Sys.setenv(LANG = "en")
# Set WD to the path of this R script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load packages 
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
  "ggthemes",
  "tools"
)

# (or install them, if not installed already)
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {install.packages(packages[!installed_packages])}
lapply(packages, library, character.only = TRUE)
rm(list = c("packages", "installed_packages"))


# 2) Data download -----------------------------------------------------------
# Based on our examination of NAs we define the indicators we want to use, allow users to add more indicators here if they wish
# The selection is based on the "indicator_id" column
my_indicators <- c(
  unemployment_rate = "SL.UEM.TOTL.ZS",
  GDP_growth_pc = "NY.GDP.PCAP.KD.ZG",
  current_health_expenditure_as_prcnt_of_GDP = "SH.XPD.CHEX.GD.ZS",
  GINI = "SI.POV.GINI"
)

# Download the desired data from world bank
d <- wbstats::wb_data(
  indicator = my_indicators,
  start_date = 2000,
  end_date = 2020,
  country = "all" # including regional aggregated data
) %>% select(date, country, names(my_indicators))

# Join the region list into the dataset
countrylist <- wbstats::wb_countries() 
d <- merge(x = d, y = countrylist[ , c("country", "region")], by = "country", all.x=TRUE)


# 3) Prepare for UI -----------------------------------------------------------
# Making alias for the variables
listofvar <- c("GDP Growth per Capita %"="GDP_growth_pc",
               "Unemployment Rate"="unemployment_rate",
               "Health Expenditure % of GDP"="current_health_expenditure_as_prcnt_of_GDP",
               "Gini Coefficient"="GINI")

varnamesdictionary <- c("GDP_growth_pc"="GDP Growth per Capita %",
                        "unemployment_rate"="Unemployment Rate",
                        "current_health_expenditure_as_prcnt_of_GDP"="Health Expenditure % of GDP",
                        "GINI"="Gini Coefficient")

# Separate the region & country lists for display
regionlist <- unique(subset(d, region=="Aggregates")$country) # lists of regions
countryregionnames <- unique(d$country) # countries including regions
countrylist <- countryregionnames[!(countryregionnames %in% regionlist)] # specific country names

# UI Design Theme function
themeSelector <- function() {
  div(
    div(
      selectInput("shinytheme-selector", "App Theme",
                  c("default", tools::toTitleCase(shinythemes:::allThemes())),
                  selectize = FALSE
      )
    ),
    tags$script(
      "$('#shinytheme-selector')
        .on('change', function(el) {
        var allThemes = $(this).find('option').map(function() {
        if ($(this).val() === 'default')
        return 'bootstrap';
        else
        return $(this).val();
        });
        // Find the current theme
        var curTheme = el.target.value;
        if (curTheme === 'default') {
        curTheme = 'bootstrap';
        curThemePath = 'shared/bootstrap/css/bootstrap.min.css';
        } else {
        curThemePath = 'shinythemes/css/' + curTheme + '.min.css';
        }
        // Find the <link> element with that has the bootstrap.css
        var $link = $('link').filter(function() {
        var theme = $(this).attr('href');
        theme = theme.replace(/^.*\\//, '').replace(/(\\.min)?\\.css$/, '');
        return $.inArray(theme, allThemes) !== -1;
        });
        // Set it to the correct path
        $link.attr('href', curThemePath);
        });"
    )
  )
}

# ggplot design theme list
themes <- ls(name = "package:ggthemes", pattern = "^theme*")
themes_names <- tools::toTitleCase(
  gsub("_", 
       " ", 
       ls(name = "package:ggthemes", pattern = "^theme*")))
names(themes) <- themes_names

# ggplot color list
colors <- ls(name = "package:ggthemes", pattern = "^scale_color_*")
colors_names <- tools::toTitleCase(
  gsub("_", 
       " ", 
       ls(name = "package:ggthemes", pattern = "^scale_color_*")))
names(colors) <- colors_names
colors <- colors[!str_detect(colors, "gradient|continuous")] #getting rid of these because they cause errors

# ggplot graph type
types <- c("Line Plot" = "geom_line",
           "Step Plot" = "geom_step")

typesdictionary <- setNames(names(types), types)


# 4) UI ----------------------------------------------------------
myUi <- fluidPage(
  # Title 
  titlePanel(title=
               div(
                 style="overflow: auto",
                 h3("Do you know your country?", style="float: left"),
                 img(src="hsg.png", height=50, style="float: right")
               ),
             div(style="clear:both")
  ),
  
  p("This is a data visualisation application that extracts and prints World Bank statistics as line graphs. 
    You may specify your own parameters for the graph with the sidebar, 
    including data type, regions, countries, timeframe, and display theme. 
    The selected data and graph created can also be downloaded. 
    Note that data is incomplete for certain countries and certain years."),
  
  # Sidebar options
  sidebarLayout(
    # Inputs Selectors
    sidebarPanel(
      
      # Select App Themes
      themeSelector(),
      
      # Select Graph Themes
      selectInput(inputId = "theme",
                  label = "Graph Theme",
                  choices = c(themes),
                  selected = "theme_gdocs"
      ),
      
      # Select Graph Colors
      selectInput(inputId = "color",
                  label = "Graph Colors",
                  choices = c(colors),
                  selected = "scale_color_gdocs"
      ),
      
      # Select Graph Type
      radioButtons(inputId = "type",
                   label = "Graph Type",
                   choices = c(types),
                   selected = "geom_line"
      ),
      
      # Data Input (y variable) Selector
      selectInput(inputId = "y",
                  label = "Data",
                  choices = c(listofvar),
                  selected = "GDP Growth per Capita"
      ),
      
      # Data Input (country/region) Selector
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
      
      # Data Date Range (x variable) Slider
      sliderInput(inputId = "slider", 
                  label = "Date Range", 
                  min = min(d$date),
                  max = max(d$date),
                  value=c(min(d$date),max(d$date)),
                  timeFormat="%Y",
                  sep = ""
      ),
      
      # Data Download Button setup
      downloadButton("downloadData", "Download Data"),
      p("Source: World Bank", style="text-align: right; font-size: 1.2rem")
    ),
    # End of Sidebar
    
    # Main panel (Graph display) 
    # Outputs
    mainPanel(
      # Tabs
      tabsetPanel(type = "tabs",
                  tabPanel("Plot",plotOutput("myPlot"), # Display Plot
                           downloadButton("downloadPlot", 
                                          "Download Graph") # Download Graph Button setup
                  ),
                  tabPanel("Summary",
                           verbatimTextOutput("summary")
                  )),
      
    )    # end of  mainPanel
  )      # end of sidebarLayout
)        # end of fluidPage



# 5) UI Server ------------------------------------------------------------------

myServer <- function(input, output) {
  # Collect input from sidebar selectors to filter dataset
  d_filtered <- reactive({ 
    selectedc <- c(input$r, input$c)
    # Filter the data and summarise
    d %>% filter(country %in% selectedc)
  })
  
  # Set Graph Parameters with ggplot
  plotInput = function() {
    ggplot(data = d_filtered(), aes_string(x = "date", y = input$y, col = "country")) + 
      labs(x ="Year", y = varnamesdictionary[input$y]) +
      coord_cartesian(xlim=input$slider)+
      ggtitle(paste(typesdictionary[input$type], "of", varnamesdictionary[input$y])) +
      get(input$theme)() +
      get(input$color)() +
      get(input$type)(size=2)
  }
  
  # Print a summary of filtered data
  output$summary <- renderPrint({
    summary(d_filtered())
  })
  
  # Print a plot of the filtered data
  output$myPlot <- renderPlot({
    print(plotInput())
  })
  
  # Download Data Button: Download dataset as csv 
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(input$y, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(d_filtered(), file, row.names = FALSE)
    })
  
  # Download Graph Button: Download graph as png
  output$downloadPlot <- downloadHandler(
    filename = function() {
      paste(input$y, ".png", sep = "")
    },
    content = function(file) {
      ggsave(file, plot = plotInput())
    })
  
}       # end of function


# 6) Call Shiny function ----------------------------------------------------
shinyApp(ui = myUi, server = myServer)
