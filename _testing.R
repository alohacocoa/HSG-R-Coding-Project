#
#    A student project in the course
#    "Programming with advanced computer languages"
#
#    R script
#    


# Environment preparation ------------------------------------------------------------

# Clear memory, set language to English, set WD to where source file is
rm(list = ls())
Sys.setenv(LANG = "en")
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


# Define list of necessary packages
packages <- c(
  "rsdmx", #OECD uses SDMX JSON, so this is package becomes necessary
  "dplyr", #general data manipulation
  "ggplot2"
) 


installed_packages <- packages %in% rownames(installed.packages())

if (any(installed_packages == FALSE)) { # Install packages not yet installed
  install.packages(packages[!installed_packages])
}

lapply(packages, library, character.only = TRUE) # Load all packages


# Fetch data from OECD through  ------------------------------------------------

#fetch data for corporate income tax variable
#rsdmx contains an integrated link with OECD's API, simplifying request
CITsdmx <- rsdmx::readSDMX(providerId = "OECD", resource = "data", flowRef = "CTS_CIT",
                 start = 2000, end = 2021,
                 dsd = TRUE)
#transform into data frame
CITdf <- as.data.frame(CITsdmx, labels = TRUE)
#apply data transformations:
CITdf <- CITdf %>%
  rename(country = COU_label.en, #rename columns for clarity
         year = obsTime,
         CIT = obsValue,
         subvariable = CORP_TAX) %>%
  filter(subvariable == "COMB_CIT_RATE") %>% #the data contains different CIT measures. we filter for "COMB_CIT_RATE"
  select(country, year, CIT) #only include relevant columns


#fetch data for annual GDP per capita growth variable
#rsdmx contains an integrated link with OECD's API, simplifying request
GDPsdmx <- rsdmx::readSDMX(providerId = "OECD", resource = "data", flowRef = "PDB_GR",
                           start = 2000, end = 2021,
                           dsd = TRUE)
#transform into data frame
GDPdf <- as.data.frame(GDPsdmx, labels = TRUE)
#apply data transformations:
GDPdf <- GDPdf %>%
  rename(country = LOCATION_label.en, #rename columns for clarity
         year = obsTime,
         GDP = obsValue,
         subvariable = SUBJECT_label.en) %>%
  filter(subvariable == "GDP per capita, constant prices",
         GDP < 10) %>% #the data contains different GDP growth measures. we filter for "GDP per capita, constant prices", the data also contains strange GDP growth rates of over 80. these are also filtered out
  select(country, year, GDP) #only include relevant columns

  
#create final data frame
data <- inner_join(CITdf, GDPdf)
data <- data %>% mutate(year == as.Date(year, format = "%Y"))


as.Date("2001", format = "%Y")

ggplot2::ggplot(filter(data, country=="Switzerland"), aes(year, GDP, group=1)) + #need to add group=1 for line plot if no categorization is present
  geom_line()



#TO DO
# add more variables
# fix date formatting (lubridate)
# add time lag
# add correlation
# display only every third year on x axis in plots https://stackoverflow.com/questions/58470039/need-help-displaying-every-10th-year-on-x-axis-ggplot-graph







