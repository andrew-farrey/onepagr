#' Extract required whisker tokens from a .typ file
#'
#' Scans for `{{{token}}}` (triple-brace, unescaped) occurrences: onepagr
#' templates never use double-brace `{{token}}` (double-brace HTML-escapes
#' and corrupts any value containing "&", "<", or ">"). Section markers
#' and comments are not matched: onepagr templates use flat
#' triple-brace substitution only, no Mustache sections or partials.
#'
#' `//` line comments are stripped before scanning: Typst templates
#' routinely document the triple-brace convention with a literal
#' `{{{token}}}` example in a header comment (this is a real case, not
#' hypothetical; the reference trend-snapshot template does exactly
#' this), and without stripping comments first, that illustrative example
#' is indistinguishable from a real required token. `//` is unambiguously
#' a comment marker in Typst (division is a single `/`), so this is safe
#' for any Typst source: the one caveat is a literal `//` inside a
#' string constant in the template's own code (not data, which arrives
#' via tokens), which onepagr's built-in templates never do.
#'
#' A token with a declared default (see the optional-token marker in
#' [compile_typst()]) is not required, so it is left out of the result.
#' A default can refer to other tokens (`{{{token}}}`); those are required.
#'
#' @param path Character. Path to a .typ file.
#' @return Character vector of unique token names, in first-appearance order.
#' @examples
#' path <- resolve_template("cohort_summary")
#' extract_required_tokens(path)
#' @export
extract_required_tokens <- function(path) {
  lines <- readLines(path, warn = FALSE)
  lines <- sub("//.*$", "", lines)
  text <- paste(lines, collapse = "\n")
  matches <- regmatches(
    text, gregexpr("\\{\\{\\{\\s*([a-zA-Z0-9_.]+)\\s*\\}\\}\\}", text)
  )[[1]]
  tokens <- gsub("^\\{\\{\\{\\s*|\\s*\\}\\}\\}$", "", matches)
  defaults <- extract_token_defaults(path)
  # A default may itself refer to other tokens, e.g. a heading default of
  # "Results (N = {{{n_total}}})": those stay required.
  token_pattern <- "\\{\\{\\{\\s*([a-zA-Z0-9_.]+)\\s*\\}\\}\\}"
  referenced <- unlist(regmatches(
    unlist(defaults), gregexpr(token_pattern, unlist(defaults))
  ))
  referenced <- gsub("^\\{\\{\\{\\s*|\\s*\\}\\}\\}$", "", referenced)
  setdiff(unique(c(tokens, referenced)), names(defaults))
}

#' List the tokens a template takes
#'
#' Shows every `{{{token}}}` a template reads: the ones your `data` list must
#' supply, and the optional ones with the value each falls back to. Use it to
#' find the name of a heading, label, caption or paragraph you want to
#' reword, then pass that name in `data` (see [render_onepager()]).
#'
#' Optional tokens are named by what they set: `heading_*` (section
#' headings), `label_*` (box and group labels), `banner_label` and
#' `banner_issued` (alert banners), `stat_*` (captions on numbers), `bar_*`
#' (bar-chart row labels), `text_*` (paragraphs, bullets and notes),
#' `alt_*` (chart and map alt text), `strip_label_*` and `footer_label_*`
#' (the metadata strip and footer labels), and `chips_*` (a short list of
#' items separated by `|`). Filter on those prefixes with [grepl()].
#'
#' A default is Typst markup and can itself contain `{{{token}}}`
#' references, which are filled from your data. A token that only a default
#' refers to still counts as required.
#'
#' @param template Character. A built-in template name (see
#'   [list_templates()]), or the path to a `.typ` file such as one written by
#'   [export_template()].
#' @return A data frame with one row per token and columns `token`,
#'   `required` (logical) and `default` (`NA` for a required token). Required
#'   tokens come first, then optional ones, each in the order the template
#'   uses them.
#' @examples
#' tokens <- template_tokens("cohort_summary")
#' head(tokens)
#'
#' # Every section heading you can reword, with its current text:
#' tokens[grepl("^heading_", tokens$token), c("token", "default")]
#' @export
template_tokens <- function(template) {
  path <- if (utils::file_test("-f", template)) {
    template
  } else {
    resolve_template(template)
  }
  defaults <- extract_token_defaults(path)
  required <- extract_required_tokens(path)
  data.frame(
    token = c(required, names(defaults)),
    required = rep(c(TRUE, FALSE), c(length(required), length(defaults))),
    default = c(rep(NA_character_, length(required)), unlist(defaults)),
    row.names = NULL,
    stringsAsFactors = FALSE
  )
}

