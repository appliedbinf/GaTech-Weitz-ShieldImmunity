## Libraries and options
source('libraries.R')
# Loading data
source('data.R', local = T)
options(future.globals.maxSize = 1024*1024^2) # Allow up to 1GB of data to be passed during DE
options(shiny.reactlog = TRUE) # Turn on reactlog (ctrl+F3)
options(shiny.maxRequestSize = 30 * 1024 ^ 2) # Allow up to 30MB files to be uploaded
options(shiny.port = 4949)
# Uncomment and edit the line below for SQL-backed queries
