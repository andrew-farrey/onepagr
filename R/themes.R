#' Resolve a theme name or path to an installed .typ file
#'
#' `theme` is checked against onepagr's built-in theme registry first
#' (`inst/typst/themes/<name>.typ`); if no registry entry matches, `theme`
#' is treated as a file path instead. `theme_path`, when supplied, always
#' wins and is used verbatim without any registry lookup.
#'
#' @param theme Character. A built-in theme name (e.g. "uk") or a path to
#'   a custom theme .typ file.
#' @param theme_path Character or NULL. Explicit path override; when
#'   supplied, `theme` is ignored entirely.
#' @return Character, an absolute path to a .typ theme file.
#' @examples
#' resolve_theme("uk")
#' resolve_theme("default")
#' @export
resolve_theme <- function(theme = "default", theme_path = NULL) {
  if (!is.null(theme_path)) {
    if (!file.exists(theme_path)) {
      stop("theme_path does not exist: ", theme_path, call. = FALSE)
    }
    return(normalizePath(theme_path, mustWork = TRUE))
  }

  registry_path <- system.file(
    "typst", "themes", paste0(theme, ".typ"),
    package = "onepagr"
  )
  if (nzchar(registry_path)) {
    return(registry_path)
  }

  if (!file.exists(theme)) {
    stop(
      "theme \"", theme, "\" is not a built-in theme and no file exists ",
      "at that path. Built-in themes: ",
      paste(list_themes(), collapse = ", "),
      call. = FALSE
    )
  }
  normalizePath(theme, mustWork = TRUE)
}

#' List built-in theme names
#'
#' @return Character vector of built-in theme names (without file extension).
#' @examples
#' list_themes()
#' @export
list_themes <- function() {
  themes_dir <- system.file("typst", "themes", package = "onepagr")
  files <- list.files(themes_dir, pattern = "\\.typ$")
  sub("\\.typ$", "", files)
}

#' Resolve a built-in template name to its installed template.typ path
#'
#' @param template Character. A built-in template name (e.g. "cohort_summary").
#' @return Character, absolute path to the template's `template.typ` file.
#' @examples
#' resolve_template("cohort_summary")
#' @export
resolve_template <- function(template) {
  path <- system.file(
    "typst", "templates", template, "template.typ",
    package = "onepagr"
  )
  if (!nzchar(path)) {
    stop(
      "template \"", template, "\" is not a built-in template. ",
      "Built-in templates: ", paste(list_templates(), collapse = ", "),
      call. = FALSE
    )
  }
  path
}

#' List built-in template names
#'
#' @return Character vector of built-in template names.
#' @examples
#' list_templates()
#' @export
list_templates <- function() {
  templates_dir <- system.file("typst", "templates", package = "onepagr")
  list.dirs(templates_dir, full.names = FALSE, recursive = FALSE)
}

