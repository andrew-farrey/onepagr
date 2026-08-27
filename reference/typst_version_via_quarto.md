# Extract the Typst version Quarto's own `typst` subcommand reports

`quarto typst --version` prints a line like `typst 0.15.1 (9dfd3a08)`.

## Usage

``` r
typst_version_via_quarto(quarto_bin)
```

## Arguments

- quarto_bin:

  Character. Path to the quarto binary.

## Value

`package_version`, or `NA` if the version couldn't be parsed.
