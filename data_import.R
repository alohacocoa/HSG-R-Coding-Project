#
#    Student project in the course
#    "Programming with advanced computer languages"
#
#    R script


# 1 - Environment preparation ------------------------------------------------------------
# Clear memory, set language to English, set WD to the path of this R script
rm(list = ls())
Sys.setenv(LANG = "en")
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load packages
# (or install them, if not installed already)
packages <- c(
  "rsdmx", #allows downloading OECD data
  "tidyr", #used in particular for drop_na()
  "dplyr", #general data manipulation
  "data.table", #used in particular for fwrite()
  "todor" #helps with code organization
) 
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {install.packages(packages[!installed_packages])}
lapply(packages, library, character.only = TRUE)




# 2 - Fetch data from OECD through rsdmx  ------------------------------------------------
#rsdmx lists OECD as a provider
#This allows downloading data through a few simple parameters

#The following code blocks fetch OECD data for
#corporate income tax, GDP per capita growth and unemployment
CITsdmx <- rsdmx::readSDMX(
  providerId = "OECD", #tells rsdmx which data provider to use
  resource = "data", #we want data (as opposed to e.g. metadata)
  flowRef = "CTS_CIT", #this gives us corporate income tax variables
  start = 2000,
  end = 2021,
  dsd = TRUE) #include variable labels

CITdf <- as.data.frame(CITsdmx, labels = TRUE) #convert the sdmx object to a df
rm(CITsdmx) #immediately delete the sdmx object to save RAM
CITbackup <- CITdf #only used for testing, will be deleted in the final code


GDPsdmx <- rsdmx::readSDMX(
  providerId = "OECD",
  resource = "data",
  flowRef = "PDB_GR",
  start = 2000,
  end = 2021,
  dsd = TRUE)

GDPdf <- as.data.frame(GDPsdmx, labels = TRUE)
rm(GDPsdmx)
GDPbackup <- GDPdf

# [TODO] try to apply some filters already here instead of later to the df to cut down on download time
EMPsdmx <- rsdmx::readSDMX(
  providerId = "OECD",
  resource = "data",
  flowRef = "LFS_SEXAGE_I_R",
  start = 2000,
  end = 2021,
  dsd = TRUE)

EMPdf <- as.data.frame(EMPsdmx, labels = TRUE)
rm(EMPsdmx)
EMPbackup <- EMPdf




# 3 - Filter for relevant data, rename columns ----------------------------
# The data from OECD contains multiple variable at once
# We filter for the ones we need 
# In the end, there is only one observation per variable per year per country
CITdf <- CITdf %>%
  filter(CORP_TAX_label.en == "Combined corporate income tax rate") %>%
  rename(country = COU_label.en, 
         year = obsTime,
         "corporate income tax rate" = obsValue) %>%
  select(country, year, "corporate income tax rate")



GDPdf <- GDPdf %>%
  filter(SUBJECT_label.en == "GDP per capita, constant prices",
         MEASURE_label.en == "Annual growth/change") %>%
  rename(country = LOCATION_label.en,
         year = obsTime,
         "GDP per capita growth" = obsValue) %>%
  select(country, year, "GDP per capita growth")


EMPdf <- EMPdf %>%
  filter(SERIES_label.en == "Unemployment rate", 
         AGE_label.en == "20 to 64",
         SEX_label.en == "All persons") %>%
  rename(country = COUNTRY_label.en, 
         year = obsTime) %>%
  mutate("employment rate" = 100-obsValue) %>%
  select(country, year, "employment rate")




# 4 - Merge into one data frame and export --------------------------------
# TODO change into one function
data <- full_join(
  CITdf,
  GDPdf,
  by=c("country", "year"))

data <- full_join(
  data,
  EMPdf,
  by=c("country", "year"))

data <- data %>% drop_na()

#save to "data" folder
dir.create('./data/')
fwrite(data, './data/shiny_data.csv')



# TODO
# add more variables
# fix date formatting (lubridate)






