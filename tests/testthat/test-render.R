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

test_that("render_onepager creates a nested output dir that doesn't exist", {
  skip_if_not(quarto::quarto_available())
  out_dir <- tempfile()
  on.exit(unlink(out_dir, recursive = TRUE))
  # Deliberately do NOT pre-create out_dir (or its parent "nested"
  # subdirectory) -- every other render_onepager test here pre-creates
  # its output directory, which meant render_onepager()'s own
  # `dir.create(dirname(output), recursive = TRUE)` fallback never
  # actually ran under test.
  out_pdf <- file.path(out_dir, "nested", "report.pdf")

  source("fixtures/sample_data.R", local = TRUE)
  render_onepager(
    sample_data, template = "cohort_summary", theme = "default",
    output = out_pdf, keep_typst = FALSE
  )

  expect_true(file.exists(out_pdf))
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

test_that("extract_designed_pages reads the marker and returns NA without one", {
  with_marker <- tempfile(fileext = ".typ")
  writeLines(c("// header", "// designed-pages: 2", "#text[x]"), with_marker)
  without_marker <- tempfile(fileext = ".typ")
  writeLines("#text[x]", without_marker)
  on.exit(unlink(c(with_marker, without_marker)))
  expect_identical(extract_designed_pages(with_marker), 2L)
  expect_identical(extract_designed_pages(without_marker), NA_integer_)
})

test_that("the three fixed templates declare 2 designed pages, the alerts none", {
  designed <- vapply(
    list_templates(),
    function(t) extract_designed_pages(resolve_template(t)),
    integer(1)
  )
  expect_equal(
    designed[c("cohort_summary", "trend_snapshot", "county_choropleth")],
    c(cohort_summary = 2L, trend_snapshot = 2L, county_choropleth = 2L)
  )
  expect_true(all(is.na(designed[c("overdose_spike_alert", "syndromic_alert")])))
})

test_that("note_page_count messages only when the page count differs", {
  skip_if_not_installed("pdftools")
  typ <- tempfile(fileext = ".typ")
  writeLines("// designed-pages: 2", typ)
  on.exit(unlink(typ))

  testthat::local_mocked_bindings(
    pdf_info = function(...) list(pages = 3L), .package = "pdftools"
  )
  expect_message(
    note_page_count(typ, "unused.pdf", "cohort_summary"),
    "cohort_summary is designed for 2 pages; this render produced 3"
  )

  testthat::local_mocked_bindings(
    pdf_info = function(...) list(pages = 1L), .package = "pdftools"
  )
  expect_message(
    note_page_count(typ, "unused.pdf", "cohort_summary"),
    "cohort_summary is designed for 2 pages; this render produced 1"
  )

  testthat::local_mocked_bindings(
    pdf_info = function(...) list(pages = 2L), .package = "pdftools"
  )
  expect_no_message(note_page_count(typ, "unused.pdf", "cohort_summary"))
})

test_that("note_page_count is silent without a marker or without pdftools", {
  no_marker <- tempfile(fileext = ".typ")
  writeLines("#text[x]", no_marker)
  marker <- tempfile(fileext = ".typ")
  writeLines("// designed-pages: 2", marker)
  on.exit(unlink(c(no_marker, marker)))

  expect_no_message(note_page_count(no_marker, "unused.pdf", "alert"))

  testthat::local_mocked_bindings(pdftools_available = function() FALSE)
  expect_no_message(note_page_count(marker, "unused.pdf", "cohort_summary"))
})
