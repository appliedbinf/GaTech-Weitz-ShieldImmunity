source('../libraries.R')
library(waiter)

ui <- sidebarLayout(sidebarPanel(
    noUiSliderInput(
        inputId = "alpha",
	label="Alpha (strength of shielding)",
        min = 0,
        max = 20,
        value = 2
    ),
    awesomeRadio(
        "severity",
        "Low or High R0 outbreak",
        choices = c("Low R0" = "low", "High R0" = "high"),
        selected = "low",
        inline = T
    )
),

mainPanel(fluidPage(
    use_waiter(),
    tags$script(src = "iframeResizer.contentWindow.min.js"),
    fluidRow(echarts4rOutput("p_Dday")),
    fluidRow(echarts4rOutput("p_Hacu_day")),
    fluidRow(echarts4rOutput("p_D_byage"))
)))
