# Reduce a `typst eval`-parsed key/type matrix to a named vector

Internal. Handles the two edge cases
[`jsonlite::fromJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)
produces for an empty or absent key/type array: `NULL` (the key, e.g.
`radius-card`, wasn't present or wasn't a dictionary at all) and
[`list()`](https://rdrr.io/r/base/list.html) (an empty Typst dictionary,
valid but pathological). Both become `character(0)` rather than erroring
on `NULL[, 2]`/`list()[, 2]`-style indexing.

## Usage

``` r
theme_type_vector(m)
```

## Arguments

- m:

  2-column character matrix (key, type), or
  `NULL`/[`list()`](https://rdrr.io/r/base/list.html).

## Value

Named character vector, type by key.
