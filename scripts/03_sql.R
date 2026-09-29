# Load tools and data
library(tidyverse)
library(DBI)
library(RSQLite)
clean <- read_csv("outputs/waiting_list_clean.csv")

# Create a small database and put the data in it
con <- dbConnect(SQLite(), "outputs/waiting_lists.db")
dbWriteTable(con, "waiting_lists",
             clean %>% mutate(archive_date = as.character(archive_date)),
             overwrite = TRUE)

# Question 1: Which hospitals' adult lists grew most from January to August?
growth <- dbGetQuery(con, "
  SELECT hospital,
         SUM(CASE WHEN archive_date = '2026-01-29' THEN total END) AS jan,
         SUM(CASE WHEN archive_date = '2026-08-27' THEN total END) AS aug,
         SUM(CASE WHEN archive_date = '2026-08-27' THEN total END) -
         SUM(CASE WHEN archive_date = '2026-01-29' THEN total END) AS change
  FROM waiting_lists
  WHERE adult_child = 'Adult'
  GROUP BY hospital
  HAVING jan IS NOT NULL AND aug IS NOT NULL
  ORDER BY change DESC
  LIMIT 10
")
print(as_tibble(growth), width = Inf)

# Question 2: Share of adults waiting over 12 months, each month
share <- dbGetQuery(con, "
  SELECT archive_date,
         SUM(total) AS total_waiting,
         SUM(over_12_months) AS over_12,
         ROUND(100.0 * SUM(over_12_months) / SUM(total), 1) AS pct_over_12
  FROM waiting_lists
  WHERE adult_child = 'Adult'
  GROUP BY archive_date
  ORDER BY archive_date
")
print(as_tibble(share), width = Inf)

dbDisconnect(con)