#' The exact key -> Typst type contract onepagr's shipped templates and
#' `components.typ` rely on
#'
#' Internal. The required keys are the ones `inst/typst/components.typ` and
#' every `inst/typst/templates/*/template.typ` actually read as
#' `theme.<key>` / `theme-grad.<key>` (counted by script, not assumed); the
#' `optional_theme` keys are allowed but not read directly. All three
#' shipped themes (`default.typ`, `uk.typ`, `kdph.typ`) define exactly these
#' keys, which `test-themes.R` checks with a real `typst eval` run, so a
#' key added to a component or template has to be added here too or that
#' test fails.
#'
#' @return A list with `theme` (named character vector, key -> Typst
#'   `type()` name; `|` separates accepted alternatives, so `body-font` is
#'   `"str|array"` to allow a font fallback list), `optional_theme` (same
#'   shape, keys that may be present), `theme_grad` (same shape), and
#'   `radius_card` (the nested dictionary `theme$radius-card` must contain).
#' @keywords internal
onepagr_theme_schema <- function() {
  list(
    theme = c(
      "brand-blue" = "color", "brand-midnight" = "color",
      "map-border-color" = "color", "brand-accent" = "color",
      "brand-accent-text" = "color",
      "lessons-text" = "color",
      "disclaimer-border" = "color", "disclaimer-text" = "color",
      "border-color" = "color", "box-border" = "color",
      "text-secondary" = "color", "text-muted" = "color",
      "severity-warning" = "color", "severity-warning-bg" = "color",
      "severity-warning-text" = "color", "severity-critical" = "color",
      "severity-critical-bg" = "color", "severity-critical-text" = "color",
      "body-font" = "str|array", "body-size" = "length",
      "min-font-size" = "length", "font-scale" = "float|int",
      "space-scale" = "float|int",
      "space-xs" = "length", "space-sm" = "length", "space-md" = "length",
      "space-lg" = "length", "stroke-hairline" = "length",
      "stroke-border" = "length", "stroke-accent" = "length",
      "stroke-accent-left" = "length", "stroke-fill" = "length",
      "radius-card" = "dictionary", "content-pad-x" = "length"
    ),
    # Keys that a theme may define but that no component or template reads
    # directly: the shipped themes use the five background colors only to
    # build their own `theme-grad` gradients, so a theme that defines its
    # gradients another way does not need them. `callout-text` is read with
    # a fallback, so a theme without it still renders. Checked for type when
    # present, never reported as missing or unknown.
    optional_theme = c(
      "brand-sky" = "color", "card-bg" = "color", "callout-bg" = "color",
      "lessons-bg" = "color", "disclaimer-bg" = "color",
      "callout-text" = "color"
    ),
    theme_grad = c(
      "card-bg-grad" = "gradient", "callout-bg-grad" = "gradient",
      "lessons-bg-grad" = "gradient", "disclaimer-bg-grad" = "gradient",
      "brand-blue-grad" = "gradient", "brand-sky-grad" = "gradient"
    ),
    radius_card = c("top-right" = "length", "bottom-right" = "length")
  )
}

#' The Typst expression `check_theme()` evaluates against a theme file
#'
#' Internal. Imports `theme` and `theme-grad` from `fname` (resolved
#' against the `--root` the caller passes) and returns each dictionary's
#' keys paired with their Typst type names, plus the nested `radius-card`
#' dictionary the same way (or `none` when it isn't a dictionary).
#'
#' @param fname Character. The theme file's name, relative to the root.
#' @return Character, a single Typst code-mode expression.
#' @noRd
theme_eval_expr <- function(fname) {
  paste0(
    "{",
    "import \"/", fname, "\": theme, theme-grad;",
    "let tn(v) = repr(type(v));",
    "(",
    "theme: theme.pairs().map(((k, v)) => (k, tn(v))),",
    "theme-grad: theme-grad.pairs().map(((k, v)) => (k, tn(v))),",
    "radius-card: if \"radius-card\" in theme and tn(theme.radius-card) == ",
    "\"dictionary\" { theme.radius-card.pairs().map(((k, v)) => (k, tn(v))) }",
    " else { none },",
    ")",
    "}"
  )
}

