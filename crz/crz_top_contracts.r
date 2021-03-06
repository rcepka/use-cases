# Script to prepare the data.
# It fetches data from database SK, schema crz
library(here)
source(here("crz", "common", "crz_db_con.R"))


library(tidyverse)
library(dbplyr)
library(ggplot2)
library(treemap)
library(kableExtra)
library(lubridate)
library(ggforce)

library(hrbrthemes)
#library(RPostgreSQL)


# Bring up the main DB table
crz_contracts_full_db <- tbl(con_SK, in_schema("crz", "contracts"))



# All contracts except those where Contractor, Supplier or contract subject are not available
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
  ) %>%
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


# As All contracts above + filtered out all contracts without price (or Price equal zero)
crz_top_contracts_db <- crz_contracts_full_db %>%
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
   ) %>%
   filter(
     !is.na(Contractor) & !is.na(Contractor.Cin),
     !is.na(Supplier) & !is.na(Supplier.Cin),
     !is.na(Signed.On) & !is.na(Effective.From),
     !is.na(Subject),
     Price > 0
   ) %>%
  mutate(
    Date = ifelse(!is.na(Signed.On), Signed.On, Effective.From),
    Contractor.Cin = str_replace_all(Contractor.Cin, " ", ""),
    Supplier.Cin = str_replace_all(Supplier.Cin, " ", "")#,
  ) %>%
  relocate(
    Date, .before = Price
  )

crz_top_contracts <- as_tibble(crz_top_contracts_db)

# Clen-up dates which are obviously error; it could not to be performed directly on the
# database, probably because SQL generated by dbplyr was incompatible with my current Psql database
crz_top_contracts <- crz_top_contracts %>%
  #mutate(Date = if_else(year(Date) > "2021",  ymd(paste(str_sub(Date, 1, 2) <- "99", str_sub(Date, 3,-1L), sep = "")), ymd(Effective.From)))
  mutate(
    Date = if_else(year(Date) > year(Sys.Date()) | year(Date) < 1990, Effective.From, Date),
    Date = if_else(Date == "0201-11-19", ymd("2001-11-19"), Date)
    ) %>%
  arrange(
    desc(Date)
  )

#save(crz_top_contracts, file = here("crz", "data", "crz_top_contracts.Rdata"))
# Note: generates large file




# e??te dopln vycistenie d??tumov aj pre prv?? tabulku "all"


# crz_top_contracts_db$Date <- str_replace(crz_top_contracts_db$Date, "^\\d{2}", "99")
# crz_top_contracts_db$Date <- paste(str_sub(crz_top_contracts_db$Date, 1, 2) <- "99", str_sub(crz_top_contracts_db$Date, 3,-1L), sep = "")









# Summaries by Years
crz_top_contracts_by_years <- crz_top_contracts %>%
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
crz_top_contracts_by_years <- crz_top_contracts_by_years %>%
  mutate(
    Date.Year = ymd(Date.Year, truncated = 2L) # Make sure that it is of class Date
  )


# For converting numbers to Slovak month names
slovak_months <- c("janu??r", "febru??r", "marec", "apr??l",
                   "m??j", "j??n", "j??l", "august",
                   "september", "okt??ber", "november", "december")

# Summaries by Years and Months
crz_top_contracts_by_years_months <- crz_top_contracts %>%
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
crz_top_contracts_by_years_months <- crz_top_contracts_by_years_months %>%
  mutate(
    Date.Year = ymd(Date.Year, truncated = 2L), # Make sure that it is of class Date
    Date.Month.Chr = slovak_months[Date.Month]
  ) %>%
  relocate(
    Date.Month.Chr, .after = Date.Month
  )





