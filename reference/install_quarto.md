# Install Quarto to a user-local directory

Downloads the official Quarto release for this OS from
quarto-dev/quarto-cli's GitHub release distribution and installs it to a
user-local directory (via
[`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html), no admin
rights required), matching the `~/opt/quarto-*` pattern this package's
reference implementation used on Posit Workbench, where the system
Quarto is pinned to an old version and users can't install system-wide.

## Usage

``` r
install_quarto(version = "latest", dir = NULL, force = FALSE)
```

## Arguments

- version:

  Character. Quarto version to install, such as `"1.10.18"`, or
  `"latest"` (the default) for the newest stable release. Looking up the
  newest release needs an internet connection; if that fails, the
  message says so, and you can name a version yourself instead.

- dir:

  Character or `NULL`. The folder to install into, created if it does
  not exist. `NULL` (the default) uses the folder onepagr manages under
  [`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html). On
  Windows this is where the installer is saved; the installer itself
  asks where to put Quarto.

- force:

  Logical. `FALSE` (the default) stops when the Quarto onepagr would use
  is already as new as `version`. `TRUE` installs anyway.

## Value

Character, the install directory (macOS/Linux) or the downloaded
installer path (Windows), invisibly; `NULL`, invisibly, if you decline
the download or the Quarto you have is already new enough.

## Details

This function is NEVER called automatically by any other onepagr
function; it must be invoked directly by the user, matching the
precedent set by `reticulate::install_miniconda()` and
`keras::install_keras()`. It downloads from an official GitHub release
URL over HTTPS only.

On Windows, this downloads the official `.msi` installer and opens it
for the user to complete; Windows installers are not silently run by
this function, to avoid requiring elevated-privilege automation. On
macOS and Linux, the release archive is downloaded and extracted
directly into the user-local install directory.

On Linux the build for the machine's architecture is downloaded (`amd64`
or `arm64`). The archive is extracted into `quarto-<version>/` under the
install directory and the `bin/quarto` binary is located inside it, so
the different archive layouts per platform do not matter.

By default the newest stable Quarto release is installed. It is looked
up from the release list at
`https://api.github.com/repos/quarto-dev/quarto-cli/releases/latest`,
which leaves out releases still in testing. Quarto 1.10.18 is the first
release that bundles Typst 0.15.1, the version onepagr is built and
tested against, and a newer Quarto release does not bundle an older
Typst, so the newest stable release always meets
[`check_quarto()`](https://andrew-farrey.github.io/onepagr/reference/check_quarto.md)'s
minimum. An older `version` than 1.10.18 is still installed if you ask
for it, with a warning.

By default the install goes into a folder onepagr manages for you
([`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html)). Pass
`dir` to install somewhere else, such as a shared `/opt` folder: the
release is unpacked into `quarto-<version>/` inside it, next to any
other copies, and you need write permission there (if you do not have
it, the function stops before downloading and says so). A folder you
chose is never cleaned up: older `quarto-<version>` copies in it are
listed and left alone, because they may belong to someone else.

Before it downloads anything, the function looks at the Quarto onepagr
would use now (the `QUARTO_PATH` environment variable, set in the
session or in `~/.Renviron`, or else the `PATH`). If that Quarto is
already as new as the version you asked for, nothing is installed and
the message says where it is; set `force = TRUE` to install anyway, for
example to put a copy in `dir`. If the requested version is already
unpacked in the install folder, it is reused instead of downloaded
again.

In an interactive session it asks before the download, which is large
(roughly 100 to 250 MB depending on the system); answering no installs
nothing. After a successful install into the default folder it removes
the older copies it put there before (the `quarto-<version>` folders,
and any older installer or archive left there), so the folder does not
grow with every version. It never removes a copy that `QUARTO_PATH`
points into, in this session or in `~/.Renviron`, and it never touches a
file or folder whose name does not match what it creates.

## Examples

``` r
if (FALSE) { # \dontrun{
# Never run automatically: downloads ~100+ MB and (on Windows) opens
# an installer. Only ever run this yourself, deliberately.
install_quarto()

# A specific release, instead of the newest:
install_quarto(version = "1.10.18")

# Into a shared folder you can write to, even if another Quarto is
# already on the machine:
install_quarto(dir = "/opt", force = TRUE)
} # }
```
