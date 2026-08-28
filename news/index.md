# Changelog

## onepagr 0.1.0

Initial release.

### Core API

- [`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md):
  render a named list of values to a finished, accessible PDF using a
  built-in template and theme.
- [`export_template()`](https://andrew-farrey.github.io/onepagr/reference/export_template.md):
  copy a built-in template’s full source into your own project for
  exploration or hand-editing.
- [`compile_typst()`](https://andrew-farrey.github.io/onepagr/reference/compile_typst.md):
  low-level primitive underlying both of the above; compiles any `.typ`
  file with whisker-substituted data.
- [`check_quarto()`](https://andrew-farrey.github.io/onepagr/reference/check_quarto.md)
  /
  [`install_quarto()`](https://andrew-farrey.github.io/onepagr/reference/install_quarto.md):
  detect and, on request, install the Quarto/Typst toolchain onepagr
  depends on.
- [`list_templates()`](https://andrew-farrey.github.io/onepagr/reference/list_templates.md)
  /
  [`list_themes()`](https://andrew-farrey.github.io/onepagr/reference/list_themes.md)
  /
  [`resolve_template()`](https://andrew-farrey.github.io/onepagr/reference/resolve_template.md)
  /
  [`resolve_theme()`](https://andrew-farrey.github.io/onepagr/reference/resolve_theme.md):
  the built-in template and theme registry.
- [`fmt_n()`](https://andrew-farrey.github.io/onepagr/reference/fmt_n.md)
  /
  [`fmt_pct()`](https://andrew-farrey.github.io/onepagr/reference/fmt_pct.md):
  number-formatting helpers matching the convention every built-in
  template’s tokens expect.
- Logos are data, not template edits: every template takes a primary
  logo (always shown) plus two independently toggleable partner logos
  (`show_partner_a`/`show_partner_b`), so a single organization, a
  two-agency partnership, and a three-organization lockup are all
  first-class cases.
- [`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)’s
  `font_dir` argument makes a directory of font files available to Typst
  for a compile, for a theme font that isn’t installed system-wide.

### Templates

Five built-in templates, each a genuinely distinct informational shape:

- `cohort_summary`: contrasts two groups at a point in time.
- `trend_snapshot`: tracks one metric across several time periods.
- `overdose_spike_alert`: anomaly/threshold alert bulletin
  (ODMAP-style), natural pagination.
- `syndromic_alert`: anomaly/threshold alert for any syndrome
  (ESSENCE-style), natural pagination.
- `county_choropleth`: geographic bivariate comparison across counties,
  supports per-run generated map images via `extra_assets`.

### Themes

- `default`: a brand-neutral palette built on Bootstrap 5.3’s own color
  variables.
- `uk`: University of Kentucky / KIPRC branding.

Every built-in template and theme combination is verified against both
Typst’s `--pdf-standard ua-1` compile-time check and a real PAC (PDF
Accessibility Checker) run covering both the PDF/UA and WCAG tabs.
