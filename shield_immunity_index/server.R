# Create mouse-over labels
maplabs <- function(mapdata) {
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
    

    updateSelectizeInput(session, "sel_county", choices = c("Full country" = "USA", county$label), selected = "USA" )
    
    observe({

        alpha = input$alpha
        model = input$model
        
        sii.df <- calc_sii(mapdata, alpha, model)    
        sii.df <- county %>% left_join(sii.df, by = c("GEOID" = "fips"))
    
    leafletProxy("sii_map", session, data = sii.df) %>%
        clearShapes() %>%
        clearControls() %>%
        addPolygons(
            color = "#444444", weight = 0.2, smoothFactor = 0.1,
            opacity = 1.0, fillOpacity = 0.5,
            fillColor = ~ pal(Si),
            highlight = highlightOptions(weight = 1),
            label = maplabs(sii.df)
        ) %>%
        addPolygons(
            data = stateline,
            fill = FALSE, color = "#943b29", weight = 1, smoothFactor = 0.5,
            opacity = 1.0) %>%
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
        county_id = "USA"
        zoom_lvl = 4
        if (sel_label != "USA"){
            county_id = county %>% 
                filter(label == sel_label) %>%
                pull(GEOID) %>% as.character
            zoom_lvl = 7
        }
        ct <- ctcounty[county_id, ]
        leafletProxy("sii_map", session) %>%
            setView(lat = ct$ct_y, lng = ct$ct_x, zoom = zoom_lvl) 
    }, ignoreNULL = T, ignoreInit = T)
})
