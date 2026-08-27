# onepagr 0.1.0

Initial release.

## Core API

* `render_onepager()`: render a named list of values to a finished,
  accessible PDF using a built-in template and theme.
* `export_template()`: copy a built-in template's full source into your
  own project for exploration or hand-editing.
* `compile_typst()`: low-level primitive underlying both of the above;
  compiles any `.typ` file with whisker-substituted data.
* `check_quarto()` / `install_quarto()`: detect and, on request, install
  the Quarto/Typst toolchain onepagr depends on.
* `list_templates()` / `list_themes()` / `resolve_template()` /
  `resolve_theme()`: the built-in template and theme registry.
* `fmt_n()` / `fmt_pct()`: number-formatting helpers matching the
  convention every built-in template's tokens expect.

## Templates

Five built-in templates, each a genuinely distinct informational shape:

* `cohort_summary`: contrasts two groups at a point in time.
* `trend_snapshot`: tracks one metric across several time periods.
* `overdose_spike_alert`: anomaly/threshold alert bulletin
  (ODMAP-style), natural pagination.
* `syndromic_alert`: anomaly/threshold alert for any syndrome
  (ESSENCE-style), natural pagination.
* `county_choropleth`: geographic bivariate comparison across counties,
  supports per-run generated map images via `extra_assets`.

## Themes

* `default`: a brand-neutral palette built on Bootstrap 5.3's own color
  variables.
* `uk`: University of Kentucky / KIPRC branding.

Every built-in template and theme combination is verified against both
Typst's `--pdf-standard ua-1` compile-time check and a real PAC (PDF
Accessibility Checker) run covering both the PDF/UA and WCAG tabs.
