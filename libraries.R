suppressPackageStartupMessages({
    library(shiny) # Required for Shiny apps
    library(shinydashboard) # Shiny dashboard base components
    library(shinydashboardPlus) # Extension to shinydash
    library(dashboardthemes) # Themes
    library(shinyjqui) # Add jquery and R-to-jquery functions
    library(shinyjs) # Javascripting of Shiny components
    # library(shinypop) # Popup notifcations
    library(ggplot2) # Plotting
    library(plotly) # Heatmaps
    library(DBI) # Database connections
    library(RSQLite) # RSQlite backend
    library("future.callr")
    plan(future.callr::callr)
    library(promises)
    library(tibble) # Data manipulation
    library(plyr) # Data manipulation
    library(stringr) # Data manipulation
    library(data.table) # Data manipulation
    library(tidyr) # Data manipulation
    library(dplyr) # Data manipulation
    library(textshape) # Data manipulation
    library(DT) # Data manipulation
    library(forcats) # Data manipulation
    library(jsonlite)  # Data manipulation
    library(reticulate) # Do silly things with python and SQL
    library(shinyWidgets) # Prettier inputs for shinyapps
    library(waiter) # splash screens
    library(rintrojs)
    library(echarts4r.suite)
    library(deSolve)
    library(reshape2)
    library(cowplot)
})