# Lollipop chart - number contracts
ggplot(
  data = crz_top_contracts_by_years,
  aes(
    x = Date.Year,
    y = N,
    label = round(N/1000, 0)
    )
  ) +
  # Plotting geom_segment() - lines
  geom_segment(
    aes(y = 0,  x = `Date.Year`,  yend = N, xend = `Date.Year`),
    color = "darkorange",
    size = 1.5,
    alpha = 1
    ) +
  # Add geom_point()
  geom_point(
    stat = "identity",
    color = "darkorange",
    fill="orange", alpha=1, shape=21, stroke=2,
    size = 15
  ) +
  #coord_flip() +
  # Plotting geom_text()
  geom_text(
    color="white",
    size=5,
    fontface = "bold"
    ) +
  scale_y_continuous (
    name = "Po??et kontraktov v tis??coch",
    limits = c(0, 100000),
    n.breaks = 5,
    labels = scales::label_number(
      suffix = " k",
      scale = (1 / 1000)
      )
  ) +
  scale_x_date(
    name = "Roky",
    limits = c(as.Date("2012-01-01"), NA),
    breaks = "1 year",
    date_labels = "%Y",
    guide = guide_axis()
  ) +
  labs(
    title = "Po??et kontraktov v CRZ",
    subtitle = "V??voj po??tu kontraktov v jednotliv??ch rokoch",
    caption = "Spracovan?? DataViz"
  ) +
  theme_ipsum_rc(grid = "Y") +
  theme(
    axis.line.x = element_line(
      color = "grey",
      size = 0.5
    ),
    axis.line.y = element_line(
      color = "grey",
      size = 0.5
    ),
    panel.border = element_rect(
      fill = "transparent",
      color = "transparent"
    ),
    axis.title.x = element_text(
        face = "bold",
        size = rel(1.25)
      ),
    axis.title.y = element_text(
      face = "bold",
      size = rel(1.25)
      ),
    panel.grid.major = element_line(
      size = 0.25,
      color = "gray95"
    )
  )




# Stacked area chart
plot_crz_top_contracts_by_years_months2 <- crz_top_contracts_by_years_months %>%
  mutate(
    Date.Month = month.name[as.numeric(Date.Month)]
    )

ggplot(data = crz_top_contracts_by_years_months) +
  # Area chart
  geom_area(
    aes(
      x = Date.Year,
      y = N,
      label = N,
      fill = month.name[as.numeric(Date.Month)]
      ),
    alpha = 0.75, position = "stack", colour="white", size = 0.5
    ) +
  scale_x_date(
    name = "Rok",
    date_breaks = "2 years",
    date_labels = "%Y",
    limits = c(as.Date("2012-01-01"), as.Date("2021-01-01"))
    ) +
  scale_y_continuous(
    name = "Po??et kontraktov (v tis??coch)",
    breaks = scales::breaks_extended(6),
    #breaks = c(30000, 60000),
    labels = scales::label_number(
      suffix = "",
      big.mark = ",",
      scale  = (1 / 1000)
      )
    ) +
  labs(title="Area Chart of Returns Percentage",
       subtitle="From Wide Data format",
       caption="Source: Economics") +
  labs(
    fill ="Mesiac",
    #x = "qqqqq",
    #y = "Ahoj"
  ) +
  theme_bw() +
  theme(
    legend.title = element_text(face = "bold"),
    legend.text = element_text(color = "blue"),
    panel.border = element_blank(),
    #panel.grid = element_blank(),
    panel.grid.major.x = element_blank()
    ) +
  # Line chart
  geom_line(
    aes(
      x = Date.Year,
      y = N,
      group = month.name[as.numeric(Date.Month)]), position = "stack",
    color = "red") +
  # Points chart
  geom_point(
    aes(
      x = Date.Year,
      y = N,
      group = month.name[as.numeric(Date.Month)]), position = "stack", size = 2,
    color = "blue") +
  # Text labels
  stat_summary(fun = sum, aes(x = Date.Year, y = N, label = ..y.., group = Date.Year), geom = "text", vjust = -1)

  stat_summary(
    aes(
      x = Date.Year,
      y = N,
    #  fun = "sum"
    ),
    fun.y = sum,
    #label = N,
    #geom = "text",
    group = Date.Year
  )
  geom_text(data = crz_top_contracts_by_years,
    aes(
      x = Date.Year,
      y = N,
      label = paste(round(N / 1000, 0), "k"),
      ),
    # label.padding = 1.5,
    #check_overlap = TRUE,
    size = 3.5,
    fontface = "bold",
    #label.size = 5,
    #show.legend = F
    nudge_y = 1.51,
   nudge_x = 2,
    # angle = 45,
   # stat = "identity",
   # position = "identity",
   vjust = -1
    ) +
  annotate("label",
           x = as.Date("2013-01-01"),
           y = 80000,
           label = "asasasasa, sdsddsd dd
           dsdd ddsdd",
           #color = "white",
           #fill = "red",
           label.padding = unit(0.5, "lines"),
           label.r = unit(0.15, "lines"),
           label.size = 0.5,
           )
