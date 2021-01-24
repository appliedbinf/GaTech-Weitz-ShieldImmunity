source('../libraries.R')
library(waiter)

ui <- sidebarLayout(
    sidebarPanel(
    noUiSliderInput(
        inputId = "alpha",
	label=HTML("Strength of shielding (&alpha;)"),
        min = 0,
        max = 20,
        value = 2
    ),
	radioButtons(
        "severity",
        HTML(paste0("Low or High R", tags$sub("0"), " outbreak")),
        choiceValues = c("low", "high"), 
        choiceNames =  list(span(HTML("Low R<sub>0</sub>")), span(HTML("High R<sub>0</sub>"))),
        inline = T
    )
),

mainPanel(fluidPage(
    use_waiter(),
    tags$script(src = "iframeResizer.contentWindow.min.js"),
    fluidRow(echarts4rOutput("p_Dday"), br(), hr()),
    fluidRow(echarts4rOutput("p_Hacu_day"), br(), hr()),
    fluidRow(echarts4rOutput("p_D_byage"))
)))
