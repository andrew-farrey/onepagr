# Package index

## Render a report

Turn a data list into a finished, accessible PDF.

- [`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
  : Render a onepagr one-pager to PDF
- [`compile_typst()`](https://andrew-farrey.github.io/onepagr/reference/compile_typst.md)
  : Compile a .typ file with whisker-substituted data via Quarto/Typst
- [`export_template()`](https://andrew-farrey.github.io/onepagr/reference/export_template.md)
  : Export a built-in template for customization

## Templates and themes

What ships with the package, and how to see what a template takes.

- [`list_templates()`](https://andrew-farrey.github.io/onepagr/reference/list_templates.md)
  : List built-in template names
- [`list_themes()`](https://andrew-farrey.github.io/onepagr/reference/list_themes.md)
  : List built-in theme names
- [`resolve_template()`](https://andrew-farrey.github.io/onepagr/reference/resolve_template.md)
  : Resolve a built-in template name to its installed template.typ path
- [`resolve_theme()`](https://andrew-farrey.github.io/onepagr/reference/resolve_theme.md)
  : Resolve a theme name or path to an installed .typ file
- [`template_tokens()`](https://andrew-farrey.github.io/onepagr/reference/template_tokens.md)
  : List the tokens a template takes
- [`template_data()`](https://andrew-farrey.github.io/onepagr/reference/template_data.md)
  : Build a starter data list for a template
- [`example_data()`](https://andrew-farrey.github.io/onepagr/reference/example_data.md)
  : Example data for a built-in template
- [`check_theme()`](https://andrew-farrey.github.io/onepagr/reference/check_theme.md)
  : Check a theme's dictionary structure against onepagr's real contract

## Preparing your data

Format values and check them before rendering.

- [`fmt_n()`](https://andrew-farrey.github.io/onepagr/reference/fmt_n.md)
  : Format a number with comma grouping
- [`fmt_pct()`](https://andrew-farrey.github.io/onepagr/reference/fmt_pct.md)
  : Format a value as a percent string
- [`typst_escape()`](https://andrew-farrey.github.io/onepagr/reference/typst_escape.md)
  : Escape plain text for use in a content token
- [`validate_template_data()`](https://andrew-farrey.github.io/onepagr/reference/validate_template_data.md)
  : Validate whisker data against a template's required tokens
- [`extract_required_tokens()`](https://andrew-farrey.github.io/onepagr/reference/extract_required_tokens.md)
  : Extract required whisker tokens from a .typ file

## Set up Quarto and Typst

Check for, install and point onepagr at the toolchain it needs.

- [`check_quarto()`](https://andrew-farrey.github.io/onepagr/reference/check_quarto.md)
  : Check whether Quarto is installed and its bundled Typst is new
  enough
- [`install_quarto()`](https://andrew-farrey.github.io/onepagr/reference/install_quarto.md)
  : Install Quarto to a user-local directory
- [`set_quarto_path()`](https://andrew-farrey.github.io/onepagr/reference/set_quarto_path.md)
  : Point onepagr (and Quarto) at a specific Quarto binary
