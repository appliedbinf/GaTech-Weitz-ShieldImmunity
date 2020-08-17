source('../libraries.R')
library(waiter)

ui <- sidebarLayout(
    sidebarPanel(
        noUiSliderInput(
            inputId = "alpha",
            min = 1,
            max = 20,
            value = 2
        ),
        noUiSliderInput(
            inputId = "beta",
            min = 0.15,
            max = .3,
            value = 2
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
        fluidRow(htmlOutput('descText')),
        fluidRow(echarts4rOutput("p_model"))
    ))
)