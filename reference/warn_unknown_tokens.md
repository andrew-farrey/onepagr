# Warn about data names no template uses

Internal. A name in `data` that is not a token of this template, or of
any built-in template, is ignored by the render, which is easy to miss
when it is a misspelled optional token (`heading_glnce`). A name that
belongs to another built-in template stays silent, so one data list can
be shared across templates. When a name is close to one of this
template's own tokens, the warning suggests it.

## Usage

``` r
warn_unknown_tokens(path, data)
```

## Arguments

- path:

  Character. Path to a .typ file.

- data:

  Named list of whisker substitution values.

## Value

Invisibly, the ignored names.
