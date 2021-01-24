# Load libraries
source('libraries.R')

getData <- function() {
    dataurl <- "us-counties.csv"
    data <- read.csv( dataurl, stringsAsFactors = FALSE) %>% mutate(date = as_date(date))
    county <<- st_read("map_data/tl_2017_us_county.geojson") %>% 
        mutate(label = paste0(NAME, ", ", stname)) 
    stateline <<- st_read("map_data/tl_2017_us_state.geojson")
    pop <- read.csv("map_data/county-population.csv", stringsAsFactors = FALSE)
    most_recent <- data %>% arrange(desc(date)) %>% slice_head(n=1) %>% pull(date) %>% unlist()
    before_date <- ymd(most_recent) - 14
    mapdata <<- data %>% filter(date == before_date) %>% mutate(fips = case_when(
        county == "New York City" ~ 99999,
        TRUE ~ as.numeric(fips)
    )) %>%
        select(c(fips, cases, deaths)) %>%
        group_by(fips) %>%
        summarize(R = sum(cases), D = sum(deaths)) %>%
        inner_join(pop, by = "fips") %>%
        mutate(Ri = R / pop) 
    
    pal <<- colorBin("YlGnBu", bins = c(0, 1, 25, 50, 75, 99, 100))
    legendlabs <<- c("< 1", " 1-25", "25-50", "50-75", "75-99", "> 99" , "No or missing data")
    ctcounty <<- read.csv('./map_data/ctcenter.csv', row.names=1)
}


getData()
