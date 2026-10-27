# install_quarto() keeps its install directory tidy: it asks before a large
# download, and after installing it removes the older copies it put there, but
# never one that QUARTO_PATH still points into and never anything it did not
# create. CRAN asks that a package using R_user_dir() "actively manage" it,
# including removing outdated material.

make_install_dir <- function(folders = character(0), files = character(0),
                             env = parent.frame()) {
  dir <- tempfile("onepagr-installs-")
  dir.create(dir)
  for (f in folders) {
    dir.create(file.path(dir, f, "bin"), recursive = TRUE)
    file.create(file.path(dir, f, "bin", "quarto"))
  }
  for (f in files) {
    file.create(file.path(dir, f))
  }
  withr::defer(unlink(dir, recursive = TRUE), envir = env)
  dir
}

contents <- function(dir) sort(list.files(dir, all.files = FALSE))

test_that("older onepagr-installed copies are removed and the new one kept", {
  dir <- make_install_dir(c("quarto-1.7.32", "quarto-1.9.1", "quarto-1.10.18"))
  removed <- suppressMessages(remove_old_quarto_installs(
    dir, keep = "quarto-1.10.18", in_use = character(0)
  ))
  expect_identical(contents(dir), "quarto-1.10.18")
  expect_setequal(removed, c("quarto-1.7.32", "quarto-1.9.1"))
})

test_that("a copy that QUARTO_PATH points into is kept, and the user is told", {
  dir <- make_install_dir(c("quarto-1.9.1", "quarto-1.10.18"))
  in_use <- file.path(dir, "quarto-1.9.1", "bin", "quarto")
  expect_message(
    removed <- remove_old_quarto_installs(
      dir, keep = "quarto-1.10.18", in_use = in_use
    ),
    "quarto-1.9.1"
  )
  expect_setequal(contents(dir), c("quarto-1.9.1", "quarto-1.10.18"))
  expect_length(removed, 0)
})

test_that("a path in use is matched by folder, not by a shared name prefix", {
  dir <- make_install_dir(c("quarto-1.9", "quarto-1.9.1", "quarto-1.10.18"))
  in_use <- file.path(dir, "quarto-1.9", "bin", "quarto")
  suppressMessages(remove_old_quarto_installs(
    dir, keep = "quarto-1.10.18", in_use = in_use
  ))
  # quarto-1.9.1 is not the folder in use, so it goes; quarto-1.9 stays.
  expect_setequal(contents(dir), c("quarto-1.9", "quarto-1.10.18"))
})

test_that("anything that does not look like an onepagr install is left alone", {
  dir <- make_install_dir(
    folders = c("quarto-1.9.1", "quarto-1.10.18", "quarto-notes", "my-project",
                "quarto-1.9.1-backup"),
    files = c("readme.txt", "quarto-1.9.1.txt")
  )
  suppressMessages(remove_old_quarto_installs(
    dir, keep = "quarto-1.10.18", in_use = character(0)
  ))
  expect_setequal(
    contents(dir),
    c("quarto-1.10.18", "quarto-notes", "my-project", "quarto-1.9.1-backup",
      "readme.txt", "quarto-1.9.1.txt")
  )
})

test_that("older installers and archives go, the current installer stays", {
  dir <- make_install_dir(files = c(
    "quarto-1.9.1-win.msi", "quarto-1.10.18-win.msi",
    "quarto-1.9.1-linux-amd64.tar.gz", "quarto-1.9.1-macos.tar.gz",
    "notes-win.msi"
  ))
  suppressMessages(remove_old_quarto_installs(
    dir, keep = NULL, keep_file = "quarto-1.10.18-win.msi",
    in_use = character(0)
  ))
  expect_setequal(contents(dir), c("quarto-1.10.18-win.msi", "notes-win.msi"))
})

test_that("a dry run reports what would go and removes nothing", {
  dir <- make_install_dir(c("quarto-1.9.1", "quarto-1.10.18"))
  would <- suppressMessages(remove_old_quarto_installs(
    dir, keep = "quarto-1.10.18", in_use = character(0), dry_run = TRUE
  ))
  expect_identical(would, "quarto-1.9.1")
  expect_setequal(contents(dir), c("quarto-1.9.1", "quarto-1.10.18"))
})

test_that("a missing install directory is not an error", {
  expect_silent(remove_old_quarto_installs(
    file.path(tempfile("never-made-"), "x"), keep = "quarto-1.10.18",
    in_use = character(0)
  ))
})

