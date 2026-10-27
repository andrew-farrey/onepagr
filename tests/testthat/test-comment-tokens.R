test_that("a token in a // comment never receives the raw value", {
  path <- write_typ(c(
    "#let a = \"{{{s}}}\"",
    "// The value, {{{s}}}, is escaped above.",
    "#a"
  ))
  out <- write_rendered_typ(path, list(s = "one\n#text(red)[STRAY]"))
  on.exit(unlink(out), add = TRUE)
  rendered <- readLines(out, warn = FALSE)
  expect_false(any(grepl("^#text\\(red\\)", rendered)))
  expect_identical(rendered[1], "#let a = \"one\\n#text(red)[STRAY]\"")
  expect_match(rendered[2], "^// The value, ")
})

test_that("a double-brace tag in a comment does not receive a value", {
  path <- write_typ(c(
    "// Never write {{contact}} here; use the triple form.",
    "#let c = \"{{{contact}}}\"",
    "#text(c)"
  ))
  out <- write_rendered_typ(path, list(contact = "a@b.org\n#text[STRAY]"))
  on.exit(unlink(out), add = TRUE)
  rendered <- readLines(out, warn = FALSE)
  expect_false(any(grepl("^#text\\[STRAY\\]", rendered)))
  expect_length(rendered, 3L)
  expect_match(rendered[1], "^// Never write ")
  expect_false(grepl("{{", rendered[1], fixed = TRUE))
})

test_that("a section tag or an unclosed brace in a comment stays inert", {
  path <- write_typ(c(
    "// {{#flag}}hidden{{/flag}} and an unclosed {{{ brace, and {{{ three }}}",
    "#text[{{{note}}}]"
  ))
  out <- write_rendered_typ(path, list(note = "n", flag = "yes"))
  on.exit(unlink(out), add = TRUE)
  rendered <- readLines(out, warn = FALSE)
  expect_length(rendered, 2L)
  # Nothing in the comment is left for whisker to read as a tag, and the
  # section it would have evaluated is still there as plain text.
  expect_false(grepl("{{", rendered[1], fixed = TRUE))
  expect_match(rendered[1], "#flag", fixed = TRUE)
  expect_match(rendered[1], "hidden", fixed = TRUE)
  expect_identical(rendered[2], "#text[n]")
})

test_that("a token after code on the same line is still filled", {
  path <- write_typ("#let a = \"{{{s}}}\" // see {{{s}}}")
  out <- write_rendered_typ(path, list(s = "x\ny"))
  on.exit(unlink(out), add = TRUE)
  rendered <- readLines(out, warn = FALSE)
  expect_length(rendered, 1L)
  expect_match(rendered, "^#let a = \"x\\\\ny\" //")
})

test_that("an optional-token comment line never receives a value", {
  path <- write_typ(c(
    "// optional-token: heading = Results (N = {{{n}}})",
    "#text[{{{heading}}}]"
  ))
  data <- fill_token_defaults(path, list(n = "5\nsecond line"))
  out <- write_rendered_typ(path, data)
  on.exit(unlink(out), add = TRUE)
  rendered <- readLines(out, warn = FALSE)
  # The declaration stays one comment line, naming the token, with no value.
  expect_identical(
    rendered[1], "// optional-token: heading = Results (N = <n>)"
  )
  expect_match(rendered[2], "^#text\\[Results \\(N = 5$")
})

test_that("a newline in a string value does not add a page", {
  skip_if_no_onepagr_typst()
  skip_if_not_installed("pdftools")
  data <- example_data("cohort_summary")
  data$contact_email <- "contact@example.org\n(urgent: call)"
  out <- tempfile(fileext = ".pdf")
  on.exit(unlink(out), add = TRUE)
  render_onepager(data, "cohort_summary", output = out, keep_typst = FALSE)
  expect_identical(pdftools::pdf_info(out)$pages, 2L)
  expect_false(grepl("urgent: call directly", pdftools::pdf_text(out)[1]))
})

test_that("a newline in an alt text does not leak into trend_snapshot", {
  skip_if_no_onepagr_typst()
  skip_if_not_installed("pdftools")
  data <- example_data("trend_snapshot")
  data$logo_primary_alt <- "Sample Health Department\nlogo"
  out <- tempfile(fileext = ".pdf")
  on.exit(unlink(out), add = TRUE)
  render_onepager(data, "trend_snapshot", output = out, keep_typst = FALSE)
  expect_identical(pdftools::pdf_info(out)$pages, 2L)
})
