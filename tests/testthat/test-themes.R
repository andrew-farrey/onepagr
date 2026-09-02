test_that("resolve_theme finds a built-in theme by name", {
  path <- resolve_theme("default")
  expect_true(file.exists(path))
  expect_match(path, "default\\.typ$")
})

test_that("resolve_theme falls back to a path when the name isn't built-in", {
  tmp <- tempfile(fileext = ".typ")
  writeLines("#let theme = (brand-blue: rgb(\"#000000\"))", tmp)
  on.exit(unlink(tmp))
  path <- resolve_theme(tmp)
  expect_equal(normalizePath(path), normalizePath(tmp))
})

test_that("resolve_theme errors when no registry name or file matches", {
  expect_error(resolve_theme("does-not-exist"), "not a built-in theme")
})

test_that("resolve_theme errors clearly when theme_path doesn't exist", {
  expect_error(
    resolve_theme("default", theme_path = "does/not/exist.typ"),
    "theme_path does not exist"
  )
})

test_that("theme_path overrides theme entirely", {
  tmp <- tempfile(fileext = ".typ")
  writeLines("#let theme = (brand-blue: rgb(\"#000000\"))", tmp)
  on.exit(unlink(tmp))
  path <- resolve_theme("uk", theme_path = tmp)
  expect_equal(normalizePath(path), normalizePath(tmp))
})

test_that("list_themes returns the built-in theme names", {
  expect_setequal(list_themes(), c("default", "uk"))
})

test_that("resolve_template finds a built-in template by name", {
  path <- resolve_template("cohort_summary")
  expect_true(file.exists(path))
  expect_match(path, "cohort_summary.*template\\.typ$")
})

test_that("resolve_template errors clearly for an unknown template", {
  expect_error(resolve_template("does-not-exist"), "not a built-in template")
})

test_that("list_templates returns the built-in template names", {
  expect_setequal(
    list_templates(),
    c(
      "cohort_summary", "trend_snapshot",
      "overdose_spike_alert", "syndromic_alert", "county_choropleth"
    )
  )
})

test_that("check_theme passes both built-in themes against their own schema", {
  for (built_in in list_themes()) {
    result <- check_theme(built_in)
    expect_true(
      result$ok,
      info = paste(
        "theme", built_in, "failed:",
        paste(capture.output(str(result)), collapse = "\n")
      )
    )
    expect_null(result$error)
    expect_length(result$missing, 0)
    expect_length(result$missing_grad, 0)
    expect_equal(nrow(result$type_mismatches), 0)
    expect_equal(nrow(result$type_mismatches_grad), 0)
  }
})

test_that("check_theme reports every missing key for an empty theme", {
  tmp <- tempfile(fileext = ".typ")
  writeLines(c("#let theme = (:)", "#let theme-grad = (:)"), tmp)
  on.exit(unlink(tmp))

  result <- suppressMessages(check_theme(theme_path = tmp))
  expect_false(result$ok)
  expect_null(result$error)
  schema <- onepagr_theme_schema()
  expect_setequal(result$missing, names(schema$theme))
  expect_setequal(result$missing_grad, names(schema$theme_grad))
})

test_that("check_theme reports wrong-type values instead of erroring", {
  tmp <- tempfile(fileext = ".typ")
  writeLines(c(
    "#let theme = (",
    "  brand-blue: \"not-a-color\",",
    "  body-font: 12pt,",
    "  radius-card: 4pt,",
    ")",
    "#let theme-grad = (card-bg-grad: gradient.linear(red, blue))"
  ), tmp)
  on.exit(unlink(tmp))

  result <- suppressMessages(check_theme(theme_path = tmp))
  expect_false(result$ok)
  expect_null(result$error)

  mismatch_for <- function(key) {
    result$type_mismatches[result$type_mismatches$key == key, ]
  }
  expect_equal(mismatch_for("brand-blue")$expected, "color")
  expect_equal(mismatch_for("brand-blue")$actual, "str")
  expect_equal(mismatch_for("body-font")$expected, "str")
  expect_equal(mismatch_for("body-font")$actual, "length")
  expect_equal(mismatch_for("radius-card")$expected, "dictionary")
  expect_equal(mismatch_for("radius-card")$actual, "length")
  # radius-card wasn't a real dictionary, so its sub-keys are never
  # separately reported as missing/mismatched -- already covered above.
  expect_length(result$radius_card_missing, 0)
  expect_equal(nrow(result$radius_card_type_mismatches), 0)
})

test_that("check_theme surfaces the raw Typst error when eval fails", {
  tmp <- tempfile(fileext = ".typ")
  # No theme-grad export at all -- an unresolved-import error at the
  # `import ...: theme, theme-grad` line itself, not a missing-key result.
  writeLines("#let theme = (brand-blue: rgb(\"#000000\"))", tmp)
  on.exit(unlink(tmp))

  result <- suppressMessages(check_theme(theme_path = tmp))
  expect_false(result$ok)
  expect_match(result$error, "unresolved import")
  expect_length(result$missing, 0)
})

test_that("check_theme errors clearly when Quarto is not found", {
  testthat::local_mocked_bindings(
    quarto_path = function() NULL,
    .package = "quarto"
  )
  expect_error(check_theme("default"), "Quarto was not found")
})

test_that("check_theme reports theme-grad and radius-card sub-key problems", {
  tmp <- tempfile(fileext = ".typ")
  # Exercises every remaining branch of the problem-report message: a
  # theme-grad key present with the wrong type (card-bg-grad, a string
  # instead of a gradient), a radius-card sub-key present with the wrong
  # type (top-right, a color instead of a length), and a radius-card
  # sub-key missing entirely (bottom-right).
  writeLines(c(
    "#let theme = (",
    "  radius-card: (top-right: rgb(\"#000000\")),",
    ")",
    "#let theme-grad = (card-bg-grad: \"not-a-gradient\")"
  ), tmp)
  on.exit(unlink(tmp))

  result <- suppressMessages(check_theme(theme_path = tmp))
  expect_false(result$ok)
  expect_null(result$error)

  expect_equal(result$type_mismatches_grad$key, "card-bg-grad")
  expect_equal(result$type_mismatches_grad$expected, "gradient")
  expect_equal(result$type_mismatches_grad$actual, "str")

  expect_equal(result$radius_card_missing, "bottom-right")
  expect_equal(result$radius_card_type_mismatches$key, "top-right")
  expect_equal(result$radius_card_type_mismatches$expected, "length")
  expect_equal(result$radius_card_type_mismatches$actual, "color")
})

test_that("check_theme flags an extra key as unknown without failing ok", {
  default_path <- resolve_theme("default")
  lines <- readLines(default_path, warn = FALSE)
  lines <- sub(
    "^#let theme = \\(",
    "#let theme = (my-custom-extra-key: rgb(\"#123456\"),", lines
  )
  tmp <- tempfile(fileext = ".typ")
  writeLines(lines, tmp)
  on.exit(unlink(tmp))

  result <- suppressMessages(check_theme(theme_path = tmp))
  expect_true(result$ok)
  expect_true("my-custom-extra-key" %in% result$unknown)
})
