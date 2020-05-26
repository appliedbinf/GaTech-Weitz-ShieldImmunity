# See global.R for pre-load and libraries
shinyServer(function(input, output, session) {
    ## Main server functions and variables
    session$allowReconnect(TRUE) #Allow reconnects
    # INTERACTIVE WALKTHROUGH WIP
    steps =  read.csv('introdata.csv')
    observeEvent(input$starthelp, {
        if (isolate(input$sidebarmenu) %in% c('data', 'changelog', 'about')){
            shinyjs::runjs("$('a[data-value=expression-signatures]').click();")
            introjs(session, options = list(steps = steps %>% filter(tab == "expression-signatures")))
        }
        else
            introjs(session, options = list(steps = steps %>% filter(tab == input$sidebarmenu)))
        }
    )

    # Reactive UI components for the gene and signaure tab
    # source('tab1.R', local = T)

})