# scale_fill_discrete(
#   breaks = c('January', 'February', 'March', 'April', "May", "June",
#              "July", "August", "September", "October", "November", "December")
#   )
###




library(lubridate)
crz_top_contracts_by_years_months$Date.Year <- ymd(crz_top_contracts_by_years_months$Date.Year, truncated = 2L)



ggplot(crz_top_contracts_by_years_months, aes(x = Date.Year, y = N, fill = Date.Month)) +
  geom_area() +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y", limits = c(as.Date("2015-01-01"), NA))

  # xlim(2011-01-01, 2022-01-01) +

#, limits = c(2011-01-01, NA)


crz_top_contracts_by_years$Date.Year <- ymd(crz_top_contracts_by_years$Date.Year, truncated = 2L)


y <- unique(crz_top_contracts_by_years_months$Date.Year)
yl <- year(y)
brks <- crz_top_contracts_by_years$Date.Year[seq(1, length(crz_top_contracts_by_years$Date.Year), 12)]

lbls <- year(brks)





# Test datfixR
crz_top_contracts %>% datefixR::fix_dates("Date", day.impute = 1, month.impute = 1)

crz_top_contracts <- crz_top_contracts %>% mutate(
  Date = ymd(Date)
)


# Shall we try the dtplyr ???
  # library(data.table)
  # library(dtplyr)
  # crz_top_contracts_db <- lazy_dt(crz_top_contracts_db)



crz_top_contracts %>%
  group_by(Contractor.Cin) %>%
  summarise(n = n()) %>%
  arrange(desc(n))


# Create basic table according to the number of top contracts, make it a tibble and save it
crz_top_contracts_100_db <- slice_max(crz_top_contracts_db, Price, n = 100)
crz_top_contracts_100 <- crz_top_contracts_100_db %>%
  as_tibble()
save(crz_top_contracts_100, file = "data/crz_top_contracts_100.Rdata")

crz_top_contracts_1000_db <- slice_max(crz_top_contracts_db, Price, n = 100000)
crz_top_contracts_1000 <- crz_top_contracts_1000_db %>%
  as_tibble()
save(crz_top_contracts_1000, file = "data/crz_top_contracts_1000.Rdata")




# testing replacement of a single row in dataframe
# crz_top_contracts_1000 <- crz_top_contracts_1000 %>%
#   mutate(Signed.On = replace(Signed.On, Contract.ID == "BAM-18331/2018", Effective.From[Contract.ID == "BAM-18331/2018"]))



# Testing some charts
crz_top_contracts <- as_tibble(crz_top_contracts)

aa <- ggplot(crz_top_contracts, aes(Date, Price)) +
  #geom_point() +
  geom_hex(bins = 50) +
  geom_smooth() +
  ylim(NA, 400) +
  labs(
    title = "Fuel economy from 1999 to 2008 for 38 car models",
    caption = "Source: https://fueleconomy.gov/",
    x = "Engine Displacement",
    y = "Miles Per Gallon"
  )
ggplotly(aa)


ggplot(crz_top_contracts, aes(Date, Price)) +
  geom_violin() +
  ylim(NA, 400)+
  scale_x_date(date_breaks = "5 years", date_labels = "%Y")



ggplot(crz_top_contracts, aes(Date)) +
  geom_histogram(binwidth = 100) +
  scale_x_date(limits = ymd(c("2011-01-01"), NA)) +
  ylab("Po??et zm??v")






length(unique(crz_top_contracts_100$Contract.ID))

crz_top_contracts_100 %>% get_dupes(Contract.ID)

n_distinct(crz_top_contracts_100$Contract.ID, na.rm = FALSE)

dpl <- crz_top_contracts %>%
  group_by(Contract.ID) %>%
  filter(n()>1)







