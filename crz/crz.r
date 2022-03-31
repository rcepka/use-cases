# Script to prepare the data.
# It fetches data from database SK, schema crz

library(tidyverse)
library(dbplyr)
library(DBI)
library(odbc)
library(RPostgres)
library(keyring)
#library(RPostgreSQL)

# key_list("SK")

con <- DBI::dbConnect(odbc::odbc(),
                      driver = "PostgreSQL Unicode",
                      database = "SK",
                      UID    = keyring::key_list("SK")[1,2],
                      PWD    = keyring::key_get("SK", key_list("SK")[1,2]),
                      host = "localhost",
                      #encoding = "latin1",
                      encoding = "Windows-1250",
                      port = 5432)



crz_contracts_full_db <- tbl(con, in_schema("crz", "contracts"))


# dokonči, vyber hlavné stĺpce
#crz_contracts_db <- select(crz_contracts_full_db)


# Total contracts, total sum, average contract size, highest contract,
# most contracting entity, most contracted supplier,
crz_contracts_summary_db <- crz_contracts_db %>%
  summarise(ContractsAmount = sum(contract_price_amount),
            AverageContract = mean(contract_price_amount),
            Count = as.numeric(n()),
            MinContract = min(contract_price_amount),
            MaxContract = max(contract_price_amount, na.rm = TRUE),
            MaxTotalContract = max(contract_price_total_amount, na.rm = TRUE),
            Contractors = as.numeric(count(distinct(contracting_authority_cin_raw))),
            Suppliers = as.numeric(count(distinct(supplier_cin_raw)))
            )
# make it tibble
crz_contracts_summary_tbl <- as_tibble(crz_contracts_summary_db)




# All time top 25(50?) contractors by amount of contract->
crz_top_contractors_by_amount_db <- crz_contracts_db %>%
  group_by(contracting_authority_name) %>%
  summarise(Quantity = as.numeric(n()),
            ContractPrice = sum(contract_price_total_amount),
            ContractAmount = sum(contract_price_amount)) %>%
  slice_max(ContractAmount, n = 5)

  crz_top_contractors_by_amount_tbl <- as_tibble(crz_top_contractors_by_amount_db)
  add_row(crz_top_contractors_by_amount_tbl, contracting_authority_name = "All others", Quantity = as.numeric(crz_contracts_summary_tbl[1,2]) / 1000, ContractPrice = 555, ContractAmount = 666)








# All time top 25(50?) contractors by quantity of contract->
crz_top_contractors_by_quantity_db


# Top 25(50?) contractors by years. For each year: contractor, quantity of contracts, amount of contracts.
crz_top_contractors_by_year


crz_top_contractors_by_year_db




crz_contracts_selected_db <- select(crz_contracts_db,
                                 contracting_authority_name,
                                 contracting_authority_formatted_address,
                                 contracting_authority_cin_raw,
                                 supplier_name,
                                 supplier_formatted_address,
                                 supplier_cin_raw,
                                 subject,
                                 signed_on,
                                 effective_from,
                                 effective_to,
                                 contract_price_amount,
                                 contract_price_total_amount,
                                 published_at,
                                 created_at,
                                 updated_at
)

# Contracting autorities - most active
crz_contr_auth_most_active_db <- crz_contracts_db %>%
  group_by(contracting_authority_name) %>%
  summarise(Quantity = n(),
            ContractPrice = sum(contract_price_total_amount),
            ContractAmount = sum(contract_price_amount)) %>%
  slice_max(Quantity, n = 50)
 # arrange(desc(Sum))

# Most active contracting autorities converted to tibble
crz_contr_auth_most_active_tbl <- as_tibble(crz_contr_auth_most_active_db)


crz_contr_auth_most_active_tbl %>%
ggplot( aes(x=ContractPrice)) +
  stat_bin()





# treemap
library(treemap)
treemap(crz_contr_auth_most_active_tbl,
        index="contracting_authority_name",
        vSize="Quantity",
        type="index"
)





ggplot(data = crz_contr_auth_most_active) +
  geom_bar(aes(contracting_authority_name))




crz_contracts_selected_tibble <- as_tibble(crz_contracts_selected)


