# Format a number with comma grouping

Thin wrapper around
[`scales::comma()`](https://scales.r-lib.org/reference/comma.html) tuned
to onepagr's integer-count formatting needs: no decimal places,
comma-grouped.

## Usage

``` r
fmt_n(x)
```

## Arguments

- x:

  Numeric vector.

## Value

Character vector.

## Examples

``` r
fmt_n(c(1234, 56789))
#> [1] "1,234"  "56,789"
```
