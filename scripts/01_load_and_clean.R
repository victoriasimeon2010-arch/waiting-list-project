# Load the tools
library(tidyverse)
library(janitor)

# Read the data file
raw <-raw <- read_csv(list.files("data", pattern = "\\.csv$", full.names = TRUE)[1])


# Look at the data
glimpse(raw)