# Script to prepare the data.
# It fetches data from database SK, schema crz

library(tidyverse)
library(dbplyr)
library(DBI)
library(odbc)
library(RPostgres)
library(keyring)
#library(RPostgreSQL)

keyring::key_set(
  service = "SK",
  username = "postgres"
  )
# key_list("SK")


con <- DBI::dbConnect(odbc::odbc(),
                      driver = "PostgreSQL Unicode",
                      database = "SK",
                      UID    = keyring::key_list("SK")[1,2],
                      PWD    = keyring::key_get("SK", key_list("SK")[1,2]),
                      host = "localhost",
                      port = 5432)


