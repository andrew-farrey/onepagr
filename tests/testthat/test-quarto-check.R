test_that("check_quarto reports ok when the bundled Typst meets the minimum", {
  testthat::local_mocked_bindings(
    quarto_available = function() TRUE,
    quarto_version = function() package_version("1.10.18"),
    quarto_path = function() "quarto",
    .package = "quarto"
  )
  testthat::local_mocked_bindings(
    typst_version_via_quarto = function(quarto_bin) package_version("0.15.1")
  )
  result <- check_quarto(min_typst_version = "0.15.1")
  expect_true(result$available)
  expect_true(result$ok)
  expect_equal(result$typst_version, package_version("0.15.1"))
})

test_that("check_quarto reports not ok when the bundled Typst is too old", {
  # This is the actual bug this rewrite fixes: a recent-looking Quarto
  # version number does NOT guarantee a new-enough bundled Typst --
  # confirmed directly (web research plus this package's own dev
  # environment) that Quarto sat on Typst 0.11.x across several 1.4-1.7.x
  # releases. This test uses a "new" Quarto version paired with an "old"
  # Typst version specifically to prove check_quarto() is keying off the
  # right one.
  testthat::local_mocked_bindings(
    quarto_available = function() TRUE,
    quarto_version = function() package_version("1.7.32"),
    quarto_path = function() "quarto",
    .package = "quarto"
  )
  testthat::local_mocked_bindings(
    typst_version_via_quarto = function(quarto_bin) package_version("0.11.0")
  )
  expect_message(
    result <- check_quarto(min_typst_version = "0.15.1"),
    "needs at least Typst"
  )
  expect_false(result$ok)
  expect_equal(result$typst_version, package_version("0.11.0"))
})

test_that("check_quarto reports unavailable and messages when not found", {
  testthat::local_mocked_bindings(
    quarto_available = function() FALSE,
    .package = "quarto"
  )
  expect_message(
    result <- check_quarto(),
    "was not found"
  )
  expect_false(result$available)
  expect_false(result$ok)
})

test_that("check_quarto handles an unparseable Typst version gracefully", {
  testthat::local_mocked_bindings(
    quarto_available = function() TRUE,
    quarto_version = function() package_version("1.10.18"),
    quarto_path = function() "quarto",
    .package = "quarto"
  )
  testthat::local_mocked_bindings(
    typst_version_via_quarto = function(quarto_bin) NA
  )
  expect_message(
    result <- check_quarto(),
    "could not be determined"
  )
  expect_false(result$ok)
})

test_that("typst_version_via_quarto parses the real bundled Typst version", {
  skip_if_not(quarto::quarto_available())
  version <- typst_version_via_quarto(quarto::quarto_path())
  expect_s3_class(version, "package_version")
})

# install_quarto() itself is NEVER unit-tested end-to-end against a real
# network download -- same reasoning as
# reticulate::install_miniconda()/keras::install_keras() not
# unit-testing their actual downloads. Verify the real download path
# manually: run onepagr::install_quarto() in an interactive session on
# each target OS (Windows/macOS/Linux) before release, and confirm
# check_quarto() reports ok afterward once QUARTO_PATH is set per its
# own message.
#
# What CAN be safely covered without a real download: the per-OS
# branching logic that picks the right release asset filename and the
# right post-install instructions -- a real, plausible bug class (e.g. a
# typo'd asset name, or the Windows/non-Windows branches swapped) that a
# manual OS-by-OS check would only catch by accident. Every
# download.file()/untar()/browseURL() call is mocked out (verified
# working directly above) so nothing here touches the network or the
# real filesystem outside a throwaway tempdir.

test_that("install_quarto downloads the Windows .msi and opens it", {
  testthat::local_mocked_bindings(Sys.info = function() {
    c(sysname = "Windows")
  }, .package = "base")
  testthat::local_mocked_bindings(
    R_user_dir = function(...) tempfile("onepagr-test-"),
    .package = "tools"
  )
  downloaded <- new.env()
  testthat::local_mocked_bindings(
    download.file = function(url, destfile, mode) {
      downloaded$url <- url
      downloaded$destfile <- destfile
      invisible(0)
    },
    browseURL = function(url) {
      downloaded$browsed <- url
      invisible(NULL)
    },
    .package = "utils"
  )

  expect_message(
    dest <- install_quarto(version = "9.9.9"),
    "Opening it now"
  )
  expect_true(grepl("quarto-9.9.9-win.msi", dest, fixed = TRUE))
  expect_equal(
    downloaded$url,
    paste0(
      "https://github.com/quarto-dev/quarto-cli/releases/download/",
      "v9.9.9/quarto-9.9.9-win.msi"
    )
  )
  expect_equal(downloaded$destfile, dest)
  # Windows installers are never silently run -- only opened for the
  # user to complete themselves (see install_quarto()'s own docs on why).
  expect_equal(downloaded$browsed, dest)
})

