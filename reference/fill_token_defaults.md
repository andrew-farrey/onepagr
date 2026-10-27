# Fill a template's omitted optional tokens with their defaults

Internal. For every optional token that `data` lacks (or holds as
`NULL`, empty, or `NA`), sets the declared default. A default is
rendered against `data` first, so it can refer to other tokens: a
section heading's default can carry a sample size, as in
`Results (N = {{{n_total}}})`. A default may refer to another omitted
default, declared above or below it; they are filled in dependency
order, and defaults that refer to each other in a loop are an error. A
value the caller supplies is used as given, except that a `{{{token}}}`
in it is filled from `data` (followed through any further references).

## Usage

``` r
fill_token_defaults(path, data)
```

## Arguments

- path:

  Character. Path to a .typ file.

- data:

  Named list of whisker substitution values.

## Value

`data` with the omitted optional tokens filled in.
