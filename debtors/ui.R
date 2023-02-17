#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(
  fluidPage(

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(

            selectInput("dataset", label = "Dataset", choices = ls("package:datasets")),


        ),

        # Show a plot of the generated distribution
        mainPanel(
            verbatimTextOutput("summary"),
            tableOutput("table")
        ),

    )
))






