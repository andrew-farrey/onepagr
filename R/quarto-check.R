#' Extract the Typst version Quarto's own `typst` subcommand reports
#'
#' `quarto typst --version` prints a line like `typst 0.15.1 (9dfd3a08)`.
#'
#' @param quarto_bin Character. Path to the quarto binary.
#' @return `package_version`, or `NA` if the version couldn't be parsed.
#' @keywords internal
typst_version_via_quarto <- function(quarto_bin) {
  out <- tryCatch(
    system2(quarto_bin, c("typst", "--version"), stdout = TRUE, stderr = TRUE),
    error = function(e) character(0), warning = function(w) character(0)
  )
  match <- regmatches(out, regexpr("[0-9]+\\.[0-9]+\\.[0-9]+", out))
  if (length(match) == 0) NA else package_version(match[[1]])
}

#' Check whether Quarto is installed and its bundled Typst is new enough
#'
#' Wraps the `quarto` package's `quarto_available()` to check Quarto is
#' present, then checks the **Typst version Quarto actually bundles** --
#' not Quarto's own version number, which is NOT a reliable proxy for
#' this: confirmed directly (via web research plus this package's own
#' pinned dev environment) that Quarto sat on Typst 0.11.x across
#' multiple Quarto 1.4-1.7.x releases before eventually bundling a newer
#' one, so a Quarto-version floor can pass while the bundled Typst is
#' still too old for `--pdf-standard ua-1` (added in Typst 0.14.0) or
#' `--features a11y-extras` (this package is built and tested against
#' Typst 0.15.1 specifically, bundled by Quarto 1.10.18 -- confirmed
#' directly by running `quarto typst --version` in the dev environment
#' every template in this package was verified against).
#'
#' @param min_typst_version Character. Minimum required Typst version
#'   (the version Quarto's own bundled `typst` binary reports, not
#'   Quarto's own version). Default `"0.15.1"`, matching this package's
#'   own tested baseline.
#' @return Invisibly, a list with `available` (logical), `quarto_version`
#'   (`package_version` or `NA`), `typst_version` (`package_version` or
#'   `NA`), and `ok` (logical, `TRUE` if available and the bundled Typst
#'   meets `min_typst_version`).
#' @export
check_quarto <- function(min_typst_version = "0.15.1") {
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
    return(invisible(list(
      available = FALSE, quarto_version = NA, typst_version = NA, ok = FALSE
    )))
  }

  quarto_bin <- quarto::quarto_path()
  quarto_ver <- quarto::quarto_version()
  typst_ver <- typst_version_via_quarto(quarto_bin)

  ok <- !is.na(typst_ver) && typst_ver >= package_version(min_typst_version)
  if (!ok) {
    message(
      "Quarto ", quarto_ver, " was found, bundling Typst ",
      if (is.na(typst_ver)) "(version could not be determined)" else typst_ver,
      ", but onepagr needs at least Typst ", min_typst_version,
      " for --pdf-standard ua-1 / --features a11y-extras support. ",
      "Quarto's own version number is NOT a reliable indicator of this --",
      " some Quarto releases went several versions without updating their",
      " bundled Typst. Update Quarto from ",
      "https://quarto.org/docs/get-started/, or run ",
      "onepagr::install_quarto(). On Posit Workbench specifically, the ",
      "system Quarto is often pinned to an old version -- install a ",
      "user-local copy and point QUARTO_PATH at its binary rather than ",
      "waiting on an admin-managed upgrade. After installing, re-run ",
      "onepagr::check_quarto() to confirm the bundled Typst is new enough."
    )
  }
  invisible(list(
    available = TRUE, quarto_version = quarto_ver, typst_version = typst_ver,
    ok = ok
  ))
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
#' The default `version` below must bundle a Typst new enough for
#' [check_quarto()]'s own minimum (see that function's docs for why
#' Quarto's version number alone isn't a safe indicator of this).
#' `"1.10.18"` is used here specifically because it's confirmed directly
#' (not assumed) to bundle Typst 0.15.1, the version this package's
#' templates were actually developed and tested against -- re-verify
#' this default against a live install (`quarto typst --version`) before
#' bumping it, rather than assuming a newer Quarto version number implies
#' a newer bundled Typst.
#'
#' @param version Character. Quarto version to install. Default
#'   `"1.10.18"`.
#' @return Character, the install directory (macOS/Linux) or the
#'   downloaded installer path (Windows), invisibly.
#' @export
install_quarto <- function(version = "1.10.18") {
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
