# Read a template's designed page count

Internal. A template declares the page count it is designed to fill with
a `//` comment line, `// designed-pages: 2`.

## Usage

``` r
extract_designed_pages(path)
```

## Arguments

- path:

  Character. Path to a .typ file.

## Value

Integer page count, or `NA_integer_` if the template declares none.
