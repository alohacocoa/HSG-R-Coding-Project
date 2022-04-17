######################################################
#
#    A student project in the course
#    "Programming with advanced computer languages"
#
#    R script
#    
######################################################


# Environment preparation ------------------------------------------------------------

# Clear memory, set language to English, set WD to where source file is
rm(list = ls())
Sys.setenv(LANG = "en")
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


# Define list of necessary packages
packages <- c(
  "httr", #used for API access
  "jsonlite" #JSON parser, used for API data
) 


installed_packages <- packages %in% rownames(installed.packages())

if (any(installed_packages == FALSE)) { # Install packages not yet installed
  install.packages(packages[!installed_packages])
}

lapply(packages, library, character.only = TRUE) # Load all packages


# Fetch data from OECD API ------------------------------------------------

url <- 
data <-  httr::GET("https://stats.oecd.org/sdmx-json/data/QNA/AUS+AUT.GDP+B1_GE.CUR+VOBARSA.Q/all?startTime=2009-Q2&endTime=2011-Q4")


read.csv()















