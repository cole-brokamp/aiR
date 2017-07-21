#' @importFrom tibble tibble
NULL

#' PM2.5 dataset (2000 - 2008).
#'
#' Dataset of estimated daily PM2.5 concentrations from 2000 - 2008. (as
#' microgram per meter cubed) corresponding to each \code{pm_grid_id} from the
#' \code{pm_grid}. The \code{pm_data} is split into two smaller datasets as a
#' workaround for GitHub's 100 MB filesize limit.  Please see the package README
#' for details.
#'
#' @format A tibble with columns \code{pm_grid_id}, \code{date}, and
#'   \code{pm_pred}.
"pm_data_early"

#' PM2.5 dataset (2009 - 2015).
#'
#' Dataset of estimated daily PM2.5 concentrations from 2009 - 2015. (as
#' microgram per meter cubed) corresponding to each \code{pm_grid_id} from the
#' \code{pm_grid}. The \code{pm_data} is split into two smaller datasets as a
#' workaround for GitHub's 100 MB filesize limit.  Please see the package README
#' for details.
#'
#' @format A tibble with columns \code{pm_grid_id}, \code{date}, and
#'   \code{pm_pred}.
"pm_data_early"

#' PM2.5 exposure assessment grid.
#'
#' The 1 x 1 km grid used for exposure assessment.
#'
#' @format A simple features object continaing the coordinate geometry and
#'   corresponding \code{pm_grid_id}.
"pm_grid"

#' Daily Weather data.
#'
#' Daily weather data for study area used within the PM2.5 prediction model.
#' Derived from the NCEP North American Regional Reanalysis (NARR).
#'
#' @format A tibble with nine variables:
#' \describe{
#' \item{\code{vis}}{visibility}
#' \item{\code{hpbl}}{planetary boundary height (m)}
#' \item{\code{air.2m}}{air temperature at 2 m (K)}
#' \item{\code{rhum.2m}}{relative humidity at 2m}
#' \item{\code{prate}}{precipitation rate (kg/m^2/s)}
#' \item{\code{apcp}}{accumulated total precipitation (kg/m^2)}
#' \item{\code{pres.sfc}}{pressure (Pa)}
#' \item{\code{uwnd.10m}}{U-wind at 10 m (m/s)}
#' \item{\code{vwnd.10m}}{V-wind at 10 m (m/s)}
#' }
"narr_data"

