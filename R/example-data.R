#' Example data for a built-in template
#'
#' Every built-in template's [render_onepager()] `data` argument needs a
#' long list of values. This returns a complete, working example -- the
#' same one this package's own tests render -- so you can see a real
#' value for every token before writing your own, or render immediately
#' to see what the template produces.
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
#' @export
example_data <- function(template) {
  # Validates template and gives the same error resolve_template() does
  # for every other function that takes a template name; the result
  # itself isn't needed here, only the check.
  resolve_template(template)
  file <- switch(
    template,
    cohort_summary = ,
    trend_snapshot = "cohort_summary.R",
    overdose_spike_alert = "overdose_spike_alert.R",
    syndromic_alert = "syndromic_alert.R",
    county_choropleth = "county_choropleth.R"
  )
  path <- system.file("examples", file, package = "onepagr")
  env <- new.env(parent = baseenv())
  sys.source(path, envir = env)
  env$example_data
}
