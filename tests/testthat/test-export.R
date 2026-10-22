test_that("export_template copies a self-contained, compilable tree", {
  dest <- tempfile()
  on.exit(unlink(dest, recursive = TRUE))
  export_template("cohort_summary", dest, theme = "uk")

  expect_true(file.exists(file.path(dest, "template.typ")))
  expect_true(file.exists(file.path(dest, "theme.typ")))
  expect_true(file.exists(file.path(dest, "components.typ")))
  expect_true(dir.exists(file.path(dest, "assets")))
})

test_that("export_template creates dest recursively if it doesn't exist", {
  parent <- tempfile()
  dest <- file.path(parent, "nested", "dir")
  on.exit(unlink(parent, recursive = TRUE))
  export_template("trend_snapshot", dest)
  expect_true(file.exists(file.path(dest, "template.typ")))
})

test_that("export_template errors clearly for an unknown template", {
  expect_error(
    export_template("does-not-exist", tempfile()), "not a built-in template"
  )
})

test_that("an exported template compiles standalone via compile_typst", {
  skip_if_not(quarto::quarto_available())
  dest <- tempfile()
  on.exit(unlink(dest, recursive = TRUE))
  export_template("cohort_summary", dest, theme = "default")

  source("fixtures/sample_data.R", local = TRUE)
  out_pdf <- file.path(dest, "out.pdf")
  compile_typst(file.path(dest, "template.typ"), sample_data, out_pdf)
  expect_true(file.exists(out_pdf))
})

test_that("export_template refuses to overwrite an exported template", {
  dest <- tempfile()
  on.exit(unlink(dest, recursive = TRUE))
  export_template("cohort_summary", dest)
  cat("// MY EDIT\n", file = file.path(dest, "template.typ"), append = TRUE)
  expect_error(export_template("cohort_summary", dest), "overwrite = TRUE")
  expect_true(any(grepl("MY EDIT", readLines(file.path(dest, "template.typ")))))
})

test_that("export_template(overwrite = TRUE) replaces an edited template", {
  dest <- tempfile()
  on.exit(unlink(dest, recursive = TRUE))
  export_template("cohort_summary", dest)
  cat("// MY EDIT\n", file = file.path(dest, "template.typ"), append = TRUE)
  export_template("cohort_summary", dest, overwrite = TRUE)
  expect_false(any(grepl("MY EDIT", readLines(file.path(dest, "template.typ")))))
})

test_that("export_template accepts a theme_path", {
  dest <- tempfile()
  on.exit(unlink(dest, recursive = TRUE))
  uk <- resolve_theme("uk")
  export_template("cohort_summary", dest, theme_path = uk)
  expect_identical(
    unname(tools::md5sum(file.path(dest, "theme.typ"))), unname(tools::md5sum(uk))
  )
})

test_that("copy_or_stop stops when a copy fails", {
  from <- tempfile()
  writeLines("x", from)
  on.exit(unlink(from))
  expect_error(
    copy_or_stop(from, file.path(tempfile(), "no-such-dir", "x.txt")),
    "Could not copy"
  )
  to <- tempfile()
  dir.create(to)
  on.exit(unlink(to, recursive = TRUE), add = TRUE)
  expect_silent(copy_or_stop(from, to))
})
