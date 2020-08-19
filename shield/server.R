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
            id = c("p_Dday", "p_Hacu_day", "p_D_byage"),
            hide_on_render = T,
            html = spin_google(),
            color = transparent(.9)
        )
    
    observe({
        par_alpha = input$alpha
        par_sev = input$severity
        if (par_sev == "low") {
            source('2020-03-30_input-parameters_low.R')
            load('low.base.RData')
            t = tb
            y = yb
            stats = statsb
        } else {
            source('2020-03-30_input-parameters_high.R')
            load('high.base.RData')
            t = tb
            y = yb
            stats = statsb
        }
        w$show()
        print("User input")
        print(input$alpha)
        
        # Sims - user input
        if (par_alpha == 2) {
            if (par_sev == "low") {
                load('low.2x.RData')
            } else {
                load('high.2x.RData')
            }
        } else if (par_alpha != 1) {
            # print(input$alpha)
            pars$alpha <<- par_alpha
            print("Running usermodel")
            model_res = run_core_model()
            print("usermodel done")
            y = model_res$y
            t = model_res$t
            stats = model_res$stats
        }
        
        df_Dday = data.frame(
            'baseShield' = statsb$Dday * 100000
            ,
            'lowShield' = stats$Dday * 100000
            ,
            't' = t[-1]
        )
        colnames(df_Dday) = c('Baseline', paste0(par_alpha, ':1 Shielding'), 't')
        melt_Dday = melt(df_Dday,
                         't',
                         variable.name = 'alpha',
                         value.name = 'deaths')
        p_Dday = melt_Dday %>%
            mutate(deaths = round(deaths, 1)) %>%
            group_by(alpha) %>%
            e_charts(t) %>%
            e_line(deaths,
                   legend = T,
                   symbol = "none",
                   step = F) %>%
            e_title("Deaths per 100,000", left = "center") %>%
            e_tooltip(trigger = "axis") %>%
            e_group("sheilds") %>%
            e_x_axis(
                name = "Days since outbreak",
                nameLocation = "middle",
                nameTextStyle = list(fontSize = 20),
                nameGap = 30,
                axisLabel = list(fontSize = 14)
            ) %>%
            e_y_axis(
                name = "Number of deaths",
                # formatter = e_axis_formatter("percent", digits = 0),
                nameLocation = "middle",
                nameTextStyle = list(fontSize = 20),
                nameGap = 30,
                axisLabel = list(fontSize = 14)
            ) %>%
            e_legend("icu_beds",
                     # top = "bottom",
                     padding = c(30, 0, 0, 0)) %>%
            e_show_loading() %>% e_theme("roma")
        output$p_Dday = renderEcharts4r({
            p_Dday
        })
        
        # DF for icu beds per day
        df_Hacu_day = data.frame(
            'baseShield' = statsb$Hacu_day * 100000
            ,
            'lowShield' = stats$Hacu_day * 100000
            ,
            't' = t
        )
        colnames(df_Hacu_day) = c('Baseline', paste0(par_alpha, ':1 Shielding'), 't')
        melt_Hacu_day = melt(df_Hacu_day,
                             't',
                             variable.name = 'alpha',
                             value.name = 'icu_beds')
        p_Hacu_day = melt_Hacu_day %>%
            mutate(icu_beds = round(icu_beds)) %>%
            group_by(alpha) %>%
            e_charts(t) %>%
            e_line(icu_beds, legend = T, symbol = "none") %>%
            e_legend("icu_beds",
                     # top = "bottom",
                     padding = c(30, 0, 0, 0)) %>%
            e_title("ICU beds per 100,000", left = "center") %>%
            e_tooltip(trigger = "axis") %>%
            e_group("sheilds") %>%
            e_x_axis(
                name = "Days since outbreak",
                nameLocation = "middle",
                nameTextStyle = list(fontSize = 20),
                nameGap = 30,
                axisLabel = list(fontSize = 14)
            ) %>%
            e_y_axis(
                name = "Number of ICU beds needed",
                # formatter = e_axis_formatter("percent", digits = 0),
                nameLocation = "middle",
                nameTextStyle = list(fontSize = 20),
                nameGap = 50,
                axisLabel = list(fontSize = 14)
            ) %>%
            e_connect_group("sheilds") %>%
            e_show_loading() %>% e_theme("roma")
        
        output$p_Hacu_day = renderEcharts4r({
            p_Hacu_day
        })
        
        # DF for deaths by age
        df_D_byAge = data.frame(
            'baseShield' = statsb$D[nrow(stats$D),] * 100000
            ,
            'lowShield' = stats$D[nrow(stats$D),] * 100000
            ,
            'age' = agepars$meanage
            ,
            'agefrac' = population$agefrac
        )
        colnames(df_D_byAge) = c('Baseline',
                                 paste0(par_alpha, ':1 Shielding'),
                                 'age',
                                 'Population Structure')
        melt_D_byAge = melt(
            df_D_byAge,
            c('age', 'Population Structure'),
            variable.name = 'alpha',
            value.name = 'deaths'
        )
        temp = melt_D_byAge[melt_D_byAge$alpha == "Baseline" ,]
        temp$alpha = "Age Structure"
        temp$deaths = NA
        melt_D_byAge = rbind(melt_D_byAge, temp)
        coeff = 6 * max(melt_D_byAge$deaths) # For plotting age structure on top of deaths by age
        p_D_byage = melt_D_byAge %>%
            mutate(age_struct = coeff * `Population Structure`) %>%
            mutate(deaths = round(deaths, 1)) %>%
            group_by(alpha) %>%
            e_charts(age) %>%
            e_line(`Population Structure`,  y_index = 1) %>% 
            e_x_axis(
                name = "Age",
                nameLocation = "middle",
                nameTextStyle = list(fontSize = 20),
                nameGap = 30,
                axisLabel = list(fontSize = 14)
            ) %>%
            e_y_axis(
                name = "Number of deaths",
                # formatter = e_axis_formatter("percent", digits = 0),
                nameLocation = "middle",
                nameTextStyle = list(fontSize = 20),
                nameGap = 50,
                axisLabel = list(fontSize = 14)
            ) %>%
            e_y_axis(
                name = "Proportion of population",
                index=1,
                # formatter = e_axis_formatter("percent", digits = 0),
                nameLocation = "middle",
                nameTextStyle = list(fontSize = 20),
                nameGap = 50,
                axisLabel = list(fontSize = 14)
            ) %>%
            e_line(deaths, legend = FALSE, symbol = "none") %>%
            e_title("Cumulative Deaths per 100,000", left = "center") %>%
            e_legend("icu_beds", padding = c(40, 0, 0, 0)) %>%
            # e_tooltip(trigger = "axis", )  %>%
            e_show_loading() %>% e_theme("roma")
        
        
        p_D_byage
        output$p_D_byage = renderEcharts4r({
            p_D_byage
        })
        
    })
    
    
})
