##' Query ProbeMap URL of Datasets
##'
##' If dataset has no ProbeMap, it will be ignored.
##'
##' @author Shixiang Wang <w_shixiang@163.com>
##' @param x a [XenaHub] object
##' @return a `data.frame` contains hosts, datasets and url
##' @importFrom dplyr filter select pull rename mutate
##' @export
##' @examples
##' \donttest{
##' xe = XenaGenerate(subset = XenaHostNames == "tcgaHub")
##' hosts(xe)
##' xe_query = XenaQueryProbeMap(xe)
##' }
XenaQueryProbeMap <- function(x) {
  message("Check ProbeMap urls of datasets.")
  datasetsName <- datasets(x)
  query <- UCSCXenaTools::XenaData %>%
    dplyr::filter((XenaDatasets %in% datasetsName) & (!is.na(ProbeMap)))

  if (nrow(query) == 0) {
    invisible(data.frame(stringsAsFactors = FALSE))
  } else {
    query <- query %>%
      dplyr::rename(hosts = XenaHosts, datasets = ProbeMap) %>%
      dplyr::mutate(url = file.path(hosts, "download", datasets)) %>%
      dplyr::mutate(url = ifelse(!sapply(url, httr::http_error),
        url, paste0(url, ".gz")
      )) %>%
      dplyr::select(hosts, datasets, url) %>%
      as.data.frame()

    invisible(unique(query))
  }
}