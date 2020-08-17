# See global.R for pre-load and libraries
shinyServer(function(input, output, session) {
    ## Main server functions and variables
    session$allowReconnect(TRUE) #Allow reconnects
    # INTERACTIVE WALKTHROUGH WIP
    # steps =  read.csv('introdata.csv')
    # observeEvent(input$starthelp, {
    #     if (isolate(input$sidebarmenu) %in% c('data', 'changelog', 'about')){
    #         shinyjs::runjs("$('a[data-value=expression-signatures]').click();")
    #         introjs(session, options = list(steps = steps %>% filter(tab == "expression-signatures")))
    #     }
    #     else
    #         introjs(session, options = list(steps = steps %>% filter(tab == input$sidebarmenu)))
    #     }
    # )
    
    w <-
        Waiter$new(
            id = c("descText", "p_D_byage"),
            hide_on_render = T,
            html = spin_google(),
            color = transparent(.9)
        )
    
    # main data goes here
    pars = list()
    pars['gamma'] = 1 / 10
    y0 = c('S' = 0.999, 'I' = 0.001, 'R' = 0)
    t = 0:200
    
    observe({
        pars['alpha'] = input$alpha
        pars['beta'] = input$beta
        pars['R0'] = pars$beta / pars$gamma
        par_model = input$model
        output$p_model <- renderEcharts4r({
            SIR_shield(t, y0, shield = par_model, pars) %>%
                mutate("Percent Infected" = I) %>%
                e_charts(time) %>%
                e_line(`Percent Infected`,
                       legend = FALSE,
                       symbol = "none") %>%
                e_title("Infections over time\n\n") %>%
                e_x_axis(
                    name = "Days since outbreak",
                    nameLocation = "middle",
                    nameTextStyle = list(fontSize = 20),
                    nameGap = 30,
                    axisLabel = list(fontSize = 14)
                ) %>%
                e_y_axis(
                    name = "Percent of population infected",
                    formatter = e_axis_formatter("percent", digits = 0),
                    nameLocation = "middle",
                    nameTextStyle = list(fontSize = 20),
                    nameGap = 50,
                    axisLabel = list(fontSize = 14)
                ) %>%
                e_tooltip(trigger = "axis",
                          formatter = e_tooltip_pointer_formatter("percent")) %>%
                e_show_loading() %>% e_theme("roma")
        })
        w$show()
        
    })
    
    
})
