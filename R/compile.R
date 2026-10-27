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
#' `{{{token}}}` example in a header comment, and without stripping
#' comments first, that illustrative example is indistinguishable from a
#' real required token. A `//` inside a quoted string, or directly after a
#' colon (the `://` of a URL), is text, not a comment, so a token after a
#' URL on the same line is still found.
#'
#' A token with a declared default (see the optional-token marker in
#' [compile_typst()]) is not required, so it is left out of the result.
#' A token that only a default refers to is not listed here either: it is
#' needed only while that default is in use (see [template_tokens()]).
#'
#' @param path Character. Path to a .typ file.
#' @return Character vector of unique token names, in first-appearance order.
#' @examples
#' path <- resolve_template("cohort_summary")
#' extract_required_tokens(path)
#' @export
extract_required_tokens <- function(path) {
  tokens <- template_spec(path)$tokens
  tokens$token[tokens$kind == "required"]
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
#' refers to is needed only while that default is in use: reword the
#' default yourself and you no longer have to supply it.
#'
#' @param template Character. A built-in template name (see
#'   [list_templates()]; a built-in name always wins over a file of the same
#'   name in the working directory), or the path to a `.typ` file such as
#'   one written by [export_template()].
#' @return A data frame with one row per token and columns `token`,
#'   `required` (logical), `default` (`NA` unless the token is optional)
#'   and `needed_by`. Required tokens come first, then tokens needed only
#'   while some optional token's default is in use (`required` is `FALSE`
#'   and `needed_by` names those optional tokens), then optional ones, each
#'   in the order the template uses them.
#' @examples
#' tokens <- template_tokens("cohort_summary")
#' head(tokens)
#'
#' # Every section heading you can reword, with its current text:
#' tokens[grepl("^heading_", tokens$token), c("token", "default")]
#' @export
template_tokens <- function(template) {
  path <- if (template %in% list_templates()) {
    resolve_template(template)
  } else if (utils::file_test("-f", template)) {
    template
  } else {
    resolve_template(template)
  }
  tokens <- template_spec(path)$tokens
  data.frame(
    token = tokens$token,
    required = tokens$kind == "required",
    default = tokens$default,
    needed_by = tokens$needed_by,
    row.names = NULL,
    stringsAsFactors = FALSE
  )
}

#' Build a starter data list for a template
#'
#' Returns a named list ready to pass to [render_onepager()] as `data`:
#' every token [template_tokens()] lists for `template`, each already set
#' to a real value, not a blank you have to guess the shape of -- an
#' optional token's own shipped default, or (for a required token, which
#' has no default) the matching value from that template's
#' [example_data()]. Starting from this instead of an empty list means
#' every value you haven't changed yet is already correctly formatted (a
#' percentage as `"84%"`, a color as a real theme value, and so on),
#' which is the actual point: reading [template_tokens()]'s token names
#' alone tells you what to set, not what a working value for it looks
#' like.
#'
#' Which entries came from a required token, as opposed to an optional
#' one, is recorded in the result's `"required"` attribute
#' (`attr(x, "required")`) rather than in the list itself, so the result
#' stays a plain data list: pass it straight to `render_onepager()`,
#' overwrite fields directly, or merge your own values in with
#' [utils::modifyList()].
#'
#' @param template Character. A built-in template name (see
#'   [list_templates()]). Unlike [template_tokens()], this does not take
#'   a path to a hand-edited [export_template()] copy, since there is no
#'   known example value for a token that copy might add.
#' @param tokens Character. Which tokens to include: `"both"` (default,
#'   everything `render_onepager()` would read), `"required"` (only the
#'   values you must actually supply), or `"optional"` (only the
#'   reworded-text and type/spacing tokens, each left at its default).
#' @return Named list of character values, with a `"required"` attribute
#'   naming the entries that came from a required token.
#' @examples
#' data <- template_data("cohort_summary")
#' attr(data, "required")
#'
#' # Change just the numbers you have; every heading and label keeps its
#' # default wording.
#' data$n_decedents <- "6,000"
#' \dontrun{
#' render_onepager(
#'   data, "cohort_summary", output = file.path(tempdir(), "report.pdf")
#' )
#' }
#' @export
template_data <- function(
  template, tokens = c("both", "required", "optional")
) {
  tokens <- match.arg(tokens)
  info <- template_tokens(template)
  required_names <- info$token[info$required]
  # Tokens with no default of their own, whether used in the body or only by
  # some default: all need a real value for the starter list to be complete.
  example_names <- info$token[is.na(info$default)]
  optional_names <- info$token[!is.na(info$default)]
  optional_defaults <- stats::setNames(
    as.list(info$default[!is.na(info$default)]), optional_names
  )

  want_required <- tokens %in% c("both", "required")
  want_optional <- tokens %in% c("both", "optional")

  out <- list()
  if (want_required && length(example_names) > 0) {
    example <- example_data(template)
    missing <- setdiff(example_names, names(example))
    if (length(missing) > 0) {
      stop(
        "example_data(\"", template, "\") is missing a value for: ",
        paste(missing, collapse = ", "), ". This is a package bug --",
        " please report it.",
        call. = FALSE
      )
    }
    out <- c(out, example[example_names])
  }
  if (want_optional && length(optional_names) > 0) {
    if (want_required) {
      # A default can refer to a required token (e.g. a heading default of
      # "Results (N = {{{n_total}}})"); resolve that here against the real
      # values already in `out`, the same resolution fill_token_defaults()
      # performs at render time, so the "both" result is finished text.
      # (With tokens = "optional" the defaults come back unresolved; they are
      # resolved when rendered, so merging them over real values is safe.)
      out <- fill_token_defaults(resolve_template(template), out)
    } else {
      out <- c(out, optional_defaults)
    }
  }
  attr(out, "required") <- if (want_required) required_names else character(0)
  out
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
  # A name that one of this template's values refers to as {{{name}}}, directly
  # or through another value, is used, so it is not an ignored name.
  own <- c(own, tokens_reachable(data, own))
  builtin <- unlist(lapply(
    list_templates(), function(t) template_tokens(t)$token
  ))
  names_in <- setdiff(names(data), c("", NA))
  unknown <- setdiff(names_in, c(own, builtin))
  if (length(unknown) == 0) {
    return(invisible(character(0)))
  }
  hint <- function(name) {
    if (length(own) == 0) {
      return("")
    }
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
  template_spec(path)$defaults
}

#' Fill a template's omitted optional tokens with their defaults
#'
#' Internal. For every optional token that `data` lacks (or holds as
#' `NULL`, empty, or `NA`), sets the declared default. A default is
#' rendered against `data` first, so it can refer to other tokens: a
#' section heading's default can carry a sample size, as in
#' `Results (N = {{{n_total}}})`. A default may refer to another omitted
#' default, declared above or below it; they are filled in dependency order,
#' and defaults that refer to each other in a loop are an error. A value the
#' caller supplies is used as given, except that a `{{{token}}}` in it is
#' filled from `data` (followed through any further references).
#'
#' @param path Character. Path to a .typ file.
#' @param data Named list of whisker substitution values.
#' @return `data` with the omitted optional tokens filled in.
#' @keywords internal
fill_token_defaults <- function(path, data) {
  defaults <- extract_token_defaults(path)
  pending <- names(defaults)[vapply(
    names(defaults), function(tok) value_missing(data, tok), logical(1)
  )]
  # A default may refer to another default, declared above or below it, so each
  # is filled once every default it refers to has been. A loop never finishes.
  while (length(pending) > 0) {
    ready <- pending[vapply(pending, function(tok) {
      !any(unlist(tokens_in(defaults[[tok]], path)) %in% pending)
    }, logical(1))]
    if (length(ready) == 0) {
      stop(
        "The defaults of these optional tokens refer to each other in a loop: ",
        paste(pending, collapse = ", "), ".",
        call. = FALSE
      )
    }
    for (tok in ready) {
      data[[tok]] <- resolve_token_refs(defaults[[tok]], data)
    }
    pending <- setdiff(pending, ready)
  }
  # Only the values this template can reach: another template's values in a
  # shared data list are not this render's concern, and a loop among them must
  # not stop it.
  own <- template_spec(path)$tokens$token
  reach <- names(data) %in% c(own, tokens_reachable(data, own))
  data[reach] <- resolve_value_references(data[reach])
  data
}

#' Replace each `{{{token}}}` in a value with that token's value
#'
#' Internal. Only the triple-brace form is substituted: the value is never
#' handed to whisker as a template, so a `{{name}}` or a `{{#section}}` in it
#' stays literal text. A name with no value becomes blank.
#'
#' @param value Character. One string.
#' @param data Named list of values.
#' @return Character, the string with its references filled.
#' @noRd
resolve_token_refs <- function(value, data) {
  found <- gregexpr(token_pattern, value, perl = TRUE)
  hits <- regmatches(value, found)[[1]]
  if (length(hits) == 0) {
    return(value)
  }
  names_in <- sub(token_pattern, "\\1", hits, perl = TRUE)
  replacement <- vapply(names_in, function(name) {
    v <- data[[name]]
    if (length(v) == 0L || is.na(v[1])) "" else as.character(v[1])
  }, character(1), USE.NAMES = FALSE)
  regmatches(value, found) <- list(replacement)
  value
}

refers_to_token <- function(value) {
  is.character(value) && length(value) == 1L && !is.na(value) &&
    grepl(token_pattern, value, perl = TRUE)
}

#' Resolve every value that still refers to a token, until none does
#'
#' Internal. A value the caller typed, or one from `template_data("optional")`,
#' can refer to a token whose own value refers to another, so references are
#' followed until nothing changes and literal `{{{token}}}` markup never
#' reaches the PDF. Values that refer to each other in a loop are an error.
#'
#' @param data Named list of values.
#' @return `data` with every reference filled.
#' @noRd
resolve_value_references <- function(data) {
  for (pass in seq_len(length(data) + 1L)) {
    referring <- names(data)[vapply(data, refers_to_token, logical(1))]
    if (length(referring) == 0) {
      return(data)
    }
    snapshot <- data
    for (name in referring) {
      data[[name]] <- resolve_token_refs(data[[name]], snapshot)
    }
  }
  stop(
    "These values refer to each other in a loop: ",
    paste(referring, collapse = ", "), ".",
    call. = FALSE
  )
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
  template_spec(path)$designed_pages
}

#' Validate whisker data against a template's required tokens
#'
#' Raises a clear error listing every missing or NA token before whisker
#' or Typst ever run, instead of letting a missing token silently render
#' as blank text. The tokens that count are the ones the template body
#' uses, plus the ones needed by a default that `data` leaves in use (see
#' [template_tokens()]). A blank value for one of them draws a warning
#' unless the template declares `// allow-empty: token`, and a bar-chart
#' `*_width` token must be a plain number from 0 to 100.
#'
#' @param path Character. Path to a .typ file.
#' @param data Named list of whisker substitution values.
#' @return Invisibly `TRUE` if validation passes.
#' @examples
#' path <- resolve_template("cohort_summary")
#' # A complete example list passes; drop a required value and it errors.
#' validate_template_data(path, example_data("cohort_summary"))
#' @export
validate_template_data <- function(path, data) {
  check_template_data(template_spec(path), data)
}

#' Rewrite the tokens in a line's comment text so whisker leaves them alone
#'
#' Internal. Only the part of the line from its `//` on changes; `{{{name}}}`
#' there becomes `<name>`.
#'
#' @param line Character. One line of Typst source.
#' @return Character, the line.
#' @noRd
neutralize_comment_tokens <- function(line) {
  code <- strip_typst_comment(line)
  if (nchar(code) == nchar(line)) {
    return(line)
  }
  comment <- substr(line, nchar(code) + 1L, nchar(line))
  comment <- gsub(token_pattern, "<\\1>", comment, perl = TRUE)
  # A double-brace {{name}}, a {{#section}} and a stray {{ are tags to whisker
  # too, so no two braces are left side by side in comment text.
  paste0(code, gsub("[{](?=[{])", "{ ", comment, perl = TRUE))
}

#' Render a template with whisker and write the result next to it
#'
#' Internal. Writes `<name>_rendered.typ` beside `path`.
#'
#' @param path Character. Path to a .typ file.
#' @param data Named list of whisker substitution values.
#' @return Character, the path of the rendered `.typ` file.
#' @noRd
write_rendered_typ <- function(path, data) {
  spec <- template_spec(path)
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  # whisker fills every {{{token}}} on a line, comments included, but a comment
  # is text to Typst. A value with a newline in it would end the comment and
  # leave the rest of the line as live markup, so a token in comment text is
  # rewritten as <token> before whisker runs.
  lines <- vapply(lines, neutralize_comment_tokens, character(1), USE.NAMES = FALSE)
  occ <- spec$occurrences
  # A token inside a "string literal" gets its own escaped copy of the value,
  # chosen per occurrence: the same token can also sit in the body, where its
  # value is markup and must stay untouched.
  for (k in unique(occ$line[occ$in_string])) {
    in_string <- occ$in_string[occ$line == k]
    found <- gregexpr(token_pattern, lines[k], perl = TRUE)
    hits <- regmatches(lines[k], found)[[1]]
    for (j in which(in_string)) {
      tok <- sub(token_pattern, "\\1", hits[j], perl = TRUE)
      value <- data[[tok]]
      data[[paste0("onepagr_str_", tok)]] <- typst_escape_string(
        if (length(value) == 0L || is.na(value)) "" else as.character(value)
      )
      hits[j] <- paste0("{{{onepagr_str_", tok, "}}}")
    }
    regmatches(lines[k], found) <- list(hits)
  }
  template_text <- paste(lines, collapse = "\n")
  rendered <- whisker::whisker.render(template_text, data)
  typ_out <- file.path(
    dirname(path),
    paste0(tools::file_path_sans_ext(basename(path)), "_rendered.typ")
  )
  # Typst reads UTF-8; write the bytes as-is so the native encoding of the R
  # session (older R on Windows, a non-UTF-8 locale) cannot change them.
  writeLines(enc2utf8(rendered), typ_out, useBytes = TRUE)
  typ_out
}

#' Remove a stale output file so a failed compile can't be masked by it
#'
#' Internal. Compile success is judged by the output file existing, so an
#' older PDF at the same path has to be cleared first.
#'
#' @param output Character. Path of the PDF about to be written.
#' @return `NULL`, invisibly. Errors if the file can't be removed.
#' @noRd
clear_output_file <- function(output) {
  unlink(output)
  if (file.exists(output)) {
    stop(
      "Cannot replace the existing output file (is it open in another ",
      "program?): ", output,
      call. = FALSE
    )
  }
  invisible(NULL)
}

#' Compile a .typ file with whisker-substituted data via Quarto/Typst
#'
#' Low-level primitive: whisker-renders `path` against `data`, writes the
#' result next to `path` as `<name>_rendered.typ` (that file, not `path`
#' itself, is what compiles), then compiles it to `output` via `quarto typst
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
#'   theme's `body-font` tokens can name either a
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
  data <- coerce_data_values(data)
  warn_unknown_tokens(path, data)
  spec <- template_spec(path)
  # Checked before the defaults are filled in, so it is known which optional
  # tokens were left out and which default-only tokens that makes necessary.
  check_template_data(spec, data)
  data <- fill_token_defaults(path, data)
  # After the defaults and references are filled, so a bracket that arrives
  # through either is caught too.
  check_bracket_balance(spec, data)

  quarto_bin <- quarto_bin_or_stop()

  if (!is.null(font_dir) && !dir.exists(font_dir)) {
    stop("font_dir does not exist: ", font_dir, call. = FALSE)
  }

  typ_out <- write_rendered_typ(path, data)
  font_args <- if (!is.null(font_dir)) c("--font-path", shQuote(font_dir))
  clear_output_file(output)
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
