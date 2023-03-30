#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

source("global.R")


# Define server logic required to draw a histogram
function(input, output, session) {

 #bs_themer()



  output$last_update <- renderText({

    autoInvalidate()
    format(Sys.time(), format = "%d.%m.%Y, %H:%M")

  })



  #countries_table
  output$table <- renderReactable ({

    #autoInvalidate()

    data_total_sum_by_countries() %>%
      reactable(
        theme = reactableTheme(
          backgroundColor = "transparent"
        ),
        class = "hidden-column-headers",
        pagination = F,
        height = 675,
        #width = 275,
        fullWidth = T,
        borderless = T,
        compact = T,
        #width = 100,
        defaultColDef = colDef(
          name=""
          ),
        columns = list(
          Country = colDef(
            #name = "Štát",
            maxWidth = 125
          ),
          Cases.Total = colDef(
            #name = "Prípady",
            maxWidth = 80,
            cell = merge_column(
              data = .,
              merged_name = "Cases.28",
              merged_position = "above",
              size = 14,
              merged_size = 18,
              merged_color = "red",
              merged_weight = "bold"
            )
          ),
        Deaths.total = colDef(
          #name = "Úmrtia",
          maxWidth = 80,
          cell = merge_column(
            data = .,
            merged_name = "Deaths.28",
            merged_position = "above",
            size = 14,
            merged_size = 18,
            merged_color = "red",
            merged_weight = "bold"
          )
        ),
        Cases.28 = colDef(show = F),
        Deaths.28 = colDef(show = F)
        )
    )

  })


  # Total Cases
  output$cases_total_sum <- renderText({

    #autoInvalidate()
    format(data_total_sum()$Cases.total, big.mark = " ")

    })


  # Total Deaths
  output$deaths_total_sum <- renderText({

    #autoInvalidate()
    format(data_total_sum()$Deaths.total, big.mark = " ")

  })


  # Total Vaccinations
  output$vaccinations_total_sum <- renderText({

    #autoInvalidate()
    format(data_total_sum()$Vaccine.Doses.Total, big.mark = " ")

  })


  # Cases 28-days
  output$cases_total_28 <- renderText({

    #autoInvalidate()
    format(data_total_28_days_sum()$Cases.total.28, big.mark = " ")

  })


  # Deaths 28-days
  output$deaths_total_28 <- renderText({

    #autoInvalidate()
    format(data_total_28_days_sum()$Deaths.total.28, big.mark = " ")

  })


  # Vaccines 28-days
  output$vaccines_total_28 <- renderText({

    #autoInvalidate()
    format(data_total_28_days_sum()$Vaccine.Doses.Total.28, big.mark = " ")

  })



  output$map_total <- renderLeaflet({

    #autoInvalidate()

    data_total_sum_by_countries_map() %>%
      leaflet() %>%
      addTiles() %>%
      # addProviderTiles(
      #   Jawg.Streets,
      #   options = providerTileOptions(
      #     accessToken: "gTgFob5Buiwl9u3smS3CPJtOKqJBVcITkTTYrOCG3xNDi4FNRZlkDmQCgeLdqouK"
      #     )
      # ) %>%
      addProviderTiles(providers$CartoDB.DarkMatter) %>%
      setView(lng = 10, lat = 10, zoom = 2.4) %>%
      addCircles(
        radius = ~sqrt(Cases.Total) * 50,
        #label = ~Country,
        #label = ~paste0("<strong>", Country, "</strong>", "<br>", "Prípady: ", format(Cases.Total, big.mark = " ")),
        popup = ~paste0(
          "<strong>", Country, "</strong>", "<br>",
          "Prípady: ", format(Cases.Total, big.mark = " "), "<br>",
          "Úmrtia: ", format(Deaths.total, big.mark = " ")
          )
      )

  })


  output$map_28_days <- renderLeaflet({

    #autoInvalidate()

    data_total_sum_by_countries_map() %>%
      leaflet() %>%
      addTiles() %>%
      # addProviderTiles(
      #   Jawg.Streets,
      #   options = providerTileOptions(
      #     accessToken: "gTgFob5Buiwl9u3smS3CPJtOKqJBVcITkTTYrOCG3xNDi4FNRZlkDmQCgeLdqouK"
      #     )
      # ) %>%
      addProviderTiles(providers$CartoDB.DarkMatter) %>%
      setView(lng = 10, lat = 10, zoom = 2.4) %>%
      addCircles(
        #radius = ~sqrt(Cases.28) * 10,
        radius = ~Cases.28,
        color = "red",
        #label = ~Country,
        popup = ~paste0(
          "<strong>", Country, "</strong>", "<br>",
          "Prípady: ", format(Cases.28, big.mark = " "), "<br>",
          "Úmrtia: ", format(Deaths.28, big.mark = " ")
          )
      )

  })





  output$subplot_weekly <- renderPlotly({

    #autoInvalidate()

    plot_cases_weekly <- reactive({
      data_weekly() %>%
      #data_weekly %>%
      plot_ly() %>%
      add_bars(x = ~Date, y = ~Cases.New.weekly, color = I("red")) %>%
      layout(
        title = "",
        #height = 450,
        plot_bgcolor  = "rgba(0, 0, 0, 0)",
        paper_bgcolor = "rgba(0, 0, 0, 0)",
        font = list(color = 'red'),
        yaxis = list(title = "Nové prípady týždenne"),
        xaxis = list()
      ) %>%
      config(displayModeBar = FALSE)
    })

    plot_deaths_weekly <- reactive({
      data_weekly() %>%
        #data_weekly %>%
        plot_ly(
          #height = 250
          ) %>%
        add_bars(x = ~Date, y = ~Deaths.New.weekly, color = I("white")) %>%
        layout(
          plot_bgcolor  = "rgba(0, 0, 0, 0)",
          paper_bgcolor = "rgba(0, 0, 0, 0)",
          font = list(color = '#FFFFFF'),
          yaxis = list(title = "Úmrtia týždenne")
        ) %>%
        config(displayModeBar = FALSE)
    })

    plot_doses_weekly <- reactive({
      data_weekly() %>%
        #data_weekly %>%
        plot_ly(
          #height = 250
        ) %>%
        add_bars(x = ~Date, y = ~Doses_admin.New.weekly, color = I("green")) %>%
        layout(
          #height = 250,
          plot_bgcolor  = "rgba(0, 0, 0, 0)",
          paper_bgcolor = "rgba(0, 0, 0, 0)",
          font = list(color = 'white'),
          xaxis = list(
            title = ""
            ),
          yaxis = list(
            title = "Vakcinácia týždeňne"
            )
          ) %>%
        config(displayModeBar = FALSE)
    })

    subplot(
      plot_cases_weekly(),
      plot_deaths_weekly(),
      plot_doses_weekly(),
      titleY = T,
      titleX = F,
      margin = 0.045,
      nrows = 3
      ) %>%
      layout(
        height = 800,
        #margin = list(b = 200),
        showlegend = F
        ) %>%
      config(displayModeBar = F)

  })


  output$subplot_28_days <- renderPlotly({

    #autoInvalidate()

    plot_cases_28_days <- reactive({
      data_28_days() %>%
        #data_weekly %>%
        plot_ly() %>%
        add_bars(x = ~Date, y = ~Cases.New.28_days, color = I("red")) %>%
        layout(
          title = "",
          #height = 450,
          plot_bgcolor  = "rgba(0, 0, 0, 0)",
          paper_bgcolor = "rgba(0, 0, 0, 0)",
          font = list(color = 'red'),
          yaxis = list(title = "Nové prípady"),
          xaxis = list()
          ) %>%
        config(displayModeBar = FALSE)
    })

    plot_deaths_28_days <- reactive({
      data_28_days() %>%
        #data_weekly %>%
        plot_ly(
          #height = 250
          ) %>%
        add_bars(x = ~Date, y = ~Deaths.New.28_days, color = I("white")) %>%
        layout(
          plot_bgcolor  = "rgba(0, 0, 0, 0)",
          paper_bgcolor = "rgba(0, 0, 0, 0)",
          font = list(color = '#FFFFFF'),
          yaxis = list(title = "Úmrtia")
          ) %>%
        config(displayModeBar = FALSE)
    })

    plot_doses_28_days <- reactive({
      data_28_days() %>%
        #data_weekly %>%
        plot_ly(
          #height = 250
          ) %>%
        add_bars(x = ~Date, y = ~Doses_admin.New.28_days, color = I("green")) %>%
        layout(
          #height = 250,
          plot_bgcolor  = "rgba(0, 0, 0, 0)",
          paper_bgcolor = "rgba(0, 0, 0, 0)",
          font = list(color = 'white'),
          xaxis = list(
            title = ""
            ),
          yaxis = list(
            title = "Vakcinácia"
            )
          ) %>%
        config(displayModeBar = FALSE)
    })

    subplot(
      plot_cases_28_days(),
      plot_deaths_28_days(),
      plot_doses_28_days(),
      titleY = T,
      titleX = F,
      margin = 0.045,
      nrows = 3
    ) %>%
      layout(
        height = 800,
        #margin = list(b = 200),
        showlegend = F
      ) %>%
      config(displayModeBar = F)

  })


  output$test_table <- renderTable({
    #head(test_df())
  })




}
