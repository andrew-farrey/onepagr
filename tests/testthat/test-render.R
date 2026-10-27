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

test_that("a data error does not create the output folder", {
  out_pdf <- file.path(tempfile("never-made"), "deeper", "report.pdf")
  expect_error(
    render_onepager(list(), "cohort_summary", output = out_pdf),
    "Missing or NA required token"
  )
  expect_false(dir.exists(dirname(out_pdf)))
  expect_false(dir.exists(dirname(dirname(out_pdf))))
})

test_that("a data error leaves the previous render's work folder intact", {
  skip_if_no_onepagr_typst()
  out_dir <- tempfile()
  dir.create(out_dir)
  on.exit(unlink(out_dir, recursive = TRUE), add = TRUE)
  out_pdf <- file.path(out_dir, "report.pdf")
  data <- example_data("cohort_summary")
  render_onepager(data, "cohort_summary", output = out_pdf)
  work <- file.path(out_dir, "report_typst")
  before <- sort(list.files(work, recursive = TRUE))
  expect_true("template_rendered.typ" %in% before)

  data$doc_title <- NULL
  expect_error(
    render_onepager(data, "cohort_summary", output = out_pdf),
    "Missing or NA required token"
  )
  expect_identical(sort(list.files(work, recursive = TRUE)), before)
  expect_true(file.exists(out_pdf))
})

test_that("a bracket error is reported before any folder is touched", {
  out_pdf <- file.path(tempfile("never-made"), "report.pdf")
  data <- example_data("cohort_summary")
  data$doc_subtitle <- "Counts rose (see note 1]"
  expect_error(
    render_onepager(data, "cohort_summary", output = out_pdf), "unbalanced"
  )
  expect_false(dir.exists(dirname(out_pdf)))
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
  skip_if_no_onepagr_typst()
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
  skip_if_no_onepagr_typst()
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
  skip_if_no_onepagr_typst()
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

test_that("note_page_count stays silent when the PDF cannot be read", {
  skip_if_not_installed("pdftools")
  typ <- tempfile(fileext = ".typ")
  writeLines("// designed-pages: 2", typ)
  on.exit(unlink(typ))
  testthat::local_mocked_bindings(
    pdf_info = function(...) stop("unreadable"), .package = "pdftools"
  )
  expect_no_message(note_page_count(typ, "unused.pdf", "cohort_summary"))
  expect_no_error(note_page_count(typ, "unused.pdf", "cohort_summary"))
})

render_to_tmp <- function(...) {
  out <- tempfile(fileext = ".pdf")
  render_onepager(
    example_data("overdose_spike_alert"), "overdose_spike_alert",
    output = out, ...
  )
}

test_that("an extra asset may not replace a package file", {
  dir <- tempfile()
  dir.create(dir)
  on.exit(unlink(dir, recursive = TRUE))
  for (reserved in c("theme.typ", "components.typ", "template.typ")) {
    fake <- file.path(dir, reserved)
    writeLines("x", fake)
    expect_error(render_to_tmp(extra_assets = fake), reserved, fixed = TRUE)
  }
})

test_that("two extra assets may not share a file name", {
  a <- file.path(tempfile(), "x.png")
  b <- file.path(tempfile(), "x.png")
  for (f in c(a, b)) {
    dir.create(dirname(f))
    writeLines("x", f)
  }
  on.exit(unlink(c(dirname(a), dirname(b)), recursive = TRUE))
  expect_error(render_to_tmp(extra_assets = c(a, b)), "share the file name")
})

test_that("a missing extra asset is reported before anything is staged", {
  out <- tempfile(fileext = ".pdf")
  expect_error(
    render_onepager(
      example_data("overdose_spike_alert"), "overdose_spike_alert",
      output = out, extra_assets = "no-such-file.png"
    ),
    "not found"
  )
  expect_false(dir.exists(sub(".pdf", "_typst", out, fixed = TRUE)))
})

test_that("an unrelated folder at the work-folder path is not deleted", {
  out <- tempfile(fileext = ".pdf")
  work <- sub(".pdf", "_typst", out, fixed = TRUE)
  dir.create(work)
  writeLines("keep me", file.path(work, "notes.txt"))
  on.exit(unlink(work, recursive = TRUE))
  expect_error(
    render_onepager(
      example_data("overdose_spike_alert"), "overdose_spike_alert", output = out
    ),
    "not an onepagr work"
  )
  expect_true(file.exists(file.path(work, "notes.txt")))
})

test_that("a re-render replaces the previous work folder", {
  skip_if_no_onepagr_typst()
  out <- tempfile(fileext = ".pdf")
  work <- sub(".pdf", "_typst", out, fixed = TRUE)
  on.exit(unlink(c(out, work), recursive = TRUE))
  data <- example_data("overdose_spike_alert")
  render_onepager(data, "overdose_spike_alert", output = out)
  writeLines("stale", file.path(work, "stale.txt"))
  render_onepager(data, "overdose_spike_alert", output = out)
  expect_false(file.exists(file.path(work, "stale.txt")))
  expect_true(file.exists(file.path(work, "template_rendered.typ")))
})

test_that("every template takes an optional doc_lang that defaults to English", {
  for (t in list_templates()) {
    tokens <- template_tokens(t)
    expect_equal(tokens$default[tokens$token == "doc_lang"], "en", info = t)
  }
})

test_that("doc_lang reaches the Typst document language", {
  dest <- tempfile()
  export_template("overdose_spike_alert", dest)
  on.exit(unlink(dest, recursive = TRUE))
  path <- file.path(dest, "template.typ")
  data <- utils::modifyList(
    example_data("overdose_spike_alert"), list(doc_lang = "es")
  )
  out <- write_rendered_typ(path, fill_token_defaults(path, data))
  expect_true(any(grepl("lang: \"es\"", readLines(out, warn = FALSE), fixed = TRUE)))
})

test_that("a Spanish document compiles", {
  skip_if_no_onepagr_typst()
  out <- tempfile(fileext = ".pdf")
  on.exit(unlink(c(out, sub(".pdf", "_typst", out, fixed = TRUE)), recursive = TRUE))
  data <- utils::modifyList(
    example_data("overdose_spike_alert"), list(doc_lang = "es")
  )
  render_onepager(data, "overdose_spike_alert", output = out)
  expect_true(file.exists(out))
})

test_that("an exported template at the work-folder path is not deleted", {
  out <- tempfile(fileext = ".pdf")
  work <- sub(".pdf", "_typst", out, fixed = TRUE)
  # An export_template() copy holds components.typ and theme.typ, just as a
  # work folder does, but it is the user's own and may carry edits.
  export_template("overdose_spike_alert", work)
  writeLines("// my notes", file.path(work, "notes.typ"))
  on.exit(unlink(work, recursive = TRUE))
  expect_error(
    render_onepager(
      example_data("overdose_spike_alert"), "overdose_spike_alert", output = out
    ),
    "not an onepagr work"
  )
  expect_true(file.exists(file.path(work, "notes.typ")))
})