#' Introspect a theme `.typ` file's real Typst-evaluated key/type structure
#'
#' Internal. Runs `typst eval` (via Quarto's bundled Typst) against a
#' small generated snippet that imports `theme`/`theme-grad` from `path`
#' and maps every key to `repr(type(value))`, so what comes back
#' describes exactly what Typst itself would see at real compile time, not
#' a guess from regex-parsing the file's text. `--root` is set to `path`'s
#' own directory and the import references just its basename, since
#' Typst's `#import` rejects an absolute filesystem path outright
#' (confirmed directly: "path contains invalid component" on a Windows
#' drive letter); it only resolves paths relative to `--root`.
#'
#' @param path Character. Absolute path to a theme `.typ` file.
#' @return A list with `error` (character or `NULL`; the raw Typst stderr
#'   if the file failed to evaluate at all; when non-`NULL`, `theme`/
#'   `theme_grad`/`radius_card` are all `NULL`), `theme` (2-column
#'   character matrix of key/type pairs, or `NULL`), `theme_grad` (same
#'   shape), and `radius_card` (same shape, or `NULL` if
#'   `theme$radius-card` isn't a dictionary or `radius-card` is missing).
#' @keywords internal
introspect_theme_typ <- function(path) {
  quarto_bin <- quarto_bin_or_stop()
  if (!typst_eval_supported(quarto_bin)) {
    stop(
      "check_theme() needs a Typst build that supports typst eval, ",
      "which the one on this system doesn't (confirmed by probing it ",
      "directly, not assuming a version cutoff). Update Quarto, which ",
      "bundles Typst: see onepagr::check_quarto() and ",
      "onepagr::install_quarto().",
      call. = FALSE
    )
  }

  root <- dirname(path)
  expr <- theme_eval_expr(basename(path))

  out <- suppressWarnings(system2(
    quarto_bin,
    args = c(
      "typst", "eval", shQuote(expr),
      "--format", "json", "--root", shQuote(root)
    ),
    stdout = TRUE, stderr = TRUE
  ))

  status <- attr(out, "status")
  if (!is.null(status) && status != 0) {
    return(list(
      error = paste(out, collapse = "\n"),
      theme = NULL, theme_grad = NULL, radius_card = NULL
    ))
  }

  parsed <- jsonlite::fromJSON(paste(out, collapse = ""))
  list(
    error = NULL,
    theme = parsed[["theme"]],
    theme_grad = parsed[["theme-grad"]],
    radius_card = parsed[["radius-card"]]
  )
}

#' Reduce a `typst eval`-parsed key/type matrix to a named vector
#'
#' Internal. Handles the two edge cases `jsonlite::fromJSON()` produces for
#' an empty or absent key/type array: `NULL` (the key, e.g. `radius-card`,
#' wasn't present or wasn't a dictionary at all) and `list()` (an empty
#' Typst dictionary, valid but pathological). Both become `character(0)`
#' rather than erroring on `NULL[, 2]`/`list()[, 2]`-style indexing.
#'
#' @param m 2-column character matrix (key, type), or `NULL`/`list()`.
#' @return Named character vector, type by key.
#' @keywords internal
theme_type_vector <- function(m) {
  if (is.null(m) || !is.matrix(m)) {
    return(character(0))
  }
  types <- m[, 2]
  names(types) <- m[, 1]
  types
}

#' Compare a theme dictionary's real keys/types against an expected schema
#'
#' Internal, shared by [check_theme()] for `theme`, `theme-grad`, and the
#' nested `radius-card` dictionary alike.
#'
#' @param actual_matrix 2-column character matrix from
#'   [introspect_theme_typ()] (key, type), or `NULL`/`list()`.
#' @param expected_types Named character vector, expected Typst type name
#'   by key (from [onepagr_theme_schema()]).
#' @return A list with `missing` (character vector), `mismatches` (data
#'   frame: `key`, `expected`, `actual`), and `unknown` (character vector
#'   of keys present but outside `expected_types`).
#' @keywords internal
check_theme_dict <- function(actual_matrix, expected_types,
                             optional_types = character(0)) {
  actual_types <- theme_type_vector(actual_matrix)
  missing <- setdiff(names(expected_types), names(actual_types))
  # An optional key is type-checked when present but is never missing or
  # unknown.
  expected_types <- c(expected_types, optional_types)
  present <- intersect(names(expected_types), names(actual_types))

  # An expected type may list alternatives separated by "|" (e.g.
  # "str|array" for a font name or a fallback list). A "length" token
  # (e.g. a stroke width) is also accepted as Typst's "relative" type (a
  # length with a "+ N%" component), since that's still a legitimate value
  # in every length-typed slot this package's templates use one in, just
  # not the plain form the shipped themes happen to use.
  type_ok <- function(expected, actual) {
    accepted <- strsplit(expected, "|", fixed = TRUE)[[1]]
    if ("length" %in% accepted) {
      accepted <- c(accepted, "relative")
    }
    actual %in% accepted
  }
  is_mismatch <- vapply(
    present, function(k) !type_ok(expected_types[[k]], actual_types[[k]]),
    logical(1)
  )
  mismatched <- present[is_mismatch]

  list(
    missing = missing,
    mismatches = data.frame(
      key = mismatched,
      expected = unname(expected_types[mismatched]),
      actual = unname(actual_types[mismatched]),
      stringsAsFactors = FALSE
    ),
    unknown = setdiff(names(actual_types), names(expected_types))
  )
}

