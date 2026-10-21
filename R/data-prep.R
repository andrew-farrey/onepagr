#' Turn each data value into the single string whisker will substitute
#'
#' Internal. whisker formats a number with `as.character()`, which prints
#' `100000` as `1e+05` and `1/3` as `0.333333333333333`, and the result lands
#' in the PDF without any error. This stops that at the door: a whole number,
#' or a short decimal such as `1.1`, is formatted plainly; a number with more
#' digits than that is rejected, so the analyst chooses the precision with
#' [fmt_n()] or [fmt_pct()] instead of getting 15 digits by accident.
#'
#' @param data Named list of values.
#' @return The list with every value a length-one string (or `NA`/`NULL`,
#'   which are left for the missing-value checks).
#' @noRd
coerce_data_values <- function(data) {
  for (name in names(data)) {
    data[name] <- list(coerce_one_value(name, data[[name]]))
  }
  data
}

coerce_one_value <- function(name, value) {
  if (is.null(value)) {
    return(NULL)
  }
  if (length(value) == 0L) {
    return(value)
  }
  if (length(value) != 1L) {
    stop(
      "Value for \"", name, "\" has length ", length(value),
      "; pass a single string.",
      call. = FALSE
    )
  }
  if (is.atomic(value) && is.na(value)) {
    return(value)
  }
  if (is.character(value)) {
    return(value)
  }
  if (is.factor(value) || inherits(value, c("Date", "POSIXt"))) {
    return(as.character(value))
  }
  if (is.logical(value)) {
    stop(
      "Value for \"", name, "\" is an R logical; use the string \"true\" or ",
      "\"false\" (or the exact text you want shown).",
      call. = FALSE
    )
  }
  if (is.numeric(value)) {
    return(format_number_value(name, value))
  }
  stop(
    "Value for \"", name, "\" is a ", class(value)[1],
    ", which cannot go into a template; pass a single string.",
    call. = FALSE
  )
}

format_number_value <- function(name, value) {
  if (!is.finite(value)) {
    stop(
      "Value for \"", name, "\" is not a finite number (", value, ").",
      call. = FALSE
    )
  }
  if (value == round(value)) {
    return(format(value, scientific = FALSE, trim = TRUE))
  }
  if (as.numeric(format(value, digits = 6)) == value) {
    return(format(value, scientific = FALSE, trim = TRUE, digits = 6))
  }
  stop(
    "Value for \"", name, "\" is the number ", format(value, digits = 15),
    "; format it first with fmt_n() or fmt_pct() so the report shows the ",
    "precision you intend.",
    call. = FALSE
  )
}
