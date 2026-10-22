#' Format a number with comma grouping
#'
#' Thin wrapper around [scales::comma()] tuned to onepagr's integer-count
#' formatting needs: no decimal places, comma-grouped.
#'
#' A value exactly halfway between two integers is rounded to the even one,
#' as R's own `round()` does (IEC 60559): `2.5` gives `"2"` and `1.5` gives
#' `"2"`. Round half up yourself first if a style guide asks for that.
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
#' A value exactly halfway rounds to the even digit, as in [fmt_n()]:
#' `84.5` gives `"84%"` and `85.5` gives `"86%"`. A fraction such as `0.84`
#' is not rescaled, so `fmt_pct(0.84)` is `"1%"`: multiply by 100 first.
#'
#' The result carries a `%` sign, so it is for text labels. A bar-chart
#' `*_width` token takes a plain number from 0 to 100 (for example `"64.6"`),
#' not this output: `"65%"` is rejected before the compile.
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
