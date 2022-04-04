# Script to prepare the data.
# It fetches data from database SK, schema crz

library(tidyverse)
library(dbplyr)
library(DBI)
library(odbc)
library(RPostgres)
library(keyring)
library(ggplot2)
library(treemap)
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



# Bring up the main DB table
crz_contracts_full_db <- tbl(con, in_schema("crz", "contracts"))



# The preview, some summary numbers ..
# Total contracts, total sum, average contract size, highest contract,
# most contracting entity, most contracted supplier, etc..
crz_contracts_summary_db <- crz_contracts_full_db %>%
  summarise(
    ContractsAmount = sum(contract_price_total_amount, na.rm = TRUE), # Total amount of all contracts
    AverageContract = mean(contract_price_total_amount),# Average contract size
    AllContractsQuantity = as.numeric(n()), # Number of all contracts
    MinContract = min(contract_price_total_amount, na.rm = TRUE), # Minimal single contract size
    MaxContract = max(contract_price_total_amount, na.rm = TRUE), # Maximal single contract size
    Contractors = as.numeric(count(distinct(contracting_authority_cin_raw))), # Contractors quanti
    Suppliers = as.numeric(count(distinct(supplier_cin_raw))), # Suppliers quantity
    MissingContractAmounts = as.numeric(count(is.na(contract_price_total_amount)))
    )

# make it tibble, bring the table into R
crz_contracts_summary_tbl <- as_tibble(crz_contracts_summary_db)




# Top ?50? contracts of all the time
crz_top_contracts_db <- crz_contracts_full_db %>%
  select(
    contracting_authority_name,
    supplier_name,
    subject,
    effective_from,
    contract_price_total_amount
  ) %>%
  slice_max(contract_price_total_amount, n = 5) %>%
  arrange(desc(contract_price_total_amount)
  )

# Make it tibble
crz_top_contracts_tbl <- as_tibble(crz_top_contracts_db)



# bar plot test
ggplot(crz_top_contracts_tbl, aes(x=supplier_name, y=contract_price_total_amount)) +
  geom_bar(stat = "identity") +
  coord_flip()+
  theme_bw()


# display table
#library(kableExtra)
#dt <- crz_top_contracts_tbl[1:5, 1:5]
#kbl(dt) %>%
 # kable_styling() %>%
  #kable_paper("hover", full_width = F)



# All time top 25(50?) contractors by amount of contract->
#
crz_top_contractors_by_amount_db <- crz_contracts_full_db %>%
  group_by(contracting_authority_name) %>%
  summarise(ContractsQuantity = as.numeric(n()),
            ContractAmount = sum(contract_price_total_amount) / 1000, #in thousands of €
            ) %>%
  slice_max(ContractAmount, n = 25) %>%
  mutate(
    SumOfContracts = sum(ContractAmount)
  ) %>%
  rename(Contractors = contracting_authority_name)

# Make it a tibble for further operations
crz_top_contractors_by_amount_tbl <- as_tibble(crz_top_contractors_by_amount_db)

# Add sum of all contracts, this enables us to calculate the percentage
crz_top_contractors_by_amount_tbl <- crz_top_contractors_by_amount_tbl %>%
  rowwise() %>%
  mutate(
    Percentage = ContractAmount / SumOfContracts * 100 #in %
  )

#  add_row(
#    Contractors = "All others",
#    ContractsQuantity = as.numeric(crz_contracts_summary_tbl[1,2]) / 1000,
#    ContractAmount = 555, ContractAmount = 666
#    ) %>%

# Treemap chart
treemap <- treemap(
  crz_top_contractors_by_amount_tbl,
  index="Contractors",
  vSize="Percentage",
  type="index"
)




# Histogram / Boxplot chart
# Distribution of contract values
crz_contracts_size_distribution_db <- crz_contracts_full_db %>%
  select(
    contract_price_total_amount,
    effective_from
  ) %>%
  rename(
    "Contract amount" = contract_price_total_amount,
    "Date" = effective_from
  ) %>%
  arrange(desc(Date))

# Make it tibble and other changes
crz_contracts_size_distribution_tbl <- as_tibble(crz_contracts_size_distribution_db) %>%
  drop_na() %>%
  group_by(Date) %>%
  summarise(
    `Contract amount` = as.numeric(sum(`Contract amount`) / 1000) #in thousands of €
  ) %>%
  filter(
    between(Date, as.Date('1999-01-01'), as.Date('2023-01-01')),
    `Contract amount` > 1000
    )

# basic histogram
# p <- ggplot(crz_contracts_size_distribution_tbl[1:100,], aes(x=`Contract amount`)) +
#   stat_bin(breaks=seq(0,1000,100), fill="#69b3a2", color="#e9ecef", alpha=0.9)
# p
#
#
# ggplot(data = crz_contracts_size_distribution_tbl, mapping = aes(x = Date, y = `Contract amount`)) +
#   geom_line()
#
# ggplot(data=crz_contracts_size_distribution_tbl, aes(x=Date, y=`Contract amount`)) +
#   geom_bar(stat="identity")






#test with data table
#library(data.table)
#crz_contracts_size_distribution_dt <- setDT(crz_contracts_size_distribution_tbl)
#dygraph(crz_contracts_size_distribution_dt) %>%
#  dyRangeSelector(dateWindow = c("2020-01-01", "2020-12-01"))




# All time top 25(50?) contractors by quantity of contract->
#crz_top_contractors_by_quantity_db

# crz_top_contractors_by_amount_db <- crz_contracts_full_db %>%
#   group_by(contracting_authority_name) %>%
#   summarise(Quantity = as.numeric(n()),
#             ContractPrice = sum(contract_price_total_amount),
#             ContractAmount = sum(contract_price_amount)
#   ) %>%
#   slice_max(ContractAmount, n = 5)
#
# # Make it a tibble for further operations
# crz_top_contractors_by_amount_tbl <- as_tibble(crz_top_contractors_by_amount_db)
#
# crz_top_contractors_by_amount_tbl <- mutate(crz_top_contractors_by_amount_tbl, sum = sum(ContractPrice))
#
# add_row(crz_top_contractors_by_amount_tbl, contracting_authority_name = "All others", Quantity = as.numeric(crz_contracts_summary_tbl[1,2]) / 1000, ContractPrice = 555, ContractAmount = 666)
#
#
# crz_top_contractors_by_amount_tbl <- crz_top_contractors_by_amount_tbl %>%
#   rowwise() %>%
#   mutate(Percentage = ContractPrice / sum)














# Top 25(50?) contractors by years. For each year: contractor, quantity of contracts, amount of contracts.
#crz_top_contractors_by_year





#crz_top_contractors_by_year_db




crz_contracts_selected_db <- select(crz_contracts_full_db,
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
crz_contr_auth_most_active_db <- crz_contracts_full_db %>%
  group_by(contracting_authority_name) %>%
  summarise(Quantity = n(),
            ContractPrice = sum(contract_price_total_amount),
            ContractAmount = sum(contract_price_amount)) %>%
  slice_max(Quantity, n = 50)
 # arrange(desc(Sum))

# Most active contracting autorities converted to tibble
crz_contr_auth_most_active_tbl <- as_tibble(crz_contr_auth_most_active_db)






# treemap
library(treemap)
mytreemap <- treemap(
  crz_contr_auth_most_active_tbl,
  index="contracting_authority_name",
  vSize="Quantity",
  type="index"
  )


print(mytreemap)


#ggplot(data = crz_contr_auth_most_active) +
 # geom_bar(aes(contracting_authority_name))




#crz_contracts_selected_tibble <- as_tibble(crz_contracts_selected)


