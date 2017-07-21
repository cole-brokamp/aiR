<!-- README.md is generated from README.Rmd. Please edit that file -->
aiR
===

aiR is used to assess PM2.5 exposures in the Cincinnati, Ohio area. The package creates predictions based on a spatiotemporal hybrid satellite/land use random forest model. PM2.5 exposure predictions are available at 1 x 1 km grid resolution covering the "seven county" area (OH: Hamilton, Clermont, Warren, Butler; KY: Boone, Kenton, Campbell) on a daily basis from 2000 - 2015.

Installing
----------

aiR is a private package hosted on GitHub.

Install with:

``` r
remotes::install_github('cole-brokamp/aiR')
```

Example
-------

This example covers how to extract PM2.5 exposure estimates given latitude/longitude coordinates and dates.

Note that `pm_grid` and `pm_data` are both R objects that will be available upon loading of the package. However, `pm_data` has to be split into two smaller files to be under GitHub's 100 MB filesize limit. This workaround requires binding the two datasets into one upon package loading.

``` r
library(aiR)
pm_data <- bind_rows(pm_data_early, pm_data_late)
```

Create a demonstration dataset of random coordinates and dates:

``` r
library(sf)
#> Linking to GEOS 3.6.1, GDAL 2.2.0, proj.4 4.9.3, lwgeom 2.3.2 r15302
library(tidyverse)

d <- tibble::tribble(
  ~id,         ~lon,        ~lat,
    809089L, -84.69127387, 39.24710734,
    813233L, -84.47798287, 39.12005904,
    814881L, -84.47123583,  39.2631309,
    799697L, -84.41741798, 39.18541228,
    799698L, -84.41395064, 39.18322447
  )

set.seed(12)

d <- d %>%
    mutate(date = seq.Date(as.Date('2015-01-01'), as.Date('2015-12-31'), by=1) %>%
             base::sample(size=nrow(d)))
```

Convert this to a simple features object and transform to the Ohio South projection. Reprojection is necessary because `pm_grid` is in the Ohio South projection.

``` r
d <- d %>%
  st_as_sf(coords = c('lon', 'lat'), crs=4326) %>% 
    st_transform(3735)
```

To estimate the exposures, we will first overlay the locations with the PM2.5 exposure grid to generate the `pm_grid_id` for each location.

``` r
( d <- st_join(d, pm_grid) )
#> Simple feature collection with 5 features and 3 fields
#> geometry type:  POINT
#> dimension:      XY
#> bbox:           xmin: 1347996 ymin: 414089 xmax: 1426020 ymax: 466143.5
#> epsg (SRID):    3735
#> proj4string:    +proj=lcc +lat_1=40.03333333333333 +lat_2=38.73333333333333 +lat_0=38 +lon_0=-82.5 +x_0=600000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=us-ft +no_defs
#>       id       date pm_grid_id                       geometry
#> 1 809089 2015-01-26       3016 POINT(1347996.00072967 4617...
#> 2 813233 2015-10-25       4249 POINT(1407369.99971281 4140...
#> 3 814881 2015-12-09       2954 POINT(1410421.21278463 4661...
#> 4 799697 2015-04-08       3687 POINT(1425054.3010004 43751...
#> 5 799698 2015-03-03       3688 POINT(1426019.99893813 4366...
```

Then merge the "lookup grid" (`pm_grid`) into the dataset by using `pm_grid_id` and `date`. Note that for the merge to work, the date column must be named `date` and be of class `Date` and the `pm_grid_id` column must exist.

``` r
( d <- left_join(d, pm_data, by=c('pm_grid_id', 'date')) )
#> Simple feature collection with 5 features and 4 fields
#> geometry type:  POINT
#> dimension:      XY
#> bbox:           xmin: 1347996 ymin: 414089 xmax: 1426020 ymax: 466143.5
#> epsg (SRID):    3735
#> proj4string:    +proj=lcc +lat_1=40.03333333333333 +lat_2=38.73333333333333 +lat_0=38 +lon_0=-82.5 +x_0=600000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=us-ft +no_defs
#>       id       date pm_grid_id   pm_pred                       geometry
#> 1 809089 2015-01-26       3016 18.352060 POINT(1347996.00072967 4617...
#> 2 813233 2015-10-25       4249  6.133256 POINT(1407369.99971281 4140...
#> 3 814881 2015-12-09       2954 14.948439 POINT(1410421.21278463 4661...
#> 4 799697 2015-04-08       3687  6.677391 POINT(1425054.3010004 43751...
#> 5 799698 2015-03-03       3688 13.853499 POINT(1426019.99893813 4366...
```

Example adding weather data
---------------------------

Several NARR weather variables are available as daily means for the entire study area in the `narr_data` R object. View the help (`?narr_data`) to see more details about the individual variables.

To merge in humidity and temperature, we will subset `narr_data` to those variables and join to our dataset:

``` r
( d <- left_join(d, narr_data %>% select(date, air.2m, rhum.2m), by='date') )
#> Simple feature collection with 5 features and 6 fields
#> geometry type:  POINT
#> dimension:      XY
#> bbox:           xmin: 1347996 ymin: 414089 xmax: 1426020 ymax: 466143.5
#> epsg (SRID):    3735
#> proj4string:    +proj=lcc +lat_1=40.03333333333333 +lat_2=38.73333333333333 +lat_0=38 +lon_0=-82.5 +x_0=600000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=us-ft +no_defs
#>       id       date pm_grid_id   pm_pred   air.2m  rhum.2m
#> 1 809089 2015-01-26       3016 18.352060 273.4738 84.21274
#> 2 813233 2015-10-25       4249  6.133256 289.7672 72.24364
#> 3 814881 2015-12-09       2954 14.948439 279.5706 86.86406
#> 4 799697 2015-04-08       3687  6.677391 292.4687 84.62123
#> 5 799698 2015-03-03       3688 13.853499 271.8341 87.85282
#>                         geometry
#> 1 POINT(1347996.00072967 4617...
#> 2 POINT(1407369.99971281 4140...
#> 3 POINT(1410421.21278463 4661...
#> 4 POINT(1425054.3010004 43751...
#> 5 POINT(1426019.99893813 4366...
```
