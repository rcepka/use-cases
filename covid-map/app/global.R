#here::i_am("app-map/global.R")

print("starting the app!")
cat(paste0(Sys.time(), "starting the app!...\n"))
if (!require("pacman")) install.packages("pacman")


print("Loading r packages with Pacman")
cat(paste0(Sys.time(), " Starting cron job...\n"))
pacman::p_load(
  shiny,
  tidyverse,
  #ggplot2,
  plotly,
  reactable,
  reactablefmtr,
  shinyWidgets,
  here,
  bslib,
  #lubridate,
  #dataui,
  shinycssloaders,
  timetk,
  leaflet,
  #sp,
  #sf,
  #rgdal,
  #maps,
  #tidygeocoder,
  #readxl
)



includeCSS("www/style.css")



autoInvalidate <- reactiveTimer(60 * 60 * 24 * 1000, NULL)
#autoInvalidate <- reactiveTimer(30000, NULL)


  # observe({
  #
  #   autoInvalidate()


  # #############################
  # Confirmed cases
  # #############################

  #autoInvalidate()

  # get the date and time of actual update
  #last_update <- format(Sys.time(), format = "%d.%m.%Y, %H:%M")

  cat(paste0(Sys.time(), " CASES RAW - downloading the data all file because doesnt exists or is old.\n"))

  cases_raw <- reactive({
    autoInvalidate()
    read_csv(
      url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"),
      col_select = !c(1, 3, 4)
      )
  })

  cases <- reactive({
    cases_raw() %>%
    rename(Country = 1) %>%
    group_by(Country) %>%
    #summarise(across(where(is.numeric), sum, na.rm = T))
    summarise(across(where(is.numeric), \(x) sum(x, na.rm = T)))
  })


  cases_L <- reactive({
    cases() %>%
    pivot_longer(
      !Country,
      names_to = "Date",
      values_to = "Cases"
    ) %>%
    mutate(
      Date = lubridate::mdy(Date),
      Cases.New = Cases - lag(Cases)
    )
  })


  # cases_L <- reactive({
  #   cases_L() %>%
  #     nest(.by = Country) %>%
  #     mutate(
  #       data = purrr::map(data,
  #                         ~ mutate(.x,
  #                                  Cases.New = Cases - lag(Cases)
  #                                  )
  #                         )
  #       ) %>%
  #     unnest(data)
  #   })


  #write_csv(cases(), here("app-map", "data", "cases.csv"))
  #write_csv(cases_L(), here("app-map", "data", "cases_L.csv"))

  # cat(paste0(Sys.time(), " file exists, skip downloading and loading it locally.\n"))
  # cases <- read_csv(here("app-map", "data", "cases.csv"))
  # cases_L <- read_csv(here("app-map", "data", "cases_L.csv"))




  # #############################
  # Confirmed deaths
  # #############################

  cat(paste0(Sys.time(), " downloading the data all file because doesnt exists or is old.\n"))

  deaths_raw <- reactive(
    read_csv(
      url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"),
      col_select = !c(1, 3, 4)
      )
  )


  deaths <- reactive({
    deaths_raw() %>%
      rename(Country = 1) %>%
      group_by(Country) %>%
      summarise(across(where(is.numeric), sum))
  })


  deaths_L <- reactive({
    deaths() %>%
      pivot_longer(
        !Country,
        names_to = "Date",
        values_to = "Deaths"
        ) %>%
      mutate(
        Date = lubridate::mdy(Date),
        Deaths.New = Deaths - lag(Deaths)
        )
    # %>%
      # nest(.by = Country) %>%
      # mutate(data = purrr::map(data,
      #                          ~ mutate(.x,
      #                                   Deaths.New = Deaths - lag(Deaths)
      #                                   )
      #                          )
      #        ) %>%
      # unnest(data)
  })

  # write_csv(deaths_raw, "data/deaths_raw.csv")
  # write_csv(deaths, "data/deaths.csv")
  # write_csv(deaths_L, "data/deaths_L.csv")


  # cat(paste0(Sys.time(), " file exists, skip downloading and loading it locally.\n"))
  # deaths <- read_csv("data/deaths.csv")
  # deaths_L <- read_csv("data/deaths_L.csv")





  # #############################
  #  recovered
  # #############################

  cat(paste0(Sys.time(), " downloading the data all file because doesnt exists or is old.\n"))


  recovered_raw <- reactive(
    read_csv(
      url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv"),
      col_select = !c(1, 3, 4)
      )
  )


  recovered <- reactive({
    recovered_raw() %>%
      rename(Country = 1) %>%
      group_by(Country) %>%
      summarise(across(where(is.numeric), sum))
  })


  recovered_L <- reactive({
    recovered() %>%
      pivot_longer(
        !Country,
        names_to = "Date",
        values_to = "Recovered"
        ) %>%
      mutate(
        Date = lubridate::mdy(Date),
        Recovered.New = Recovered - lag(Recovered)
        )
    # %>%
      # nest(.by = Country) %>%
      # mutate(data = purrr::map(data,
      #                          ~ mutate(.x,
      #                                   Recovered.New = Recovered - lag(Recovered)
      #                                   )
      #                          )
      #        ) %>%
      # unnest(data)
  })

  # write_csv(recovered_raw, "data/recovered_raw.csv")
  # write_csv(recovered, "data/recovered.csv")
  # write_csv(recovered_L, "data/recovered_L.csv")


  # cat(paste0(Sys.time(), " file exists, skip downloading and loading it locally.\n"))
  # recovered <- read_csv("data/recovered.csv")
  # recovered_L <- read_csv("data/recovered_L.csv")





  # #############################
  #  Vaccines
  # #############################

  cat(paste0(Sys.time(), " downloading the data all file because doesnt exists or is old.\n"))


  vaccines_raw <- reactive({
    read_csv(
      url("https://raw.githubusercontent.com/govex/COVID-19/master/data_tables/vaccine_data/global_data/time_series_covid19_vaccine_global.csv"),
      col_select = !c(2, 3)
      )
  })


  vaccines <- reactive({
    vaccines_raw() %>%
      rename(Country = Country_Region) %>%
      nest(.by = Country) %>%
      # mutate(
      #   Doses_admin.New = Doses_admin - lag(Doses_admin),
      #   People_at_least_one_dose.New = People_at_least_one_dose - lag(People_at_least_one_dose)
      #   )
      mutate(data = purrr::map(data,
                             ~ mutate(.x,
                                      Doses_admin.New = Doses_admin - lag(Doses_admin),
                                      People_at_least_one_dose.New = People_at_least_one_dose - lag(People_at_least_one_dose)
                                      )
                             )
             ) %>%
      unnest(data)
  })


  # Summerized vaccines
  vaccines_summarised <- reactive({
    vaccines() %>%
      summarise(
        Doses_admin = sum(Doses_admin, na.rm = T),
        People_at_least_one_dose = sum(People_at_least_one_dose, na.rm = T)
        )
  })

  # write_csv(vaccines_raw, "data/vaccines_raw.csv")
  # write_csv(vaccines, "data/vaccines.csv")
  # write.csv(vaccines_summarised, "data/vaccines_summarised.csv")

  # cat(paste0(Sys.time(), " file exists, skip downloading and loading it locally.\n"))
  # vaccines <- read_csv("data/vaccines.csv")
  # vaccines_summarised <- read_csv("data/vaccines_summarised.csv")






  # #############################
  # Final data frames
  # #############################

  # Basic df
  data_total1 <- reactive({
    left_join(
      cases_L(), deaths_L(), by = c("Country", "Date")
      )
  })

  data_total2 <- reactive({
    left_join(
      data_total1(), recovered_L(), by = c("Country", "Date")
      )
  })

  data_total <- reactive({
    left_join(
      data_total2(), vaccines(), by = c("Country", "Date")
      )
  })



  # Data total summarized
  # Total Cases, Deaths, Recovered, Vaccinations
  # Used in boxes above the map
  data_total_sum <- reactive({
    data_total() %>%
      group_by(Country) %>%
      mutate(Doses_admin = replace_na(Doses_admin, 0)) %>%
      summarise(
        Cases = max(Cases, na.rm = T),
        Deaths = max(Deaths, na.rm = T),
        Recovered = max(Recovered, na.rm = T),
        Vaccine.Doses = max(Doses_admin, na.rm = TRUE)
        ) %>%
      summarize(
        Cases.total = sum(Cases, na.rm = T),
        Deaths.total = sum(Deaths, na.rm = T),
        Recovered.Total = sum(Recovered, na.rm = T),
        Vaccine.Doses.Total = sum(Vaccine.Doses, na.rm = T)
        )
  })


  # Data last 28-days summarized
  # the same as above but for 28-day period
  data_total_28_days_sum <- reactive({
    data_total() %>%
      mutate(Doses_admin = replace_na(Doses_admin, 0)) %>%
      group_by(Country) %>%
      filter(Date > max(data_total()$Date) - 28) %>%
    # summarise(
    #   Cases = max(Cases, na.rm = T),
    #   Deaths = max(Deaths, na.rm = T),
    #   Recovered = max(Recovered, na.rm = T),
    #   Vaccine.Doses = max(Doses_admin, na.rm = TRUE)
    # ) %>%
      summarize(
        Cases.total.28 = sum(Cases.New, na.rm = T),
        Deaths.total.28 = sum(Deaths.New, na.rm = T),
        Recovered.Total.28 = sum(Recovered.New, na.rm = T),
        Vaccine.Doses.Total.28 = sum(Doses_admin.New, na.rm = T)
        ) %>%
      summarise_if(is.numeric, ~sum(.x, na.rm = T))
  })


  # Data grouped by countries and summarized, DF for table at the left side of the screen
  # Totals by countries
  data_total_sum_by_countries_total <- reactive({
    data_total() %>%
      group_by(Country) %>%
      summarize(
        Cases.Total = max(Cases),
        Deaths.total = max(Deaths)
        )
  })
  # 28-day totals by countries
  data_total_sum_by_countries_28_days <- reactive({
    data_total() %>%
      group_by(Country) %>%
      timetk::summarize_by_time(
        .date_var = Date,
        .by = "month",
        Cases.28 = sum(Cases.New),
        Deaths.28 = sum(Deaths.New)
        ) %>%
      #group_by(Country) %>%
      filter(Date == max(Date)) %>%
      select(-Date)
  })

  # Merged into a single DF
  data_total_sum_by_countries <- reactive({
    full_join(
      data_total_sum_by_countries_total(),
      data_total_sum_by_countries_28_days(),
      by = "Country"
      ) %>%
      mutate(
        Country = replace(Country, Country == "Korea, North", "North Korea"),
        Country = replace(Country, Country == "Korea, South", "South Korea"),
        Country = replace(Country, Country == "Taiwan*", "Taiwan"),
        Country = replace(Country, Country == "US", "USA")
        )
  })


  # #################################
  # DF for the map
  # ################################

  # Prepare the countries coordinates df
  countries_coordinates <- reactive({
    read_csv("countries_coordinates.csv") %>%
      select(-1) %>%
      rename(Country = name) %>%
      mutate(
        Country = replace(Country, Country == "United States", "USA"),
        Country = replace(Country, Country == "Czech Republic", "Czechia")
        )
  })

  # We will use as a base the "data_total_sum_by_countries" df created before
  # Get the countries coordinates
  data_total_sum_by_countries_map <- reactive({
    left_join(
      data_total_sum_by_countries(),
      countries_coordinates(),
      by = "Country"
      )
  })






  # ######################
  # Prepare data for right-side charts - weekly and monthly
  # Data are summarised by "Date"
  # ######################

  # Weekly
  data_weekly <- reactive({
    data_total() %>%
      group_by(Date) %>%
      timetk::summarise_by_time(
        .date_var = Date,
        .by = "week",
        Cases.New.weekly = sum(Cases.New),
        Deaths.New.weekly = sum(Deaths.New),
        Doses_admin.New.weekly = sum(Doses_admin.New, na.rm = T)
        )
  })

  # Monthly
  data_28_days <- reactive({
    data_total() %>%
      group_by(Date) %>%
      timetk::summarise_by_time(
        .date_var = Date,
        .by = "month",
        Cases.New.28_days = sum(Cases.New) / 30,
        Deaths.New.28_days = sum(Deaths.New) / 30,
        Doses_admin.New.28_days = sum(Doses_admin.New, na.rm = T) / 30
        )
  })


