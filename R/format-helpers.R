#' Format a number with comma grouping
#'
#' Thin wrapper around [scales::comma()] tuned to onepagr's integer-count
#' formatting needs: no decimal places, comma-grouped.
#'
#' @param x Numeric vector.
#' @return Character vector.
#' @examples
#' fmt_n(c(1234, 56789))
#' @export
fmt_n <- function(x) {
  scales::comma(x, accuracy = 1)
}

#' Format a value as a percent string
#'
#' Thin wrapper around [scales::percent()]. Input is already on a 0-100
#' scale (e.g. 84, not 0.84), matching the convention used throughout
#' onepagr's reference templates and R data-prep scripts.
#'
#' @param x Numeric vector, already scaled 0-100.
#' @param digits Number of decimal places. Default 0.
#' @return Character vector.
#' @examples
#' fmt_pct(84.2)
#' fmt_pct(84.216, digits = 1)
#' @export
fmt_pct <- function(x, digits = 0) {
  scales::percent(x, scale = 1, accuracy = 10^(-digits))
}
