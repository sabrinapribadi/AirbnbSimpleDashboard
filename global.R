# --- Shiny Library --- #

library(shiny)
library(shinyWidgets)
library(shinydashboard)

# --- Library used in the dashboard --- #
library(tidyverse)
library(lubridate)
library(data.table)
library(DT)
library(knitr)
library(glue)
library(scales)
library(plotly)
library(leaflet)
library(rgdal)
library(maps)

# --- Importing Data --- #

# Airbnb Data
london_listing <- read.csv("assets/london-listings.csv") 

# London Boroughs (.json)
london_neigh <- readOGR("assets/london-neighbourhoods.geojson")


# --- Data Wrangling --- #
london_listing <- london_listing %>% 
  mutate(
    host_name = as.factor(host_name),
    neighbourhood = as.factor(neighbourhood),
    room_type = as.factor(room_type),
    last_review = ymd(last_review),
    year = year(last_review),
    month = month(last_review),
    day = day(last_review),
    yearmo = format_ISO8601(last_review, precision = "ym")
  )


# --- Data for Data Visualization --- #

# Show top-N the most listings by Room
mostlisting_type <- london_listing %>% 
  group_by(neighbourhood, room_type) %>% 
  summarize(freq_room = n(),
            avg_price_room = mean(price, na.rm = TRUE)) %>% #  number of observations within a group
  ungroup() 

mostlisting__neigh <- london_listing %>%
  filter(room_type %in% c("Private room", "Entire home/apt", "Shared room", "Hotel room")) %>% 
  group_by(neighbourhood) %>% 
  summarize(count_n4 = n(),
            avg_price_neigh = mean(price, na.rm = TRUE)) %>% 
  ungroup()

mostlisting_byroom <- merge (mostlisting_type, mostlisting__neigh, by= "neighbourhood")