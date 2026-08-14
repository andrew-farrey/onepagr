test_that("check_quarto reports ok when the version meets the minimum", {
  testthat::local_mocked_bindings(
    quarto_available = function() TRUE,
    quarto_version = function() package_version("1.5.0"),
    .package = "quarto"
  )
  result <- check_quarto(min_version = "1.4.549")
  expect_true(result$available)
  expect_true(result$ok)
})

test_that("check_quarto reports not ok and messages when below minimum", {
  testthat::local_mocked_bindings(
    quarto_available = function() TRUE,
    quarto_version = function() package_version("1.2.0"),
    .package = "quarto"
  )
  expect_message(
    result <- check_quarto(min_version = "1.4.549"),
    "needs at least"
  )
  expect_false(result$ok)
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

# install_quarto() downloads and installs real software and is
# deliberately NOT covered by automated tests here -- same reasoning as
# reticulate::install_miniconda()/keras::install_keras() not unit-testing
# their actual downloads. Verify it manually: run
# onepagr::install_quarto() in an interactive session on each target OS
# (Windows/macOS/Linux) before release, and confirm check_quarto()
# reports ok afterward once QUARTO_PATH is set per its own message.