#' An empty type-mismatch table, in the shape `check_theme()` returns
#'
#' Internal.
#'
#' @return A zero-row data frame with `key`, `expected`, `actual` columns.
#' @noRd
empty_type_mismatches <- function() {
  data.frame(
    key = character(0), expected = character(0), actual = character(0)
  )
}

#' The `check_theme()` result for a theme file that failed to evaluate
#'
#' Internal.
#'
#' @param path Character. The resolved theme file.
#' @param error Character. Typst's own error text.
#' @return A list shaped like `check_theme()`'s result, with `ok = FALSE`.
#' @noRd
failed_theme_result <- function(path, error) {
  list(
    ok = FALSE, path = path, error = error,
    missing = character(0), missing_grad = character(0),
    type_mismatches = empty_type_mismatches(),
    type_mismatches_grad = empty_type_mismatches(),
    radius_card_missing = character(0),
    radius_card_type_mismatches = empty_type_mismatches(),
    unknown = character(0), unknown_grad = character(0)
  )
}

#' Describe wrong-type keys as "key (expected X, got Y)" strings
#'
#' Internal.
#'
#' @param df Data frame with `key`, `expected`, `actual` columns.
#' @return Character vector, one string per row.
#' @noRd
describe_type_mismatches <- function(df) {
  sprintf("%s (expected %s, got %s)", df$key, df$expected, df$actual)
}

#' One-line descriptions of everything wrong in a `check_theme()` result
#'
#' Internal.
#'
#' @param result A `check_theme()` result list.
#' @return Character vector, one entry per kind of problem found; empty if
#'   there are none.
#' @noRd
theme_problems <- function(result) {
  keys <- function(label, x) {
    if (length(x) > 0) paste0(label, "(s): ", paste(x, collapse = ", "))
  }
  wrong <- function(label, df) {
    if (nrow(df) > 0) {
      paste0(
        label, "(s): ", paste(describe_type_mismatches(df), collapse = "; ")
      )
    }
  }
  c(
    keys("missing theme key", result$missing),
    keys("missing theme-grad key", result$missing_grad),
    wrong("wrong-type theme key", result$type_mismatches),
    wrong("wrong-type theme-grad key", result$type_mismatches_grad),
    keys("missing radius-card sub-key", result$radius_card_missing),
    wrong("wrong-type radius-card sub-key", result$radius_card_type_mismatches)
  )
}

#' Check the nested `radius-card` dictionary, when there is one to check
#'
#' Internal. Only checked when `theme` defines `radius-card` and it
#' evaluated to a dictionary; otherwise nothing is reported for it here
#' (a missing `radius-card` key is already reported by the `theme` check).
#'
#' @param radius_card Key/type matrix from [introspect_theme_typ()], or
#'   `NULL`.
#' @param theme_check The [check_theme_dict()] result for `theme`.
#' @param expected_types Named character vector, expected types by key.
#' @return A list with `missing` (character vector) and `mismatches` (data
#'   frame).
#' @noRd
check_radius_card <- function(radius_card, theme_check, expected_types) {
  if ("radius-card" %in% theme_check$missing || is.null(radius_card)) {
    return(list(missing = character(0), mismatches = empty_type_mismatches()))
  }
  rc <- check_theme_dict(radius_card, expected_types)
  list(missing = rc$missing, mismatches = rc$mismatches)
}

