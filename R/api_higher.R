# FUN: higher API functions

##' Get hosts of XenaHub object
##' @param x a [XenaHub] object
##' @importFrom methods slot
##' @return a character vector contains hosts
##' @export
##' @examples xe = XenaGenerate(subset = XenaHostNames == "tcgaHub"); hosts(xe)
hosts <- function(x) {
  unname(slot(x, "hosts"))
}
##' Get cohorts of XenaHub object
##' @param x a [XenaHub] object
##' @return a character vector contains cohorts
##' @importFrom methods slot
##' @export
##' @examples xe = XenaGenerate(subset = XenaHostNames == "tcgaHub"); cohorts(xe)
cohorts <- function(x) {
  slot(x, "cohorts")
}
##' Get datasets of XenaHub object
##' @param x a [XenaHub] object
##' @return a character vector contains datasets
##' @importFrom methods slot
##' @export
##' @examples xe = XenaGenerate(subset = XenaHostNames == "tcgaHub"); datasets(xe)
datasets <- function(x) {
  slot(x, "datasets")
}

##' Get Samples of a XenaHub object according to 'by' and 'how' action arguments
##'
##' One is often interested in identifying samples or features present in each data set,
##' or shared by all data sets, or present in any of several data sets.
##' Identifying these samples, including samples in arbitrarily chosen data sets.
##' @param x a [XenaHub] object
##' @param i default is a empty character, it is used to specify
##' the host, cohort or dataset by `by` option otherwise
##' info will be automatically extracted by code
##' @param by a character specify `by` action
##' @param how a character specify `how` action
##' @return a list include samples
##' @export
##' @examples
##' \dontrun{
##' xe = XenaHub(cohorts = "Cancer Cell Line Encyclopedia (CCLE)")
##' # samples in each dataset, first host
##' x = samples(xe, by="datasets", how="each")[[1]]
##' lengths(x)        # data sets in ccle cohort on first (only) host
##' }

samples <- function(x,
                    i = character(),
                    by = c("hosts", "cohorts", "datasets"),
                    how = c("each", "any", "all")) {
  stopifnot(methods::is(x, "XenaHub"), is.character(i))
  by <- match.arg(by)
  how <- match.arg(how)

  fun <- switch(
    match.arg(by),
    hosts = .samples_by_host,
    cohorts = .samples_by_cohort,
    datasets = .samples_by_dataset
  )
  fun(x, i, how)
}
