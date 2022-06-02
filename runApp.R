#
#    Student project in the course
#    "8,789: Programming with Advanced Computer Languages"
#
#    R script for running app


# Clear memory
rm(list = ls())
# Set language to English
Sys.setenv(LANG = "en")
# Set WD to the path of this R script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load packages 
packages <- "shiny"

# (or install them, if not installed already)
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {install.packages(packages[!installed_packages])}
lapply(packages, library, character.only = TRUE)
rm(list = c("packages", "installed_packages"))


# ***************************
# The code below runs the app
# ***************************
shiny::runApp("my_app")

