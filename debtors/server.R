#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  dat <- reactive({
    get(input$dataset, "package:datasets")
  })


  output$summary <- renderPrint({
  #  dat <- get(input$dataset, "package:datasets")
    summary(dat())
  })

  output$table <- renderTable({
    #dats <- get(input$dataset, "package:datasets")
    #dats <- as.data.frame(dats)
    #dats
    dat()
  })

})


