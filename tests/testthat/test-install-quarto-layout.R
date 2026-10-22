# install_quarto() must find the Quarto binary wherever the archive put it:
# the macOS tarball unpacks bin/ and share/ at its root, the Linux tarballs
# unpack into a quarto-<version>/ folder.

run_fake_install <- function(sysname, machine, layout) {
  old <- Sys.getenv("QUARTO_PATH", unset = NA)
  on.exit(
    if (is.na(old)) Sys.unsetenv("QUARTO_PATH") else Sys.setenv(QUARTO_PATH = old)
  )
  testthat::local_mocked_bindings(
    Sys.info = function() c(sysname = sysname, machine = machine),
    .package = "base"
  )
  testthat::local_mocked_bindings(
    R_user_dir = function(...) tempfile("onepagr-test-"),
    .package = "tools"
  )
  calls <- new.env()
  testthat::local_mocked_bindings(
    download.file = function(url, destfile, mode) {
      calls$url <- url
      invisible(0)
    },
    untar = function(tarfile, exdir) {
      if (layout != "empty") {
        root <- if (layout == "nested") file.path(exdir, "quarto-9.9.9") else exdir
        dir.create(file.path(root, "bin"), recursive = TRUE, showWarnings = FALSE)
        file.create(file.path(root, "bin", "quarto"))
      }
      invisible(0)
    },
    .package = "utils"
  )
  suppressMessages(install_quarto(version = "9.9.9"))
  list(url = calls$url, quarto_path = Sys.getenv("QUARTO_PATH"))
}

test_that("a flat macOS-style archive (bin/ at the root) is installed", {
  res <- run_fake_install("Darwin", "arm64", "flat")
  expect_true(file.exists(res$quarto_path))
  expect_match(res$quarto_path, "bin/quarto$")
  expect_match(res$url, "quarto-9.9.9-macos.tar.gz", fixed = TRUE)
})

test_that("a nested Linux-style archive (quarto-<version>/bin) is installed", {
  res <- run_fake_install("Linux", "x86_64", "nested")
  expect_true(file.exists(res$quarto_path))
  expect_match(res$quarto_path, "bin/quarto$")
})

test_that("a 64-bit ARM Linux machine gets the arm64 build", {
  expect_match(
    run_fake_install("Linux", "aarch64", "nested")$url,
    "linux-arm64.tar.gz", fixed = TRUE
  )
  expect_match(
    run_fake_install("Linux", "x86_64", "nested")$url,
    "linux-amd64.tar.gz", fixed = TRUE
  )
})

test_that("an archive without bin/quarto is reported clearly", {
  expect_error(
    run_fake_install("Linux", "x86_64", "empty"),
    "Could not find bin/quarto"
  )
})

test_that("set_quarto_path persists an absolute path, not a relative one", {
  old_env <- Sys.getenv("QUARTO_PATH", unset = NA)
  old_wd <- setwd(tempdir())
  on.exit({
    setwd(old_wd)
    if (is.na(old_env)) Sys.unsetenv("QUARTO_PATH") else Sys.setenv(QUARTO_PATH = old_env)
  })
  file.create("quarto")
  on.exit(unlink("quarto"), add = TRUE)
  renviron <- tempfile("Renviron")
  on.exit(unlink(renviron), add = TRUE)
  suppressMessages(
    set_quarto_path("quarto", persist = TRUE, renviron_path = renviron)
  )
  saved <- readLines(renviron)
  expect_false(identical(saved, "QUARTO_PATH=\"quarto\""))
  expect_match(saved, "^QUARTO_PATH=\".*/quarto\"$")
  expect_true(file.exists(Sys.getenv("QUARTO_PATH")))
})
