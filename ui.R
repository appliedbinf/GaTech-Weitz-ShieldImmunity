source('libraries.R')
library(waiter)
# fancy_app_tab <- tabItem(
#     tabName = "model",
#     sidebarLayout(
#         
#         sidebarPanel(
#             noUiSliderInput(
#                 inputId = "alpha",
#                 min = 0, max = 5,
#                 value = 2
#             ),
#             awesomeRadio("severity", "Low or High severity outbreak", choices = c("low", "high"), selected = "low", inline = T)
#         ),
#         
#         mainPanel(
#             fluidPage(
#                 fluidRow(echarts4rOutput("p_Dday")),
#                 fluidRow(echarts4rOutput("p_Hacu_day")),
#                 fluidRow(echarts4rOutput("p_D_byage"))
#             )
#         )
#     )
# )


# The about tab data, just a straight include of the rendered Rmd file
# about <- tabItem(tabName = "about",
#                 fluidRow(column(
#                     width = 11,
#                     offset = .5,
#                     includeMarkdown("README.md")
#                 )))
# 
# data <- tabItem(tabName = "data",
#                  fluidRow(width = 12)
#                  )
# 
# 
# changelog <- tabItem(tabName = "changelog",
#                      fluidPage(fluidRow(includeMarkdown("changelog.md"))))

# ui <- dashboardPagePlus(
#     loading_duration = 5,
#     enable_preloader = F,
#     skin = "black",
#     dashboardHeaderPlus(
#         title = "Shields",
#         enable_rightsidebar = F,
#         fixed = F,
#         rightSidebarIcon = "object-ungroup",
#         left_menu = NULL
#     ),
#     dashboardSidebar(
#         sidebarMenu(
#             id = 'sidebarmenu',
#             menuItem("Sheilds", tabName="model")
#             # menuItem(
#             #     "Data Description",
#             #     tabName = "data",
#             #     icon = icon("info-circle")
#             # ),
#             # menuItem(
#             #     "Changelog",
#             #     tabName = "changelog",
#             #     icon = icon("exclamation-triangle")
#             # ),
#             # menuItem("About",
#             #          tabName = "about",
#             #          icon = icon("address-card"))
#         )
#     ),
#     dashboardBody(
#         tabItems(
#             fancy_app_tab
#             # changelog,
#             # about
#         )
# 
#     )
# )

ui <- sidebarLayout(

    sidebarPanel(
        noUiSliderInput(
            inputId = "alpha",
            min = 0, max = 5,
            value = 2
        ),
        awesomeRadio("severity", "Low or High severity outbreak", choices = c("low", "high"), selected = "low", inline = T)
    ),
    
    mainPanel(
        fluidPage(
            use_waiter(),
            # waiter_on_busy(),
            fluidRow(echarts4rOutput("p_Dday")),
            fluidRow(echarts4rOutput("p_Hacu_day")),
            fluidRow(echarts4rOutput("p_D_byage"))
        )
    )
)