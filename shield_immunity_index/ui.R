ui <- fluidPage(
    tags$script(src = "iframeResizer.contentWindow.min.js"),
    fluidRow(leafletOutput(outputId = "sii_map")),
    fluidRow(
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
