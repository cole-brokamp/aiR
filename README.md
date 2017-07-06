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

Create a demonstration dataset by using randomly sampled locations from the CAGIS master address file:

``` r
library(sf)
#> Linking to GEOS 3.6.1, GDAL 2.1.3, proj.4 4.9.3, lwgeom 2.3.2 r15302
library(tidyverse)

d <- tibble::tribble(
  ~id,         ~lon,        ~lat,
    809089L, -84.69127387, 39.24710734,
    813233L, -84.47798287, 39.12005904,
    814881L, -84.47123583,  39.2631309,
    799697L, -84.41741798, 39.18541228,
    799698L, -84.41395064, 39.18322447
  )
```

Convert this to a simple features object and transform to the Ohio South projection:

``` r
d <- d %>%
    mutate(geometry = map2(lon, lat, ~ st_point(c(.x,.y)))) %>%
    mutate(geometry = st_sfc(geometry, crs=4326)) %>%
    st_sf() %>%
    st_transform(3735)
```

Add in randomly selected dates. Here, we will use a case and control date as is common in case-crossover studies.

``` r
set.seed(12)

d <- d %>%
    mutate(case_date = seq.Date(as.Date('2015-01-01'), as.Date('2015-12-31'), by=1) %>%
             base::sample(size=nrow(d))) %>%
    mutate(control_date = case_date + 7)
```

If using non simulated dates, be sure that the dates column is an object of class `Date`. See `?as.Date` for more information on converting a characteristring tinto a object of class "`Date`".

To estimate the exposures, we will first overlay the locations with the PM2.5 exposure grid to generate the `pm_grid_id` for each location.

``` r
( d <- st_join(d, pm_grid) )
#> Simple feature collection with 5 features and 6 fields
#> geometry type:  POINT
#> dimension:      XY
#> bbox:           xmin: 1347996 ymin: 414089 xmax: 1426020 ymax: 466143.5
#> epsg (SRID):    3735
#> proj4string:    +proj=lcc +lat_1=40.03333333333333 +lat_2=38.73333333333333 +lat_0=38 +lon_0=-82.5 +x_0=600000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=us-ft +no_defs
#>       id       lon      lat  case_date control_date pm_grid_id
#> 1 809089 -84.69127 39.24711 2015-01-26   2015-02-02       3016
#> 2 813233 -84.47798 39.12006 2015-10-25   2015-11-01       4249
#> 3 814881 -84.47124 39.26313 2015-12-09   2015-12-16       2954
#> 4 799697 -84.41742 39.18541 2015-04-08   2015-04-15       3687
#> 5 799698 -84.41395 39.18322 2015-03-03   2015-03-10       3688
#>                         geometry
#> 1 POINT(1347996.00072967 4617...
#> 2 POINT(1407369.99971281 4140...
#> 3 POINT(1410421.21278463 4661...
#> 4 POINT(1425054.3010004 43751...
#> 5 POINT(1426019.99893813 4366...
```

Gather the `case_date` and `control_dates` into one `date` columns with a corresponding `event` column.

``` r
d <- d %>%
    gather(event, date, case_date, control_date) %>%
    mutate(event = stringr::str_replace_all(event, stringr::fixed('_date'),''))
```

Merge the "lookup grid" (`pm_grid`) into the dataset by using `pm_grid_id` and `date`. Note that for the merge to work, the date column must be named `date` and the `pm_grid_id` column must exist.

``` r
( d <- left_join(d, pm_data, by=c('pm_grid_id', 'date')) )
#> Simple feature collection with 10 features and 7 fields
#> geometry type:  POINT
#> dimension:      XY
#> bbox:           xmin: 1347996 ymin: 414089 xmax: 1426020 ymax: 466143.5
#> epsg (SRID):    3735
#> proj4string:    +proj=lcc +lat_1=40.03333333333333 +lat_2=38.73333333333333 +lat_0=38 +lon_0=-82.5 +x_0=600000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=us-ft +no_defs
#>        id       lon      lat pm_grid_id   event       date   pm_pred
#> 1  809089 -84.69127 39.24711       3016    case 2015-01-26 18.352060
#> 2  813233 -84.47798 39.12006       4249    case 2015-10-25  6.133256
#> 3  814881 -84.47124 39.26313       2954    case 2015-12-09 14.948439
#> 4  799697 -84.41742 39.18541       3687    case 2015-04-08  6.677391
#> 5  799698 -84.41395 39.18322       3688    case 2015-03-03 13.853499
#> 6  809089 -84.69127 39.24711       3016 control 2015-02-02  6.008283
#> 7  813233 -84.47798 39.12006       4249 control 2015-11-01  7.499119
#> 8  814881 -84.47124 39.26313       2954 control 2015-12-16  8.122611
#> 9  799697 -84.41742 39.18541       3687 control 2015-04-15  6.207844
#> 10 799698 -84.41395 39.18322       3688 control 2015-03-10 14.304821
#>                          geometry
#> 1  POINT(1347996.00072967 4617...
#> 2  POINT(1407369.99971281 4140...
#> 3  POINT(1410421.21278463 4661...
#> 4  POINT(1425054.3010004 43751...
#> 5  POINT(1426019.99893813 4366...
#> 6  POINT(1347996.00072967 4617...
#> 7  POINT(1407369.99971281 4140...
#> 8  POINT(1410421.21278463 4661...
#> 9  POINT(1425054.3010004 43751...
#> 10 POINT(1426019.99893813 4366...
```
