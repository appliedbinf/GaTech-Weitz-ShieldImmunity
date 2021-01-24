source('libraries.R')

getData <- function() {
    dataurl <- "../recovery_index/us-counties.csv"
    data <- read.csv( dataurl, stringsAsFactors = FALSE) %>% mutate(date = as_date(date))
    # GeoJSON with county borders
    county <<- st_read("map_data/tl_2017_us_county.geojson") %>% 
        mutate(label = paste0(NAME, ", ", stname)) 
    # GeoJSON with state borders
    stateline <<- st_read("map_data/tl_2017_us_state.geojson")
    # US county populations
    pop <- read.csv("map_data/county-population.csv", stringsAsFactors = FALSE)
    # Get most recent date we have data on
    most_recent <- data %>% arrange(desc(date)) %>% slice_head(n=1) %>% pull(date) %>% unlist()
    before_date <- ymd(most_recent) - 14
    # Select data for maps
    mapdata <<- data %>% filter(date == before_date) %>% mutate(fips = case_when(
        county == "New York City" ~ 99999,
        TRUE ~ as.numeric(fips)
    )) %>%
        select(c(fips, cases, deaths)) %>%
        group_by(fips) %>%
        # R: Recovered inds, assumed non-infectious after 14 days D: Dead inds
        summarize(R = sum(cases), D = sum(deaths)) %>%
        inner_join(pop, by = "fips") %>%
        # Ri: Recovery index; recovered alive inds per FIPS region
        mutate(Ri = round((R / pop)*100, 1)) 
    
    pal <<- colorBin("YlGnBu", bins = c(0, 1, 25, 50, 75, 99, 100))
    legendlabs <<- c("< 1", " 1-25", "25-50", "50-75", "75-99", "> 99" , "No or missing data")
    # County center geocoords 
    ctcounty <<- read.csv('./map_data/ctcenter.csv', row.names=1)
}


getData()
