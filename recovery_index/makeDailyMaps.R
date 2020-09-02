library(dplyr)
library(ggplot2)
library(ggpubr)
library(ggrepel)
library(ggthemes)
library(jsonlite)
library(leaflet)
library(leaflet.extras)
library(lubridate)
library(mapview)
library(matlab)
library(RCurl)
library(rtweet)
library(sf)
library(withr)

getData <- function() {
  dataurl <- "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv"
  data <- read.csv( dataurl, stringsAsFactors = FALSE) %>% mutate(date = as_date(date))
  county <<- st_read("map_data/tl_2017_us_county.geojson") 
  stateline <<- st_read("map_data/tl_2017_us_state.geojson")
  pop <- read.csv("map_data/county-population.csv", stringsAsFactors = FALSE)
  cur_date <- ymd(gsub("-", "", Sys.Date())) - 1
  before_date <- ymd(cur_date) - 14
  mapdata <- data %>% filter(date == before_date) %>% mutate(fips = case_when(
     county == "New York City" ~ 99999,
     TRUE ~ as.numeric(fips)
    )) %>%
      select(c(fips, cases, deaths)) %>%
    group_by(fips) %>%
    summarize(R = sum(cases), D = sum(deaths)) %>%
    inner_join(pop, by = "fips") %>%
    mutate(Ri = round((R / pop)*100, 1)) 
  
  pal <<- colorBin("YlOrRd", bins = c(0, 1, 25, 50, 75, 99, 100))
  legendlabs <<- c("< 1", " 1-25", "25-50", "50-75", "75-99", "> 99" , "No or missing data")
}

# Create mouse-over labels
maplabs <- function(riskData) {
  riskData <- riskData %>%
    mutate(Ri = case_when(
      Ri == 100 ~ '> 99',
      Ri < 1 ~ '< 1',
      is.na(Ri) ~ 'No data',
      TRUE ~ as.character(Ri)
    ))
  labels <- paste0(
    "<strong>", paste0(riskData$NAME, ", ", riskData$stname), "</strong><br/>",
    "Recovery index: <b>",riskData$Ri, ifelse(riskData$Ri == "No data", "", " &#37;"),"</b>"
  ) %>% lapply(htmltools::HTML)
  return(labels)
}






getData()

myLabelFormat = function(..., reverse_order = FALSE){ 
  if(reverse_order){ 
    function(type = "numeric", cuts){ 
      cuts <- sort(cuts, decreasing = T)
      paste(legendlabs)
    } 
  }else{
    labelFormat(...)
  }
}

riskdt_map <- mapdata %>% mutate(Ri = Ri * 10)
riskdt_map <- county %>% left_join(riskdt_map, by = c("GEOID" = "fips"))

map <- leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  setView(lat = 37.1, lng = -95.7, zoom = 4) %>%
  addPolygons(
    data = riskdt_map,
    color = "#444444", weight = 0.2, smoothFactor = 0.1,
    opacity = 1.0, fillOpacity = 0.5,
    fillColor = ~ pal(Ri),
    highlight = highlightOptions(weight = 1),
    label = maplabs(riskdt_map)
  ) %>%
  addPolygons(
    data = stateline,
    fill = FALSE, color = "#943b29", weight = 1, smoothFactor = 0.5,
    opacity = 1.0) %>%
  addLegend(
    data = riskdt_map,
    position = "topright", pal = pal, values = ~Ri,
    title = "Recovery index (%)",
    opacity = 1,
    labFormat = function(type, cuts, p) {
      cuts <- sort(cuts, decreasing = T)
      paste0(legendlabs)
    }) 
map