# Make sure that the main table has correct names of companies according to "ICO"
# This requires to bring up tables from RPO database (Register pr??vnickych os??b),
# which contains correct company ID -> company name records

# Bring up the tables from DB
rpo_ids_full_db <- tbl(con_SK, in_schema("rpo", "organization_identifier_entries"))
rpo_names_full_db <- tbl(con_SK, in_schema("rpo", "organization_name_entries"))

# Join tables into a single one so we get company ID and company name pairs
rpo <- left_join(rpo_names_full_db, rpo_ids_full_db, by ='organization_id')

#
rpo_db <- rpo %>%
  select(
    ipo, # Company ID
    name
  ) %>%
  mutate(
    ipo = as.character(ipo) # In CRZ tables the company ID is a char.
  )


# Lets process the Contractors company Id -> company name pairs
crz_top_contracts_100 <- left_join(
  crz_top_contracts_100,
  rpo_db,
  by=c("Contractor.Cin" = "ipo"),
  copy = TRUE
  ) %>%
  select(
    -Contractor
  ) %>%
  rename(
    Contractor = name
  )  %>%
  relocate(
    Contractor, .after = Contract.ID
  )


# Lets process the Suppliers company Id -> company name pairs
crz_top_contracts_100_db <- left_join(
  crz_top_contracts_100_db,
  rpo_db,
  by=c("Supplier.Cin" = "ipo"),
  copy = TRUE
) %>%
  select(
    -Supplier
  ) %>%
  rename(
    Supplier = name
  )  %>%
  relocate(
    Supplier, .after = Contractor.Cin
  )


























# Top 100 Contractors + their top 5 corresponding Suppliers
crz_top_contractors_by_quantity_db <- crz_contracts_full_db %>%
  select(
    #id,
    contract_identifier,
    contracting_authority_name,
    contracting_authority_cin_raw,
    supplier_name,
    supplier_cin_raw,
    subject,
    effective_from,
    contract_price_total_amount
  ) %>%
  rename(
    #ID = id,
    Contract.ID = contract_identifier,
    Contractor = contracting_authority_name,
    Contractor.Cin = contracting_authority_cin_raw,
    Supplier = supplier_name,
    Supplier.Cin = supplier_cin_raw,
    Subject = subject,
    Effective.From = effective_from,
    Price = contract_price_total_amount
  ) %>%
  group_by(
    Contractor
  ) %>%
  summarise(
    n = n(),
    Sum = sum(Price)
  ) %>%
  slice_max(n, n = 100)

crz_top_contractors_by_quantity <- as_tibble(crz_top_contractors_by_quantity_db)
save(crz_top_contractors_by_quantity, file = "data/crz_top_contractors_by_quantity.Rdata")

  # mutate(
  #   #Price = paste(round(Price / 1000000, digits = 1), "???", sep = "") # Make it in millions of ???
  #   Price = round(Price / 1000000, digits = 0) # Make it in millions of ???
  # )


# Top 100 Suppliers + their top 5 corresponding Suppliers
crz_top_suppliers_by_quantity_db <- crz_contracts_full_db %>%
  select(
    #id,
    contract_identifier,
    contracting_authority_name,
    contracting_authority_cin_raw,
    supplier_name,
    supplier_cin_raw,
    subject,
    effective_from,
    contract_price_total_amount
  ) %>%
  rename(
    #ID = id,
    Contract.ID = contract_identifier,
    Contractor = contracting_authority_name,
    Contractor.Cin = contracting_authority_cin_raw,
    Supplier = supplier_name,
    Supplier.Cin = supplier_cin_raw,
    Subject = subject,
    Effective.From = effective_from,
    Price = contract_price_total_amount
  ) %>%
  group_by(
    Supplier
  ) %>%
  summarise(
    n = n(),
    Sum = sum(Price)
  ) %>%
  slice_max(n, n = 100)

crz_top_suppliers_by_quantity <- as_tibble(crz_top_suppliers_by_quantity_db)
save(crz_top_suppliers_by_quantity, file = "data/crz_top_suppliers_by_quantity.Rdata")

