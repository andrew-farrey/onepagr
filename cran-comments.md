## Submission

This is a new submission (onepagr 0.2.0).

An earlier version, 0.1.1, was submitted on 2026-10-16 and withdrawn on
2026-10-21 at my request, with CRAN's agreement by email, after an external code
review found bugs in how data values reach a template. This version fixes them,
so it has a new version number. The user-visible changes are listed in
`NEWS.md`.

## Test environments

* Local: Windows 11, R 4.6.1 (release), Quarto 1.10.18 with Typst 0.15.1
* GitHub Actions (on every push): macOS (R release), Windows (R release),
  Ubuntu (R devel, R release, R oldrel-1)
* win-builder: [TO FILL IN after the final run on the release sources: platform,
  R version and date]
* R-hub: [TO FILL IN after the final run on the release sources: platforms and
  date]

## R CMD check results

[TO FILL IN after the final runs. Local `devtools::check(cran = TRUE)` on the
development sources gave 0 errors | 0 warnings | 0 notes, both with Quarto
present and with Quarto hidden from the PATH (as on a machine without it). The
expected result on win-builder is the one note below.]

0 errors | 0 warnings | 1 note

* This is a new submission.

* Possibly misspelled words in DESCRIPTION: "UA", "WCAG". These are correct
  acronyms, each spelled out in full where first used in the Description:
  WCAG is the W3C Web Content Accessibility Guidelines, and PDF/UA is the
  Portable Document Format Universal Accessibility standard (ISO 14289-1).

* There are no published references describing the methods in this package,
  so the Description field has no reference citations.

## External software

onepagr renders PDFs by calling Quarto, which bundles Typst. Quarto is declared
in `SystemRequirements`. A check machine may not have it, or may have a Quarto
whose bundled Typst is older than the package needs (0.15.1 or newer), so:

* Examples that need it are wrapped in `\dontrun{}`. Examples that do not need
  it (the number formatters, the template and theme registries) run normally.
* Tests that render a PDF, and the vignette chunks that do, run only when
  `check_quarto()` reports a Quarto whose bundled Typst is new enough, so a
  machine with no Quarto, or an older one, skips them instead of failing. Tests
  that need a Typst feature missing from some builds skip on a direct capability
  probe, not a version number.
* The package never downloads or installs software on its own.
  `install_quarto()` and `set_quarto_path()` do so only when a user calls them
  explicitly. Examples and vignettes never call them, and the tests exercise
  them only with the network download mocked.
* `install_quarto()` keeps its files in `tools::R_user_dir("onepagr", "data")`.
  In an interactive session it asks before the download, and after installing
  it removes the older Quarto copies it put there, so the folder is managed
  rather than growing with each version.

## URLs

* The `accessibility-checks` vignette links to two pages on pdfa.org (the PDF
  Association's Matterhorn Protocol 1.1: the landing page and the direct PDF).
  That server returns HTTP 403 to non-browser clients such as `curl`, so an
  automated URL check may report them as unreachable. Both load normally in a
  web browser, and the PDF is the document the vignette cites.

## Downstream dependencies

There are none on CRAN (new package).
