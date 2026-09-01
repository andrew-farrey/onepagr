# onepagr

Generate polished, accessible one-page (front-and-back) PDF reports from
analysis output, using a small set of fixed Typst templates and a
swappable design-token theme system.

Every template compiles under Typst’s `--pdf-standard ua-1` conformance
check and is built to pass WCAG 2.2 AA color contrast and PDF/UA-1
structural tagging, not as a final pass but as a requirement checked at
every step of development.

## Why

Public health teams and similar analysis groups often need to turn a
piece of analysis into a one-page fact sheet, surveillance brief, or
alert bulletin: something that can be printed front-and-back, shared as
a PDF, or read on a phone. Doing that by hand in a slide deck or word
processor is slow to reproduce and easy to get wrong on accessibility.
onepagr turns a named list of values into a finished PDF with one
function call, using templates whose layout and accessibility patterns
are already solved.

## Installation

onepagr is not yet on CRAN. Install the development version from GitHub:

``` r

# install.packages("pak")
pak::pak("andrew-farrey/onepagr")
```

onepagr also needs [Quarto](https://quarto.org), which bundles
[Typst](https://typst.app), on your system. **Accessible PDF output
needs Typst 0.14.0 or newer**, the release that [added PDF/UA-1
conformance and automatic tagged-PDF
support](https://typst.app/docs/changelog/0.14.0/) in the first place.
Older Typst simply cannot produce an accessible PDF, no matter what
onepagr does. onepagr itself checks for Typst 0.15.1+ by default (a
newer floor than the bare minimum, confirmed to be what’s actually
bundled by recent Quarto releases). Check whether your system’s Typst is
new enough, and get a clear message naming the actual version if it
isn’t:

``` r

onepagr::check_quarto()
```

If it’s missing,
[`onepagr::install_quarto()`](https://andrew-farrey.github.io/onepagr/reference/install_quarto.md)
installs a user-local copy without needing admin rights (you must run it
yourself; onepagr never installs software automatically). On macOS and
Linux it also points onepagr at the copy it just installed for you: it
sets `QUARTO_PATH` for your current session immediately, then asks
whether to save that to your `~/.Renviron` too, so every future R
session picks it up automatically without you ever needing to know what
a `.Renviron` file is. (On Windows it opens the official installer
instead of extracting anything itself, so there’s no path to point at
until you finish that installer yourself.)

Already have a Quarto install somewhere else onepagr should use instead,
for example an admin-managed one on Posit Workbench? Point onepagr at it
the same way, without hand-editing anything:

``` r

onepagr::set_quarto_path("/path/to/quarto")
```

## Quick start

``` r

library(onepagr)

data <- list(
  doc_title = "OVERDOSE SPIKE ALERT",
  doc_subtitle = "Sample County Surveillance",
  org_full = "Sample Health Department",
  contact_url = "https://example.org/",
  contact_email = "contact@example.org",
  severity_level = "critical",
  alert_area = "Sample County",
  alert_issued_at = "August 26, 2026, 9:00 AM",
  n_events = "14",
  window_days = "3",
  n_spikes = "2",
  spike_window_days = "30",
  threshold = "8",
  narrative_text = "Sample County has recorded 14 suspected overdoses...",
  geo_breakdown_text = "- Northside: 6 events\n- Downtown: 5 events",
  actions_text = "- Increase naloxone distribution in the affected area",
  show_resources = "true",
  resources_text = "Sample Health Department, (555) 123-4567.",
  footnote_sources = "Sample Overdose Detection Mapping System"
)

render_onepager(data, template = "overdose_spike_alert", theme = "uk", output = "alert.pdf")
```

That’s it: `alert.pdf` is a finished, accessible PDF. By default,
[`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
also leaves the resolved `.typ` source next to the output
(`alert_typst/`), so it’s never hidden away, even if you never need to
look at it. That’s deliberate: it’s useful for troubleshooting, and it
means a real, working template is always sitting somewhere you can hand
it to an AI coding assistant (or a collaborator) to build out further,
which is part of the point of how onepagr is structured. Set
`keep_typst = FALSE` to skip that and get only the PDF.

See
[`?render_onepager`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
for every argument, or run
[`vignette("getting-started", package = "onepagr")`](https://andrew-farrey.github.io/onepagr/articles/getting-started.md)
for a fuller walkthrough. For a realistic, worked example that starts
from real public data and runs a small analysis before rendering (rather
than a hand-typed values list), see
[`vignette("end-to-end-workflow", package = "onepagr")`](https://andrew-farrey.github.io/onepagr/articles/end-to-end-workflow.md).

## Built-in templates

Each template is a distinct informational shape, not a variation on the
same layout:

| Template | Shape | Pages |
|----|----|----|
| `cohort_summary` | Contrasts two groups at a point in time | Fixed, 2 |
| `trend_snapshot` | Tracks one metric across several periods | Fixed, 2 |
| `overdose_spike_alert` | Anomaly/threshold alert (ODMAP-style) | 1-2, natural |
| `syndromic_alert` | Anomaly/threshold alert, any syndrome (ESSENCE-style) | 1-2, natural |
| `county_choropleth` | Geographic bivariate comparison across counties | Fixed, 2 |

List them programmatically with
[`list_templates()`](https://andrew-farrey.github.io/onepagr/reference/list_templates.md).
Want to see one without any real data yet?
`export_template("cohort_summary", "my-report/")` copies the template
plus everything it needs to compile, into your own project, ready to
read, hand-edit, or extend.

## Themes

onepagr ships two built-in themes, selectable by name: `default` (a
brand-neutral palette built on Bootstrap’s own color variables) and `uk`
(University of Kentucky / KIPRC branding).

``` r

render_onepager(data, template = "trend_snapshot", theme = "default", output = "report.pdf")
```

Your own project can supply a completely custom theme instead of a
built-in name:

``` r

render_onepager(data, template = "trend_snapshot", theme_path = "my-theme.typ", output = "report.pdf")
```

A theme is a single Typst dictionary of colors, typography, and spacing
tokens. See any file in `inst/typst/themes/` for the full schema, or
[`list_themes()`](https://andrew-farrey.github.io/onepagr/reference/list_themes.md)
to see what’s built in.

Logos are separate from theming: every template takes a primary logo
(always shown) plus two optional partner logos, toggled independently
via `show_partner_a`/`show_partner_b`, so a single organization, a
two-agency partnership, and a three-organization lockup are all first-
class cases – no template editing required either way. A `font_dir`
argument to
[`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
makes a directory of font files available to Typst for a compile, for a
theme’s font that isn’t installed system-wide. See
[`vignette("theming")`](https://andrew-farrey.github.io/onepagr/articles/theming.md)
for all of the above.

## Accessibility

Every built-in template and theme has been verified with
[PAC](https://pac.pdf-accessibility.org/en) (PDF Accessibility Checker)
against both the PDF/UA and WCAG tabs, not just Typst’s own
`--pdf-standard ua-1` compile-time check. If you write your own theme or
template, re-run that check yourself. A color or layout choice that
passes for one template’s usage isn’t automatically safe for another
(see the package’s own development notes on why large-text-safe colors
aren’t automatically small-text-safe).

## Development

This package was developed with the assistance of AI coding tools
(Claude Code). Every accessibility claim in this README and in the
package’s own comments reflects an actual verification run (a real Typst
`--pdf-standard ua-1` compile, a real PAC check, or a real computed WCAG
contrast ratio), not an assumption, whichever tool did the typing.
AI-assisted development is also part of why onepagr is structured the
way it is:
[`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
never hides the `.typ` source it compiles from, and
[`export_template()`](https://andrew-farrey.github.io/onepagr/reference/export_template.md)
exists specifically so a real, working template is always available to
hand to an AI assistant, or a human collaborator, to extend.

## License

MIT. See `LICENSE.md`.

The package logo (`man/figures/logo.png`) incorporates Microsoft’s
Fluent System Icon `Accessibility Checkmark 20 Regular` (MIT). See
`data-raw/hex-sticker/ICON-LICENSE.md` for full attribution and the
unmodified source SVG.

## Citation

``` r

citation("onepagr")
```
