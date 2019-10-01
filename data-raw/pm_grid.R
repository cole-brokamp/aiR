library(sf)
library(tidyverse)

pm_grid <- read_sf('data-raw/prediction_grid_1km/prediction_grid_1km.shp') %>%
  mutate(id = as.character(id)) %>%
  mutate(id = str_pad(id, width = 4, side = 'left', pad = '0')) %>%
  rename(pm_grid_id = id) %>%
  st_transform(3735)

devtools::use_data(pm_grid, overwrite=TRUE, compress='xz')
