# install_quarto() installs the newest stable Quarto unless a version is named.
# Nothing here touches the network: the release lookup and the download are
# both mocked.

mock_release_reply <- function(json) {
  testthat::local_mocked_bindings(
    download.file = function(url, destfile, mode) {
      writeLines(json, destfile)
      invisible(0)
    },
    .package = "utils",
    .env = parent.frame()
  )
}

test_that("the newest release is read from the tag of the latest-release reply", {
  mock_release_reply('{"tag_name": "v1.11.9", "prerelease": false}')
  expect_identical(latest_quarto_version(), "1.11.9")
})

test_that("a tag without a leading v is accepted", {
  mock_release_reply('{"tag_name": "1.11.9"}')
  expect_identical(latest_quarto_version(), "1.11.9")
})

test_that("a reply with no usable version stops with the way out", {
  for (json in c("{}", '{"tag_name": "nightly"}', '{"tag_name": ["v1.1", "v1.2"]}',
                 "not json at all")) {
    mock_release_reply(json)
    expect_error(
      latest_quarto_version(),
      "install_quarto(version = ", fixed = TRUE
    )
  }
})

test_that("a failed lookup says so and names the way out", {
  testthat::local_mocked_bindings(
    download.file = function(url, destfile, mode) stop("cannot open URL"),
    .package = "utils"
  )
  expect_error(
    latest_quarto_version(),
    "Could not look up the newest Quarto release.*cannot open URL.*version ="
  )
})

test_that("a version string is checked before it reaches a URL or a folder name", {
  expect_identical(check_quarto_version_string("1.10.18"), "1.10.18")
  expect_no_warning(check_quarto_version_string("1.10.18"))
  expect_no_warning(check_quarto_version_string("1.11.9"))
  expect_no_warning(check_quarto_version_string("2.0"))
  for (bad in list("", "latest", "1.10; rm -rf /", "../1.10.18", "v1.10.18", NA,
                   c("1.10.18", "1.11.9"), 1.1)) {
    expect_error(check_quarto_version_string(bad), "must be \"latest\" or")
  }
})

test_that("a version older than the first one with a new enough Typst is warned about", {
  expect_warning(check_quarto_version_string("1.9.1"), "older than 1.10.18")
  expect_warning(check_quarto_version_string("1.10.17"), "older than 1.10.18")
})

test_that("the default version is the newest stable release", {
  expect_identical(formals(install_quarto)$version, "latest")
})

test_that("install_quarto() with no version downloads the newest stable release", {
  old <- Sys.getenv("QUARTO_PATH", unset = NA)
  withr::defer(
    if (is.na(old)) Sys.unsetenv("QUARTO_PATH") else Sys.setenv(QUARTO_PATH = old)
  )
  testthat::local_mocked_bindings(
    Sys.info = function() c(sysname = "Linux", machine = "x86_64"),
    .package = "base"
  )
  testthat::local_mocked_bindings(
    R_user_dir = function(...) tempfile("onepagr-test-"),
    .package = "tools"
  )
  testthat::local_mocked_bindings(latest_quarto_version = function() "9.8.7")
  calls <- new.env()
  testthat::local_mocked_bindings(
    download.file = function(url, destfile, mode) {
      calls$url <- url
      invisible(0)
    },
    untar = function(tarfile, exdir) {
      dir.create(file.path(exdir, "bin"), recursive = TRUE, showWarnings = FALSE)
      file.create(file.path(exdir, "bin", "quarto"))
      invisible(0)
    },
    .package = "utils"
  )

  expect_message(install_quarto(), "newest stable Quarto release is 9.8.7")
  expect_identical(
    calls$url,
    paste0(
      "https://github.com/quarto-dev/quarto-cli/releases/download/",
      "v9.8.7/quarto-9.8.7-linux-amd64.tar.gz"
    )
  )
})

test_that("an explicit version skips the release lookup", {
  testthat::local_mocked_bindings(
    latest_quarto_version = function() stop("must not look up the release"),
    confirm_quarto_download = function(...) FALSE
  )
  expect_message(install_quarto(version = "9.9.9"), "not installed")
})