# mutate(
#   #Price = paste(round(Price / 1000000, digits = 1), "???", sep = "") # Make it in millions of ???
#   Price = round(Price / 1000000, digits = 0) # Make it in millions of ???
# )























table1 <- crz_top_contracts_100 %>%
  select(Contract.ID, Contractor, Supplier, Subject, Price) %>%
  rename("Contract ID" = Contract.ID) %>%
  mutate(
    Contractor = str_trunc(Contractor, 40, "right"),
    Supplier = str_trunc(Supplier, 40, "right"),
    Subject = str_trunc(Subject, 40, "right"),
    Price = paste(Price, "???", sep = "")) %>%
  #arrange(desc(Price)) %>%
  #slice_max(Price, n = 25) %>%
  kbl() %>%
  kable_classic(full_width = F, html_font = "Cambria", bootstrap_options = c("condensed", "hover", "striped"), position = "left") %>%
  row_spec(2:3, color = 'white', background = 'black') %>%
  add_header_above(c(" " = 1, "Group 1" = 2, "Group 2" = 2))








# Select only basic info for TOP 25 contracts
crz_top_contracts_100_basic <- crz_top_contracts_100 %>%
  select(
    Subject,
    Price
  ) %>%
  slice_max(Price, n = 25) %>%
  arrange(desc(Price))

# Save the data to file
save(crz_top_contracts_100_basic, file = "data/crz_top_contracts_100_basic.Rdata")


#crz_top_contracts_100_basic <- as_tibble(crz_top_contracts_db_basic)



