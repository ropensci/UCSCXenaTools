##' Generate and Subset a XenaHub Object from 'XenaData'
##'
##' @author Shixiang Wang <w_shixiang@163.com>
##' @param XenaData a `data.frame`. Default is `data(XenaData)`.
##' The input of this option can only be `data(XenaData)` or its subset.
##' @param subset logical expression indicating elements or rows to keep.
##' @return a [XenaHub] object.
##' @export
##' @examples
##' # 1 get all datasets
##' XenaGenerate()
##' # 2 get TCGA BRCA
##' XenaGenerate(subset = XenaCohorts == "TCGA Breast Cancer (BRCA)")
##' # 3 get all datasets containing BRCA
##' XenaGenerate(subset = grepl("BRCA", XenaCohorts))

XenaGenerate <- function(XenaData = UCSCXenaTools::XenaData,
                         subset = TRUE) {
  enclos <- parent.frame()
  subset <- substitute(subset)
  row_selector <- eval(subset, XenaData, enclos)
  XenaData <- XenaData[row_selector, ]

  .XenaHub(
    hosts = unique(XenaData$XenaHosts),
    cohorts = unique(XenaData$XenaCohorts),
    datasets = XenaData$XenaDatasets
  )
}
