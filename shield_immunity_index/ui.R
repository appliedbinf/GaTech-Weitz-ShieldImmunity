ui <- fluidPage(
    tags$script(src = "iframeResizer.contentWindow.min.js"),
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
                   label = "Alpha (strength of shielding)",
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
    ),
    leafletOutput(outputId = "sii_map"),
)
