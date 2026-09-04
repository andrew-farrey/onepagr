# Export a built-in template for customization

Copies a template's full self-contained folder (`template.typ` plus the
resolved `theme.typ`, `components.typ`, and assets it needs to compile
independently) into `dest`, before any real data exists, for
exploration, hand-editing, or handing to an AI coding assistant to
extend. That last case is a deliberate design goal, not an afterthought:
[`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
also never hides the `.typ` source it compiles from by default,
precisely so a real, readable, working template is always sitting
somewhere an AI assistant (or a collaborator) can be pointed at to build
a variation of it. Once exported, the copy is the user's own; nothing in
onepagr auto-regenerates over it. Compile an exported template directly
with
[`compile_typst()`](https://andrew-farrey.github.io/onepagr/reference/compile_typst.md).

## Usage

``` r
export_template(template, dest, theme = "default")
```

## Arguments

- template:

  Character. A built-in template name (see
  [`list_templates()`](https://andrew-farrey.github.io/onepagr/reference/list_templates.md)).

- dest:

  Character. Directory to copy the template into. Created recursively if
  it doesn't exist.

- theme:

  Character. A built-in theme name, or a path to a custom theme .typ
  file, to resolve and copy in as `theme.typ`. Default `"default"`.

## Value

Character, `dest`, invisibly.

## Examples

``` r
dest <- file.path(tempdir(), "my-cohort-summary")
export_template("cohort_summary", dest, theme = "uk")
list.files(dest)
#> [1] "assets"         "components.typ" "template.typ"   "theme.typ"     
unlink(dest, recursive = TRUE)
```
