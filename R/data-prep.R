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

#' Escape text for a Typst string literal
#'
#' Internal. Applied automatically to every token that sits inside a
#' `"..."` literal in a template: a backslash, a double quote or a newline
#' there would otherwise end the string or break the compile.
#'
#' @param x Character vector.
#' @return Character vector, escaped.
#' @noRd
typst_escape_string <- function(x) {
  x <- gsub("\\", "\\\\", x, fixed = TRUE)
  x <- gsub("\"", "\\\"", x, fixed = TRUE)
  x <- gsub("\r", "", x, fixed = TRUE)
  gsub("\n", "\\n", x, fixed = TRUE)
}

#' Escape plain text for use in a content token
#'
#' A value for a token that sits in the body of a template is Typst markup:
#' `*bold*` and `_italic_` work, and `#link(...)` embeds a link. That is
#' what you want for formatted text. For plain text from a database or a
#' free-text field, use `typst_escape()` so that characters Typst would
#' treat as markup (`#`, `$`, `*`, `_`, a backtick, `<`, `>`, `@`, `[`, `]`,
#' `~` and the backslash itself) show up literally instead of breaking the
#' compile.
#'
#' Tokens that sit inside a quoted string in a template (organization names,
#' alt text, contact details, file paths) are escaped for you and do not
#' need this.
#'
#' @param x Character vector of plain text.
#' @return Character vector with a backslash before each special character;
#'   `NA` stays `NA`.
#' @examples
#' typst_escape("Cost: $5 (see #3) [draft]")
#' @export
typst_escape <- function(x) {
  gsub("([\\\\#$*_`<>@\\[\\]~])", "\\\\\\1", x, perl = TRUE)
}

brackets_balanced <- function(x) {
  # Drop backslash-escaped characters and quoted segments, then check that
  # square brackets nest and close.
  x <- gsub("\\\\.", "", x, perl = TRUE)
  x <- gsub("\"[^\"]*\"", "", x, perl = TRUE)
  brackets <- strsplit(x, "")[[1]]
  brackets <- brackets[brackets %in% c("[", "]")]
  depth <- 0L
  for (b in brackets) {
    depth <- depth + if (b == "[") 1L else -1L
    if (depth < 0L) {
      return(FALSE)
    }
  }
  depth == 0L
}

#' Stop early on a value that would break a content block
#'
#' Internal. A lone `]` (or an unclosed `[`) in a value that lands in a
#' template's body ends the Typst content block early, and the compile
#' fails with an error about a generated file the user never wrote. Tokens
#' that sit only inside a quoted string are exempt: a bracket is text there.
#'
#' @param spec A [template_spec()].
#' @param data Named list of values.
#' @return `invisible(TRUE)`.
#' @noRd
check_bracket_balance <- function(spec, data) {
  occ <- spec$occurrences
  for (tok in unique(occ$token[!occ$in_string])) {
    value <- data[[tok]]
    if (is.null(value) || length(value) != 1L || is.na(value)) {
      next
    }
    if (!brackets_balanced(as.character(value))) {
      stop(
        "Value for \"", tok, "\" has an unbalanced \"[\" or \"]\", which ",
        "would break the Typst compile. Escape a literal bracket with a ",
        "backslash, or use typst_escape() for plain text.",
        call. = FALSE
      )
    }
  }
  invisible(TRUE)
}
