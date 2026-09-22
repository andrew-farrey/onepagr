# Build a starter data list for a template

Returns a named list ready to pass to
[`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
as `data`: every token
[`template_tokens()`](https://andrew-farrey.github.io/onepagr/reference/template_tokens.md)
lists for `template`, each already set to a real value, not a blank you
have to guess the shape of – an optional token's own shipped default, or
(for a required token, which has no default) the matching value from
that template's
[`example_data()`](https://andrew-farrey.github.io/onepagr/reference/example_data.md).
Starting from this instead of an empty list means every value you
haven't changed yet is already correctly formatted (a percentage as
`"84%"`, a color as a real theme value, and so on), which is the actual
point: reading
[`template_tokens()`](https://andrew-farrey.github.io/onepagr/reference/template_tokens.md)'s
token names alone tells you what to set, not what a working value for it
looks like.

## Usage

``` r
template_data(template, tokens = c("both", "required", "optional"))
```

## Arguments

- template:

  Character. A built-in template name (see
  [`list_templates()`](https://andrew-farrey.github.io/onepagr/reference/list_templates.md)).
  Unlike
  [`template_tokens()`](https://andrew-farrey.github.io/onepagr/reference/template_tokens.md),
  this does not take a path to a hand-edited
  [`export_template()`](https://andrew-farrey.github.io/onepagr/reference/export_template.md)
  copy, since there is no known example value for a token that copy
  might add.

- tokens:

  Character. Which tokens to include: `"both"` (default, everything
  [`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
  would read), `"required"` (only the values you must actually supply),
  or `"optional"` (only the reworded-text and type/spacing tokens, each
  left at its default).

## Value

Named list of character values, with a `"required"` attribute naming the
entries that came from a required token.

## Details

Which entries came from a required token, as opposed to an optional one,
is recorded in the result's `"required"` attribute
(`attr(x, "required")`) rather than in the list itself, so the result
stays a plain data list: pass it straight to
[`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md),
overwrite fields directly, or merge your own values in with
[`utils::modifyList()`](https://rdrr.io/r/utils/modifyList.html).

## Examples

``` r
data <- template_data("cohort_summary")
attr(data, "required")
#>  [1] "contact_email"                   "logo_primary_path"              
#>  [3] "logo_primary_alt"                "org_full"                       
#>  [5] "contact_url"                     "doc_title"                      
#>  [7] "doc_subtitle"                    "strip_data"                     
#>  [9] "strip_period"                    "strip_design"                   
#> [11] "strip_geography"                 "n_decedents"                    
#> [13] "n_ems_total"                     "pct_linked"                     
#> [15] "n_prior_ems"                     "n_prior_od_ems"                 
#> [17] "pct_linked_male_width"           "n_male"                         
#> [19] "pct_linked_female_width"         "n_female"                       
#> [21] "pct_linked_appalachian_width"    "n_appalachian"                  
#> [23] "pct_linked_nonappalachian_width" "n_nonappalachian"               
#> [25] "pct_linked_white_width"          "n_white"                        
#> [27] "pct_linked_black_width"          "n_black"                        
#> [29] "pct_linked_other_width"          "n_other"                        
#> [31] "pct_linked_age_lt25_width"       "n_age_lt25"                     
#> [33] "pct_linked_age_25_34_width"      "n_age_25_34"                    
#> [35] "pct_linked_age_35_44_width"      "n_age_35_44"                    
#> [37] "pct_linked_age_45_54_width"      "n_age_45_54"                    
#> [39] "pct_linked_age_55_64_width"      "n_age_55_64"                    
#> [41] "pct_linked_age_65plus_width"     "n_age_65plus"                   
#> [43] "tl1_yr"                          "tl1_label"                      
#> [45] "tl2_yr"                          "tl2_label"                      
#> [47] "tl3_yr"                          "tl3_label"                      
#> [49] "pct_any_prior_enc"               "pct_od_prior_enc"               
#> [51] "pct_naloxone_width"              "pct_no_naloxone_width"          
#> [53] "pct_naloxone"                    "n_naloxone_enc"                 
#> [55] "pct_no_naloxone"                 "n_no_naloxone_enc"              
#> [57] "domain_diff_scene"               "domain_diff_history"            
#> [59] "domain_diff_drug"                "domain_diff_medication"         
#> [61] "domain_diff_mental"              "median_days"                    
#> [63] "mean_days"                       "pct_30d_width"                  
#> [65] "n_30d"                           "pct_90d_width"                  
#> [67] "n_90d"                           "pct_365d_width"                 
#> [69] "n_365d"                          "pct_gt365d_width"               
#> [71] "n_gt365d"                        "lessons_learned_text"           
#> [73] "disclaimer_text"                 "footnote_sources"               
#> [75] "n_od_ems_denom"                  "timing_denom"                   
#> [77] "n_eligible_decedents"            "n_unlinked_decedents"           
#> [79] "wc_linked_median"                "wc_unlinked_median"             
#> [81] "mean_prior_enc"                  "median_prior_enc"               
#> [83] "pct_decedent_nax"                "timing_iqr"                     

# Change just the numbers you have; every heading and label keeps its
# default wording.
data$n_decedents <- "6,000"
if (FALSE) { # \dontrun{
render_onepager(data, "cohort_summary", output = "report.pdf")
} # }
```
