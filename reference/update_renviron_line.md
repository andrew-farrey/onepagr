# Add or replace a single `KEY="value"` line in a `.Renviron`-style file

Every other line in the file is left untouched: reads the file if it
exists (an empty vector if it doesn't yet), replaces the first existing
line matching `^key\s*=` if there is one (dropping any further
duplicates, which should never legitimately exist but would be ambiguous
for R to parse if they did), or appends a new line if there's no
existing match.

## Usage

``` r
update_renviron_line(key, value, renviron_path)
```

## Arguments

- key:

  Character. Environment variable name.

- value:

  Character. Value to assign (written as a quoted string).

- renviron_path:

  Character. Path to the file to update. Created if it doesn't exist
  yet.

## Value

Invisibly, `renviron_path`.
