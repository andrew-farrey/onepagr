#' Check whether Quarto is installed and meets onepagr's minimum version
#'
#' Wraps the `quarto` package's `quarto_available()`/`quarto_version()` to
#' report what's installed. onepagr needs Quarto's Typst backend to
#' support `--pdf-standard ua-1` and `--features a11y-extras` -- this
#' checks against that floor, not just "is Quarto present at all."
#'
#' @param min_version Character. Minimum required Quarto version. Default
#'   `"1.4.549"`.
#' @return Invisibly, a list with `available` (logical), `version`
#'   (`package_version` or `NA`), and `ok` (logical, `TRUE` if available
#'   and meets `min_version`).
#' @export
check_quarto <- function(min_version = "1.4.549") {
  available <- quarto::quarto_available()
  if (!available) {
    message(
      "Quarto was not found on this system. Install it from ",
      "https://quarto.org/docs/get-started/, or run ",
      "onepagr::install_quarto(). On a locked-down environment (e.g. ",
      "Posit Workbench) where the system Quarto is outdated and you can't ",
      "install system-wide, install a user-local copy and point the ",
      "QUARTO_PATH environment variable at its binary instead."
    )
    return(invisible(list(available = FALSE, version = NA, ok = FALSE)))
  }

  version <- quarto::quarto_version()
  ok <- version >= package_version(min_version)
  if (!ok) {
    message(
      "Quarto ", version, " was found, but onepagr needs at least ",
      min_version, " for --pdf-standard ua-1 / --features a11y-extras ",
      "support. Update Quarto from https://quarto.org/docs/get-started/, ",
      "or run onepagr::install_quarto(). On Posit Workbench specifically, ",
      "the system Quarto is often pinned to an old version -- install a ",
      "user-local copy and point QUARTO_PATH at its binary rather than ",
      "waiting on an admin-managed upgrade."
    )
  }
  invisible(list(available = TRUE, version = version, ok = ok))
}

#' Install Quarto to a user-local directory
#'
#' Downloads the official Quarto release for this OS from
#' quarto-dev/quarto-cli's GitHub release distribution and installs it to
#' a user-local directory (via [tools::R_user_dir()], no admin rights
#' required) -- matching the `~/opt/quarto-*` pattern this package's
#' reference implementation used on Posit Workbench, where the system
#' Quarto is pinned to an old version and users can't install
#' system-wide.
#'
#' This function is NEVER called automatically by any other onepagr
#' function -- it must be invoked directly by the user, matching the
#' precedent set by `reticulate::install_miniconda()` and
#' `keras::install_keras()`. It downloads from an official GitHub release
#' URL over HTTPS only.
#'
#' On Windows, this downloads the official `.msi` installer and opens it
#' for the user to complete -- Windows installers are not silently run by
#' this function, to avoid requiring elevated-privilege automation. On
#' macOS and Linux, the release archive is downloaded and extracted
#' directly into the user-local install directory.
#'
#' Before shipping: verify the exact release archive filename pattern
#' used below against quarto-dev/quarto-cli's current GitHub releases page
#' (https://github.com/quarto-dev/quarto-cli/releases) -- release asset
#' naming has changed across Quarto versions historically, so this should
#' be confirmed against a live release rather than assumed to still match.
#'
#' @param version Character. Quarto version to install. Default
#'   `"1.7.32"`.
#' @return Character, the install directory (macOS/Linux) or the
#'   downloaded installer path (Windows), invisibly.
#' @export
install_quarto <- function(version = "1.7.32") {
  sysname <- Sys.info()[["sysname"]]
  install_dir <- tools::R_user_dir("onepagr", which = "data")
  dir.create(install_dir, recursive = TRUE, showWarnings = FALSE)

  base_url <- sprintf(
    "https://github.com/quarto-dev/quarto-cli/releases/download/v%s/",
    version
  )

  if (sysname == "Windows") {
    file_name <- sprintf("quarto-%s-win.msi", version)
    dest <- file.path(install_dir, file_name)
    utils::download.file(paste0(base_url, file_name), dest, mode = "wb")
    message(
      "Downloaded the Quarto ", version, " installer to ", dest,
      ". Opening it now -- complete the installer, then restart R."
    )
    utils::browseURL(dest)
    return(invisible(dest))
  }

  file_name <- if (sysname == "Darwin") {
    sprintf("quarto-%s-macos.tar.gz", version)
  } else {
    sprintf("quarto-%s-linux-amd64.tar.gz", version)
  }
  dest <- file.path(install_dir, file_name)
  utils::download.file(paste0(base_url, file_name), dest, mode = "wb")
  utils::untar(dest, exdir = install_dir)
  unlink(dest)

  bin_path <- file.path(
    install_dir, sprintf("quarto-%s", version), "bin", "quarto"
  )
  message(
    "Quarto ", version, " installed to ", install_dir, ".\n",
    "Point onepagr (and the quarto package) at it by setting:\n",
    "  Sys.setenv(QUARTO_PATH = \"", bin_path, "\")\n",
    "in your session, .Rprofile, or project .Renviron."
  )
  invisible(install_dir)
}
