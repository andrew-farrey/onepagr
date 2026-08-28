# Getting started with onepagr

onepagr turns a named list of values into a finished, accessible PDF
report using one of its built-in Typst templates. This vignette walks
through rendering your first report, picking a theme, and moving on to
customizing a template.

## Before you start

onepagr needs [Quarto](https://quarto.org) (which bundles Typst) on your
system. Check whether it’s available:

``` r

onepagr::check_quarto()
```

If that reports a problem, install a user-local copy yourself with
[`onepagr::install_quarto()`](https://andrew-farrey.github.io/onepagr/reference/install_quarto.md)
(onepagr never installs anything automatically) or install Quarto
normally from quarto.org, then restart your R session.

## Render your first report

Every template needs a named list of values, and which values depend on
the template. `cohort_summary` (contrasting two groups at a point in
time) needs the fewest, so it’s a good first example.

``` r

library(onepagr)

data <- list(
  doc_title = "SAMPLE COHORT SUMMARY",
  doc_subtitle = "Sample Program . Sample Region",
  org_full = "Sample Health Organization",
  contact_url = "https://example.org/",
  contact_email = "contact@example.org",
  # Logo tokens are required by every template -- these values point at
  # onepagr's own bundled placeholder assets. See vignette("theming") to
  # swap in your own branding instead.
  logo_partner_a_path = "assets/partner-org-a-white.png",
  logo_partner_a_alt = "Partner Organization A logo",
  show_partner_a = "true",
  logo_primary_path = "assets/primary-org-white.png",
  logo_primary_alt = "Primary Organization logo",
  logo_partner_b_path = "assets/partner-org-b-white.png",
  logo_partner_b_alt = "Partner Organization B logo",
  show_partner_b = "true",
  header_texture_path = "assets/header-texture.png",
  strip_data = "Sample System",
  strip_period = "2024",
  strip_design = "Retrospective Cohort",
  strip_geography = "Sample Region",
  n_decedents = "5,267", n_ems_total = "24,906", pct_linked = "84%",
  n_prior_ems = "21,021", n_eligible_decedents = "6,260",
  n_unlinked_decedents = "993", n_coroner_counties = "120",
  pct_linked_male_width = "64.6", n_male = "3,400",
  pct_linked_female_width = "35.4", n_female = "1,867",
  pct_linked_appalachian_width = "31.2", n_appalachian = "1,643",
  pct_linked_nonappalachian_width = "68.8", n_nonappalachian = "3,624",
  pct_linked_age_lt25_width = "8", n_age_lt25 = "421",
  pct_linked_age_25_34_width = "22", n_age_25_34 = "1,159",
  pct_linked_age_35_44_width = "27", n_age_35_44 = "1,422",
  pct_linked_age_45_54_width = "24", n_age_45_54 = "1,264",
  pct_linked_age_55_64_width = "14", n_age_55_64 = "737",
  pct_linked_age_65plus_width = "5", n_age_65plus = "264",
  pct_linked_white_width = "86", n_white = "4,527",
  pct_linked_black_width = "10.7", n_black = "574",
  pct_linked_other_width = "1.3", n_other = "66",
  wc_linked_median = "188", wc_unlinked_median = "121",
  domain_diff_scene = "6.8", domain_diff_history = "5.8",
  domain_diff_drug = "2.4", domain_diff_medication = "1.2",
  domain_diff_mental = "0.8", n_prior_od_ems = "5,189",
  tl1_yr = "2019", tl1_label = "Pilot phase",
  tl2_yr = "2020-2022", tl2_label = "Infrastructure build-out",
  tl3_yr = "2023-Present", tl3_label = "Operational",
  pct_any_prior_enc = "76.9%", pct_od_prior_enc = "38.1%",
  mean_prior_enc = "4", median_prior_enc = "2",
  n_od_ems_denom = "5,189", pct_naloxone_width = "70.2",
  pct_naloxone = "70.2%", pct_no_naloxone_width = "29.8",
  pct_no_naloxone = "29.8%", n_naloxone_enc = "3,643",
  n_no_naloxone_enc = "1,546", pct_decedent_nax = "30.8%",
  timing_denom = "2,009", median_days = "330", timing_iqr = "53-941",
  mean_days = "575.1", pct_30d_width = "20.8", n_30d = "417",
  pct_90d_width = "29.8", n_90d = "598", pct_365d_width = "52.8",
  n_365d = "1,061", pct_gt365d_width = "47.2", n_gt365d = "948",
  lessons_learned_text = "Sample lessons-learned narrative text.",
  disclaimer_text = "Sample disclaimer text for illustration only.",
  footnote_sources = "Sample Data Source"
)

out <- tempfile(fileext = ".pdf")
render_onepager(
  data, template = "cohort_summary", theme = "default", output = out
)
file.exists(out)
#> [1] TRUE
```

That’s the whole workflow: a named list in, a finished PDF out. A real
project won’t hand-type every value like this vignette does for
demonstration. You’d typically build this list from your analysis output
using ordinary R ([`sprintf()`](https://rdrr.io/r/base/sprintf.html),
[`scales::comma()`](https://scales.r-lib.org/reference/comma.html),
[`paste()`](https://rdrr.io/r/base/paste.html)), the same way you’d
assemble any other report’s numbers.

## What you just got

By default,
[`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
leaves the resolved `.typ` source (and everything it needs to recompile:
the theme, shared components, and assets) next to your output PDF, in a
folder named after it, here something like `<tempfile>_typst/`. That’s
deliberate: the actual Typst source is never hidden, even if you never
open it. If you want only the PDF and nothing else, pass
`keep_typst = FALSE`.

## Picking a theme

onepagr ships two built-in themes, selectable by name:

``` r

render_onepager(data, template = "cohort_summary", theme = "default", output = "report.pdf")
render_onepager(data, template = "cohort_summary", theme = "uk", output = "report.pdf")
```

List what’s available:

``` r

onepagr::list_themes()
#> [1] "default" "uk"
```

Your own project can supply a fully custom theme instead. See
[`?resolve_theme`](https://andrew-farrey.github.io/onepagr/reference/resolve_theme.md)
for how `theme_path` works, and any file under
`system.file("typst/themes", package = "onepagr")` for the token schema
a custom theme needs to define.

## Exploring or customizing a template

To see a template’s real Typst source, or hand-edit one, export it into
your own project rather than reading it out of the installed package:

``` r

export_template("cohort_summary", "my-report/", theme = "uk")
```

That copies the template, the resolved theme, shared components, and
assets into `my-report/` as one self-contained, independently compilable
unit. Once exported, it’s yours: onepagr never touches it again. Compile
your edited copy directly with
[`compile_typst()`](https://andrew-farrey.github.io/onepagr/reference/compile_typst.md).

## What’s required for each template

Every template validates its input before compiling: if a required value
is missing,
[`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
raises a clear R error listing exactly which ones, rather than silently
producing a PDF with a blank spot. You can check what a template needs
ahead of time:

``` r

onepagr::list_templates()
#> [1] "cohort_summary"       "county_choropleth"    "overdose_spike_alert"
#> [4] "syndromic_alert"      "trend_snapshot"
```

``` r

# Path to a built-in template's source, if you want to read its {{{token}}} usage directly
onepagr::resolve_template("overdose_spike_alert")
```

## Learn more

- [`?render_onepager`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md),
  [`?export_template`](https://andrew-farrey.github.io/onepagr/reference/export_template.md),
  [`?compile_typst`](https://andrew-farrey.github.io/onepagr/reference/compile_typst.md)
  for the full function reference.
- [`?check_quarto`](https://andrew-farrey.github.io/onepagr/reference/check_quarto.md),
  [`?install_quarto`](https://andrew-farrey.github.io/onepagr/reference/install_quarto.md)
  for the Quarto/Typst toolchain helpers.
- The package README for the full list of built-in templates and their
  informational shapes.