#' Warn about data names no template uses
#'
#' Internal. A name in `data` that is not a token of this template, or of any
#' built-in template, is ignored by the render, which is easy to miss when it
#' is a misspelled optional token (`heading_glnce`). A name that belongs to
#' another built-in template stays silent, so one data list can be shared
#' across templates. When a name is close to one of this template's own
#' tokens, the warning suggests it.
#'
#' @param path Character. Path to a .typ file.
#' @param data Named list of whisker substitution values.
#' @return Invisibly, the ignored names.
#' @keywords internal
warn_unknown_tokens <- function(path, data) {
  own <- template_tokens(path)$token
  builtin <- unlist(lapply(
    list_templates(), function(t) template_tokens(t)$token
  ))
  names_in <- setdiff(names(data), c("", NA))
  unknown <- setdiff(names_in, c(own, builtin))
  if (length(unknown) == 0) {
    return(invisible(character(0)))
  }
  hint <- function(name) {
    distance <- drop(utils::adist(name, own))
    closest <- which.min(distance)
    if (distance[closest] <= max(2, floor(nchar(name) / 4))) {
      paste0(" Did you mean \"", own[closest], "\"?")
    } else {
      ""
    }
  }
  lines <- vapply(unknown, function(name) {
    paste0(
      "\"", name, "\" was ignored: it is not a token of this template ",
      "(see template_tokens()).", hint(name)
    )
  }, character(1))
  warning(paste(lines, collapse = "\n"), call. = FALSE)
  invisible(unknown)
}

#' Read a template's optional-token defaults
#'
#' Internal. A template declares a token as optional with a `//` comment
#' line of the form `// optional-token: name = default`. Callers who don't
#' supply `name` get `default` (as a string) instead of a missing-token
#' error. The default may be empty (`// optional-token: name =`), for a
#' token that should be present but blank unless the caller sets it.
#'
#' @param path Character. Path to a .typ file.
#' @return Named list of default values (empty if none are declared).
#' @keywords internal
extract_token_defaults <- function(path) {
  lines <- readLines(path, warn = FALSE)
  found <- regmatches(lines, regexec(
    "^\\s*//\\s*optional-token:\\s*([a-zA-Z0-9_.]+)\\s*=\\s*(.*?)\\s*$",
    lines
  ))
  found <- found[lengths(found) == 3]
  stats::setNames(
    lapply(found, function(f) f[[3]]),
    vapply(found, function(f) f[[2]], character(1))
  )
}

#' Fill a template's omitted optional tokens with their defaults
#'
#' Internal. For every optional token that `data` lacks (or holds as
#' `NULL`, empty, or `NA`), sets the declared default. A default is
#' rendered against `data` first, so it can refer to other tokens: a
#' section heading's default can carry a sample size, as in
#' `Results (N = {{{n_total}}})`. A value the caller supplies is used
#' as given and never rendered again.
#'
#' @param path Character. Path to a .typ file.
#' @param data Named list of whisker substitution values.
#' @return `data` with the omitted optional tokens filled in.
#' @keywords internal
fill_token_defaults <- function(path, data) {
  defaults <- extract_token_defaults(path)
  omitted <- names(defaults)[vapply(names(defaults), function(tok) {
    value <- data[[tok]]
    length(value) == 0 || is.na(value)[1]
  }, logical(1))]
  for (tok in omitted) {
    data[[tok]] <- whisker::whisker.render(defaults[[tok]], data)
  }
  data
}

