# Validate whisker data against a template's required tokens

Raises a clear error listing every missing or NA token before whisker or
Typst ever run, instead of letting a missing token silently render as
blank text.

## Usage

``` r
validate_template_data(path, data)
```

## Arguments

- path:

  Character. Path to a .typ file.

- data:

  Named list of whisker substitution values.

## Value

Invisibly `TRUE` if validation passes.

## Examples

``` r
path <- resolve_template("cohort_summary")
required <- extract_required_tokens(path)
# Placeholder values -- validate_template_data() only checks presence/
# non-NA, not real content, so this always passes regardless of which
# tokens a given template actually needs.
data <- setNames(as.list(rep("placeholder", length(required))), required)
validate_template_data(path, data)
```
