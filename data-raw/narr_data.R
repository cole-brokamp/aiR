library(tidyverse)

narr_data <- readRDS('data-raw/NARR_data_2000-2015.rds') %>%
  ungroup() %>%
  mutate(date = as.Date(paste(day, year), format='%j %Y')) %>%
  select(-day, -year)

devtools::use_data(narr_data, overwrite=TRUE)
