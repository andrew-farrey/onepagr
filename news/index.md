# Changelog

## onepagr (development version)

This release folds in fixes from two external code reviews and a round
of accessibility evidence work. Apart from the header subtitle change
described under Themes, all 15 built-in template and theme combinations
render the same as before these fixes (same text, same pixels).

### Data and tokens

- [`compile_typst()`](https://andrew-farrey.github.io/onepagr/reference/compile_typst.md)
  and
  [`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
  escape a double quote, backslash or newline in a value that a template
  places inside a quoted string (organization names, alt text, contact
  details, file paths), so `Sample "North" Health Department` renders
  instead of failing in Typst. A value in the body of a template is
  still Typst markup, as before.
- [`typst_escape()`](https://andrew-farrey.github.io/onepagr/reference/typst_escape.md)
  is new. It makes plain text safe for a body token: `#`, `$`, `*`, `_`,
  a backtick, `<`, `>`, `@`, `/`, brackets and `~` show up literally.
  Escaping the slash keeps `//` in the text from starting a Typst
  comment, which would drop the rest of the line.
- [`compile_typst()`](https://andrew-farrey.github.io/onepagr/reference/compile_typst.md)
  reports a lone `]` or an unclosed `[` in a body value in R, naming the
  token, instead of as a Typst error about a generated file. The check
  runs after defaults and references are filled in, so a bracket that
  arrives through either is caught too.
- A token in a `//` comment of a template no longer receives its value.
  A value with a newline in it used to end the comment and turn the rest
  of the line into live markup, which could add a page.
- A default can refer to an optional token declared below it, and a
  chain of references (a refers to b, b refers to c) is followed to the
  end. Defaults or values that refer to each other in a loop are an
  error. Only `{{{token}}}` references are filled in; a `{{name}}` or
  `{{#section}}` in a value stays literal text.
- A name that one of your values refers to is no longer reported as
  ignored.
- An error about a missing token names the built-in template, such as
  `cohort_summary`, not `template.typ`.
- Numbers are formatted without scientific notation, so `100000` prints
  as `100000`, not `1e+05`. A number with more digits than a short
  decimal, an R logical, or a vector longer than one is an error that
  points to
  [`fmt_n()`](https://andrew-farrey.github.io/onepagr/reference/fmt_n.md)
  and
  [`fmt_pct()`](https://andrew-farrey.github.io/onepagr/reference/fmt_pct.md)
  or to the accepted spelling.
- A value that refers to a token (`{{{n_total}}}`), including a value
  from `template_data(tokens = "optional")`, is filled from your data,
  so literal `{{{token}}}` text no longer reaches the PDF.
- [`template_tokens()`](https://andrew-farrey.github.io/onepagr/reference/template_tokens.md)
  gains a `needed_by` column, and
  [`extract_required_tokens()`](https://andrew-farrey.github.io/onepagr/reference/extract_required_tokens.md)
  lists only tokens the template body uses. A token that only an
  optional token’s default uses is needed only while that default is in
  use.
- [`validate_template_data()`](https://andrew-farrey.github.io/onepagr/reference/validate_template_data.md)
  warns about a blank required value. A template can declare
  `// allow-empty: token` for text that is blank on purpose; the alert
  templates do this for `cluster_text` and `resources_text`.
- Template parsing no longer treats a `//` after a URL or inside a
  quoted string as a comment, so a token after `https://` on a line is
  found. A token name with a dot is rejected, `template_tokens("name")`
  no longer prefers a file of the same name in the working directory,
  and each template is parsed once per session (the file is only re-read
  to notice edits).
- A `*_width` bar token must be a plain number from 0 to 100, and bars
  are clamped to their track. `"65%"`, `"64,6"` and `"140"` stop with an
  error naming the token.
- [`compile_typst()`](https://andrew-farrey.github.io/onepagr/reference/compile_typst.md)
  no longer crashes on a custom template with no tokens when `data` has
  a name it does not use.
- Every template takes an optional `doc_lang` (default `"en"`) that sets
  the document language screen readers use.

### Export, render and install

- [`export_template()`](https://andrew-farrey.github.io/onepagr/reference/export_template.md)
  stops if `dest` already holds an exported template, so hand edits are
  not lost; use `overwrite = TRUE` to replace it. It also takes
  `theme_path`.
- [`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
  stops on an `extra_assets` file that would replace `theme.typ`,
  `components.typ` or a template file, or that two assets share a name,
  and stops on a failed file copy. It replaces its `_typst` work folder
  on each render, but only one that onepagr created (it holds a hidden
  marker file). Any other folder at that path, including an
  [`export_template()`](https://andrew-farrey.github.io/onepagr/reference/export_template.md)
  copy or a work folder left by an earlier version, is left alone and
  the render stops, so delete an old one once.
- The documentation for
  [`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
  and
  [`compile_typst()`](https://andrew-farrey.github.io/onepagr/reference/compile_typst.md)
  now says that `template_rendered.typ`, not `template.typ`, is the file
  that compiles.
- [`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
  checks the data before it creates the output folder or replaces the
  work folder, so a data error no longer removes the previous render’s
  work folder or leaves a new empty folder behind.
- [`install_quarto()`](https://andrew-farrey.github.io/onepagr/reference/install_quarto.md)
  finds `bin/quarto` wherever the archive put it (the macOS archive has
  no `quarto-<version>/` folder) and downloads the arm64 build on 64-bit
  ARM Linux.
  [`set_quarto_path()`](https://andrew-farrey.github.io/onepagr/reference/set_quarto_path.md)
  saves an absolute path.
- [`install_quarto()`](https://andrew-farrey.github.io/onepagr/reference/install_quarto.md)
  asks before the download in an interactive session, and after
  installing it removes the older copies it put in its folder, so the
  folder does not grow with every version. A copy that `QUARTO_PATH`
  points into is kept, and so is anything the function did not create.

### Themes

- [`check_theme()`](https://andrew-farrey.github.io/onepagr/reference/check_theme.md)
  no longer fails a theme for lacking `brand-sky`, `card-bg`,
  `callout-bg`, `lessons-bg` or `disclaimer-bg`, which no component
  reads, and reports unknown `theme-grad` keys as `unknown_grad`.
- Callout body text is a theme key, `callout-text`, with the previous
  color as its fallback, so a custom theme with a dark callout
  background can set it.
- The header subtitle in all five templates is now solid white instead
  of white at 85% opacity. With the `default` theme the translucent text
  measured 3.93:1 against the lightest end of the header gradient, under
  the 4.5:1 that WCAG 2.2 AA requires for text this size. It now
  measures 4.95:1 there, the same margin as the title, and the `uk` and
  `kdph` themes pass by a wider margin (7.53:1 and 10.60:1).

### Accessibility documentation

- [`vignette("accessibility-checks")`](https://andrew-farrey.github.io/onepagr/articles/accessibility-checks.md)
  is new. It explains what PAC, veraPDF and Typst’s own `ua-1` compile
  check, which PDF/UA-1 conditions still need a person (cross-referenced
  to the PDF Association’s Matterhorn Protocol 1.1), and gives a
  checklist for them.
- The README states the scope of the accessibility claims: which
  checkers were run, that PAC was run by hand, and that onepagr does not
  certify legal compliance with any law or regulation. Every built-in
  template and theme was also checked with veraPDF (PDF/UA-1 profile).
- The README and the accessibility vignette now say that on the two
  alert templates the page footer is a pagination artifact, so its
  logos, organization name and contact details are not read by a screen
  reader.

### Documentation and packaging

- [`fmt_n()`](https://andrew-farrey.github.io/onepagr/reference/fmt_n.md)
  and
  [`fmt_pct()`](https://andrew-farrey.github.io/onepagr/reference/fmt_pct.md)
  document that a half rounds to the even digit.
- [`example_data()`](https://andrew-farrey.github.io/onepagr/reference/example_data.md)
  names the missing file when a template has no example. Templates are
  read and written as UTF-8.
- `DESCRIPTION` now says the templates are designed to meet WCAG 2.2
  level AA and PDF/UA-1, quotes ‘Typst’, spells out both acronyms, adds
  the copyright holder role to `Authors@R`, declares `R (>= 4.1.0)` and
  `quarto (>= 1.5.0)` (the first quarto release that exports
  `quarto_available()`, which needs R 4.1.0), and lists `stats` in
  Imports.
- `example_data("county_choropleth")` can be rendered: its five
  placeholder maps ship in `inst/extdata/maps`, and the help page shows
  how to pass them as `extra_assets`.
- [`citation()`](https://rdrr.io/r/utils/citation.html) takes its year
  from the package’s publication date, so it no longer changes every
  January.
- Tests and vignettes that render a PDF run only when
  [`check_quarto()`](https://andrew-farrey.github.io/onepagr/reference/check_quarto.md)
  reports a Quarto whose bundled Typst is new enough, so an older Quarto
  skips them instead of failing.
- The bundled header texture is an original generated pattern, and the
  bundled Fluent icon in the hex logo is credited in `inst/COPYRIGHTS`.
- The README gains a Background section on where the templates came
  from, and the gallery images are regenerated from the current
  templates and themes.
- Corrected references to unshipped design documents and to theme keys
  that do not exist.

### Internal

- [`check_theme()`](https://andrew-farrey.github.io/onepagr/reference/check_theme.md)
  and
  [`compile_typst()`](https://andrew-farrey.github.io/onepagr/reference/compile_typst.md)
  are split into smaller helpers, the “Quarto was not found” error comes
  from one place, and
  [`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
  inherits parameter documentation from
  [`export_template()`](https://andrew-farrey.github.io/onepagr/reference/export_template.md)
  and
  [`compile_typst()`](https://andrew-farrey.github.io/onepagr/reference/compile_typst.md).
  A `.lintr` file sets the lint settings, and a lint workflow runs on
  every push.

## onepagr 0.1.0

Initial release. onepagr generates polished, WCAG 2.2 AA and PDF/UA-1
accessible one-page (front-and-back) PDF reports from analysis output,
using a small set of fixed Typst templates and a design-token theme
system that a consuming project can restyle with its own branding.

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
- All the reader-facing text in the built-in templates is tokenized, so
  changing it is a change to your `data` list, not to the template:
  section headings, box labels, captions, paragraphs, bullets, bar-chart
  row labels, the metadata strip and footer labels, and chart and map
  alt text. Each token is optional and defaults to the text the template
  shipped with, so default output is unchanged. Names follow a prefix
  pattern (`heading_*`, `label_*`, `stat_*`, `bar_*`, `text_*`, `alt_*`,
  and a few others; see the theming vignette, Part 5). A default may
  refer to other tokens, as in `Results (N = {{{n_total}}})`, and those
  stay required.
- A name in `data` that no template uses is ignored with a warning
  instead of silently, and the warning suggests the closest token when
  there is one
  (`"heading_glnce" was ignored ... Did you mean "heading_glance"?`). A
  name that belongs to a different built-in template stays quiet, so one
  data list can be shared across templates.
- [`template_tokens()`](https://andrew-farrey.github.io/onepagr/reference/template_tokens.md)
  lists every token a built-in template, or an exported copy of one,
  takes: which are required, and the default of each optional one.
- [`template_data()`](https://andrew-farrey.github.io/onepagr/reference/template_data.md)
  returns a complete, working starter list for a built-in template:
  every token
  [`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
  would read, each already set to a real value, not a blank to guess the
  shape of. A required token (which has no default of its own) gets the
  matching value from the template’s
  [`example_data()`](https://andrew-farrey.github.io/onepagr/reference/example_data.md);
  an optional token gets its own shipped default. The `tokens` argument
  narrows this to `"required"` or `"optional"` alone, and the result’s
  `"required"` attribute names which entries came from which, so the
  plain list itself stays exactly what
  [`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
  expects.
- [`example_data()`](https://andrew-farrey.github.io/onepagr/reference/example_data.md)
  returns a built-in template’s full example data as a named list: the
  same data this package’s own tests render, and the single, installed
  source of truth that
  [`template_data()`](https://andrew-farrey.github.io/onepagr/reference/template_data.md)
  also draws from, so there’s no separate hand-typed copy to keep in
  sync.
- The shared footer’s logo lockup takes a height and a vertical nudge
  for each logo (`logo-a-height`, `logo-height`, `logo-b-height` and
  `logo-a-dy`, `logo-dy`, `logo-b-dy`, defaulting to 32pt and 0pt), for
  logos whose artwork differs in size or sits off-center in its canvas.
  Every logo sits in a cell as tall as the tallest logo shown (a hidden
  partner’s height is ignored), so the dividers between logos span the
  full lockup height.

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
- `uk`: University of Kentucky and Kentucky Injury Prevention and
  Research Center (KIPRC) branding.
- `kdph`: Kentucky Department for Public Health colors and fonts,
  following the department’s 2026 Data Visualization Style Guidelines
  (unofficial; not endorsed by KDPH). A theme’s `body-font` can be a
  fallback list instead of a single name; `kdph` uses one (Calibri, then
  Carlito, then Liberation Sans).

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
