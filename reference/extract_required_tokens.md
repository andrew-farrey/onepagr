# Extract required whisker tokens from a .typ file

Scans for `{{{token}}}` (triple-brace, unescaped) occurrences: onepagr
templates never use double-brace `{{token}}` (double-brace HTML-escapes
and corrupts any value containing "&", "\<", or "\>"). Section markers
and comments are not matched: onepagr templates use flat triple-brace
substitution only, no Mustache sections or partials.

## Usage

``` r
extract_required_tokens(path)
```

## Arguments

- path:

  Character. Path to a .typ file.

## Value

Character vector of unique token names, in first-appearance order.

## Details

`//` line comments are stripped before scanning: Typst templates
routinely document the triple-brace convention with a literal
`{{{token}}}` example in a header comment (this is a real case, not
hypothetical; the reference trend-snapshot template does exactly this),
and without stripping comments first, that illustrative example is
indistinguishable from a real required token. `//` is unambiguously a
comment marker in Typst (division is a single `/`), so this is safe for
any Typst source: the one caveat is a literal `//` inside a string
constant in the template's own code (not data, which arrives via
tokens), which onepagr's built-in templates never do.

A token with a declared default (see the optional-token marker in
[`compile_typst()`](https://andrew-farrey.github.io/onepagr/reference/compile_typst.md))
is not required, so it is left out of the result. A default can refer to
other tokens (`{{{token}}}`); those are required.

## Examples

``` r
path <- resolve_template("cohort_summary")
extract_required_tokens(path)
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
```
