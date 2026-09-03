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

## Examples

``` r
fmt_pct(84.2)
#> [1] "84%"
fmt_pct(84.216, digits = 1)
#> [1] "84.2%"
```
