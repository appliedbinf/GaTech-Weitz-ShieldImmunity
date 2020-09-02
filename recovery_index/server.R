# Create mouse-over labels
maplabs <- function(mapdata) {
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

    riskdt_map <- mapdata %>% mutate(Ri = Ri * as.numeric(input$ri_asc_bias))
    riskdt_map <- county %>% left_join(riskdt_map, by = c("GEOID" = "fips"))
    
    leafletProxy("ri_map", session, data = riskdt_map) %>%
        clearShapes() %>%
        clearControls() %>%
        addPolygons(
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
    })
    

    observeEvent(input$sel_county, {
        sel_label = input$sel_county
        county_id = "USA"
        zoom_lvl = 4
        if (sel_label != "USA"){
            county_id = county %>% 
                filter(label == sel_label) %>%
                pull(GEOID) %>% as.character
            zoom_lvl = 7
        }
        ct <- ctcounty[county_id, ]
        print(ct)
        print(county_id)
        leafletProxy("ri_map", session) %>%
            setView(lat = ct$ct_y, lng = ct$ct_x, zoom = zoom_lvl) 
    }, ignoreNULL = T, ignoreInit = T)
})
