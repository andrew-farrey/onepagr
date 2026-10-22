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

## Details

A value exactly halfway between two integers is rounded to the even one,
as R's own [`round()`](https://rdrr.io/r/base/Round.html) does (IEC
60559): `2.5` gives `"2"` and `1.5` gives `"2"`. Round half up yourself
first if a style guide asks for that.

## Examples

``` r
fmt_n(c(1234, 56789))
#> [1] "1,234"  "56,789"
```
