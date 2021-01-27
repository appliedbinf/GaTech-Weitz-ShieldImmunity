ui <- fluidPage(
    tags$script(src = "iframeResizer.contentWindow.min.js"),
    # Set z-index on dropdown to always be over leaflet controls
    tags$style(type='text/css', ".selectize-dropdown, .selectize-dropdown.form-control { z-index: 99999; }"),
    fluidRow(
      # Model selection radios
        column(
            4,
            awesomeRadio(
                "model",
                "Choose the type of dynamic model to fit",
                choices = c(
                    "Conventional" = "core",
                    "Flexible" = "soft",
                    "Fixed" = "hard"
                ),
                selected = "core",
                inline = T
            )
        ),
        # Alpha slider
        column(4,
               sliderInput(
                   inputId = "alpha",
                   label = span(HTML("Strength of shielding (&alpha;)")),
                   min = 0,
                   max = 20,
                   value = 2,
                   step = .1
               )
        ),
        # County selection dropdown
        column(
            4,
            selectizeInput(
                "sel_county",
                "Select a county",
                choices = NULL
            )
        )
    ),
    fluidRow(leafletOutput(outputId = "sii_map"), style = "height:600px; padding-bottom: 25px;")
)
