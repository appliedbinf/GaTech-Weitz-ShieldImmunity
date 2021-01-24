# Create mouse-over labels
maplabs <- function(mapdata) {
    # Create Recovery index labels, round off tails to 1/99
    mapdata <- mapdata %>%
        mutate(Ri = case_when(
            Ri >= 100 ~ '> 99',
            Ri < 1 ~ '< 1',
            is.na(Ri) ~ 'No data',
            TRUE ~ as.character(Ri)
        ))
    labels <- paste0(
        "<strong>", paste0(mapdata$NAME, ", ", mapdata$stname), "</strong><br/>",
        "Recovery index: <b>",mapdata$Ri, ifelse(mapdata$Ri == "No data", "", " &#37;"),"</b>"
    ) %>% lapply(htmltools::HTML)
    return(labels)
}


shinyServer(function(input, output, session) {
    session$allowReconnect(TRUE) #Allow reconnects


    output$ri_map <- renderLeaflet({
        leaflet() %>%
            addProviderTiles(providers$CartoDB.Positron) %>%
            setView(lat = 37.1, lng = -95.7, zoom = 4) 
    })
    

    updateSelectizeInput(session, "sel_county", choices = c("Full country" = "USA", county$label), selected = "USA" )
    
    observeEvent(input$ri_asc_bias, {
    # Compute recooery index and join with GeoJSON
    riskdt_map <<- mapdata %>% mutate(Ri = Ri * as.numeric(input$ri_asc_bias))
    riskdt_map <<- county %>% left_join(riskdt_map, by = c("GEOID" = "fips"))
    
    leafletProxy("ri_map", session, data = riskdt_map) %>%
        clearShapes() %>%
        clearControls() %>%
        # Add county Recovery data
        addPolygons(
            color = "#444444", weight = 0.2, smoothFactor = 0.1,
            opacity = 1.0, fillOpacity = 0.5,
            fillColor = ~ pal(Ri),
            highlight = highlightOptions(weight = 1),
            label = maplabs(riskdt_map)
        ) %>%
        # Overlap state borders
        addPolygons(
            data = stateline,
            fill = FALSE, color = "#943b29", weight = 1, smoothFactor = 0.5,
            opacity = 1.0) %>%
        # Add legend
        addLegend(
            data = riskdt_map,
            position = "topright", pal = pal, values = ~Ri,
            title = "Recovery index (%)",
            opacity = 1,
            labFormat = function(type, cuts, p) {
                cuts <- sort(cuts, decreasing = T)
                paste0(legendlabs)
            }) 
    })
    

    observeEvent(input$sel_county, {
        sel_label = input$sel_county
        # USA / zoom level 4 are defaults
        county_id = "USA"
        zoom_lvl = 4
        if (sel_label != "USA"){
            # county_id is FIPS id for county
            county_id = county %>% 
                filter(label == sel_label) %>%
                pull(GEOID) %>% as.character
            zoom_lvl = 7
            # Get lat/long for center of county 
            ct <- ctcounty[county_id, ]
            # Select the county polygon for highlight
            selected_polygon <- subset(riskdt_map, riskdt_map$label==sel_label)
            leafletProxy("ri_map", session) %>%
                setView(lat = ct$ct_y, lng = ct$ct_x, zoom = zoom_lvl) %>%
                clearGroup(group="highlighted_polygon") %>%
                # Add county highlight
                addPolylines(
                    stroke = TRUE,
                    weight = 8,
                    color = "red",
                    data = selected_polygon,
                    group = "highlighted_polygon"
                )
        } else (
            leafletProxy("ri_map", session) %>%
                setView(lat = 39.8283, lng = -98.5795, zoom = zoom_lvl) %>%
                clearGroup(group="highlighted_polygon")
        )

            
    }, ignoreNULL = T, ignoreInit = T)
})
