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
    load('baseline_data.RData') # Precomputed baseline data
    # Parameters list
    pars = list()
    pars['gamma'] = 1 / 10
    y0 = c('S' = 0.999, 'I' = 0.001, 'R' = 0) # Supplied by JSW
    t = 0:200 # Day index, 0 to 200
    
    observe({
        # Set user model input
        pars['alpha'] = input$alpha
        pars['beta'] = input$beta
        pars['R0'] = pars$beta / pars$gamma
        par_model = input$model
        output$p_model <- renderEcharts4r({
            # Generate SIR from user input
            SIR_shield(t, y0, shield = par_model, pars) %>%
                # Assign a "model" for grouping later
                mutate(model = paste0("Alpha: ", pars$alpha)) %>%
                # Append baseline data
                rbind.data.frame(base_line) %>%
                # Make sure baseline is on top
                arrange(desc(model)) %>%
                # Rename I to be more descriptive
                mutate("Percent Infected" = I) %>%
                group_by(model) %>%
                e_charts(time) %>% # X axis is time
                e_line(`Percent Infected`, # Percent infected line
                       legend = FALSE,
                       symbol = "none") %>%
                e_title("Infections over time", subtext = paste0("R0 = ", pars['R0'])) %>%
                # X axis labeling and themeing
                e_x_axis(
                    name = "Days since outbreak",
                    nameLocation = "middle",
                    nameTextStyle = list(fontSize = 20),
                    nameGap = 30,
                    axisLabel = list(fontSize = 14)
                ) %>%
                # Y axis labeling and themeing
                e_y_axis(
                    name = "Percent of population infected",
                    formatter = e_axis_formatter("percent", digits = 1),
                    nameLocation = "middle",
                    nameTextStyle = list(fontSize = 20),
                    nameGap = 50,
                    axisLabel = list(fontSize = 14)
                ) %>%
                e_tooltip(trigger = "axis",
                          formatter = e_tooltip_pointer_formatter("percent", digits=1)) %>%
                e_show_loading() %>% e_theme("shine") %>%
                e_legend("model",
                         padding = c(30, 0, 0, 0)) %>%
                e_hide_grid_lines()
        })
        w$show()
        
    })
    
    
})
