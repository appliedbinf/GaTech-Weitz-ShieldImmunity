source('libraries.R')

fancy_app_tab <- tabItem(
    tabName = "fancy-app",
    # h2("Create plots"),#
    tags$head(tags$style(HTML(
        "
            .dropup {display: inline-block;}
                 "
    ))),
    fluidPage(
        fluidRow(
        ),
        actionButton('insertBtn', '+ Plot data')
    )
)


# The about tab data, just a straight include of the rendered Rmd file
about <- tabItem(tabName = "about",
                fluidRow(column(
                    width = 11,
                    offset = .5,
                    includeMarkdown("README.md")
                )))

data <- tabItem(tabName = "data",
                 fluidRow(width = 12)
                 )


changelog <- tabItem(tabName = "changelog",
                     fluidPage(fluidRow(includeMarkdown("changelog.md"))))

ui <- dashboardPagePlus(
    loading_duration = 5,
    enable_preloader = F,
    skin = "black",
    dashboardHeaderPlus(
        title = "TVSig",
        enable_rightsidebar = F,
        fixed = F,
        rightSidebarIcon = "object-ungroup",
        left_menu = tagList(
        )
    ),
    dashboardSidebar(
        sidebarMenu(
            id = 'sidebarmenu',
            menuItem(
                "Data Description",
                tabName = "data",
                icon = icon("info-circle")
            ),
            menuItem(
                "Changelog",
                tabName = "changelog",
                icon = icon("exclamation-triangle")
            ),
            menuItem("About",
                     tabName = "about",
                     icon = icon("address-card"))
        )
    ),
    dashboardBody(
        tabItems(
            fancy_app_tab,
            changelog,
            about
        )

    )
)
