# Contributing to onepagr

Thank you for taking an interest in onepagr. This page explains how to
report a problem, how to set up for development, and the conventions the
project follows, so that a change is easy to review.

## Reporting a problem or asking for a feature

Please open an issue at
<https://github.com/andrew-farrey/onepagr/issues>. A useful bug report
has:

- a minimal example that reproduces it, ideally using
  [`example_data()`](https://andrew-farrey.github.io/onepagr/reference/example_data.md)
  so nobody needs your data,
- the output of
  [`onepagr::check_quarto()`](https://andrew-farrey.github.io/onepagr/reference/check_quarto.md)
  and [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html),
- what you expected and what happened instead.

For an accessibility problem, attach the PDF and say which checker or
screen reader reported it. A problem that passes the automated checkers
but fails a person is exactly what we want to hear about.

Please never post real, record-level, or sensitive data in an issue, a
comment, or an attachment. Use
[`example_data()`](https://andrew-farrey.github.io/onepagr/reference/example_data.md)
or made-up values. To report a security problem, follow
`.github/SECURITY.md` instead of opening a public issue.

## Setting up

``` r

# install.packages("devtools")
devtools::load_all()
devtools::test()
devtools::check()
```

Rendering needs Quarto 1.10 or newer, which bundles Typst 0.15.1 or
newer. Tests that need it skip themselves when it is missing; run
[`onepagr::check_quarto()`](https://andrew-farrey.github.io/onepagr/reference/check_quarto.md)
to see what you have.

## Code, tests and documentation

- **Style.** The tidyverse style guide, enforced by the `lintr` settings
  in `.lintr` (lines up to 100 characters). `lintr::lint_package()`
  should report nothing. Please do not reformat code you are not
  otherwise changing.
- **Documentation.** roxygen2 with markdown. Edit the roxygen comments,
  then run `devtools::document()`. Write plainly, in short sentences.
- **Tests.** testthat 3rd edition, one behavior per test, named for the
  behavior. A test that needs Quarto starts with
  `skip_if_not(quarto::quarto_available())`. Tests must never call
  [`install_quarto()`](https://andrew-farrey.github.io/onepagr/reference/install_quarto.md)
  or anything else that downloads software. For a bug fix, write the
  failing test first.
- **Dependencies.** Call optional packages as `pkg::fn()` behind a
  [`requireNamespace()`](https://rdrr.io/r/base/ns-load.html) guard, and
  declare what you use in `DESCRIPTION`.

## Changing a template, component, theme or asset

onepagr exists to produce accessible PDFs, so these changes carry extra
checks. Before opening a pull request:

1.  Render all 15 template and theme combinations from
    [`example_data()`](https://andrew-farrey.github.io/onepagr/reference/example_data.md)
    (`Rscript data-raw/gallery-images.R` renders the gallery set).
2.  Check each PDF with veraPDF (`--flavour ua1`) and pdfa11y.
3.  Measure text contrast against the lightest end of every gradient it
    sits on. A color that passes where the text happens to sit can still
    fail at the other end of the gradient.
4.  Run PAC by hand on the changed templates. PAC is a manual check, and
    its AI-assisted tab is advisory. The README lists the findings
    already reviewed.
5.  Regenerate the gallery images if anything looks different.

Say in the pull request what you ran and what it showed.

## Branches, commits and pull requests

- **Branch names** are a short kebab-case topic, such as `type-spacing`
  or `tokenize-headings`. No version numbers or prefixes.
- **Commit messages** start with an imperative, sentence-case subject of
  about 70 characters or fewer and no trailing period (“Add
  example_data() and template_data() starter-list helpers”). Use the
  body to explain why. One logical change per commit. No `feat:` or
  `fix:` prefixes.
- **Pull request titles** follow the same style. The body uses the
  sections in the pull request template: Summary, Why, Behavior to know
  about, and Verification.
- Keep a pull request to one topic. Include the tests, the documentation
  and the `NEWS.md` entry in the same pull request.

## NEWS

Add an entry under `# onepagr (development version)` in `NEWS.md` for
anything a user would notice. Write each bullet as a complete sentence
about what changed for the reader, in the present tense, and lead with
the function or topic in backticks when one function is the subject.
Group entries under `##` headings only when there are many. If your
change comes from an issue or a pull request, end the bullet with
`(#123)`, and thank outside contributors with `(@username)`.

## Code of conduct

Please note that onepagr is released with a Contributor Code of Conduct.
By contributing you agree to abide by its terms (see
`CODE_OF_CONDUCT.md`).