#' Read a template's designed page count
#'
#' Internal. A template declares the page count it is designed to fill with a
#' `//` comment line, `// designed-pages: 2`.
#'
#' @param path Character. Path to a .typ file.
#' @return Integer page count, or `NA_integer_` if the template declares none.
#' @keywords internal
extract_designed_pages <- function(path) {
  lines <- readLines(path, warn = FALSE)
  found <- regmatches(lines, regexec(
    "^\\s*//\\s*designed-pages:\\s*([0-9]+)\\s*$", lines
  ))
  found <- found[lengths(found) == 2]
  if (length(found) == 0) {
    return(NA_integer_)
  }
  as.integer(found[[1]][[2]])
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
#' @examples
#' path <- resolve_template("cohort_summary")
#' required <- extract_required_tokens(path)
#' # Placeholder values: validate_template_data() only checks presence/
#' # non-NA, not real content, so this always passes regardless of which
#' # tokens a given template actually needs.
#' data <- setNames(as.list(rep("placeholder", length(required))), required)
#' validate_template_data(path, data)
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
#' file (a package-shipped template or a user's own
#' `export_template()`-edited copy) since required-token validation is
#' derived by scanning the file itself, not a separately-maintained
#' manifest.
#'
#' A template can declare a token optional with a `//` comment line,
#' `// optional-token: name = default`. When `data` lacks that token (or
#' it is `NULL`, empty, or `NA`), the declared default is used instead of
#' raising a missing-token error. A default can refer to other tokens, as
#' in `// optional-token: heading = Results (N = {{{n_total}}})`; it is
#' rendered against `data` first, and those tokens stay required.
#'
#' @param path Character. Path to a .typ file. Its
#'   `theme.typ`/`components.typ`/assets must already be alongside it, so
#'   Typst's relative `#import` paths resolve correctly.
#' @param data Named list of whisker substitution values. A name that is not
#'   a token of `path` or of any built-in template is ignored with a warning
#'   (naming the closest token, if there is one), which catches misspelled
#'   optional tokens.
#' @param output Character. Path to write the compiled PDF to.
#' @param font_dir Character or `NULL`. A directory of font files (`.ttf`/
#'   `.otf`) to make available to Typst for this compile, passed through
#'   as `--font-path`. Typst does not merge this with the system font
#'   list: both system fonts and this directory are searched, so a
#'   theme's `text-font`/`heading-font` tokens can name either a
#'   system-installed font or one shipped here (confirmed directly:
#'   `quarto typst fonts --font-path <dir>` lists a font from `<dir>`
#'   alongside system fonts, not instead of them). Default `NULL` (system
#'   fonts only).
#' @return Character, the `output` path, invisibly.
#' @examples
#' \dontrun{
#' # Needs Quarto (bundling Typst) on the system: see check_quarto().
#' typ <- tempfile(fileext = ".typ")
#' writeLines(
#'   c("#set document(title: [Example])", "#text[{{{greeting}}}]"), typ
#' )
#' compile_typst(typ, list(greeting = "Hello!"), tempfile(fileext = ".pdf"))
#' }
#' @export
compile_typst <- function(path, data, output, font_dir = NULL) {
  warn_unknown_tokens(path, data)
  data <- fill_token_defaults(path, data)
  validate_template_data(path, data)

  quarto_bin <- quarto::quarto_path()
  if (is.null(quarto_bin)) {
    stop(
      "Quarto was not found. Run onepagr::check_quarto() for details, or ",
      "onepagr::install_quarto() to install it.",
      call. = FALSE
    )
  }

  if (!is.null(font_dir) && !dir.exists(font_dir)) {
    stop("font_dir does not exist: ", font_dir, call. = FALSE)
  }

  template_text <- paste(readLines(path, warn = FALSE), collapse = "\n")
  rendered <- whisker::whisker.render(template_text, data)
  typ_out <- file.path(
    dirname(path),
    paste0(tools::file_path_sans_ext(basename(path)), "_rendered.typ")
  )
  writeLines(rendered, typ_out)

  font_args <- if (!is.null(font_dir)) c("--font-path", shQuote(font_dir))
  # A failed compile must not be masked by an older PDF at the same path:
  # success is judged by the file existing, so clear it first.
  unlink(output)
  if (file.exists(output)) {
    stop(
      "Cannot replace the existing output file (is it open in another ",
      "program?): ", output,
      call. = FALSE
    )
  }
  # suppressWarnings() only silences system2()'s own "had status N" warning,
  # which fires unconditionally on a non-zero exit whenever stdout is
  # captured as text: redundant here since a non-zero exit is already
  # surfaced below via the file.exists() check and a stop() carrying the
  # full captured output, a clearer message than the warning's bare status
  # code. system2() has no other warning path: a missing executable is a
  # hard error from system2() itself, not a warning, so this can't mask
  # that case.
  result <- suppressWarnings(system2(
    quarto_bin,
    args = c(
      "typst", "compile",
      "--pdf-standard", "ua-1",
      "--features", "a11y-extras",
      font_args,
      shQuote(typ_out), shQuote(output)
    ),
    stdout = TRUE, stderr = TRUE
  ))

  if (!file.exists(output)) {
    stop(
      "Typst compilation failed:\n", paste(result, collapse = "\n"),
      call. = FALSE
    )
  }

  invisible(output)
}
