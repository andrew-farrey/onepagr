# install_quarto(dir =, force =): install into a folder the user picks, and do
# not download when the Quarto already in use is new enough. The download and
# the unpacking are mocked, so nothing touches the network.

fresh_dir <- function(entries = character(0)) {
  dir <- tempfile("quarto-dir-")
  dir.create(dir)
  withr::defer(unlink(dir, recursive = TRUE), envir = parent.frame())
  for (entry in entries) {
    if (grepl("[.](msi|gz)$", entry)) {
      file.create(file.path(dir, entry))
    } else {
      dir.create(file.path(dir, entry, "bin"), recursive = TRUE)
      file.create(file.path(dir, entry, "bin", "quarto"))
    }
  }
  dir
}

# Calls install_quarto() with the system, the current Quarto and the download
# faked. Returns what the call did.
run_install <- function(..., sysname = "Linux", current = NULL) {
  old <- Sys.getenv("QUARTO_PATH", unset = NA)
  withr::defer(
    if (is.na(old)) Sys.unsetenv("QUARTO_PATH") else Sys.setenv(QUARTO_PATH = old)
  )
  testthat::local_mocked_bindings(
    Sys.info = function() c(sysname = sysname, machine = "x86_64"),
    .package = "base"
  )
  testthat::local_mocked_bindings(
    R_user_dir = function(...) stop("the managed folder must not be used"),
    .package = "tools"
  )
  testthat::local_mocked_bindings(
    quarto_paths_in_use = function(...) character(0),
    confirm_quarto_download = function(...) TRUE,
    current_quarto = function() current
  )
  calls <- new.env()
  calls$downloaded <- character(0)
  calls$browsed <- NULL
  testthat::local_mocked_bindings(
    download.file = function(url, destfile, mode) {
      calls$downloaded <- c(calls$downloaded, basename(url))
      invisible(0)
    },
    untar = function(tarfile, exdir) {
      dir.create(file.path(exdir, "bin"), recursive = TRUE, showWarnings = FALSE)
      file.create(file.path(exdir, "bin", "quarto"))
      invisible(0)
    },
    browseURL = function(url) calls$browsed <- url,
    .package = "utils"
  )
  seen <- new.env()
  seen$messages <- character(0)
  result <- withCallingHandlers(
    install_quarto(...),
    message = function(m) {
      seen$messages <- c(seen$messages, conditionMessage(m))
      invokeRestart("muffleMessage")
    }
  )
  list(
    result = result, downloaded = calls$downloaded, browsed = calls$browsed,
    messages = paste(seen$messages, collapse = "\n"),
    quarto_path = Sys.getenv("QUARTO_PATH")
  )
}

quarto_at <- function(version, path = "/usr/local/bin/quarto") {
  list(version = package_version(version), path = path)
}

# The folder to install into ----

test_that("dir installs into the folder given, not the managed one", {
  dir <- fresh_dir()
  res <- run_install(version = "9.9.9", dir = dir)
  expect_identical(res$result, normalizePath(dir, winslash = "/"))
  expect_true(file.exists(file.path(dir, "quarto-9.9.9", "bin", "quarto")))
  expect_identical(res$downloaded, "quarto-9.9.9-linux-amd64.tar.gz")
  expect_identical(
    res$quarto_path,
    normalizePath(file.path(dir, "quarto-9.9.9", "bin", "quarto"), winslash = "/")
  )
})

test_that("dir is created when it does not exist yet", {
  dir <- file.path(fresh_dir(), "opt", "tools")
  run_install(version = "9.9.9", dir = dir)
  expect_true(file.exists(file.path(dir, "quarto-9.9.9", "bin", "quarto")))
})

test_that("a folder the user chose is never cleaned up, only reported", {
  dir <- fresh_dir(c("quarto-1.9.1", "quarto-1.10.18", "other-tool"))
  res <- run_install(version = "9.9.9", dir = dir)
  expect_setequal(
    list.files(dir),
    c("quarto-1.9.1", "quarto-1.10.18", "quarto-9.9.9", "other-tool")
  )
  expect_match(res$messages, "Older Quarto copies were left in", fixed = TRUE)
  expect_match(res$messages, "quarto-1.9.1", fixed = TRUE)
  expect_false(grepl("Removed older", res$messages, fixed = TRUE))
})

test_that("nothing is reported when a chosen folder holds no older copy", {
  dir <- fresh_dir("other-tool")
  res <- run_install(version = "9.9.9", dir = dir)
  expect_false(grepl("left in", res$messages, fixed = TRUE))
})

