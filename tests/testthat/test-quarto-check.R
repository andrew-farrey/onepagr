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
    untar = function(tarfile, exdir) {
      calls$untar_exdir <- exdir
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
    untar = function(tarfile, exdir) invisible(0),
    .package = "utils"
  )

  install_quarto(version = "9.9.9")
  expect_true(
    grepl("quarto-9.9.9-linux-amd64.tar.gz", calls$download_url, fixed = TRUE)
  )
})