#' Check a theme's dictionary structure against onepagr's real contract
#'
#' Validates a theme `.typ` file's `theme` and `theme-grad` exports by
#' actually evaluating them with Typst (`typst eval`, via Quarto's bundled
#' binary) rather than a hand-rolled text parser, so a theme flagged
#' here is confirmed to fail (or nearly fail) the exact same way it would
#' at real render time, not just suspected to. Checks:
#'
#' 1. The file evaluates at all (catches a Typst syntax error, a missing
#'    `theme`/`theme-grad` export, or any other error Typst itself would
#'    raise).
#' 2. Every key onepagr's shipped templates and `components.typ` actually
#'    dereference is present, in both `theme` and `theme-grad`.
#' 3. Each present key's real Typst-evaluated type matches what onepagr
#'    expects (e.g. a color key set to a bare string, or a length key set
#'    to a color), exactly the kind of mistake that would otherwise
#'    surface as a much less legible Typst error deep inside
#'    `components.typ`, pointing at the component's own code rather than
#'    the theme file that actually caused it.
#'
#' Does **not** check color contrast or WCAG compliance: a value can be
#' a perfectly well-formed `color` and still fail WCAG (or vice versa,
#' though a malformed value can never pass it). That's a semantic
#' judgment, not a structural one, and belongs in a separate
#' contrast-checking function, not folded in here.
#'
#' Callable standalone while developing a new theme (before ever calling
#' [render_onepager()]), or from another onepagr function or your own test
#' suite that wants to validate a theme up front; nothing about it is
#' tied to a particular call site.
#'
#' @param theme Character. A built-in theme name (e.g. "uk") or a path to
#'   a custom theme `.typ` file. Default `"default"`.
#' @param theme_path Character or `NULL`. Explicit path override, same as
#'   [resolve_theme()].
#' @return Invisibly, a list: `ok` (logical), `path` (the resolved theme
#'   file), `error` (character or `NULL`; set only when the file failed to
#'   evaluate at all, in which case every field below is empty/`NA`),
#'   `missing` / `missing_grad` (character vectors of required keys not
#'   found in `theme` / `theme-grad`), `type_mismatches` /
#'   `type_mismatches_grad` (data frames with `key`, `expected`, `actual`
#'   columns), `radius_card_missing` / `radius_card_type_mismatches` (same
#'   shape, for the nested `radius-card` dictionary), and `unknown` /
#'   `unknown_grad` (character vectors of keys present in `theme` /
#'   `theme-grad` but outside onepagr's known schema, informational only,
#'   not a failure; could be a typo, or a key your own templates read
#'   directly).
#' @examples
#' \dontrun{
#' # Needs Quarto (bundling Typst) on the system: see check_quarto().
#' check_theme("uk")
#' check_theme("default")
#' }
#' @export
check_theme <- function(theme = "default", theme_path = NULL) {
  path <- resolve_theme(theme, theme_path)
  schema <- onepagr_theme_schema()
  info <- introspect_theme_typ(path)

  if (!is.null(info$error)) {
    message("Theme \"", path, "\" failed to evaluate:\n", info$error)
    return(invisible(failed_theme_result(path, info$error)))
  }

  theme_check <- check_theme_dict(info$theme, schema$theme, schema$optional_theme)
  grad_check <- check_theme_dict(info$theme_grad, schema$theme_grad)

  rc <- check_radius_card(info$radius_card, theme_check, schema$radius_card)

  result <- list(
    ok = FALSE, path = path, error = NULL,
    missing = theme_check$missing, missing_grad = grad_check$missing,
    type_mismatches = theme_check$mismatches,
    type_mismatches_grad = grad_check$mismatches,
    radius_card_missing = rc$missing,
    radius_card_type_mismatches = rc$mismatches,
    unknown = theme_check$unknown,
    unknown_grad = grad_check$unknown
  )
  problems <- theme_problems(result)
  result$ok <- length(problems) == 0

  if (!result$ok) {
    message(
      "Theme \"", path, "\" has ", length(problems), " problem(s):\n- ",
      paste(problems, collapse = "\n- ")
    )
  }
  extra <- c(
    result$unknown,
    if (length(result$unknown_grad) > 0) paste0("theme-grad.", result$unknown_grad)
  )
  if (length(extra) > 0) {
    message(
      "Note: theme \"", path, "\" defines key(s) onepagr doesn't use: ",
      paste(extra, collapse = ", "),
      ". Not an error: could be a typo, or intentional for your own ",
      "templates."
    )
  }

  invisible(result)
}