test_that("install_quarto downloads and extracts the macOS tar.gz", {
  # install_quarto() now calls set_quarto_path() for real on success,
  # which sets QUARTO_PATH for the actual session (not mocked -- that's
  # the point) -- restore whatever it was before, so this fake path
  # doesn't leak into later tests that check quarto::quarto_available().
  old_path <- Sys.getenv("QUARTO_PATH", unset = NA)
  on.exit(
    if (is.na(old_path)) {
      Sys.unsetenv("QUARTO_PATH")
    } else {
      Sys.setenv(QUARTO_PATH = old_path)
    },
    add = TRUE
  )
  testthat::local_mocked_bindings(Sys.info = function() {
    c(sysname = "Darwin")
  }, .package = "base")
  testthat::local_mocked_bindings(
    R_user_dir = function(...) tempfile("onepagr-test-"),
    .package = "tools"
  )
  calls <- new.env()
  testthat::local_mocked_bindings(
    download.file = function(url, destfile, mode) {
      calls$download_url <- url
      invisible(0)
    },
    # A real untar() would leave the extracted quarto binary on disk --
    # set_quarto_path() (called by install_quarto() after extraction) now
    # checks file.exists() on that path, so this mock creates a real
    # placeholder file rather than doing nothing, matching what a genuine
    # extraction would produce.
    untar = function(tarfile, exdir) {
      calls$untar_exdir <- exdir
      bin_dir <- file.path(exdir, "quarto-9.9.9", "bin")
      dir.create(bin_dir, recursive = TRUE, showWarnings = FALSE)
      file.create(file.path(bin_dir, "quarto"))
      invisible(0)
    },
    .package = "utils"
  )

  expect_message(
    install_dir <- install_quarto(version = "9.9.9"),
    "QUARTO_PATH"
  )
  expect_true(
    grepl("quarto-9.9.9-macos.tar.gz", calls$download_url, fixed = TRUE)
  )
  expect_equal(calls$untar_exdir, install_dir)
})

test_that("install_quarto downloads and extracts the Linux tar.gz", {
  old_path <- Sys.getenv("QUARTO_PATH", unset = NA)
  on.exit(
    if (is.na(old_path)) {
      Sys.unsetenv("QUARTO_PATH")
    } else {
      Sys.setenv(QUARTO_PATH = old_path)
    },
    add = TRUE
  )
  testthat::local_mocked_bindings(Sys.info = function() {
    c(sysname = "Linux")
  }, .package = "base")
  testthat::local_mocked_bindings(
    R_user_dir = function(...) tempfile("onepagr-test-"),
    .package = "tools"
  )
  calls <- new.env()
  testthat::local_mocked_bindings(
    download.file = function(url, destfile, mode) {
      calls$download_url <- url
      invisible(0)
    },
    untar = function(tarfile, exdir) {
      bin_dir <- file.path(exdir, "quarto-9.9.9", "bin")
      dir.create(bin_dir, recursive = TRUE, showWarnings = FALSE)
      file.create(file.path(bin_dir, "quarto"))
      invisible(0)
    },
    .package = "utils"
  )

  install_quarto(version = "9.9.9")
  expect_true(
    grepl("quarto-9.9.9-linux-amd64.tar.gz", calls$download_url, fixed = TRUE)
  )
})

# set_quarto_path() calls Sys.setenv() for real (not mocked -- that's the
# whole point of the function), so every test below saves and restores
# whatever QUARTO_PATH was already set to, rather than leaking a test
# value into later tests or the developer's own session.

test_that("set_quarto_path sets QUARTO_PATH for the current session", {
  old <- Sys.getenv("QUARTO_PATH", unset = NA)
  on.exit(
    if (is.na(old)) {
      Sys.unsetenv("QUARTO_PATH")
    } else {
      Sys.setenv(QUARTO_PATH = old)
    },
    add = TRUE
  )
  quarto_bin <- tempfile()
  file.create(quarto_bin)

  expect_message(
    set_quarto_path(quarto_bin, persist = FALSE),
    "QUARTO_PATH set to"
  )
  expect_equal(Sys.getenv("QUARTO_PATH"), quarto_bin)
})

