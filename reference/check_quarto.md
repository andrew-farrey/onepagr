# Check whether Quarto is installed and its bundled Typst is new enough

Wraps the `quarto` package's `quarto_available()` to check Quarto is
present, then checks the **Typst version Quarto actually bundles**, not
Quarto's own version number, which is NOT a reliable proxy for this:
confirmed directly (via web research plus this package's own pinned dev
environment) that Quarto sat on Typst 0.11.x across multiple Quarto
1.4-1.7.x releases before eventually bundling a newer one, so a
Quarto-version floor can pass while the bundled Typst is still too old
for `--pdf-standard ua-1` (added in Typst 0.14.0) or
`--features a11y-extras` (this package is built and tested against Typst
0.15.1 specifically, bundled by Quarto 1.10.18, confirmed directly by
running `quarto typst --version` in the dev environment every template
in this package was verified against).

## Usage

``` r
check_quarto(min_typst_version = "0.15.1")
```

## Arguments

- min_typst_version:

  Character. Minimum required Typst version (the version Quarto's own
  bundled `typst` binary reports, not Quarto's own version). Default
  `"0.15.1"`, matching this package's own tested baseline.

## Value

Invisibly, a list with `available` (logical), `quarto_version`
(`package_version` or `NA`), `typst_version` (`package_version` or
`NA`), and `ok` (logical, `TRUE` if available and the bundled Typst
meets `min_typst_version`).

## Examples

``` r
# Safe to call whether or not Quarto is installed; it reports back
# either way rather than erroring.
check_quarto()
```
