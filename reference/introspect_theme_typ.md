# Introspect a theme `.typ` file's real Typst-evaluated key/type structure

Internal. Runs `typst eval` (via Quarto's bundled Typst) against a small
generated snippet that imports `theme`/`theme-grad` from `path` and maps
every key to `repr(type(value))` – so what comes back describes exactly
what Typst itself would see at real compile time, not a guess from
regex-parsing the file's text. `--root` is set to `path`'s own directory
and the import references just its basename, since Typst's `#import`
rejects an absolute filesystem path outright (confirmed directly: "path
contains invalid component" on a Windows drive letter) – it only
resolves paths relative to `--root`.

## Usage

``` r
introspect_theme_typ(path)
```

## Arguments

- path:

  Character. Absolute path to a theme `.typ` file.

## Value

A list with `error` (character or `NULL`; the raw Typst stderr if the
file failed to evaluate at all – when non-`NULL`, `theme`/
`theme_grad`/`radius_card` are all `NULL`), `theme` (2-column character
matrix of key/type pairs, or `NULL`), `theme_grad` (same shape), and
`radius_card` (same shape, or `NULL` if `theme$radius-card` isn't a
dictionary or `radius-card` is missing).
