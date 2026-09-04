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

## Examples

``` r
path <- resolve_template("cohort_summary")
extract_required_tokens(path)
#>  [1] "contact_email"                   "logo_partner_a_path"            
#>  [3] "logo_partner_a_alt"              "show_partner_a"                 
#>  [5] "logo_primary_path"               "logo_primary_alt"               
#>  [7] "logo_partner_b_path"             "logo_partner_b_alt"             
#>  [9] "show_partner_b"                  "org_full"                       
#> [11] "contact_url"                     "doc_title"                      
#> [13] "header_texture_path"             "doc_subtitle"                   
#> [15] "strip_data"                      "strip_period"                   
#> [17] "strip_design"                    "strip_geography"                
#> [19] "n_decedents"                     "n_ems_total"                    
#> [21] "pct_linked"                      "n_prior_ems"                    
#> [23] "n_eligible_decedents"            "n_unlinked_decedents"           
#> [25] "wc_linked_median"                "wc_unlinked_median"             
#> [27] "n_prior_od_ems"                  "pct_linked_male_width"          
#> [29] "n_male"                          "pct_linked_female_width"        
#> [31] "n_female"                        "pct_linked_appalachian_width"   
#> [33] "n_appalachian"                   "pct_linked_nonappalachian_width"
#> [35] "n_nonappalachian"                "pct_linked_white_width"         
#> [37] "n_white"                         "pct_linked_black_width"         
#> [39] "n_black"                         "pct_linked_other_width"         
#> [41] "n_other"                         "pct_any_prior_enc"              
#> [43] "pct_od_prior_enc"                "mean_prior_enc"                 
#> [45] "median_prior_enc"                "n_od_ems_denom"                 
#> [47] "pct_naloxone_width"              "pct_no_naloxone_width"          
#> [49] "pct_naloxone"                    "n_naloxone_enc"                 
#> [51] "pct_no_naloxone"                 "n_no_naloxone_enc"              
#> [53] "pct_decedent_nax"                "domain_diff_scene"              
#> [55] "domain_diff_history"             "domain_diff_drug"               
#> [57] "domain_diff_medication"          "domain_diff_mental"             
#> [59] "timing_denom"                    "median_days"                    
#> [61] "timing_iqr"                      "mean_days"                      
#> [63] "lessons_learned_text"            "disclaimer_text"                
#> [65] "footnote_sources"               
```
