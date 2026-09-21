# Read a template's optional-token defaults

Internal. A template declares a token as optional with a `//` comment
line of the form `// optional-token: name = default`. Callers who don't
supply `name` get `default` (as a string) instead of a missing-token
error. The default may be empty (`// optional-token: name =`), for a
token that should be present but blank unless the caller sets it.

## Usage

``` r
extract_token_defaults(path)
```

## Arguments

- path:

  Character. Path to a .typ file.

## Value

Named list of default values (empty if none are declared).
