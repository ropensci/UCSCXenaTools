#' View Info of Dataset or Cohort at UCSC Xena Website Using Web browser
#'
#' This will open dataset/cohort link of UCSC Xena
#' in user's default browser.
#' @param x a [XenaHub] object.
#' @param type one of "dataset" and "cohort".
#' @param multiple if `TRUE`, browse multiple links instead of throwing error.
#' @importFrom utils URLencode browseURL
#' @export
#'
#' @examples
#' \donttest{
#' XenaGenerate(subset = XenaHostNames == "tcgaHub") %>%
#'   XenaFilter(filterDatasets = "clinical") %>%
#'   XenaFilter(filterDatasets = "LUAD") -> to_browse
#' }
XenaBrowse <- function(x, type = c("dataset", "cohort"), multiple = FALSE) { # nocov start
  if (!inherits(x, "XenaHub")) {
    stop("Input x must be a XenaHub object.")
  }

  type <- match.arg(type)

  if (type == "dataset") {
    all_datasets <- datasets(x)
    if (length(all_datasets) != 1) {
      if (!multiple) stop("This function limite 1 dataset to browse.\n Set multiple to TRUE if you want to browse multiple links.")
      for (i in all_datasets) {
        xe_tmp <- XenaFilter(x,
          filterDatasets = i,
          ignore.case = FALSE, fixed = TRUE
        )
        y <- utils::URLencode(
          paste0(
            "https://xenabrowser.net/datapages/?",
            "dataset=", datasets(xe_tmp),
            "&host=", hosts(xe_tmp)
          )
        )
        utils::browseURL(y)
      }
    } else {
      y <- utils::URLencode(
        paste0(
          "https://xenabrowser.net/datapages/?",
          "dataset=", datasets(x),
          "&host=", hosts(x)
        )
      )
      utils::browseURL(y)
    }
  } else {
    all_cohorts <- cohorts(x)
    if (length(all_cohorts) != 1) {
      if (!multiple) stop("This function limite 1 cohort to browse. \n Set multiple to TRUE if you want to browse multiple links.")
      for (i in all_cohorts) {
        xe_tmp <- XenaFilter(x,
          filterCohorts = i,
          ignore.case = FALSE, fixed = TRUE
        )
        y <- utils::URLencode(
          paste0(
            "https://xenabrowser.net/datapages/?",
            "cohort=", cohorts(xe_tmp)
          )
        )
        utils::browseURL(y)
      }
    } else {
      y <- utils::URLencode(
        paste0(
          "https://xenabrowser.net/datapages/?",
          "cohort=", cohorts(x)
        )
      )
      utils::browseURL(y)
    }
  }

  invisible(NULL)
} # nocov end

utils::globalVariables(c("XenaDatasets", "XenaHosts", "ProbeMap"))
