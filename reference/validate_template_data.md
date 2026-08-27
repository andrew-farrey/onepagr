# Validate whisker data against a template's required tokens

Raises a clear error listing every missing or NA token before whisker or
Typst ever run, instead of letting a missing token silently render as
blank text.

## Usage

``` r
validate_template_data(path, data)
```

## Arguments

- path:

  Character. Path to a .typ file.

- data:

  Named list of whisker substitution values.

## Value

Invisibly `TRUE` if validation passes.
