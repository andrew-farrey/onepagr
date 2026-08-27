# Render a onepagr one-pager to PDF

The quick path: given data, a built-in template name, and a theme,
produces a finished PDF with a single call. Validates `data` against the
target template's required tokens before compiling (see
[`compile_typst()`](https://andrew-farrey.github.io/onepagr/reference/compile_typst.md)),
so a missing value raises a clear R error instead of silently rendering
blank.

## Usage

``` r
render_onepager(
  data,
  template,
  theme = "default",
  theme_path = NULL,
  output,
  keep_typst = TRUE,
  extra_assets = character(0)
)
```

## Arguments

- data:

  Named list of whisker substitution values. For alert-style templates
  (`overdose_spike_alert`, `syndromic_alert`), the `severity_level`
  token must be the literal lowercase string `"warning"` or
  `"critical"`, and any `show_*` toggle token (e.g. `show_resources`,
  `show_cluster`) must be the literal lowercase string `"true"` or
  `"false"`. These are substituted directly into Typst string
  comparisons, so an R logical (which whisker coerces to
  `"TRUE"`/`"FALSE"`, uppercase) or any other value fails the compile
  loudly with a Typst `panic()` rather than silently rendering with the
  wrong severity styling or a mis-toggled section.

- template:

  Character. A built-in template name (see
  [`list_templates()`](https://andrew-farrey.github.io/onepagr/reference/list_templates.md)).

- theme:

  Character. A built-in theme name, or a path to a custom theme .typ
  file (see
  [`resolve_theme()`](https://andrew-farrey.github.io/onepagr/reference/resolve_theme.md)).
  Default `"default"`.

- theme_path:

  Character or `NULL`. Explicit theme file path override; when supplied,
  `theme` is ignored. Default `NULL`.

- output:

  Character. Path to write the compiled PDF to.

- keep_typst:

  Logical. Whether to leave the resolved `.typ` tree next to `output`
  (`TRUE`, default) or use a disposable tempdir (`FALSE`).

- extra_assets:

  Character vector of file paths to stage into the compile work
  directory alongside the theme/components/package assets – for per-run
  generated images (e.g. charts/maps produced fresh by the calling
  script) that a template's own `#image()` calls need to reference.
  Typst's compiler sandboxes file access to the directory being compiled
  from and rejects absolute filesystem paths outright (confirmed
  directly: `#image("C:/abs/path/map.png")` fails to compile with "path
  contains invalid component" even after fixing Windows backslashes to
  forward slashes – this isn't a path-syntax issue, Typst does not
  permit escaping its compile root at all). Each file is copied in by
  its basename (overwriting on conflict); pass just that basename as the
  corresponding whisker token's value (e.g.
  `extra_assets = "path/to/map0.png"` pairs with a template token value
  of `"map0.png"`, not the original full path). Default `character(0)`
  (no extra assets, e.g. for templates whose images are all static
  package assets).

## Value

Character, the `output` path, invisibly.

## Details

By default (`keep_typst = TRUE`) the resolved, whisker-substituted
`.typ` file is written next to `output`, along with the theme,
components, and assets it was compiled with – self-contained and
independently recompilable, not hidden in a disposable tempdir. Set
`keep_typst = FALSE` to compile in a disposable tempdir instead and
return only the PDF.
