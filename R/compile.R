#' Extract required whisker tokens from a .typ file
#'
#' Scans for `{{{token}}}` (triple-brace, unescaped) occurrences -- onepagr
#' templates never use double-brace `{{token}}` (double-brace HTML-escapes
#' and corrupts any value containing "&", "<", or ">"). Section markers
#' and comments are not matched -- onepagr templates use flat
#' triple-brace substitution only, no Mustache sections or partials.
#'
#' @param path Character. Path to a .typ file.
#' @return Character vector of unique token names, in first-appearance order.
#' @export
extract_required_tokens <- function(path) {
  text <- paste(readLines(path, warn = FALSE), collapse = "\n")
  matches <- regmatches(
    text, gregexpr("\\{\\{\\{\\s*([a-zA-Z0-9_.]+)\\s*\\}\\}\\}", text)
  )[[1]]
  tokens <- gsub("^\\{\\{\\{\\s*|\\s*\\}\\}\\}$", "", matches)
  unique(tokens)
}

#' Validate whisker data against a template's required tokens
#'
#' Raises a clear error listing every missing or NA token before whisker
#' or Typst ever run, instead of letting a missing token silently render
#' as blank text.
#'
#' @param path Character. Path to a .typ file.
#' @param data Named list of whisker substitution values.
#' @return Invisibly `TRUE` if validation passes.
#' @export
validate_template_data <- function(path, data) {
  required <- extract_required_tokens(path)
  is_missing <- function(tok) {
    !tok %in% names(data) || length(data[[tok]]) == 0 || is.na(data[[tok]])[1]
  }
  problems <- required[vapply(required, is_missing, logical(1))]
  if (length(problems) > 0) {
    stop(
      "Missing or NA required token(s) for ", basename(path), ": ",
      paste(problems, collapse = ", "),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

#' Compile a .typ file with whisker-substituted data via Quarto/Typst
#'
#' Low-level primitive: whisker-renders `path` against `data`, writes the
#' result next to `path`, then compiles it to `output` via `quarto typst
#' compile --pdf-standard ua-1 --features a11y-extras`. Works on any .typ
#' file -- a package-shipped template or a user's own
#' `export_template()`-edited copy -- since required-token validation is
#' derived by scanning the file itself, not a separately-maintained
#' manifest.
#'
#' @param path Character. Path to a .typ file. Its
#'   `theme.typ`/`components.typ`/assets must already be alongside it, so
#'   Typst's relative `#import` paths resolve correctly.
#' @param data Named list of whisker substitution values.
#' @param output Character. Path to write the compiled PDF to.
#' @return Character, the `output` path, invisibly.
#' @export
compile_typst <- function(path, data, output) {
  validate_template_data(path, data)

  quarto_bin <- quarto::quarto_path()
  if (is.null(quarto_bin)) {
    stop(
      "Quarto was not found. Run onepagr::check_quarto() for details, or ",
      "onepagr::install_quarto() to install it.",
      call. = FALSE
    )
  }

  template_text <- paste(readLines(path, warn = FALSE), collapse = "\n")
  rendered <- whisker::whisker.render(template_text, data)
  typ_out <- file.path(
    dirname(path),
    paste0(tools::file_path_sans_ext(basename(path)), "_rendered.typ")
  )
  writeLines(rendered, typ_out)

  result <- system2(
    quarto_bin,
    args = c(
      "typst", "compile",
      "--pdf-standard", "ua-1",
      "--features", "a11y-extras",
      shQuote(typ_out), shQuote(output)
    ),
    stdout = TRUE, stderr = TRUE
  )

  if (!file.exists(output)) {
    stop(
      "Typst compilation failed:\n", paste(result, collapse = "\n"),
      call. = FALSE
    )
  }

  invisible(output)
}
