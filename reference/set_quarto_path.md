# Point onepagr (and Quarto) at a specific Quarto binary

Sets `QUARTO_PATH` for the current R session immediately. With consent,
also persists it to the user-level `~/.Renviron` so future sessions pick
it up automatically – the whole reason this function exists is so a
consuming team never has to learn what `.Renviron` is or hand-edit one:
[`install_quarto()`](https://andrew-farrey.github.io/onepagr/reference/install_quarto.md)
calls this automatically on macOS/Linux once it knows the real installed
binary path, and this can also be called directly to point onepagr at
any other Quarto install (e.g. an admin-managed one on Posit Workbench).

## Usage

``` r
set_quarto_path(path, persist = NA, renviron_path = path.expand("~/.Renviron"))
```

## Arguments

- path:

  Character. Path to a quarto binary. Must already exist.

- persist:

  Logical or `NA`. `NA` (default): if the session is interactive, asks
  before writing to `renviron_path`; if not interactive, does not
  persist. `TRUE`/`FALSE`: persist or don't, with no prompt – for
  scripts and non-interactive use.

- renviron_path:

  Character. Path to the `.Renviron` file to update when persisting.
  Default the current user's `~/.Renviron`. Exposed as an argument
  mainly so this is testable without touching a real `.Renviron`; most
  callers should leave it at the default.

## Value

Invisibly, `path`.

## Details

`.Renviron` is specifically the right place for this, not a
project-local config and not bare
[`options()`](https://rdrr.io/r/base/options.html): it's a machine-local
fact about where Quarto happens to live on THIS system, not a fact about
any one analysis project, so it should follow the user across projects
rather than being redeclared per-project.

Like
[`install_quarto()`](https://andrew-farrey.github.io/onepagr/reference/install_quarto.md),
this is only ever invoked directly by the user or on the user's behalf
immediately after a real install – never called automatically by
[`render_onepager()`](https://andrew-farrey.github.io/onepagr/reference/render_onepager.md)
or any other rendering function.

## Examples

``` r
if (FALSE) { # \dontrun{
# Never run automatically -- points onepagr at a real Quarto binary on
# your system and, with consent, edits ~/.Renviron. Adjust the path to
# a real quarto install before running.
set_quarto_path("/opt/quarto/bin/quarto")
} # }
```
