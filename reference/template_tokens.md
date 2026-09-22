# List the tokens a template takes

Shows every `{{{token}}}` a template reads: the ones your `data` list
must supply, and the optional ones with the value each falls back to.
Use it to find the name of a heading, label, caption or paragraph you
want to reword, then pass that name in `data` (see
[`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)).

## Usage

``` r
template_tokens(template)
```

## Arguments

- template:

  Character. A built-in template name (see
  [`list_templates()`](https://andrew-farrey.github.io/onepagr/reference/list_templates.md)),
  or the path to a `.typ` file such as one written by
  [`export_template()`](https://andrew-farrey.github.io/onepagr/reference/export_template.md).

## Value

A data frame with one row per token and columns `token`, `required`
(logical) and `default` (`NA` for a required token). Required tokens
come first, then optional ones, each in the order the template uses
them.

## Details

Optional tokens are named by what they set: `heading_*` (section
headings), `label_*` (box and group labels), `banner_label` and
`banner_issued` (alert banners), `stat_*` (captions on numbers), `bar_*`
(bar-chart row labels), `text_*` (paragraphs, bullets and notes),
`alt_*` (chart and map alt text), `strip_label_*` and `footer_label_*`
(the metadata strip and footer labels), and `chips_*` (a short list of
items separated by `|`). Filter on those prefixes with
[`grepl()`](https://rdrr.io/r/base/grep.html).

A default is Typst markup and can itself contain `{{{token}}}`
references, which are filled from your data. A token that only a default
refers to still counts as required.

## Examples

``` r
tokens <- template_tokens("cohort_summary")
head(tokens)
#>               token required default
#> 1     contact_email     TRUE    <NA>
#> 2 logo_primary_path     TRUE    <NA>
#> 3  logo_primary_alt     TRUE    <NA>
#> 4          org_full     TRUE    <NA>
#> 5       contact_url     TRUE    <NA>
#> 6         doc_title     TRUE    <NA>

# Every section heading you can reword, with its current text:
tokens[grepl("^heading_", tokens$token), c("token", "default")]
#>                         token
#> 88             heading_glance
#> 89         heading_background
#> 90          heading_data_adds
#> 91            heading_capture
#> 92           heading_timeline
#> 93       heading_key_findings
#> 94      heading_prior_history
#> 95  heading_intervention_docs
#> 96       heading_completeness
#> 97     heading_richer_records
#> 98             heading_timing
#> 99            heading_lessons
#> 100        heading_disclaimer
#>                                                                                                                                   default
#> 88                                                                        SAMPLE COHORT AT A GLANCE #sym.dash.en {{{strip_period}}} CASES
#> 89                                                                                                                 BACKGROUND & RATIONALE
#> 90                                                                                                                    WHAT THIS DATA ADDS
#> 91                                                                                                            WHO IS CAPTURED BY LINKAGE?
#> 92                                                                                                                IMPLEMENTATION TIMELINE
#> 93                                                                                                                           KEY FINDINGS
#> 94                                                                                             PRIOR ENCOUNTER HISTORY AMONG LINKED CASES
#> 95                                            SAMPLE INTERVENTION DOCUMENTATION IN PRIOR QUALIFYING ENCOUNTERS (N = {{{n_od_ems_denom}}})
#> 96                                                                             STRUCTURED FIELD COMPLETENESS: LINKED VS. UNLINKED RECORDS
#> 97                                                                                              LONGER, RICHER RECORDS AMONG LINKED CASES
#> 98  TIMING FROM LAST PRIOR QUALIFYING ENCOUNTER TO REFERENCE DATE (AMONG CASES WITH A PRIOR QUALIFYING ENCOUNTER, N = {{{timing_denom}}})
#> 99                                                                                                         LESSONS LEARNED & IMPLICATIONS
#> 100                                                                                                                            DISCLAIMER
```
