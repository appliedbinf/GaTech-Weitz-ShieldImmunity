ui <- fluidPage(
    tags$script(src = "iframeResizer.contentWindow.min.js"),
    fluidRow(leafletOutput(outputId = "ri_map")),
    fluidRow(
        column(
            3,
            shinyWidgets::awesomeRadio(
                "ri_asc_bias",
                "Ascertainment bias ",
                choices = c(3, 5),
                selected = 3,
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
    )
)