test_that("a folder that cannot be written to stops before any download", {
  blocker <- tempfile("blocker-")
  file.create(blocker)
  withr::defer(unlink(blocker))
  calls <- new.env()
  calls$downloaded <- FALSE
  testthat::local_mocked_bindings(
    quarto_paths_in_use = function(...) character(0),
    confirm_quarto_download = function(...) TRUE,
    current_quarto = function() NULL
  )
  testthat::local_mocked_bindings(
    download.file = function(...) calls$downloaded <- TRUE,
    .package = "utils"
  )
  expect_error(
    install_quarto(version = "9.9.9", dir = file.path(blocker, "opt")),
    "Cannot write to.*dir = ...*set_quarto_path"
  )
  expect_false(calls$downloaded)
})

test_that("dir must be NULL or one folder path", {
  for (bad in list("", NA_character_, c("a", "b"), 1, TRUE)) {
    expect_error(
      install_quarto(version = "9.9.9", dir = bad),
      "`dir` must be NULL or a single folder path",
      fixed = TRUE
    )
  }
})

test_that("a tilde in dir is expanded", {
  expect_identical(
    resolve_quarto_install_dir("~/quarto-tools"),
    normalizePath(path.expand("~/quarto-tools"), winslash = "/", mustWork = FALSE)
  )
})

test_that("on Windows dir is where the installer is saved, and nothing is deleted", {
  dir <- fresh_dir("quarto-1.9.1-win.msi")
  res <- run_install(version = "9.9.9", dir = dir, sysname = "Windows")
  expect_identical(
    res$browsed,
    file.path(normalizePath(dir, winslash = "/"), "quarto-9.9.9-win.msi")
  )
  expect_identical(res$downloaded, "quarto-9.9.9-win.msi")
  expect_true(file.exists(file.path(dir, "quarto-1.9.1-win.msi")))
  expect_match(res$messages, "quarto-1.9.1-win.msi", fixed = TRUE)
})

# A Quarto that is already new enough ----

test_that("nothing is downloaded when the Quarto in use is already as new", {
  dir <- fresh_dir()
  res <- run_install(
    version = "9.9.9", dir = dir, current = quarto_at("9.9.9", "/opt/q/bin/quarto")
  )
  expect_null(res$result)
  expect_identical(res$downloaded, character(0))
  expect_match(res$messages, "already as new as 9.9.9", fixed = TRUE)
  expect_match(res$messages, "/opt/q/bin/quarto", fixed = TRUE)
  expect_match(res$messages, "force = TRUE", fixed = TRUE)
  expect_identical(list.files(dir), character(0))
})

test_that("a newer Quarto in use also stops the install", {
  res <- run_install(
    version = "9.9.9", dir = fresh_dir(), current = quarto_at("10.0.0")
  )
  expect_null(res$result)
  expect_identical(res$downloaded, character(0))
})

test_that("an older Quarto in use does not stop the install", {
  res <- run_install(
    version = "9.9.9", dir = fresh_dir(), current = quarto_at("1.9.1")
  )
  expect_identical(res$downloaded, "quarto-9.9.9-linux-amd64.tar.gz")
})

test_that("force installs even when the Quarto in use is new enough", {
  dir <- fresh_dir()
  res <- run_install(
    version = "9.9.9", dir = dir, force = TRUE, current = quarto_at("9.9.9")
  )
  expect_identical(res$downloaded, "quarto-9.9.9-linux-amd64.tar.gz")
  expect_true(file.exists(file.path(dir, "quarto-9.9.9", "bin", "quarto")))
})

test_that("a release already unpacked in the folder is reused, not downloaded", {
  dir <- fresh_dir("quarto-9.9.9")
  res <- run_install(version = "9.9.9", dir = dir)
  expect_identical(res$downloaded, character(0))
  expect_match(res$messages, "already installed", fixed = TRUE)
  expect_match(res$quarto_path, "quarto-9.9.9/bin/quarto$")
})

test_that("force downloads again over an unpacked release", {
  dir <- fresh_dir("quarto-9.9.9")
  res <- run_install(version = "9.9.9", dir = dir, force = TRUE)
  expect_identical(res$downloaded, "quarto-9.9.9-linux-amd64.tar.gz")
})

# current_quarto() ----

test_that("current_quarto is NULL when there is no Quarto", {
  testthat::local_mocked_bindings(
    quarto_available = function() FALSE,
    .package = "quarto"
  )
  expect_null(current_quarto())
})

test_that("current_quarto reports the version and the path", {
  testthat::local_mocked_bindings(
    quarto_available = function() TRUE,
    quarto_version = function() package_version("1.11.9"),
    quarto_path = function() "/opt/quarto/bin/quarto",
    .package = "quarto"
  )
  expect_identical(
    current_quarto(),
    list(version = package_version("1.11.9"), path = "/opt/quarto/bin/quarto")
  )
})

test_that("current_quarto is NULL when the version cannot be read", {
  testthat::local_mocked_bindings(
    quarto_available = function() TRUE,
    quarto_version = function() stop("no version"),
    .package = "quarto"
  )
  expect_null(current_quarto())
})
