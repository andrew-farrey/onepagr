# The exact key -\> Typst type contract onepagr's shipped templates and `components.typ` rely on

Internal. The required keys are the ones `inst/typst/components.typ` and
every `inst/typst/templates/*/template.typ` actually read as
`theme.<key>` / `theme-grad.<key>` (counted by script, not assumed); the
`optional_theme` keys are allowed but not read directly. All three
shipped themes (`default.typ`, `uk.typ`, `kdph.typ`) define exactly
these keys, which `test-themes.R` checks with a real `typst eval` run,
so a key added to a component or template has to be added here too or
that test fails.

## Usage

``` r
onepagr_theme_schema()
```

## Value

A list with `theme` (named character vector, key -\> Typst `type()`
name; `|` separates accepted alternatives, so `body-font` is
`"str|array"` to allow a font fallback list), `optional_theme` (same
shape, keys that may be present), `theme_grad` (same shape), and
`radius_card` (the nested dictionary `theme$radius-card` must contain).
