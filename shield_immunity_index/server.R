# Create mouse-over labels
maplabs <- function(mapdata) {
    # Create Sheild index labels, round off tails to 1/99
    mapdata <- mapdata %>%
        mutate(Si = case_when(
            Si >= 100 ~ '> 99',
            Si < 1 ~ '< 1',
            is.na(Si) ~ 'No data',
            TRUE ~ as.character(Si)
        ))
    labels <- paste0(
        "<strong>", paste0(mapdata$NAME, ", ", mapdata$stname), "</strong><br/>",
        "Shield Immunity index: <b>",mapdata$Si, ifelse(mapdata$Si == "No data", "", " &#37;"),"</b>"
    ) %>% lapply(htmltools::HTML)
    return(labels)
}



calc_sii <- function(data, alpha, model){
    if (model == "core"){
        data %>% mutate(Si = 100*1/(1+(alpha*Ri))) %>%
            mutate(Si = round(100-Si, 2))
    } else if (model == "soft"){
        data %>% mutate(Si = 100*1/(1+(alpha*Ri))**2) %>%
            mutate(Si = round(100-Si, 2))
    } else {
        limit <- 1/(1+alpha)
        data %>% mutate(Si = 100*(1-((1+alpha)*Ri)**2)/(1-Ri)**2) %>%
            mutate(Si = round(100-Si, 2))
    }
    
}

shinyServer(function(input, output, session) {
    session$allowReconnect(TRUE) #Allow reconnects

    
    output$sii_map <- renderLeaflet({
        leaflet() %>%
            addProviderTiles(providers$CartoDB.Positron) %>%
            setView(lat = 37.1, lng = -95.7, zoom = 4) 
    })
    

    updateSelectizeInput(
        session,
        "sel_county",
        choices = c("Full country" = "USA", county$label),
        selected = "",
        options = list(placeholder = 'select a county')
    )
    
    observe({

        alpha = input$alpha
        model = input$model
        # Compute DF for map
        sii.df <<- map_data %>%
                    mutate(Ri = round(((R - D)/pop * 100, 2))) %>%
                    calc_sii(., alpha, model)
        # Merge with GeoJSON
        sii.df <<- county %>% left_join(sii.df, by = c("GEOID" = "fips"))
        # Valid values are within 0-100
        sii.df <<- sii.df %>%
            mutate(Si = case_when(
                Si >= 100 ~ 100,
                Si < 1 ~ 0,
                TRUE ~ Si
            )
        )
    
    leafletProxy("sii_map", session, data = sii.df) %>%
        clearShapes() %>%
        clearControls() %>%
        # Add county Shield data
        addPolygons(
            color = "#444444", weight = 0.2, smoothFactor = 0.1,
            opacity = 1.0, fillOpacity = 0.5,
            fillColor = ~ pal(Si),
            highlight = highlightOptions(weight = 1),
            label = maplabs(sii.df)
        ) %>%
        # Overlap state borders
        addPolygons(
            data = stateline,
            fill = FALSE, color = "#943b29", weight = 1, smoothFactor = 0.5,
            opacity = 1.0) %>%
        # Add legend
        addLegend(
            data = sii.df,
            position = "topright", pal = pal, values = ~Ri,
            title = "Shield Immunity index (%)",
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
            selected_polygon <- subset(sii.df, sii.df$label==sel_label)
            leafletProxy("sii_map", session) %>%
                # Center on and zoom to county
                setView(lat = ct$ct_y, lng = ct$ct_x, zoom = zoom_lvl) %>%
                # Clear an existing highlighted poly
                clearGroup(group="highlighted_polygon") %>%
                # Add county highlight
                addPolylines(
                    stroke = TRUE,
                    weight = 8,
                    color = "red",
                    data = selected_polygon,
                    group = "highlighted_polygon"
                )
        } else ( # If full country
            leafletProxy("sii_map", session) %>%
                setView(lat = 39.8283, lng = -98.5795, zoom = zoom_lvl) %>%
                clearGroup(group="highlighted_polygon")
        ) 
    }, ignoreNULL = T, ignoreInit = T)
})
