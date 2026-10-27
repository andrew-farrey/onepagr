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
#' `~`, `/` and the backslash itself) show up literally instead of breaking
#' the compile. A slash is escaped so that `//` in the text, which Typst
#' reads as the start of a comment, cannot drop the rest of the line.
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
  gsub("([\\\\#$*_`<>@\\[\\]~/])", "\\\\\\1", x, perl = TRUE)
}

# The name an error gives a template: a built-in's own name, since every
# built-in's file is called template.typ, and the file name for anything else.
template_label <- function(path) {
  in_registry <- basename(path) == "template.typ" &&
    basename(dirname(dirname(path))) == "templates"
  if (in_registry) basename(dirname(path)) else basename(path)
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
#' @param spec A `template_spec()`.
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

# Names that the values of `start` refer to as {{{name}}}, directly or through
# another value, not counting the starting names themselves. One data list can
# be shared across templates, so this is what limits a check or a substitution
# to what a template's own values can actually reach.
tokens_reachable <- function(data, start) {
  found <- character(0)
  repeat {
    refs <- tokens_referenced_in_values(data[names(data) %in% c(start, found)])
    added <- setdiff(refs, c(start, found))
    if (length(added) == 0) {
      return(found)
    }
    found <- c(found, added)
  }
}

# A value counts as missing when it is absent, empty, or NA.
value_missing <- function(data, tok) {
  value <- data[[tok]]
  length(value) == 0L || is.na(value)[1]
}

# Token names referenced as {{{name}}} inside the supplied string values.
tokens_referenced_in_values <- function(data) {
  pattern <- "[{][{][{][[:space:]]*([A-Za-z0-9_]+)[[:space:]]*[}][}][}]"
  texts <- unlist(lapply(data, function(v) {
    if (is.character(v) && length(v) == 1L && !is.na(v)) v
  }), use.names = FALSE)
  found <- unlist(regmatches(texts, gregexpr(pattern, texts, perl = TRUE)))
  unique(sub(pattern, "\\1", found, perl = TRUE))
}

#' Check data against what a template needs, before anything is rendered
#'
#' Internal. A token is needed when the template body uses it and it has no
#' default; when it is used only by the default of an optional token that
#' `data` leaves out (so that default will be used); or when a value in
#' `data` refers to it as `{{{token}}}`. A needed token that is missing or
#' `NA` stops with an error naming every one. A needed token that is blank
#' gets a warning, unless the template declares `// allow-empty: token`.
#'
#' @param spec A `template_spec()`.
#' @param data Named list of values (before defaults are filled in).
#' @return `invisible(TRUE)`.
#' @noRd
check_template_data <- function(spec, data) {
  tokens <- spec$tokens
  omitted <- names(spec$defaults)[vapply(
    names(spec$defaults), function(tok) value_missing(data, tok), logical(1)
  )]
  uses_omitted_default <- vapply(tokens$needed_by, function(by) {
    !is.na(by) && any(trimws(strsplit(by, ",", fixed = TRUE)[[1]]) %in% omitted)
  }, logical(1))
  # Only what this template's own tokens lead to, through any chain of values:
  # one data list can be shared across templates, and what another template's
  # value refers to is not needed here.
  referenced <- setdiff(
    tokens_reachable(data, tokens$token), names(spec$defaults)
  )
  needed <- unique(c(
    tokens$token[tokens$kind == "required"],
    tokens$token[tokens$kind == "conditional" & uses_omitted_default],
    referenced
  ))

  missing <- needed[vapply(needed, function(tok) value_missing(data, tok), NA)]
  if (length(missing) > 0) {
    stop(
      "Missing or NA required token(s) for ", template_label(spec$path), ": ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }

  # A *_width token used in code (not inside a string) is a bare Typst number
  # that sets a bar's width, so it has to be a plain number from 0 to 100:
  # "65%", "64,6" and "140" all compile or draw wrongly otherwise.
  occ <- spec$occurrences
  for (tok in unique(occ$token[!occ$in_string & grepl("_width$", occ$token)])) {
    if (value_missing(data, tok)) {
      next
    }
    text <- trimws(as.character(data[[tok]][1]))
    if (!grepl("^[0-9]+([.][0-9]+)?$", text) || as.numeric(text) > 100) {
      stop(
        'Token "', tok, '" must be a plain number from 0 to 100 (for ',
        'example 64.6), not "', text, '".',
        call. = FALSE
      )
    }
  }

  blank <- needed[vapply(needed, function(tok) {
    value <- data[[tok]]
    is.character(value) && !nzchar(trimws(value[1]))
  }, NA)]
  blank <- setdiff(blank, spec$allow_empty)
  if (length(blank) > 0) {
    warning(
      "Blank value for required token(s): ", paste(blank, collapse = ", "),
      '. If blank is intended, declare "// allow-empty: ', blank[1],
      '" in the template.',
      call. = FALSE
    )
  }
  invisible(TRUE)
}
