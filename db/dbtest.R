if(!require("pacman")) install.packages("pacman")

pacman::p_load(
  RPostgres,
  ggplot2

)


con <- dbConnect(
  RPostgres::Postgres(),
  host = "e-vision.biz",
  dbname = "vszp",
  user = "vszp",
  #password = "789653",
  password=rstudioapi::askForPassword("Database password"),
)

str(con)

dbListTables(con)

dbListObjects(con)
