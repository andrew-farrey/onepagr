# Extract required whisker tokens from a .typ file

Scans for `{{{token}}}` (triple-brace, unescaped) occurrences – onepagr
templates never use double-brace `{{token}}` (double-brace HTML-escapes
and corrupts any value containing "&", "\<", or "\>"). Section markers
and comments are not matched – onepagr templates use flat triple-brace
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
hypothetical – the reference trend-snapshot template does exactly this),
and without stripping comments first, that illustrative example is
indistinguishable from a real required token. `//` is unambiguously a
comment marker in Typst (division is a single `/`), so this is safe for
any Typst source – the one caveat is a literal `//` inside a string
constant in the template's own code (not data, which arrives via
tokens), which onepagr's built-in templates never do.
