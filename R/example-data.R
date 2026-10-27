#' Example data for a built-in template
#'
#' Every built-in template's [render_onepager()] `data` argument needs a
#' long list of values. This returns a complete, working example -- the
#' same one this package's own tests render -- so you can see a real
#' value for every token before writing your own, or render immediately
#' to see what the template produces. `county_choropleth` also needs five
#' map images, which Typst can only read from its own compile folder: pass
#' the placeholder maps that ship with the package as `extra_assets` (see the
#' example below).
#'
#' [template_data()] builds on this: it returns only the tokens you'd
#' actually pass to `render_onepager()`, matching [template_tokens()]'s
#' required/optional split, and is what you want for a starting point.
#' Use this function directly when you want the full, untouched example,
#' e.g. to see the exact value used for a token you're not sure how to
#' format.
#'
#' @param template Character. A built-in template name (see
#'   [list_templates()]).
#' @return Named list, the example data for `template`. `trend_snapshot`
#'   shares `cohort_summary`'s example data: both were designed around
#'   the same underlying example numbers (see either template's
#'   `template.typ` header comment for why).
#' @examples
#' str(example_data("overdose_spike_alert"))
#' \dontrun{
#' # county_choropleth takes five map images as extra_assets; placeholders
#' # ship with the package. Needs Quarto: see check_quarto().
#' maps <- list.files(
#'   system.file("extdata", "maps", package = "onepagr"),
#'   pattern = "^map[0-4][.]png$", full.names = TRUE
#' )
#' render_onepager(
#'   example_data("county_choropleth"), "county_choropleth",
#'   output = file.path(tempdir(), "choropleth.pdf"), extra_assets = maps
#' )
#' }
#' @export
example_data <- function(template) {
  # Validates template and gives the same error resolve_template() does
  # for every other function that takes a template name; the result
  # itself isn't needed here, only the check.
  resolve_template(template)
  # Each template's example lives in inst/examples/<template>.R; a template
  # that deliberately shares another's numbers is listed here.
  shared <- c(trend_snapshot = "cohort_summary")
  stem <- if (template %in% names(shared)) shared[[template]] else template
  file <- paste0(stem, ".R")
  path <- system.file("examples", file, package = "onepagr")
  if (!nzchar(path)) {
    stop(
      "No example data for template \"", template, "\": expected ",
      "inst/examples/", file, ".",
      call. = FALSE
    )
  }
  env <- new.env(parent = baseenv())
  sys.source(path, envir = env)
  env$example_data
}