test_that("a linked folder is not followed", {
  skip_on_os("windows")
  outside <- tempfile("outside-")
  dir.create(file.path(outside, "bin"), recursive = TRUE)
  file.create(file.path(outside, "bin", "quarto"))
  withr::defer(unlink(outside, recursive = TRUE))
  dir <- make_install_dir("quarto-1.10.18")
  skip_if_not(file.symlink(outside, file.path(dir, "quarto-1.9.1")))
  suppressMessages(remove_old_quarto_installs(
    dir, keep = "quarto-1.10.18", in_use = character(0)
  ))
  expect_true(file.exists(file.path(outside, "bin", "quarto")))
})

test_that("quarto_paths_in_use reads QUARTO_PATH and ~/.Renviron", {
  renviron <- tempfile(".Renviron-")
  writeLines(c(
    "OTHER=1", "QUARTO_PATH=\"C:/Users/x/quarto-1.9.1/bin/quarto\"", "# QUARTO_PATH=old"
  ), renviron)
  withr::defer(unlink(renviron))
  withr::local_envvar(QUARTO_PATH = "C:/session/quarto-1.7.32/bin/quarto")
  found <- quarto_paths_in_use(renviron_path = renviron)
  expect_true("C:/session/quarto-1.7.32/bin/quarto" %in% found)
  expect_true("C:/Users/x/quarto-1.9.1/bin/quarto" %in% found)
  expect_false(any(grepl("old", found)))
})

test_that("quarto_paths_in_use is empty when nothing is set", {
  withr::local_envvar(QUARTO_PATH = NA)
  expect_identical(
    quarto_paths_in_use(renviron_path = tempfile("missing-")), character(0)
  )
})

test_that("the download prompt never fires outside an interactive session", {
  expect_true(confirm_quarto_download(
    "1.10.18", "dir", is_interactive = FALSE,
    ask = function(...) stop("must not ask")
  ))
})

test_that("an interactive session is asked, and only a yes goes ahead", {
  asked <- NULL
  yes <- function(msg, ...) {
    asked <<- msg
    TRUE
  }
  expect_true(confirm_quarto_download("1.10.18", "dir", TRUE, yes))
  expect_match(asked, "1.10.18", fixed = TRUE)
  expect_match(asked, "MB", fixed = TRUE)
  expect_false(confirm_quarto_download("1.10.18", "dir", TRUE, function(...) FALSE))
  expect_false(confirm_quarto_download("1.10.18", "dir", TRUE, function(...) NA))
})

# install_quarto(), end to end with the download and unpacking mocked ----
run_install_into <- function(dir, in_use = character(0), confirm = TRUE) {
  old <- Sys.getenv("QUARTO_PATH", unset = NA)
  withr::defer(
    if (is.na(old)) Sys.unsetenv("QUARTO_PATH") else Sys.setenv(QUARTO_PATH = old)
  )
  testthat::local_mocked_bindings(
    Sys.info = function() c(sysname = "Linux", machine = "x86_64"),
    .package = "base"
  )
  testthat::local_mocked_bindings(R_user_dir = function(...) dir, .package = "tools")
  testthat::local_mocked_bindings(
    quarto_paths_in_use = function(...) in_use,
    confirm_quarto_download = function(...) confirm
  )
  calls <- new.env()
  calls$downloaded <- FALSE
  testthat::local_mocked_bindings(
    download.file = function(url, destfile, mode) {
      calls$downloaded <- TRUE
      invisible(0)
    },
    untar = function(tarfile, exdir) {
      dir.create(file.path(exdir, "bin"), recursive = TRUE, showWarnings = FALSE)
      file.create(file.path(exdir, "bin", "quarto"))
      invisible(0)
    },
    .package = "utils"
  )
  result <- suppressMessages(install_quarto(version = "9.9.9"))
  list(result = result, downloaded = calls$downloaded)
}

test_that("install_quarto removes the older copies it installed", {
  dir <- make_install_dir(c("quarto-1.7.32", "quarto-1.9.1"))
  res <- run_install_into(dir)
  expect_true(res$downloaded)
  expect_identical(contents(dir), "quarto-9.9.9")
})

test_that("install_quarto keeps an older copy that is still in use", {
  dir <- make_install_dir(c("quarto-1.9.1"))
  in_use <- file.path(dir, "quarto-1.9.1", "bin", "quarto")
  run_install_into(dir, in_use = in_use)
  expect_setequal(contents(dir), c("quarto-1.9.1", "quarto-9.9.9"))
})

test_that("a declined prompt downloads nothing and changes nothing", {
  dir <- make_install_dir(c("quarto-1.9.1"))
  res <- run_install_into(dir, confirm = FALSE)
  expect_false(res$downloaded)
  expect_null(res$result)
  expect_identical(contents(dir), "quarto-1.9.1")
})
