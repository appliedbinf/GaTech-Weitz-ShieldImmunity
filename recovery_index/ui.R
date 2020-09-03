ui <- fluidPage(
    tags$script(src = "iframeResizer.contentWindow.min.js"),
    fluidRow(
        column(
            3,
            shinyWidgets::awesomeRadio(
                "ri_asc_bias",
                "Ascertainment bias ",
                choices = c(5, 10),
                selected = 10,
                inline = T
            )
        ),
        column(
            4,
            selectizeInput(
                "sel_county",
                "Select a county",
                choices = NULL
            )
        )
        # column(2, actionButton("zoom_county", label = "Go to a county"))
    ),
    leafletOutput(outputId = "ri_map"),
)
