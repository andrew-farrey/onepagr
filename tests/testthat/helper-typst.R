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
