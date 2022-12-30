if (!require("pacman")) install.packages("pacman")

pacman::p_load(
  DBI,
  RPostgres,
  dplyr,
  dbplyr
)



# Connect to a specific postgres database i.e. Heroku
con <- dbConnect(RPostgres::Postgres(),
                 dbname = 'vszp',
                 host = 'e-vision.biz', # i.e. 'ec2-54-83-201-96.compute-1.amazonaws.com' / 135.181.152.233
                 port = 5432, # or any other port specified by your DBA
                 user = 'vszp',
                 password = '789653')






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






con_rpo <- dbConnect(RPostgres::Postgres(),
                     dbname = 'rpo',
                     host = 're-charge.sk',
                     port = 5432,
                     user = 'postgres',
                     password = '789653')

dbListTables(con_rpo)



con_crz <- dbConnect(RPostgres::Postgres(),
                     dbname = 'crz',
                     host = 're-charge.sk',
                     port = 5432,
                     user = 'postgres',
                     password = '789653')

dbListTables(con_crz)



con_vvo <- dbConnect(RPostgres::Postgres(),
                     dbname = 'vvo',
                     host = 're-charge.sk',
                     port = 5432,
                     user = 'postgres',
                     password = '789653')

dbListTables(con_vvo)




con_ruz <- dbConnect(RPostgres::Postgres(),
                     dbname = 'ruz',
                     host = 're-charge.sk',
                     port = 5432,
                     user = 'postgres',
                     password = '789653')

dbListTables(con_ruz)












