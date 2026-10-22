# Validate whisker data against a template's required tokens

Raises a clear error listing every missing or NA token before whisker or
Typst ever run, instead of letting a missing token silently render as
blank text. The tokens that count are the ones the template body uses,
plus the ones needed by a default that `data` leaves in use (see
[`template_tokens()`](https://andrew-farrey.github.io/onepagr/reference/template_tokens.md)).
A blank value for one of them draws a warning unless the template
declares `// allow-empty: token`, and a bar-chart `*_width` token must
be a plain number from 0 to 100.

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

## Examples

``` r
path <- resolve_template("cohort_summary")
# A complete example list passes; drop a required value and it errors.
validate_template_data(path, example_data("cohort_summary"))
```
