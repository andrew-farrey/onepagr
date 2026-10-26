# A test that renders a PDF needs Quarto bundling a Typst new enough for
# `--pdf-standard ua-1` and `--features a11y-extras`, not just any Quarto:
# quarto::quarto_available() is TRUE for a Quarto whose Typst is too old,
# and every render then fails with "invalid value 'ua-1'". check_quarto()
# compares the Typst Quarto actually bundles, so rendering tests skip on it.
skip_if_no_onepagr_typst <- function() {
  testthat::skip_if_not(
    isTRUE(suppressMessages(check_quarto())$ok),
    "Quarto with a Typst new enough for onepagr is not available"
  )
}

# Write lines to a temporary .typ file that is removed when the calling test
# ends.
write_typ <- function(lines, env = parent.frame()) {
  path <- tempfile(fileext = ".typ")
  writeLines(lines, path)
  withr::defer(unlink(path), envir = env)
  path
}

# check_theme() depends entirely on `typst eval`, a real Typst CLI
# capability this package cannot assume is present -- confirmed missing
# on a real R-devel win-builder CRAN check (that Typst build errored with
# "unrecognized subcommand 'eval'"), even though Quarto/Typst were
# otherwise available and every typst-compile-based test ran fine there.
# Skip check_theme()-against-real-Typst tests on any environment lacking
# this specific capability, rather than letting them fail as if onepagr's
# own logic were broken.
skip_if_no_typst_eval <- function() {
  quarto_bin <- quarto::quarto_path()
  testthat::skip_if(is.null(quarto_bin), "Quarto not found")
  testthat::skip_if_not(
    typst_eval_supported(quarto_bin),
    "typst eval is not supported by the installed Typst"
  )
}
