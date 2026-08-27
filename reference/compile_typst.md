# Compile a .typ file with whisker-substituted data via Quarto/Typst

Low-level primitive: whisker-renders `path` against `data`, writes the
result next to `path`, then compiles it to `output` via
`quarto typst compile --pdf-standard ua-1 --features a11y-extras`. Works
on any .typ file – a package-shipped template or a user's own
[`export_template()`](https://andrew-farrey.github.io/onepagr/reference/export_template.md)-edited
copy – since required-token validation is derived by scanning the file
itself, not a separately-maintained manifest.

## Usage

``` r
compile_typst(path, data, output)
```

## Arguments

- path:

  Character. Path to a .typ file. Its
  `theme.typ`/`components.typ`/assets must already be alongside it, so
  Typst's relative `#import` paths resolve correctly.

- data:

  Named list of whisker substitution values.

- output:

  Character. Path to write the compiled PDF to.

## Value

Character, the `output` path, invisibly.
