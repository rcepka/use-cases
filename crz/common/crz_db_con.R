
library(tidyverse)
library(dbplyr)
library(DBI)
library(odbc)
library(RPostgres)
library(keyring)
#library(RPostgreSQL)

# key_list("SK")

#Set up DB connection
con <- DBI::dbConnect(odbc::odbc(),
                      driver = "PostgreSQL Unicode",
                      database = "SK",
                      UID    = keyring::key_list("SK")[1,2],
                      PWD    = keyring::key_get("SK", key_list("SK")[1,2]),
                      host = "localhost",
                      #encoding = "latin1",
                      encoding = "Windows-1250",
                      port = 5432)
