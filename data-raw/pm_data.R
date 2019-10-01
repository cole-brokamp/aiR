library(tidyverse)

pm_data <- readRDS('data-raw/pm_pred_grid.rds') %>%
  mutate(id = str_pad(id, width = 4, side = 'left', pad = '0')) %>%
  rename(pm_grid_id = id)

pm_data_early <- pm_data %>%
  filter(date < as.Date('2008-01-01'))

devtools::use_data(pm_data_early, overwrite=TRUE)

pm_data_late <- pm_data %>%
  filter(date >= as.Date('2008-01-01'))

devtools::use_data(pm_data_late, overwrite=TRUE)
