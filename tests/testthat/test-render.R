test_that("render_onepager raises the missing-token error without Quarto", {
  out_pdf <- tempfile(fileext = ".pdf")
  expect_error(
    render_onepager(
      data = list(),
      template = "cohort_summary",
      output = out_pdf
    ),
    "Missing or NA required token"
  )
  expect_false(file.exists(out_pdf))
})

test_that("render_onepager errors clearly for an unknown template", {
  out_pdf <- tempfile(fileext = ".pdf")
  expect_error(
    render_onepager(
      data = list(), template = "does-not-exist", output = out_pdf
    ),
    "not a built-in template"
  )
})

test_that("render_onepager keep_typst = TRUE leaves a tree next to the PDF", {
  skip_if_not(quarto::quarto_available())
  out_dir <- tempfile()
  dir.create(out_dir)
  on.exit(unlink(out_dir, recursive = TRUE))
  out_pdf <- file.path(out_dir, "report.pdf")

  source("fixtures/sample_data.R", local = TRUE)
  render_onepager(
    sample_data, template = "cohort_summary", theme = "uk", output = out_pdf
  )

  expect_true(file.exists(out_pdf))
  typst_dir <- file.path(out_dir, "report_typst")
  expect_true(dir.exists(typst_dir))
  expect_true(file.exists(file.path(typst_dir, "theme.typ")))
  expect_true(file.exists(file.path(typst_dir, "components.typ")))
  expect_true(dir.exists(file.path(typst_dir, "assets")))
})

test_that("render_onepager keep_typst = FALSE leaves only the PDF", {
  skip_if_not(quarto::quarto_available())
  out_dir <- tempfile()
  dir.create(out_dir)
  on.exit(unlink(out_dir, recursive = TRUE))
  out_pdf <- file.path(out_dir, "report.pdf")

  source("fixtures/sample_data.R", local = TRUE)
  render_onepager(
    sample_data, template = "trend_snapshot", theme = "default",
    output = out_pdf, keep_typst = FALSE
  )

  expect_true(file.exists(out_pdf))
  expect_false(dir.exists(file.path(out_dir, "report_typst")))
})
