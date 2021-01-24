source('../libraries.R')
library(waiter)

ui <- sidebarLayout(
    sidebarPanel(
        sliderInput(
            inputId = "alpha",
            label = "Alpha (strength of shielding)",
            min = 0,
            max = 20,
            value = 2,
            step = .1
        ),
        sliderInput(
            inputId = "beta",
            label="Beta (transmission rate)",
            min = 0.15,
            max = .3,
            value = .2,
            step=.005
        ),
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
    
    mainPanel(fluidPage(
        use_waiter(),
        tags$script(src = "iframeResizer.contentWindow.min.js"),
        fluidRow(htmlOutput('descText')),
        fluidRow(echarts4rOutput("p_model"))
    ))
)
