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
compile_typst(path, data, output, font_dir = NULL)
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

- font_dir:

  Character or `NULL`. A directory of font files (`.ttf`/ `.otf`) to
  make available to Typst for this compile, passed through as
  `--font-path`. Typst does not merge this with the system font list –
  both system fonts and this directory are searched, so a theme's
  `text-font`/`heading-font` tokens can name either a system-installed
  font or one shipped here (confirmed directly:
  `quarto typst fonts --font-path <dir>` lists a font from `<dir>`
  alongside system fonts, not instead of them). Default `NULL` (system
  fonts only).

## Value

Character, the `output` path, invisibly.
