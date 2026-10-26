test_that("errors name a built-in template, not template.typ", {
  expect_error(
    validate_template_data(resolve_template("cohort_summary"), list()),
    "cohort_summary"
  )
  expect_error(
    validate_template_data(resolve_template("syndromic_alert"), list()),
    "syndromic_alert"
  )
})

test_that("errors for a file that is not a built-in keep the file name", {
  path <- write_typ("#text[{{{needed}}}]")
  expect_error(
    validate_template_data(path, list()), basename(path), fixed = TRUE
  )
})

test_that("whole numbers are formatted without scientific notation", {
  expect_identical(coerce_data_values(list(n = 100000))$n, "100000")
  expect_identical(coerce_data_values(list(n = 14L))$n, "14")
  expect_identical(coerce_data_values(list(n = 2500000))$n, "2500000")
  expect_identical(coerce_data_values(list(n = -3))$n, "-3")
})

test_that("short decimals are kept as written", {
  expect_identical(coerce_data_values(list(s = 1.1))$s, "1.1")
  expect_identical(coerce_data_values(list(s = 0.5))$s, "0.5")
})

test_that("a long decimal is rejected with a pointer to the formatters", {
  expect_error(coerce_data_values(list(rate = 1 / 3)), "rate")
  expect_error(coerce_data_values(list(rate = 1 / 3)), "fmt_pct")
  expect_error(coerce_data_values(list(rate = 0.1 + 0.2)), "fmt_n")
})

test_that("an R logical is rejected with the accepted spelling", {
  expect_error(coerce_data_values(list(show_x = TRUE)), "show_x")
  expect_error(coerce_data_values(list(show_x = TRUE)), "\"true\"")
})

test_that("a vector longer than one is rejected", {
  expect_error(coerce_data_values(list(x = c("a", "b", "c"))), "length 3")
  expect_error(coerce_data_values(list(x = 1:2)), "length 2")
})

test_that("an empty value passes through to the missing-value logic", {
  expect_identical(coerce_data_values(list(x = character(0)))$x, character(0))
})

test_that("strings, NA and NULL pass through; factors and dates become text", {
  out <- coerce_data_values(list(a = "x", b = NA, c = NULL, d = factor("lvl")))
  expect_identical(out$a, "x")
  expect_identical(out$b, NA)
  expect_identical(out$d, "lvl")
  expect_identical(
    coerce_data_values(list(when = as.Date("2026-10-21")))$when, "2026-10-21"
  )
})

test_that("an unsupported type is rejected naming the token", {
  expect_error(coerce_data_values(list(f = function(x) x)), "\"f\"")
  expect_error(coerce_data_values(list(l = list(1))), "\"l\"")
  expect_error(coerce_data_values(list(n = Inf)), "\"n\"")
})

test_that("compile_typst formats a numeric value without scientific notation", {
  skip_if_no_onepagr_typst()
  skip_if_not_installed("pdftools")
  data <- example_data("overdose_spike_alert")
  data$n_events <- 100000
  out <- tempfile(fileext = ".pdf")
  on.exit(unlink(c(out, sub("\\.pdf$", "_typst", out)), recursive = TRUE))
  render_onepager(data, "overdose_spike_alert", output = out)
  text <- paste(pdftools::pdf_text(out), collapse = "\n")
  expect_true(grepl("100000", text, fixed = TRUE))
  expect_false(grepl("1e+05", text, fixed = TRUE))
})

write_width_template <- function(env = parent.frame()) {
  path <- tempfile(fileext = ".typ")
  writeLines("#bar-row(theme, [x], {{{pct_x_width}}}, [n])", path)
  withr::defer(unlink(path), envir = env)
  path
}

test_that("a bar width token must be a plain number from 0 to 100", {
  spec <- template_spec(write_width_template())
  for (bad in c("140", "-1", "64,6", "65%", "", "abc", "1e2")) {
    expect_error(
      check_template_data(spec, list(pct_x_width = bad)), "pct_x_width",
      info = bad
    )
  }
  for (ok in c("0", "100", "64.6", "7")) {
    expect_true(check_template_data(spec, list(pct_x_width = ok)), info = ok)
  }
})

test_that("a width token used inside a string is not a bar width", {
  path <- tempfile(fileext = ".typ")
  writeLines("#image(\"a.png\", width: \"{{{logo_width}}}\")", path)
  on.exit(unlink(path))
  expect_true(check_template_data(template_spec(path), list(logo_width = "32pt")))
})

test_that("the shipped example data passes the width rule", {
  for (t in c("cohort_summary", "trend_snapshot")) {
    expect_true(validate_template_data(resolve_template(t), example_data(t)))
  }
})

test_that("bar-pct clamps a bar width to the track", {
  skip_if_no_typst_eval()
  dest <- tempfile()
  export_template("cohort_summary", dest)
  on.exit(unlink(dest, recursive = TRUE))
  eval_typst <- function(expr) {
    out <- system2(
      quarto::quarto_path(),
      c("typst", "eval", shQuote(expr), "--format", "json", "--root", shQuote(dest)),
      stdout = TRUE, stderr = TRUE
    )
    jsonlite::fromJSON(paste(out, collapse = ""))
  }
  expect_equal(eval_typst("{import \"/components.typ\": bar-pct; bar-pct(140)}"), 100)
  expect_equal(eval_typst("{import \"/components.typ\": bar-pct; bar-pct(-5)}"), 0)
  expect_equal(eval_typst("{import \"/components.typ\": bar-pct; bar-pct(64.6)}"), 64.6)
})
