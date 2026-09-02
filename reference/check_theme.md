# Check a theme's dictionary structure against onepagr's real contract

Validates a theme `.typ` file's `theme` and `theme-grad` exports by
actually evaluating them with Typst (`typst eval`, via Quarto's bundled
binary) rather than a hand-rolled text parser – so a theme flagged here
is confirmed to fail (or nearly fail) the exact same way it would at
real render time, not just suspected to. Checks:

## Usage

``` r
check_theme(theme = "default", theme_path = NULL)
```

## Arguments

- theme:

  Character. A built-in theme name (e.g. "uk") or a path to a custom
  theme `.typ` file. Default `"default"`.

- theme_path:

  Character or `NULL`. Explicit path override, same as
  [`resolve_theme()`](https://andrew-farrey.github.io/onepagr/reference/resolve_theme.md).

## Value

Invisibly, a list: `ok` (logical), `path` (the resolved theme file),
`error` (character or `NULL`; set only when the file failed to evaluate
at all, in which case every field below is empty/`NA`), `missing` /
`missing_grad` (character vectors of required keys not found in `theme`
/ `theme-grad`), `type_mismatches` / `type_mismatches_grad` (data frames
with `key`, `expected`, `actual` columns), `radius_card_missing` /
`radius_card_type_mismatches` (same shape, for the nested `radius-card`
dictionary), and `unknown` (character vector of keys present in `theme`
but outside onepagr's known schema – informational only, not a failure;
could be a typo, or a key your own templates read directly).

## Details

1.  The file evaluates at all (catches a Typst syntax error, a missing
    `theme`/`theme-grad` export, or any other error Typst itself would
    raise).

2.  Every key onepagr's shipped templates and `components.typ` actually
    dereference is present, in both `theme` and `theme-grad`.

3.  Each present key's real Typst-evaluated type matches what onepagr
    expects (e.g. a color key set to a bare string, or a length key set
    to a color) – exactly the kind of mistake that would otherwise
    surface as a much less legible Typst error deep inside
    `components.typ`, pointing at the component's own code rather than
    the theme file that actually caused it.

Does **not** check color contrast or WCAG compliance – a value can be a
perfectly well-formed `color` and still fail WCAG (or vice versa, though
a malformed value can never pass it). That's a semantic judgment, not a
structural one, and belongs in a separate contrast-checking function,
not folded in here.

Callable standalone while developing a new theme (before ever calling
[`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)),
or from another onepagr function or your own test suite that wants to
validate a theme up front – nothing about it is tied to a particular
call site.
