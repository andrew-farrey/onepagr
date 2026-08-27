# Check whether Quarto is installed and meets onepagr's minimum version

Wraps the `quarto` package's `quarto_available()`/`quarto_version()` to
report what's installed. onepagr needs Quarto's Typst backend to support
`--pdf-standard ua-1` and `--features a11y-extras` – this checks against
that floor, not just "is Quarto present at all."

## Usage

``` r
check_quarto(min_version = "1.4.549")
```

## Arguments

- min_version:

  Character. Minimum required Quarto version. Default `"1.4.549"`.

## Value

Invisibly, a list with `available` (logical), `version`
(`package_version` or `NA`), and `ok` (logical, `TRUE` if available and
meets `min_version`).
