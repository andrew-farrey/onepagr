# Security policy

## Supported versions

Security fixes are made to the latest release and to the `master` branch.

## Reporting a vulnerability

Please report a vulnerability privately, not in a public issue. Use the
**Report a vulnerability** button on the repository's
[Security tab](https://github.com/andrew-farrey/onepagr/security/advisories/new).
I aim to acknowledge a report within seven days.

Please do not include real, record-level, or sensitive data in a report. A
minimal example that uses `example_data()` or made-up values is enough.

## What counts as a vulnerability

onepagr runs on your computer. It calls Quarto and Typst, writes the PDF and a
work folder next to it, and uses a temporary folder. It downloads software only
when you call `install_quarto()`, and it edits `~/.Renviron` only when you
agree to that in `set_quarto_path()`.

Reports that fit this package include:

- a data value, template, theme, or file path that makes onepagr read or write
  outside the folders it is meant to use,
- a way to make onepagr run a command you did not ask it to run,
- a flaw in how `install_quarto()` downloads or unpacks Quarto.

A value placed in the body of a template is Typst markup by design. Text that
comes from outside your own analysis should go through `typst_escape()` first.
That is documented behavior, not a vulnerability.

For an accessibility problem in a PDF, please open a public issue with the
accessibility template instead.