#
# # bar plot test
# ggplot(crz_top_contracts_100, aes(x=supplier_name, y=contract_price_total_amount)) +
#   geom_bar(stat = "identity") +
#   coord_flip()+
#   theme_bw()
#
#
# # display table
# #library(kableExtra)
# #dt <- crz_top_contracts_100[1:5, 1:5]
# #kbl(dt) %>%
#  # kable_styling() %>%
#   #kable_paper("hover", full_width = F)
#
#
#
# # All time top 25(50?) contractors by amount of contract->
# #
# crz_top_contractors_by_amount_db <- crz_contracts_full_db %>%
#   group_by(contracting_authority_name) %>%
#   summarise(ContractsQuantity = as.numeric(n()),
#             ContractAmount = sum(contract_price_total_amount) / 1000, #in thousands of ???
#             ) %>%
#   slice_max(ContractAmount, n = 25) %>%
#   mutate(
#     SumOfContracts = sum(ContractAmount)
#   ) %>%
#   rename(Contractors = contracting_authority_name)
#
# # Make it a tibble for further operations
# crz_top_contractors_by_amount_tbl <- as_tibble(crz_top_contractors_by_amount_db)
#
# # Add sum of all contracts, this enables us to calculate the percentage
# crz_top_contractors_by_amount_tbl <- crz_top_contractors_by_amount_tbl %>%
#   rowwise() %>%
#   mutate(
#     Percentage = ContractAmount / SumOfContracts * 100 #in %
#   )
#
# #  add_row(
# #    Contractors = "All others",
# #    ContractsQuantity = as.numeric(crz_contracts_summary_tbl[1,2]) / 1000,
# #    ContractAmount = 555, ContractAmount = 666
# #    ) %>%
#
# # Treemap chart
# treemap <- treemap(
#   crz_top_contractors_by_amount_tbl,
#   index="Contractors",
#   vSize="Percentage",
#   type="index"
# )
#
#
#
#
# # Histogram / Boxplot chart
# # Distribution of contract values
# crz_contracts_size_distribution_db <- crz_contracts_full_db %>%
#   select(
#     contract_price_total_amount,
#     effective_from
#   ) %>%
#   rename(
#     "Contract amount" = contract_price_total_amount,
#     "Date" = effective_from
#   ) %>%
#   arrange(desc(Date))
#
# # Make it tibble and other changes
# crz_contracts_size_distribution_tbl <- as_tibble(crz_contracts_size_distribution_db) %>%
#   drop_na() %>%
#   group_by(Date) %>%
#   summarise(
#     `Contract amount` = as.numeric(sum(`Contract amount`) / 1000) #in thousands of ???
#   ) %>%
#   filter(
#     between(Date, as.Date('1999-01-01'), as.Date('2023-01-01')),
#     `Contract amount` > 1000
#     )
#
# # basic histogram
# # p <- ggplot(crz_contracts_size_distribution_tbl[1:100,], aes(x=`Contract amount`)) +
# #   stat_bin(breaks=seq(0,1000,100), fill="#69b3a2", color="#e9ecef", alpha=0.9)
# # p
# #
# #
# # ggplot(data = crz_contracts_size_distribution_tbl, mapping = aes(x = Date, y = `Contract amount`)) +
# #   geom_line()
# #
# # ggplot(data=crz_contracts_size_distribution_tbl, aes(x=Date, y=`Contract amount`)) +
# #   geom_bar(stat="identity")
#
#
#
#
#
#
# #test with data table
# #library(data.table)
# #crz_contracts_size_distribution_dt <- setDT(crz_contracts_size_distribution_tbl)
# #dygraph(crz_contracts_size_distribution_dt) %>%
# #  dyRangeSelector(dateWindow = c("2020-01-01", "2020-12-01"))
#
#
#
#
# # All time top 25(50?) contractors by quantity of contract->
# #crz_top_contractors_by_quantity_db
#
# # crz_top_contractors_by_amount_db <- crz_contracts_full_db %>%
# #   group_by(contracting_authority_name) %>%
# #   summarise(Quantity = as.numeric(n()),
# #             ContractPrice = sum(contract_price_total_amount),
# #             ContractAmount = sum(contract_price_amount)
# #   ) %>%
# #   slice_max(ContractAmount, n = 5)
# #
# # # Make it a tibble for further operations
# # crz_top_contractors_by_amount_tbl <- as_tibble(crz_top_contractors_by_amount_db)
# #
# # crz_top_contractors_by_amount_tbl <- mutate(crz_top_contractors_by_amount_tbl, sum = sum(ContractPrice))
# #
# # add_row(crz_top_contractors_by_amount_tbl, contracting_authority_name = "All others", Quantity = as.numeric(crz_contracts_summary_tbl[1,2]) / 1000, ContractPrice = 555, ContractAmount = 666)
# #
# #
# # crz_top_contractors_by_amount_tbl <- crz_top_contractors_by_amount_tbl %>%
# #   rowwise() %>%
# #   mutate(Percentage = ContractPrice / sum)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# # Top 25(50?) contractors by years. For each year: contractor, quantity of contracts, amount of contracts.
# #crz_top_contractors_by_year
#
#
#
#
#
# #crz_top_contractors_by_year_db
#
#
#
#
# crz_contracts_selected_db <- select(crz_contracts_full_db,
#                                  contracting_authority_name,
#                                  contracting_authority_formatted_address,
#                                  contracting_authority_cin_raw,
#                                  supplier_name,
#                                  supplier_formatted_address,
#                                  supplier_cin_raw,
#                                  subject,
#                                  signed_on,
#                                  effective_from,
#                                  effective_to,
#                                  contract_price_amount,
#                                  contract_price_total_amount,
#                                  published_at,
#                                  created_at,
#                                  updated_at
# )
#
# # Contracting autorities - most active
# crz_contr_auth_most_active_db <- crz_contracts_full_db %>%
#   group_by(contracting_authority_name) %>%
#   summarise(Quantity = n(),
#             ContractPrice = sum(contract_price_total_amount),
#             ContractAmount = sum(contract_price_amount)) %>%
#   slice_max(Quantity, n = 50)
#  # arrange(desc(Sum))
#
# # Most active contracting autorities converted to tibble
# crz_contr_auth_most_active_tbl <- as_tibble(crz_contr_auth_most_active_db)
#
#
#
#
#
#
# # treemap
# library(treemap)
# mytreemap <- treemap(
#   crz_contr_auth_most_active_tbl,
#   index="contracting_authority_name",
#   vSize="Quantity",
#   type="index"
#   )
#
#
# print(mytreemap)
#
#
# #ggplot(data = crz_contr_auth_most_active) +
#  # geom_bar(aes(contracting_authority_name))
#
#
#
#
# #crz_contracts_selected_tibble <- as_tibble(crz_contracts_selected)
#
#
