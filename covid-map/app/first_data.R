

# #############################
# Confirmed cases
# #############################

if (!file.exists(here("app-map","data","cases.csv")) == "TRUE") {

  # get the date and time of actual update
  last_update <- format(Sys.time(), format = "%d.%m.%Y, %H:%M")

  cat(paste0(Sys.time(), " downloading the data all file because doesnt exists or is old.\n"))




    cases <- read_csv(url(
      "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"),
      col_select = !c(1, 3, 4))



  cases <- cases %>%
    rename(Country = 1) %>%
    group_by(Country) %>%
    #summarise(across(where(is.numeric), sum, na.rm = T))
    summarise(across(where(is.numeric), \(x) sum(x, na.rm = T)))


  cases_L <- cases %>%
    pivot_longer(
      !Country,
      names_to = "Date",
      values_to = "Cases"
    ) %>%
    mutate(
      Date = lubridate::mdy(Date)
    )
  cases_L <- cases_L %>%
    nest(.by = Country) %>%
    mutate(data = purrr::map(data,
                             ~ mutate(.x,
                                      Cases.New = Cases - lag(Cases)
                             )
    )
    ) %>%
    unnest(data)


  write_csv(cases, here("app-map", "data", "cases.csv"))
  write_csv(cases_L, here("app-map", "data", "cases_L.csv"))


} else {


  cat(paste0(Sys.time(), " file exists, skip downloading and loading it locally.\n"))

  cases <- read_csv(here("app-map", "data", "cases.csv"))
  cases_L <- read_csv(here("app-map", "data", "cases_L.csv"))

}




# #############################
# Confirmed deaths
# #############################

if (!file.exists("data/deaths.csv") == "TRUE") {


  cat(paste0(Sys.time(), " downloading the data all file because doesnt exists or is old.\n"))

  deaths <- read_csv(url(
    "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"),
    col_select = !c(1, 3, 4))


  deaths <- deaths %>%
    rename(Country = 1) %>%
    group_by(Country) %>%
    summarise(across(where(is.numeric), sum))


  deaths_L <- deaths %>%
    pivot_longer(
      !Country,
      names_to = "Date",
      values_to = "Deaths"
    ) %>%
    mutate(Date = lubridate::mdy(Date)) %>%
    nest(.by = Country) %>%
    mutate(data = purrr::map(data,
                             ~ mutate(.x,
                                      Deaths.New = Deaths - lag(Deaths)
                             )
    )
    ) %>%
    unnest(data)


  write_csv(deaths, "data/deaths.csv")
  write_csv(deaths_L, "data/deaths_L.csv")


} else {


  cat(paste0(Sys.time(), " file exists, skip downloading and loading it locally.\n"))

  deaths <- read_csv("data/deaths.csv")
  deaths_L <- read_csv("data/deaths_L.csv")

}




# #############################
#  recovered
# #############################

if (!file.exists("data/recovered.csv") == "TRUE") {


  cat(paste0(Sys.time(), " downloading the data all file because doesnt exists or is old.\n"))


  recovered <- read_csv(url(
    "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv"),
    col_select = !c(1, 3, 4))


  recovered <- recovered %>%
    rename(Country = 1) %>%
    group_by(Country) %>%
    summarise(across(where(is.numeric), sum))


  recovered_L <- recovered %>%
    pivot_longer(
      !Country,
      names_to = "Date",
      values_to = "Recovered"
    ) %>%
    mutate(Date = lubridate::mdy(Date)) %>%
    nest(.by = Country) %>%
    mutate(data = purrr::map(data,
                             ~ mutate(.x,
                                      Recovered.New = Recovered - lag(Recovered)
                             )
    )
    ) %>%
    unnest(data)


  write_csv(recovered, "data/recovered.csv")
  write_csv(recovered_L, "data/recovered_L.csv")


} else {


  cat(paste0(Sys.time(), " file exists, skip downloading and loading it locally.\n"))

  recovered <- read_csv("data/recovered.csv")
  recovered_L <- read_csv("data/recovered_L.csv")

}




# #############################
#  Vaccines
# #############################

if (!file.exists("data/vaccines.csv") == "TRUE") {


  cat(paste0(Sys.time(), " downloading the data all file because doesnt exists or is old.\n"))


  vaccines <- read_csv(url(
    #"https://raw.githubusercontent.com/govex/COVID-19/master/data_tables/vaccine_data/global_data/time_series_covid19_vaccine_doses_admin_global.csv"),
    "https://raw.githubusercontent.com/govex/COVID-19/master/data_tables/vaccine_data/global_data/time_series_covid19_vaccine_global.csv"),
    col_select = !c(2, 3)
  )

  vaccines <- vaccines %>%
    rename(Country = Country_Region) %>%
    nest(.by = Country) %>%
    mutate(data = purrr::map(data,
                             ~ mutate(.x,
                                      Doses_admin.New = Doses_admin - lag(Doses_admin),
                                      People_at_least_one_dose.New = People_at_least_one_dose - lag(People_at_least_one_dose)
                             )
    )
    ) %>%
    unnest(data)


  # Summerized vaccines
  vaccines_summarised <- vaccines %>%
    summarise(
      Doses_admin = sum(Doses_admin, na.rm = T),
      People_at_least_one_dose = sum(People_at_least_one_dose, na.rm = T)
    )


  write_csv(vaccines, "data/vaccines.csv")
  write.csv(vaccines_summarised, "data/vaccines_summarised.csv")


} else {


  cat(paste0(Sys.time(), " file exists, skip downloading and loading it locally.\n"))
  vaccines <- read_csv("data/vaccines.csv")
  vaccines_summarised <- read_csv("data/vaccines_summarised.csv")

}

