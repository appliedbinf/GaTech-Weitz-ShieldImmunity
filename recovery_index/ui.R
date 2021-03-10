ui <- fluidPage(
    tags$script(src = "iframeResizer.contentWindow.min.js"),
    # Set z-index so that the dropdown is always over leaflet legend
    tags$style(type='text/css', ".selectize-dropdown, .selectize-dropdown.form-control { z-index: 99999; }"),
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
        ),
        column(
            4,
            p(
                "Estimates above 99% are not high confidence estimates and likely reflect errors in ascertainment biases, reporting, or both."
            )
        )
    ),
    fluidRow(leafletOutput(outputId = "ri_map", height=550), style = "height:600px; padding-bottom: 25px;")
)
