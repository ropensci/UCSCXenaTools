#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL


.attach_this <- function() { # nocov start
  if (!"UCSCXenaTools" %in% (.packages())) {
    attachNamespace("UCSCXenaTools")
  } # nocov end
}
