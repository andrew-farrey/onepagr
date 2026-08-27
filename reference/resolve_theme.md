# Resolve a theme name or path to an installed .typ file

`theme` is checked against onepagr's built-in theme registry first
(`inst/typst/themes/<name>.typ`); if no registry entry matches, `theme`
is treated as a file path instead. `theme_path`, when supplied, always
wins and is used verbatim without any registry lookup.

## Usage

``` r
resolve_theme(theme = "default", theme_path = NULL)
```

## Arguments

- theme:

  Character. A built-in theme name (e.g. "uk") or a path to a custom
  theme .typ file.

- theme_path:

  Character or NULL. Explicit path override; when supplied, `theme` is
  ignored entirely.

## Value

Character, an absolute path to a .typ theme file.
