#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(bslib)
pacman::p_load(shiny, dplyr, shinydashboard, lubridate, scales, DT)



 #theme <- bs_theme(bg = "#6c757d", fg = "white", primary = "orange"),
  #theme = theme,

  my_theme = bs_theme(version = 5, bootswatch = "minty")
 # theme = my_theme
 # my_theme,


#Define UI for application that draws a histogram
# fluidPage(
#
#
#
# theme = bs_theme(version = 5, bootswatch = "minty"),
#
#     # Application title
#     titlePanel("Old Faithful Geyser Data"),
#
#     # Sidebar with a slider input for number of bins
#     sidebarLayout(
#         sidebarPanel(
#             sliderInput("bins",
#                         "Number of bins:",
#                         min = 1,
#                         max = 50,
#                         value = 30)
#         ),
#
#         # Show a plot of the generated distribution
#         mainPanel(
#             plotOutput("distPlot")
#         )
#     )
# )




ui <- navbarPage(
  title = tags$div("Čau", class = "fs-1 pe-5 me-5", style = "color:red;"),
  tabPanel("Plot"),
  sidebarLayout(
    sidebarPanel(
      "hello"
    ),
    mainPanel("cau"),

  ),

  theme = bs_theme(version = 5, bootswatch = "darkly"),
  lang = NULL
)

#   bs_theme(bg = "#6c757d", fg = "white", primary = "orange"),
#   title = "Sidebar example",
#   sidebarPanel("ahooooj", "sasasassasa"),
#   nav("Page 1", "hi"),
#   nav("Page 2", "ahoj")
# )







