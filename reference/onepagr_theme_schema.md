# The exact key -\> Typst type contract onepagr's shipped templates and `components.typ` rely on

Internal. Derived by grep-ing every real `theme.<key>` /
`theme-grad.<key>` reference across `inst/typst/components.typ` and
every `inst/typst/templates/*/template.typ` (not assumed), then
cross-checked directly against both shipped theme files' own key sets
via a real `typst eval` run – confirmed identical key-for-key between
`default.typ` and `uk.typ`. If a future template or component introduces
a new theme token, add it here too; `test-themes.R` diffs this list
against both shipped theme files' real key sets and fails loudly if they
diverge.

## Usage

``` r
onepagr_theme_schema()
```

## Value

A list with `theme` (named character vector, key -\> Typst `type()`
name), `theme_grad` (same shape), and `radius_card` (the nested
dictionary `theme$radius-card` must contain).
