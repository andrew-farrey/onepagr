test_that("fmt_n formats integers with comma grouping", {
  expect_equal(fmt_n(5267), "5,267")
  expect_equal(fmt_n(120), "120")
  expect_equal(fmt_n(24906), "24,906")
})

test_that("fmt_pct formats percentages with default 0 digits", {
  expect_equal(fmt_pct(84), "84%")
  expect_equal(fmt_pct(6), "6%")
})

test_that("fmt_pct respects the digits argument", {
  expect_equal(fmt_pct(70.2, digits = 1), "70.2%")
  expect_equal(fmt_pct(29.83, digits = 1), "29.8%")
})
