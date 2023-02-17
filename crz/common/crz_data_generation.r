# Script to prepare the data.
# It fetches data from database SK, schema crz

if (!require("pacman")) install.packages("pacman")

pacman::p_load(
  here,
  tidyverse,
  dbplyr,
  feather,
  lubridate
  )

# Bring up the basic DB table
source(here("crz", "common", "crz_db_con.R"))


# Bring up the main DB table
crz_contracts_full_db <- tbl(con_SK, in_schema("crz", "contracts"))



# Tables:
# 1. All contracts
# 2. All contracts cleaned - data tidied
# 3. All contracts summary
# 4. Summaries by years and by years&months
# 5. Top contracts
# 6. Top contractors
# 7. Top suppliers





# ******************************************************************************
# 1. The basic table
# All contracts, no filters applied,  selected required columns (large data set)
# ******************************************************************************
crz_all_contracts_db <- crz_contracts_full_db %>%
  select(
    Contract.ID = contract_identifier,
    Contractor = contracting_authority_name,
    Contractor.Cin = contracting_authority_cin_raw,
    Supplier = supplier_name,
    Supplier.Cin = supplier_cin_raw,
    Subject = subject,
    Signed.On = signed_on,
    Effective.From = effective_from,
    Price = contract_price_total_amount
  )






# ******************************************************************************
# 2. All contracts cleaned
# Filtered out NA´s or obviously wrong data
# ******************************************************************************

# All contracts except those where Contractor, Supplier or contract subject are not available
crz_all_contracts_cleaned_db <- crz_all_contracts_db %>%
  filter(
    !is.na(Contractor) & !is.na(Contractor.Cin),
    !is.na(Supplier) & !is.na(Supplier.Cin),
    !is.na(Signed.On) & !is.na(Effective.From),
    !is.na(Subject)
  ) %>%
  mutate(
    Date = ifelse(!is.na(Signed.On), Signed.On, Effective.From),
    Contractor.Cin = str_replace_all(Contractor.Cin, " ", ""),
    Supplier.Cin = str_replace_all(Supplier.Cin, " ", "")#,
  ) %>%
  relocate(
    Date, .before = Price
  )

# Make it tibble
crz_all_contracts_cleaned <- as_tibble(crz_all_contracts_cleaned_db)

# Clen-up dates which are obviously error; it could not to be performed directly on the
# database, probably because SQL generated by dbplyr was incompatible with my current Psql database
crz_all_contracts_cleaned <- crz_all_contracts_cleaned %>%
  #mutate(Date = if_else(year(Date) > "2021",  ymd(paste(str_sub(Date, 1, 2) <- "99", str_sub(Date, 3,-1L), sep = "")), ymd(Effective.From)))
  mutate(
    Date = if_else(year(Date) > year(Sys.Date()) + 1 | year(Date) < 1990, Effective.From, Date),
    Date = if_else(Date == "0201-11-19", ymd("2001-11-19"), Date),
    Date = if_else(Date == "0202-02-24", ymd("2002-11-19"), Date)
  ) %>%
  arrange(
    desc(Date)
  )

# Save it?
# feather::write_feather(crz_all_contracts_cleaned, (here::here("crz", "data", "crz_all_contracts_cleaned.feather")))






# *******************************************************************************
# 3. Summaries table, total contracts, total sum, average contract size, highest contract, etc..
# *******************************************************************************
crz_all_contracts_summary_db <- crz_all_contracts_db %>%
  filter(
    Price >= 0
  ) %>%
  summarise(
    Contracts.Amount = sum(Price, na.rm = TRUE), # Total amount of all contracts
    Contracts.Quantity = as.numeric(n()), # Number of all contracts
    Aver.Contract.Size = round(mean(Price), digits = 1),# Average contract size
    Min.Contract.Size = min(Price, na.rm = TRUE) , # Minimal single contract size
    Max.Contract.Size = max(Price, na.rm = TRUE), # Maximal single contract size
    Contractors.Quantity = as.numeric(count(distinct(Contractor.Cin))), # Contractors quanti
    Suppliers.Quantity = as.numeric(count(distinct(Supplier.Cin))), # Suppliers quantity
    Missing.Contract.Amounts = as.numeric(count(is.na(Price)))
    )

# make it tibble, bring the table into R
crz_all_contracts_summary <- as_tibble(crz_all_contracts_summary_db)

# Save it as feather file
feather::write_feather(crz_all_contracts_summary, (here::here("crz", "data", "crz_all_contracts_summary.feather")))

