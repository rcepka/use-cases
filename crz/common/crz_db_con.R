
if (!require("pacman")) install.packages("pacman")

pacman::p_load(
  dbplyr,
  DBI,
  odbc,
  RPostgres,
  keyring
  )

# library(RPostgreSQL)

# key_list("SK")

#Set up DB connection
con_SK <- DBI::dbConnect(odbc::odbc(),
                      driver = "PostgreSQL Unicode",
                      database = "SK",
                      UID    = keyring::key_list("SK")[1,2],
                      PWD    = keyring::key_get("SK", key_list("SK")[1,2]),
                      host = "localhost",
                      #encoding = "latin1",
                      encoding = "Windows-1250",
                      port = 5432)



#Set up DB connection
con_test <- DBI::dbConnect(odbc::odbc(),
                         driver = "PostgreSQL Unicode",
                         database = "test",
                         UID    = keyring::key_list("test")[1,2],
                         PWD    = keyring::key_get("test", key_list("test")[1,2]),
                         host = "localhost",
                         #encoding = "latin1",
                         encoding = "Windows-1250",
                         port = 5432)
