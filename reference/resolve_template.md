# Resolve a built-in template name to its installed template.typ path

Resolve a built-in template name to its installed template.typ path

## Usage

``` r
resolve_template(template)
```

## Arguments

- template:

  Character. A built-in template name (e.g. "cohort_summary").

## Value

Character, absolute path to the template's `template.typ` file.

## Examples

``` r
resolve_template("cohort_summary")
#> [1] "/home/runner/work/_temp/Library/onepagr/typst/templates/cohort_summary/template.typ"
```
