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
  expect_setequal(list_templates(), c("cohort_summary", "trend_snapshot"))
})