test_that("set_quarto_path errors clearly on a nonexistent path", {
  expect_error(
    set_quarto_path("/does/not/exist/quarto", persist = FALSE),
    "does not exist"
  )
})

test_that("set_quarto_path does not touch .Renviron when persist = FALSE", {
  old <- Sys.getenv("QUARTO_PATH", unset = NA)
  on.exit(
    if (is.na(old)) {
      Sys.unsetenv("QUARTO_PATH")
    } else {
      Sys.setenv(QUARTO_PATH = old)
    },
    add = TRUE
  )
  quarto_bin <- tempfile()
  file.create(quarto_bin)
  renviron_path <- tempfile()

  set_quarto_path(quarto_bin, persist = FALSE, renviron_path = renviron_path)
  expect_false(file.exists(renviron_path))
})

test_that("set_quarto_path persists to renviron_path when persist = TRUE", {
  old <- Sys.getenv("QUARTO_PATH", unset = NA)
  on.exit(
    if (is.na(old)) {
      Sys.unsetenv("QUARTO_PATH")
    } else {
      Sys.setenv(QUARTO_PATH = old)
    },
    add = TRUE
  )
  quarto_bin <- tempfile()
  file.create(quarto_bin)
  renviron_path <- tempfile()
  on.exit(unlink(renviron_path), add = TRUE)

  expect_message(
    set_quarto_path(quarto_bin, persist = TRUE, renviron_path = renviron_path),
    "Saved to"
  )
  expect_true(file.exists(renviron_path))
  lines <- readLines(renviron_path)
  expect_true(any(grepl(
    paste0('QUARTO_PATH="', quarto_bin, '"'), lines, fixed = TRUE
  )))
})

test_that("persist = NA skips the prompt and the write when not interactive", {
  # testthat runs non-interactively, so interactive() is FALSE and the NA
  # branch's `interactive() && ...` short-circuits without ever calling
  # utils::askYesNo() -- this is what keeps this test (and every
  # install_quarto() test above, which now calls set_quarto_path()
  # internally) from blocking on stdin or silently writing to a real
  # ~/.Renviron during a test run.
  old <- Sys.getenv("QUARTO_PATH", unset = NA)
  on.exit(
    if (is.na(old)) {
      Sys.unsetenv("QUARTO_PATH")
    } else {
      Sys.setenv(QUARTO_PATH = old)
    },
    add = TRUE
  )
  quarto_bin <- tempfile()
  file.create(quarto_bin)
  renviron_path <- tempfile()

  set_quarto_path(quarto_bin, renviron_path = renviron_path)
  expect_false(file.exists(renviron_path))
})

test_that("update_renviron_line appends a new key to a nonexistent file", {
  renviron_path <- tempfile()
  on.exit(unlink(renviron_path), add = TRUE)

  update_renviron_line("QUARTO_PATH", "/opt/quarto/bin/quarto", renviron_path)

  expect_equal(
    readLines(renviron_path), 'QUARTO_PATH="/opt/quarto/bin/quarto"'
  )
})

test_that("update_renviron_line replaces an existing key, keeps other lines", {
  renviron_path <- tempfile()
  on.exit(unlink(renviron_path), add = TRUE)
  writeLines(c(
    'SOME_OTHER_VAR="keep-me"',
    'QUARTO_PATH="/old/stale/path"',
    'ANOTHER_VAR="also-keep-me"'
  ), renviron_path)

  update_renviron_line("QUARTO_PATH", "/new/path/quarto", renviron_path)

  expect_equal(readLines(renviron_path), c(
    'SOME_OTHER_VAR="keep-me"',
    'QUARTO_PATH="/new/path/quarto"',
    'ANOTHER_VAR="also-keep-me"'
  ))
})

test_that("update_renviron_line collapses duplicate keys to one line", {
  renviron_path <- tempfile()
  on.exit(unlink(renviron_path), add = TRUE)
  writeLines(c(
    'QUARTO_PATH="/first/stale/path"',
    'KEEP_ME="yes"',
    'QUARTO_PATH="/second/stale/path"'
  ), renviron_path)

  update_renviron_line("QUARTO_PATH", "/final/path/quarto", renviron_path)

  expect_equal(readLines(renviron_path), c(
    'QUARTO_PATH="/final/path/quarto"',
    'KEEP_ME="yes"'
  ))
})
