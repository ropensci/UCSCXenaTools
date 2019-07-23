##' Filter a XenaHub Object
##'
##' One of main functions in **UCSCXenatools**. It is used to filter
##' `XenaHub` object according to cohorts, datasets. All datasets can be found
##' at <https://xenabrowser.net/datapages/>.
##'
##' @param x a [XenaHub] object
##' @param filterCohorts default is `NULL`. A character used to filter cohorts,
##' regular expression is supported.
##' @param filterDatasets default is `NULL`. A character used to filter datasets,
##' regular expression is supported.
##' @param ignore.case if `FALSE`, the pattern matching is case sensitive
##' and if `TRUE`, case is ignored during matching.
##' @param ... other arguments except `value` passed to [base::grep()].
##' @return a `XenaHub` object
##' @author Shixiang Wang <w_shixiang@163.com>
##' @export
##' @examples
##' # operate TCGA datasets
##' xe = XenaGenerate(subset = XenaHostNames == "tcgaHub")
##' xe
##' # get all names of clinical data
##' xe2 = XenaFilter(xe, filterDatasets = "clinical")
##' datasets(xe2)
XenaFilter <- function(x,
                       filterCohorts = NULL,
                       filterDatasets = NULL,
                       ignore.case = TRUE, ...) {
  if (is.null(filterCohorts) & is.null(filterDatasets)) {
    warning("No operation for input, do nothing...")
    return(x)
  }

  cohorts_select <- character()
  datasets_select <- character()

  # suppress binding notes
  XenaHosts <- XenaCohorts <- XenaDatasets <- NULL

  if (!is.null(filterCohorts)) {
    cohorts_select <- grep(
      pattern = filterCohorts,
      x@cohorts,
      ignore.case = ignore.case,
      value = TRUE,
      ...
    )
  }

  if (!is.null(filterDatasets)) {
    datasets_select <- grep(
      pattern = filterDatasets,
      x@datasets,
      ignore.case = ignore.case,
      value = TRUE,
      ...
    )
  }

  if (identical(cohorts_select, character()) &
    identical(datasets_select, character())) {
    warning("No valid cohorts or datasets find! Please check your input.")
  } else {
    if (identical(cohorts_select, character()) &
      !identical(datasets_select, character())) {
      UCSCXenaTools::XenaGenerate(subset = XenaHosts %in% x@hosts &
        XenaDatasets %in% datasets_select)
    } else { # nocov start
      if (!identical(cohorts_select, character()) &
        identical(datasets_select, character())) {
        UCSCXenaTools::XenaGenerate(subset = XenaHosts %in% x@hosts &
          XenaCohorts %in% cohorts_select)
      } else {
        UCSCXenaTools::XenaGenerate(
          subset = XenaHosts %in% x@hosts &
            XenaCohorts %in% cohorts_select &
            XenaDatasets %in% datasets_select
        )
      }
    } # nocov end
  }
}
