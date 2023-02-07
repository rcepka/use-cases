library("ggplot2")
ui <- fluidPage(

  titlePanel("Hello !!!"),


  fluidRow(

    column(3,
           numericInput("i_num1", label = "Number 1", value = 1),
           numericInput("i_num2", label = "Number 2", value = 2),
           textInput("i_text1", label = "Text 1", value = ""),
           actionButton("action_button", label = "Recalculate"),

           ),

    column(9,
           textOutput("o_text1"),
           textOutput("greeting")
           ),

    )

  )



server <- function(input, output, session) {

  output1 <- eventReactive(
    input$action_button, {
      input$i_text1
      }
    )

  output$o_text1 <- renderText({paste("Hello ", output1(), "")})

  observeEvent(
    input$action_button,
    {
      message("Greeting performed")
      }
    )

  observeEvent(input$i_text1, {message("Text was inserted")})




}

shinyApp(ui, server)
