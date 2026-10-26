write_typ <- function(lines, env = parent.frame()) {
  path <- tempfile(fileext = ".typ")
  writeLines(lines, path)
  withr::defer(unlink(path), envir = env)
  path
}

test_that("typst_escape_string escapes backslashes, quotes and newlines", {
  expect_identical(typst_escape_string("a \"b\" \\c"), "a \\\"b\\\" \\\\c")
  expect_identical(typst_escape_string("one\ntwo"), "one\\ntwo")
  expect_identical(typst_escape_string("plain"), "plain")
})

test_that("typst_escape makes plain text safe in a content token", {
  expect_identical(
    typst_escape("cost: $5 #1 @x [a]"), "cost: \\$5 \\#1 \\@x \\[a\\]"
  )
  expect_identical(
    typst_escape("a*b_c`d<e>f~g\\h"), "a\\*b\\_c\\`d\\<e\\>f\\~g\\\\h"
  )
  expect_identical(typst_escape(c("a", NA)), c("a", NA))
})

test_that("typst_escape escapes a slash so // cannot start a comment", {
  expect_identical(
    typst_escape("Rates rose 5% // provisional"),
    "Rates rose 5% \\/\\/ provisional"
  )
  expect_identical(typst_escape("a/b and /* c"), "a\\/b and \\/\\* c")
  expect_identical(typst_escape("https://x.org/a"), "https:\\/\\/x.org\\/a")
})

test_that("plain text with // renders in full once escaped", {
  skip_if_no_onepagr_typst()
  skip_if_not_installed("pdftools")
  path <- write_typ(c("#set document(title: [T])", "A: {{{note}}} END-A"))
  out <- tempfile(fileext = ".pdf")
  on.exit(unlink(out), add = TRUE)
  compile_typst(
    path,
    list(note = typst_escape("Rates rose 5% // provisional, see https://x.org")),
    out
  )
  text <- gsub("\\s+", " ", paste(pdftools::pdf_text(out), collapse = " "))
  expect_match(text, "Rates rose 5% // provisional, see https://x.org END-A",
               fixed = TRUE)
})

test_that("a string-context token is escaped and a content token is not", {
  path <- write_typ(
    c("#let f(a) = a", "#f(\"{{{s}}}\")", "[{{{c}}}]", "\"{{{both}}}\" {{{both}}}")
  )
  out <- write_rendered_typ(path, list(s = "a\"b\\c", c = "*bold*", both = "q\"z"))
  rendered <- readLines(out, warn = FALSE)
  on.exit(unlink(out), add = TRUE)
  expect_identical(rendered[2], "#f(\"a\\\"b\\\\c\")")
  expect_identical(rendered[3], "[*bold*]")
  expect_identical(rendered[4], "\"q\\\"z\" q\"z")
})

test_that("an unbalanced bracket in a content token is reported in R", {
  path <- write_typ(c("#set document(title: [T])", "#text[{{{narrative_text}}}]"))
  expect_error(
    compile_typst(path, list(narrative_text = "Counts rose (see note 1]"),
                  tempfile(fileext = ".pdf")),
    "narrative_text.*unbalanced|unbalanced.*narrative_text"
  )
})

test_that("balanced, escaped, and string-context brackets are accepted", {
  content <- write_typ("#text[{{{c}}}]")
  expect_silent(check_bracket_balance(template_spec(content), list(c = "see [1]")))
  expect_silent(
    check_bracket_balance(template_spec(content), list(c = "a literal \\] here"))
  )
  expect_silent(
    check_bracket_balance(
      template_spec(content), list(c = "#link(\"x\")[a] and ( \"[\" )")
    )
  )
  in_string <- write_typ(c("#let f(a) = a", "#f(\"{{{s}}}\")"))
  expect_silent(check_bracket_balance(template_spec(in_string), list(s = "a]b")))
})

test_that("a quote or backslash in header and alt text renders", {
  skip_if_no_onepagr_typst()
  skip_if_not_installed("pdftools")
  data <- example_data("overdose_spike_alert")
  data$org_full <- "Sample \"North\" Health Department"
  data$logo_primary_alt <- "The \"Safe\" logo, C:\\logos"
  out <- tempfile(fileext = ".pdf")
  on.exit(unlink(c(out, sub("\\.pdf$", "_typst", out)), recursive = TRUE))
  expect_silent(render_onepager(data, "overdose_spike_alert", output = out))
  text <- paste(pdftools::pdf_text(out), collapse = "\n")
  # In body text Typst turns straight quotes into typographic ones.
  expect_match(text, "Sample .North. Health Department")
})

test_that("values pre-escaped for markup render exactly as before", {
  skip_if_no_onepagr_typst()
  skip_if_not_installed("pdftools")
  data <- example_data("overdose_spike_alert")
  data$footnote_sources <- "Source: Sample System\\*"
  data$narrative_text <- "Funding totals \\$5,769,396 in awards, see \\@desk for \\*details\\*."
  out <- tempfile(fileext = ".pdf")
  on.exit(unlink(c(out, sub("\\.pdf$", "_typst", out)), recursive = TRUE))
  render_onepager(data, "overdose_spike_alert", output = out)
  text <- paste(pdftools::pdf_text(out), collapse = "\n")
  # Captured from the 0.1.1 release build before escaping changed.
  expect_true(grepl("Funding totals $5,769,396 in awards", text, fixed = TRUE))
  expect_true(grepl("Source: Sample System*", text, fixed = TRUE))
  expect_true(grepl("@desk", text, fixed = TRUE))
  expect_true(grepl("details", text, fixed = TRUE))
  expect_false(grepl("\\", text, fixed = TRUE))
})
