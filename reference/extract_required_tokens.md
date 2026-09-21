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

  Character. Path to a .typ file. A token with a declared default (see
  the optional-token marker in
  [`compile_typst()`](https://andrew-farrey.github.io/onepagr/reference/compile_typst.md))
  is not required, so it is left out of the result.

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
#>  [1] "contact_email"                   "logo_primary_path"              
#>  [3] "logo_primary_alt"                "org_full"                       
#>  [5] "contact_url"                     "doc_title"                      
#>  [7] "doc_subtitle"                    "strip_data"                     
#>  [9] "strip_period"                    "strip_design"                   
#> [11] "strip_geography"                 "n_decedents"                    
#> [13] "n_ems_total"                     "pct_linked"                     
#> [15] "n_prior_ems"                     "n_eligible_decedents"           
#> [17] "n_unlinked_decedents"            "wc_linked_median"               
#> [19] "wc_unlinked_median"              "n_prior_od_ems"                 
#> [21] "pct_linked_male_width"           "n_male"                         
#> [23] "pct_linked_female_width"         "n_female"                       
#> [25] "pct_linked_appalachian_width"    "n_appalachian"                  
#> [27] "pct_linked_nonappalachian_width" "n_nonappalachian"               
#> [29] "pct_linked_white_width"          "n_white"                        
#> [31] "pct_linked_black_width"          "n_black"                        
#> [33] "pct_linked_other_width"          "n_other"                        
#> [35] "pct_any_prior_enc"               "pct_od_prior_enc"               
#> [37] "mean_prior_enc"                  "median_prior_enc"               
#> [39] "n_od_ems_denom"                  "pct_naloxone_width"             
#> [41] "pct_no_naloxone_width"           "pct_naloxone"                   
#> [43] "n_naloxone_enc"                  "pct_no_naloxone"                
#> [45] "n_no_naloxone_enc"               "pct_decedent_nax"               
#> [47] "domain_diff_scene"               "domain_diff_history"            
#> [49] "domain_diff_drug"                "domain_diff_medication"         
#> [51] "domain_diff_mental"              "timing_denom"                   
#> [53] "median_days"                     "timing_iqr"                     
#> [55] "mean_days"                       "lessons_learned_text"           
#> [57] "disclaimer_text"                 "footnote_sources"               
```
