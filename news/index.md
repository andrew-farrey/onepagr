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
  logo (always shown) plus two optional partner logos, off by default
  and switched on independently with `show_partner_a`/`show_partner_b`.
  A single organization passes only `logo_primary_path` and
  `logo_primary_alt` (the header texture defaults to the bundled one); a
  two-agency partnership and a three-organization lockup are first-class
  cases too. Switching a partner on without its path and alt text is an
  error, not a placeholder.
- [`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)’s
  `font_dir` argument makes a directory of font files available to Typst
  for a compile, for a theme font that isn’t installed system-wide.
- A template can declare a token optional with a comment line,
  `// optional-token: name = default`. When the data list omits that
  token,
  [`compile_typst()`](https://andrew-farrey.github.io/onepagr/reference/compile_typst.md)
  and
  [`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
  use the default instead of raising a missing-token error, and
  [`extract_required_tokens()`](https://andrew-farrey.github.io/onepagr/reference/extract_required_tokens.md)
  no longer lists it.
- The shared footer’s logo lockup takes a height and a vertical nudge
  for each logo (`logo-a-height`, `logo-height`, `logo-b-height` and
  `logo-a-dy`, `logo-dy`, `logo-b-dy`, defaulting to 32pt and 0pt), for
  logos whose artwork differs in size or sits off-center in its canvas.
  Every logo now sits in a cell as tall as the tallest logo shown (a
  hidden partner’s height is ignored), so the dividers between logos
  span the full lockup height (previously about 23pt in the two alert
  templates).

### Templates

Five built-in templates, each a genuinely distinct informational shape:

- `cohort_summary`: contrasts two groups at a point in time.
- `trend_snapshot`: tracks one metric across several time periods.
- `overdose_spike_alert`: anomaly/threshold alert bulletin
  (ODMAP-style), natural pagination.
- `syndromic_alert`: anomaly/threshold alert for any syndrome
  (ESSENCE-style), natural pagination.
- `county_choropleth`: geographic bivariate comparison across counties,
  supports per-run generated map images via `extra_assets`. Its footer
  logos can be sized and nudged per render with the optional tokens
  `logo_a_height`, `logo_height`, `logo_b_height` (points, default 32)
  and `logo_a_dy`, `logo_dy`, `logo_b_dy` (points, default 0).

### Themes

- `default`: a brand-neutral palette built on Bootstrap 5.3’s own color
  variables.
- `uk`: University of Kentucky / KIPRC branding.
- `kdph`: Kentucky Department for Public Health colors and fonts,
  following the department’s 2026 Data Visualization Style Guidelines
  (unofficial; not endorsed by KDPH). A theme’s `body-font` may now be a
  fallback list, which this theme uses (Calibri, then Carlito, then
  Liberation Sans).

Every theme has three type and spacing keys: `min-font-size` (a floor
for text size), `font-scale`, and `space-scale`. All default to no
change. Each can be overridden for a single render with the optional
data tokens `min_font_size` (points), `font_scale`, and `space_scale`. A
custom theme needs the three keys added. Boxes that hold text grow with
the type, including the alert templates’ bottom margin and the county
map explainer box; images, logos, and map sizes stay fixed. When a
fixed-page template’s output no longer matches its designed page count,
[`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
says so.

Every built-in template combined with the `default` or `uk` theme is
verified against both Typst’s `--pdf-standard ua-1` compile-time check
and a real PAC (PDF Accessibility Checker) run covering both the PDF/UA
and WCAG tabs. Combinations with `kdph` compile under
`--pdf-standard ua-1`, have computed WCAG contrast ratios at both ends
of every gradient, and were run through PAC on the sample content.
