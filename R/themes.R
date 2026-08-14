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
#' @export
list_templates <- function() {
  templates_dir <- system.file("typst", "templates", package = "onepagr")
  list.dirs(templates_dir, full.names = FALSE, recursive = FALSE)
}
