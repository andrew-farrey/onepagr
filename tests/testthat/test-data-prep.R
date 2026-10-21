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
  skip_if_not(quarto::quarto_available())
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
