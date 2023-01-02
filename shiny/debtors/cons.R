if (!require("pacman")) install.packages("pacman")

pacman::p_load(
  DBI,
  RPostgres,
  dplyr,
  dbplyr,
  tidyverse
)







con_vszp <- dbConnect(RPostgres::Postgres(),
                      dbname = "vszp",
                      host = "re-charge.sk",
                      port = 5432,
                      user = "postgres",
                      password = "789653")

dbListTables(con_vszp)






con_socpoist <- dbConnect(RPostgres::Postgres(),
                          dbname = "socpoist",
                          host = "re-charge.sk",
                          port = 5432,
                          user = "postgres",
                          password = "789653")

dbListTables(con_socpoist)


vszp.debtors <- tbl(con_vszp, "debtors")
socpoist.debtors <- tbl(con_socpoist, "debtors")


vszp.debtors <- vszp.debtors %>%
  select(name, address, city, cin, payer_type, amount, full_health_care_claim) %>%
  mutate(source = "vszp")

socpoist.debtors <- socpoist.debtors %>%
  select(name, address, city, amount) %>%
  mutate(source = "socpoist")


debtors.full.join <- vszp.debtors %>%
  full_join(
    socpoist.debtors,
    by = c("name", "source"),
    copy = TRUE
  ) %>%
  rename(
    address.vszp = address.x,
    address.socpoist = address.y,
    amount.vszp = amount.x,
    amount.socpoist = amount.y,
    city.vszp = city.x,
    city.socpoist = city.y,
    cin.vszp = cin,
  ) %>%
  relocate(source, .before = name)

debtors.full.join.summarised <- debtors.full.join %>%
  group_by(source, name, address.vszp, address.socpoist, amount.vszp, amount.socpoist) %>%
  summarise(
    count = n(),
    sum.amount.vszp = sum(amount.vszp),
    sum.amount.socpoist = sum(amount.socpoist)
  ) %>%
  mutate(bigger = pmax(amount.vszp, amount.socpoist)) %>%
  # arrange(desc(count), desc(bigger))
  arrange(desc(count), desc(pmax(amount.vszp, amount.socpoist)))







debtors.full.join_L <- pivot_longer(
  cols = !c("address.vszp", "city.vszp", "cin.vszp",
  )

  debtors.full.join %>% group_by(name) %>% arrange(desc(n()))

  debtors.full.join %>% group_by(name, address.x, address.y) %>% summarise(a = n()) %>% arrange(desc(a))


  debtors.all <- debtors.full.join %>%
    select(name, source, address.x, address.y,amount.x, amount.y) %>%
    group_by(name, address.x, address.y, source) %>%
    summarise(count = n(), amount.vszp=sum(amount.x), amount.socpoist=sum(amount.y))%>%
    #arrange(desc(count), desc(amount.vszp), desc(amount.socpoist))
    #arrange(desc(count), desc(pmax(amount.vszp, amount.socpoist)))
    arrange(desc(count), desc(pmax(amount.vszp, amount.socpoist))))


debtors.all %>% mutate(a = pmax(amount.vszp, amount.socpoist))


debtors.all2 <- data.frame(debtors.all)
pmax(debtors.all2$amount.vszp, debtors.all2$amount.socpoist)



filter(debtors.full.join, grepl("horváth jozef", name, ignore.case = TRUE)) %>% print(n=100)






debtors.left.join <- left_join(
  vszp.debtors,
  socpoist.debtors,
  by = "name",
  copy = TRUE
) %>%
  as_tibble()

debtors.left.join



vszp.debtors <- vszp.debtors %>%
