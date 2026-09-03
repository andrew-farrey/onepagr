# Check whether the installed Typst supports the `eval` subcommand

[`check_theme()`](https://andrew-farrey.github.io/onepagr/reference/check_theme.md)
depends entirely on `typst eval` (via
[`introspect_theme_typ()`](https://andrew-farrey.github.io/onepagr/reference/introspect_theme_typ.md)),
which cannot be assumed present just because Typst itself is – confirmed
directly on a real R-devel win-builder CRAN check, where `typst eval`
errored with `unrecognized subcommand 'eval'` even though Quarto/Typst
were otherwise available and every `typst compile`-based test ran fine
there. Probes the real capability (`typst eval "1"`, about as minimal a
Typst expression as exists) rather than checking a specific
version-number floor, since the exact Typst version `eval` was
introduced in isn't independently confirmed here – verifying the real
behavior directly is more honest than assuming a version cutoff.

## Usage

``` r
typst_eval_supported(quarto_bin)
```

## Arguments

- quarto_bin:

  Character. Path to the quarto binary.

## Value

Logical.
