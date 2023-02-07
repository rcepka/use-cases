#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(

          fluidRow(
            sliderInput("mydate", "Date range input",
                        min = as.Date("2020-09-16", "%Y-%m-%d"),
                        max = as.Date("2020-09-23", "%Y-%m-%d"),
                        value = as.Date("2020-09-17", "%Y-%m-%d"),
                        timeFormat="%Y-%m-%d"
                        )
          ),


          fluidRow(
            actionButton("click", "Click me!", class = "btn-danger"),
            actionButton("drink", "Drink me!", class = "btn-lg btn-success")
          ),
          tags$br(),
          fluidRow(
            actionButton("eat", "Eat me!", class = "btn-block")
          ),

          tags$br(),



          checkboxInput("smooth", "Smooth"),
          conditionalPanel(
            condition = "input.smooth == false",
            selectInput("smoothMethod", "Method",
                        list("lm", "glm", "gam", "loess", "rlm"))),
          conditionalPanel(
            condition = "input.smooth == true",
            selectInput("smoothMethod2", "Method2",
                        list("a", "b", "c", "loess", "rlm"))),





          textInput("name", "What's your name?"),
          numericInput("age", "How old are you?", value = NA),

          textInput("name", "What's your name?"),
          passwordInput("password", "What's your password?"),
          textAreaInput("story", "Tell me about yourself", rows = 3),

          sliderInput("integer", "Integer:",
                      min = 0, max = 1000,
                      value = 500),

          # Input: Decimal interval with step value ----
          sliderInput("decimal", "Decimal:",
                      min = 0, max = 1,
                      value = 0.5, step = 0.1),

          # Input: Specification of range within an interval ----
          sliderInput("range", "Range:",
                      min = 1, max = 1000,
                      value = c(200,500)),

          # Input: Custom currency format for with basic animation ----
          sliderInput("format", "Custom Format:",
                      min = 0, max = 10000,
                      value = 0, step = 2500,
                      pre = "$", sep = ",",
                      animate = TRUE),

          # Input: Animation with custom interval (in ms) ----
          # to control speed, plus looping
          sliderInput("animation", "Looping Animation:",
                      min = 1, max = 2000,
                      value = 1, step = 10,
                      animate =
                        animationOptions(interval = 300, loop = TRUE))

        ),

        # Show a plot of the generated distribution
        mainPanel(
          textOutput("greeting"),
          tableOutput("mortgage"),
          plotOutput("histogram"),

          tableOutput("values")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {


  output$greeting <- renderText({
    paste0("Hello ", input$name, ". You are ", input$age, " years old.")
  })

  output$histogram <- renderPlot({
    hist(rnorm(1000))
  }, res = 90)





  sliderValues <- reactive({

    data.frame(
      Name = c("Integer",
               "Decimal",
               "Range",
               "Custom Format",
               "Animation"),
      Value = as.character(c(input$integer,
                             input$decimal,
                             paste(input$range, collapse = " "),
                             input$format,
                             input$animation)),
      stringsAsFactors = FALSE)

  })

  # Show the values in an HTML table ----
  output$values <- renderTable({
    sliderValues()
  })

}

# Run the application
shinyApp(ui = ui, server = server)
