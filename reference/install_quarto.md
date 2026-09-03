# Install Quarto to a user-local directory

Downloads the official Quarto release for this OS from
quarto-dev/quarto-cli's GitHub release distribution and installs it to a
user-local directory (via
[`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html), no admin
rights required) – matching the `~/opt/quarto-*` pattern this package's
reference implementation used on Posit Workbench, where the system
Quarto is pinned to an old version and users can't install system-wide.

## Usage

``` r
install_quarto(version = "1.10.18")
```

## Arguments

- version:

  Character. Quarto version to install. Default `"1.10.18"`.

## Value

Character, the install directory (macOS/Linux) or the downloaded
installer path (Windows), invisibly.

## Details

This function is NEVER called automatically by any other onepagr
function – it must be invoked directly by the user, matching the
precedent set by `reticulate::install_miniconda()` and
`keras::install_keras()`. It downloads from an official GitHub release
URL over HTTPS only.

On Windows, this downloads the official `.msi` installer and opens it
for the user to complete – Windows installers are not silently run by
this function, to avoid requiring elevated-privilege automation. On
macOS and Linux, the release archive is downloaded and extracted
directly into the user-local install directory.

Before shipping: verify the exact release archive filename pattern used
below against quarto-dev/quarto-cli's current GitHub releases page
(https://github.com/quarto-dev/quarto-cli/releases) – release asset
naming has changed across Quarto versions historically, so this should
be confirmed against a live release rather than assumed to still match.

The default `version` below must bundle a Typst new enough for
[`check_quarto()`](https://andrew-farrey.github.io/onepagr/reference/check_quarto.md)'s
own minimum (see that function's docs for why Quarto's version number
alone isn't a safe indicator of this). `"1.10.18"` is used here
specifically because it's confirmed directly (not assumed) to bundle
Typst 0.15.1, the version this package's templates were actually
developed and tested against – re-verify this default against a live
install (`quarto typst --version`) before bumping it, rather than
assuming a newer Quarto version number implies a newer bundled Typst.

## Examples

``` r
if (FALSE) { # \dontrun{
# Never run automatically -- downloads ~100+ MB and (on Windows) opens
# an installer. Only ever run this yourself, deliberately.
install_quarto()
} # }
```
