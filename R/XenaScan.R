#' Scan all rows according to user input by a regular expression
#'
#' `XenaScan()` is a function can be used before [XenaGenerate()].
#'
#' @inheritParams XenaGenerate
#' @inheritParams base::grep
#' @importFrom rlang .data
#'
#' @return a `data.frame`
#' @export
#'
#' @examples
#'
#' x1 <- XenaScan(pattern = "Blood")
#' x2 <- XenaScan(pattern = "LUNG", ignore.case = FALSE)
#'
#' x1 %>%
#'   XenaGenerate()
#' x2 %>%
#'   XenaGenerate()
XenaScan <- function(XenaData = UCSCXenaTools::XenaData, pattern = NULL, ignore.case = TRUE) {
  if (!is.null(pattern)) {
    index <- XenaData %>%
      dplyr::rowwise() %>%
      dplyr::do(data.frame(i = any(grepl(pattern,
        .data,
        ignore.case = ignore.case
      )))) %>%
      dplyr::pull(.data$i)
    if (any(index)) {
      data <- XenaData %>% dplyr::filter(index)
      return(data)
    } else {
      return(XenaData[FALSE, ])
    }
  } else {
    return(XenaData)
  }
}
