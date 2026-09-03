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

#' Check whether the installed Typst supports the `eval` subcommand
#'
#' [check_theme()] depends entirely on `typst eval` (via
#' `introspect_theme_typ()`), which cannot be assumed present just because
#' Typst itself is -- confirmed directly on a real R-devel win-builder
#' CRAN check, where `typst eval` errored with `unrecognized subcommand
#' 'eval'` even though Quarto/Typst were otherwise available and every
#' `typst compile`-based test ran fine there. Probes the real capability
#' (`typst eval "1"`, about as minimal a Typst expression as exists)
#' rather than checking a specific version-number floor, since the exact
#' Typst version `eval` was introduced in isn't independently confirmed
#' here -- verifying the real behavior directly is more honest than
#' assuming a version cutoff.
#'
#' @param quarto_bin Character. Path to the quarto binary.
#' @return Logical.
#' @keywords internal
typst_eval_supported <- function(quarto_bin) {
  out <- suppressWarnings(system2(
    quarto_bin, c("typst", "eval", shQuote("1")),
    stdout = TRUE, stderr = TRUE
  ))
  status <- attr(out, "status")
  is.null(status) || status == 0
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
#' @examples
#' # Safe to call whether or not Quarto is installed -- reports back
#' # either way rather than erroring.
#' check_quarto()
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

#' Download a URL with a generous timeout and a clear failure message
#'
#' Internal. `download.file()` alone uses the session's current
#' `options("timeout")` (60 seconds by default) -- too short for a Quarto
#' release archive (100+ MB) on anything but a fast connection. Raises it
#' for the duration of this one call only, always restored afterward
#' (even on error), and converts any download failure (no connection, DNS
#' failure, a 404 from a bad `version`) into one clear, onepagr-specific
#' message instead of `download.file()`'s own low-level error.
#'
#' @param url Character. URL to download.
#' @param dest Character. Destination file path.
#' @param min_timeout Numeric. Minimum timeout, in seconds, for this
#'   download if the session's current `options("timeout")` is smaller.
#'   Default `600` (10 minutes) -- generous for a large release archive on
#'   a slow connection.
#' @return Invisibly, `dest`.
#' @keywords internal
download_with_timeout <- function(url, dest, min_timeout = 600) {
  old_timeout <- getOption("timeout")
  on.exit(options(timeout = old_timeout), add = TRUE)
  options(timeout = max(old_timeout, min_timeout))

  tryCatch(
    utils::download.file(url, dest, mode = "wb"),
    error = function(e) {
      stop(
        "Failed to download ", url, ": ", conditionMessage(e),
        ". Check your internet connection, or install Quarto manually ",
        "from https://quarto.org/docs/get-started/.",
        call. = FALSE
      )
    }
  )
  invisible(dest)
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
#' @examples
#' \dontrun{
#' # Never run automatically -- downloads ~100+ MB and (on Windows) opens
#' # an installer. Only ever run this yourself, deliberately.
#' install_quarto()
#' }
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
    download_with_timeout(paste0(base_url, file_name), dest)
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
  download_with_timeout(paste0(base_url, file_name), dest)
  utils::untar(dest, exdir = install_dir)
  unlink(dest)

  bin_path <- file.path(
    install_dir, sprintf("quarto-%s", version), "bin", "quarto"
  )
  message("Quarto ", version, " installed to ", install_dir, ".")
  set_quarto_path(bin_path)
  invisible(install_dir)
}

#' Point onepagr (and Quarto) at a specific Quarto binary
#'
#' Sets `QUARTO_PATH` for the current R session immediately. With consent,
#' also persists it to the user-level `~/.Renviron` so future sessions pick
#' it up automatically -- the whole reason this function exists is so a
#' consuming team never has to learn what `.Renviron` is or hand-edit one:
#' [install_quarto()] calls this automatically on macOS/Linux once it knows
#' the real installed binary path, and this can also be called directly to
#' point onepagr at any other Quarto install (e.g. an admin-managed one on
#' Posit Workbench).
#'
#' `.Renviron` is specifically the right place for this, not a
#' project-local config and not bare `options()`: it's a machine-local fact
#' about where Quarto happens to live on THIS system, not a fact about any
#' one analysis project, so it should follow the user across projects
#' rather than being redeclared per-project.
#'
#' Like [install_quarto()], this is only ever invoked directly by the user
#' or on the user's behalf immediately after a real install -- never called
#' automatically by [render_onepager()] or any other rendering function.
#'
#' @param path Character. Path to a quarto binary. Must already exist.
#' @param persist Logical or `NA`. `NA` (default): if the session is
#'   interactive, asks before writing to `renviron_path`; if not
#'   interactive, does not persist. `TRUE`/`FALSE`: persist or don't, with
#'   no prompt -- for scripts and non-interactive use.
#' @param renviron_path Character. Path to the `.Renviron` file to update
#'   when persisting. Default the current user's `~/.Renviron`. Exposed as
#'   an argument mainly so this is testable without touching a real
#'   `.Renviron`; most callers should leave it at the default.
#' @return Invisibly, `path`.
#' @examples
#' \dontrun{
#' # Never run automatically -- points onepagr at a real Quarto binary on
#' # your system and, with consent, edits ~/.Renviron. Adjust the path to
#' # a real quarto install before running.
#' set_quarto_path("/opt/quarto/bin/quarto")
#' }
#' @export
set_quarto_path <- function(
  path, persist = NA, renviron_path = path.expand("~/.Renviron")
) {
  if (!file.exists(path)) {
    stop("path does not exist: ", path, call. = FALSE)
  }

  Sys.setenv(QUARTO_PATH = path)
  message("QUARTO_PATH set to ", path, " for this session.")

  should_persist <- if (is.na(persist)) {
    interactive() && isTRUE(utils::askYesNo(
      "Persist this to ~/.Renviron so future R sessions use it too?"
    ))
  } else {
    isTRUE(persist)
  }

  if (should_persist) {
    update_renviron_line("QUARTO_PATH", path, renviron_path)
    message(
      "Saved to ", renviron_path,
      ". Future R sessions will use this automatically."
    )
  }

  invisible(path)
}

#' Add or replace a single `KEY="value"` line in a `.Renviron`-style file
#'
#' Every other line in the file is left untouched: reads the file if it
#' exists (an empty vector if it doesn't yet), replaces the first existing
#' line matching `^key\s*=` if there is one (dropping any further
#' duplicates, which should never legitimately exist but would be
#' ambiguous for R to parse if they did), or appends a new line if there's
#' no existing match.
#'
#' @param key Character. Environment variable name.
#' @param value Character. Value to assign (written as a quoted string).
#' @param renviron_path Character. Path to the file to update. Created if
#'   it doesn't exist yet.
#' @return Invisibly, `renviron_path`.
#' @keywords internal
update_renviron_line <- function(key, value, renviron_path) {
  lines <- if (file.exists(renviron_path)) {
    readLines(renviron_path, warn = FALSE)
  } else {
    character(0)
  }

  pattern <- paste0("^", key, "\\s*=")
  new_line <- paste0(key, "=\"", value, "\"")
  match_idx <- grep(pattern, lines)

  if (length(match_idx) > 0) {
    lines[match_idx[1]] <- new_line
    if (length(match_idx) > 1) lines <- lines[-match_idx[-1]]
  } else {
    lines <- c(lines, new_line)
  }

  writeLines(lines, renviron_path)
  invisible(renviron_path)
}
