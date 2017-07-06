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