# Rename columns and make it "flipped" table
# Slovak
crz_all_contracts_summary_flipped_sk <- crz_all_contracts_summary %>%
  rename("Hodnota kontraktov" = Contracts.Amount,
         "Počet kontraktov" = Contracts.Quantity,
         "Priemerný kontrakt" = Aver.Contract.Size,
         "Maximálny kontrakt" = Max.Contract.Size,
         "Minimálny kontrakt" = Min.Contract.Size,
         "Počet zadávateľov" = Contractors.Quantity,
         "Počet dodávateľov" = Suppliers.Quantity,
         "Chýbajúce hodnoty" = Missing.Contract.Amounts) %>%
  pivot_longer(
    everything(),
    names_to = "Položka",
    values_to = "Hodnota"
  )

# English
crz_all_contracts_summary_flipped_en <- crz_all_contracts_summary %>%
  rename_with(~ gsub("\\.", " ", .x))  %>%
  pivot_longer(
    everything(),
    names_to = "Item",
    values_to = "Value"
  )

# Save both SK & EN versions
feather::write_feather(crz_all_contracts_summary_flipped_sk, (here::here("crz", "data", "crz_all_contracts_summary_flipped_sk.feather")))
feather::write_feather(crz_all_contracts_summary_flipped_en, (here::here("crz", "data", "crz_all_contracts_summary_flipped_en.feather")))








# ******************************************************************************
# 4. Summaries by years and by years&months
# SUM & COUNT
# ******************************************************************************

# Summaries by Years
crz_all_contracts_summary_by_years <- crz_all_contracts_cleaned %>%
  mutate(
    Date.Year = year(Date)
  ) %>%
  group_by(
    Date.Year
  ) %>%
  summarise(
    N = n(),
    #SUM = sum(Price) / 1000000
    SUM = as.numeric(format(sum(Price) / 1000000, digits = "2", trim = TRUE, width = 3, nsmall = "1"))
  ) %>%
  arrange(
    Date.Year
  )
# Change Date.Year to class Date
crz_all_contracts_summary_by_years <- crz_all_contracts_summary_by_years %>%
  mutate(
    Date.Year = ymd(Date.Year, truncated = 2L) # Make sure that it is of class Date
  )

# Save it
feather::write_feather(crz_all_contracts_summary_by_years, (here::here("crz", "data", "crz_all_contracts_summary_by_years.feather")))



# Summaries by Years and Months
# For converting numbers to Slovak month names
slovak_months <- c("január", "február", "marec", "apríl", "máj", "jún",
                   "júl", "august", "september", "október", "november", "december")

crz_all_contracts_summary_by_years_months <- crz_all_contracts_cleaned %>%
  mutate(
    Date.Year = year(Date),
    Date.Month = month(Date)
  ) %>%
  group_by(
    Date.Year,
    Date.Month
  ) %>%
  summarise(
    N = n(),
    SUM = sum(Price) / 1000000
    #SUM = format(sum(Price) / 1000000, digits = "2", nsmall = "1", big.mark = " ", justify = "centre")
  ) %>%
  arrange(
    Date.Year,
    Date.Month
  )

# Change Date.Year to class Date
crz_all_contracts_summary_by_years_months <- crz_all_contracts_summary_by_years_months %>%
  mutate(
    Date.Year = ymd(Date.Year, truncated = 2L), # Make sure that it is of class Date
    Date.Month.Chr = slovak_months[Date.Month]
  ) %>%
  relocate(
    Date.Month.Chr, .after = Date.Month
  )

# Save it
feather::write_feather(crz_all_contracts_summary_by_years_months, (here::here("crz", "data", "crz_all_contracts_summary_by_years_months.feather")))




# ******************************************************************************
# 5. Top contracts
# Filtered only contracts with Price > 0 and arranged by size
# ******************************************************************************

crz_top_contracts_all <- crz_all_contracts_cleaned %>%
  filter(
    Price > 0
  ) %>%
  arrange(
    desc(Price)
  )
# Save it ?
# feather::write_feather(crz_top_contracts_all, (here::here("crz", "data", "crz_top_contracts_all.feather")))


crz_top_contracts_1000 <- crz_top_contracts_all %>%
  slice_max(order_by = Price, n = 1000
  )

# Save it
feather::write_feather(crz_top_contracts_1000, (here::here("crz", "data", "crz_top_contracts_1000.feather")))






# ******************************************************************************
# 6. Top contractors
# Top contractors by total amount and contract quantity
# ******************************************************************************

crz_all_contracts_db # Use the dataset with all contracts
crz_top_contractors_all <- crz_all_contracts_cleaned %>%
  filter(
    Price > 0
  ) %>%
  arrange(
    desc(Price)
  )
# Save it ?
# feather::write_feather(crz_top_contracts_all, (here::here("crz", "data", "crz_top_contracts_all.feather")))


crz_top_contracts_1000 <- crz_top_contracts_all %>%
  slice_max(order_by = Price, n = 1000
  )

# Save it
feather::write_feather(crz_top_contracts_1000, (here::here("crz", "data", "crz_top_contracts_1000.feather")))
