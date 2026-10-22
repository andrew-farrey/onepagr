# Format a value as a percent string

Thin wrapper around
[`scales::percent()`](https://scales.r-lib.org/reference/percent_format.html).
Input is already on a 0-100 scale (e.g. 84, not 0.84), matching the
convention used throughout onepagr's reference templates and R data-prep
scripts.

## Usage

``` r
fmt_pct(x, digits = 0)
```

## Arguments

- x:

  Numeric vector, already scaled 0-100.

- digits:

  Number of decimal places. Default 0.

## Value

Character vector.

## Details

A value exactly halfway rounds to the even digit, as in
[`fmt_n()`](https://andrew-farrey.github.io/onepagr/reference/fmt_n.md):
`84.5` gives `"84%"` and `85.5` gives `"86%"`. A fraction such as `0.84`
is not rescaled, so `fmt_pct(0.84)` is `"1%"`: multiply by 100 first.

The result carries a `%` sign, so it is for text labels. A bar-chart
`*_width` token takes a plain number from 0 to 100 (for example
`"64.6"`), not this output: `"65%"` is rejected before the compile.

## Examples

``` r
fmt_pct(84.2)
#> [1] "84%"
fmt_pct(84.216, digits = 1)
#> [1] "84.2%"
```
