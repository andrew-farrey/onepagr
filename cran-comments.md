## Submission

This is a new submission (onepagr 0.1.0).

## Test environments

* Local: Windows 11, R 4.6.1 (release)
* win-builder: Windows Server 2022, R Under development (2026-09-30 r90605 ucrt)
* GitHub Actions (on every push): macOS (R release), Windows (R release),
  Ubuntu (R devel, R release, R oldrel-1)

## R CMD check results

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
in `SystemRequirements`. It is not installed on CRAN's check machines, so:

* Examples that need it are wrapped in `\dontrun{}`. Examples that do not need
  it (the number formatters, the template and theme registries) run normally.
* Tests that need it skip themselves when Quarto is not available. Tests that
  need a Typst feature missing from older Typst builds skip on a direct
  capability probe, not a version number.
* The package never downloads or installs software on its own.
  `install_quarto()` and `set_quarto_path()` do so only when a user calls them
  explicitly. Examples and vignettes never call them, and the tests exercise
  them only with the network download mocked. The vignettes evaluate their
  rendering chunks only when Quarto is present.

## Downstream dependencies

There are none (new package).
