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

# install_quarto() downloads and installs real software and is
# deliberately NOT covered by automated tests here -- same reasoning as
# reticulate::install_miniconda()/keras::install_keras() not unit-testing
# their actual downloads. Verify it manually: run
# onepagr::install_quarto() in an interactive session on each target OS
# (Windows/macOS/Linux) before release, and confirm check_quarto()
# reports ok afterward once QUARTO_PATH is set per its own message.
