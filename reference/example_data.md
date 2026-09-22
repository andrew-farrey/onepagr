# Example data for a built-in template

Every built-in template's
[`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
`data` argument needs a long list of values. This returns a complete,
working example – the same one this package's own tests render – so you
can see a real value for every token before writing your own, or render
immediately to see what the template produces.

## Usage

``` r
example_data(template)
```

## Arguments

- template:

  Character. A built-in template name (see
  [`list_templates()`](https://andrew-farrey.github.io/onepagr/reference/list_templates.md)).

## Value

Named list, the example data for `template`. `trend_snapshot` shares
`cohort_summary`'s example data: both were designed around the same
underlying example numbers (see either template's `template.typ` header
comment for why).

## Details

[`template_data()`](https://andrew-farrey.github.io/onepagr/reference/template_data.md)
builds on this: it returns only the tokens you'd actually pass to
[`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md),
matching
[`template_tokens()`](https://andrew-farrey.github.io/onepagr/reference/template_tokens.md)'s
required/optional split, and is what you want for a starting point. Use
this function directly when you want the full, untouched example, e.g.
to see the exact value used for a token you're not sure how to format.

## Examples

``` r
str(example_data("overdose_spike_alert"))
#> List of 28
#>  $ doc_title          : chr "SAMPLE OVERDOSE SPIKE ALERT"
#>  $ doc_subtitle       : chr "Sample Region Overdose Surveillance . Primary Sample Organization"
#>  $ org_full           : chr "Primary Sample Organization"
#>  $ contact_url        : chr "https://example.org/"
#>  $ contact_email      : chr "contact@example.org"
#>  $ logo_partner_a_path: chr "assets/partner-org-a-white.png"
#>  $ logo_partner_a_alt : chr "Partner Organization A logo"
#>  $ show_partner_a     : chr "true"
#>  $ logo_primary_path  : chr "assets/primary-org-white.png"
#>  $ logo_primary_alt   : chr "Primary Organization logo"
#>  $ logo_partner_b_path: chr "assets/partner-org-b-white.png"
#>  $ logo_partner_b_alt : chr "Partner Organization B logo"
#>  $ show_partner_b     : chr "true"
#>  $ header_texture_path: chr "assets/header-texture.png"
#>  $ severity_level     : chr "critical"
#>  $ alert_area         : chr "Sample County"
#>  $ alert_issued_at    : chr "August 16, 2026, 9:00 AM"
#>  $ n_events           : chr "14"
#>  $ window_days        : chr "3"
#>  $ n_spikes           : chr "2"
#>  $ spike_window_days  : chr "30"
#>  $ threshold          : chr "8"
#>  $ narrative_text     : chr "Sample County has recorded 14 suspected overdoses in the past 3 days, exceeding the county's spike threshold of"| __truncated__
#>  $ geo_breakdown_text : chr "- Northside: 6 events\n- Downtown: 5 events\n- Eastside: 3 events"
#>  $ actions_text       : chr "- Increase naloxone distribution in the affected area\n- Alert local emergency departments and EMS to the ongoi"| __truncated__
#>  $ show_resources     : chr "true"
#>  $ resources_text     : chr "Sample County Health Department, 123 Main Street, (555) 123-4567. #link(\"https://example.org/naloxone\")[Nalox"| __truncated__
#>  $ footnote_sources   : chr "Sample Overdose Detection Mapping System"
```
