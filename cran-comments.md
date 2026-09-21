## Submission

This is a new submission (onepagr 0.1.0).

## Test environments

* Local: Windows 11, R 4.5.2 (release)
* win-builder: Windows Server 2022, R Under development (2026-09-20 r90574 ucrt)
* GitHub Actions (on every push): macOS (R release), Windows (R release),
  Ubuntu (R devel, R release, R oldrel-1)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

* Possibly misspelled words in DESCRIPTION: "Typst", "UA", "WCAG". These are
  correct. Typst is the open-source typesetting system the package compiles
  its templates with, PDF/UA is the ISO 14289 accessible-PDF standard, and
  WCAG is the W3C Web Content Accessibility Guidelines.

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
