library(shiny)
library(DT)
library(colourpicker)
library(shinythemes)
library(bslib)
library(tidyverse)
library(shinyWidgets)
library(dplyr)
library(rAmCharts)
library(leaflet)
library(plotly)
library(rnaturalearth)
library(caret)
library(pROC)


heart = read_csv("www/data/heart.csv")
variables = read_csv("www/data/variables_explicatives.csv")

dr = read_csv("www/data/death-rate-from-cardiovascular-disease-age-standardized-ghe.csv") |> 
  rename(country = Entity,
         iso_code = Code,
         year = Year,
         rate = `Age-standardized death rate from cardiovascular diseases among both sexes`
         
  )



