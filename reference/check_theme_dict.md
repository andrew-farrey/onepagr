# Compare a theme dictionary's real keys/types against an expected schema

Internal, shared by
[`check_theme()`](https://andrew-farrey.github.io/onepagr/reference/check_theme.md)
for `theme`, `theme-grad`, and the nested `radius-card` dictionary
alike.

## Usage

``` r
check_theme_dict(actual_matrix, expected_types)
```

## Arguments

- actual_matrix:

  2-column character matrix from
  [`introspect_theme_typ()`](https://andrew-farrey.github.io/onepagr/reference/introspect_theme_typ.md)
  (key, type), or `NULL`/[`list()`](https://rdrr.io/r/base/list.html).

- expected_types:

  Named character vector, expected Typst type name by key (from
  [`onepagr_theme_schema()`](https://andrew-farrey.github.io/onepagr/reference/onepagr_theme_schema.md)).

## Value

A list with `missing` (character vector), `mismatches` (data frame:
`key`, `expected`, `actual`), and `unknown` (character vector of keys
present but outside `expected_types`).
