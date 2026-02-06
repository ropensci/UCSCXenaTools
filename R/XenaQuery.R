##' Query URL of Datasets before Downloading
##' @author Shixiang Wang <w_shixiang@163.com>
##' @param x a [XenaHub] object
##' @return a `data.frame` contains hosts, datasets and url
##' @importFrom dplyr filter select pull rename mutate
##' @export
##' @examples
##' xe = XenaGenerate(subset = XenaHostNames == "tcgaHub")
##' hosts(xe)
##' \dontrun{
##' xe_query = XenaQuery(xe)
##' }
XenaQuery <- function(x) {
  data_list <- UCSCXenaTools::XenaData

  message("This will check url status, please be patient.")
  datasetsName <- datasets(x)

  query <- data_list %>%
    dplyr::filter(XenaDatasets %in% datasetsName) %>%
    dplyr::rename(hosts = XenaHosts, datasets = XenaDatasets) %>%
    dplyr::mutate(url = ifelse(.data$XenaHostNames == "gdcHub",
      file.path(hosts, "download", url_encode(basename(datasets))),
      file.path(hosts, "download", url_encode(datasets))
    )) %>%
    dplyr::mutate(url = ifelse(!sapply(url, http_error2),
      url, paste0(url, ".gz")
    )) %>%
    dplyr::select(hosts, datasets, url) %>%
    as.data.frame()

  invisible(query)
}

url_encode <- function(x, reserved = TRUE) {
  sapply(x, function(y, reserved) {
    # 保留 /
    as.character(gsub("%2F", "/", utils::URLencode(y, reserved = reserved)))
  }, reserved = reserved)
}

http_error2 <- function(url, max_try = 3L, ...) {
  Sys.sleep(0.001)
  tryCatch(
    {
      # message("==> Trying #", abs(max_try - 4L))
      httr::http_error(url, ...)
    },
    error = function(e) {
      if (max_try == 1) {
        message("Tried 3 times but failed, please check your internet connection!")
        invisible(NULL)
      } else {
        http_error2(url, max_try - 1L)
      }
    }
  )
}
