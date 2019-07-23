##' Query URL of Datasets before Downloading
##' @author Shixiang Wang <w_shixiang@163.com>
##' @param x a [XenaHub] object
##' @return a `data.frame` contains hosts, datasets and url
##' @importFrom dplyr filter select pull rename mutate
##' @export
##' @examples
##' \donttest{
##' xe = XenaGenerate(subset = XenaHostNames == "tcgaHub")
##' hosts(xe)
##' xe_query = XenaQuery(xe)
##' }
XenaQuery <- function(x) {
  message("This will check url status, please be patient.")
  datasetsName <- datasets(x)
  query <- UCSCXenaTools::XenaData %>%
    dplyr::filter(XenaDatasets %in% datasetsName) %>%
    dplyr::rename(hosts = XenaHosts, datasets = XenaDatasets) %>%
    dplyr::mutate(url = file.path(hosts, "download", datasets)) %>%
    dplyr::mutate(url = ifelse(!sapply(url, httr::http_error),
      url, paste0(url, ".gz")
    )) %>%
    dplyr::select(hosts, datasets, url) %>%
    as.data.frame()

  invisible(query)
}
