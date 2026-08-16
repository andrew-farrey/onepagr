test_that("syndromic_alert renders end-to-end", {
  skip_if_not(quarto::quarto_available())
  out_dir <- tempfile()
  dir.create(out_dir)
  on.exit(unlink(out_dir, recursive = TRUE))
  out_pdf <- file.path(out_dir, "alert.pdf")

  source("fixtures/sample_data_syndromic_alert.R", local = TRUE)
  render_onepager(
    sample_data_syndromic_alert,
    template = "syndromic_alert", theme = "default",
    output = out_pdf, keep_typst = FALSE
  )

  expect_true(file.exists(out_pdf))
  expect_gt(file.info(out_pdf)$size, 5000)
})

test_that("syndromic_alert respects show_cluster = true", {
  skip_if_not(quarto::quarto_available())
  out_dir <- tempfile()
  dir.create(out_dir)
  on.exit(unlink(out_dir, recursive = TRUE))
  out_pdf <- file.path(out_dir, "alert.pdf")

  source("fixtures/sample_data_syndromic_alert.R", local = TRUE)
  data <- sample_data_syndromic_alert
  data$show_cluster <- "true"
  data$cluster_text <- paste(
    "SaTScan spatial scan statistic: relative risk 2.4,",
    "p = 0.01, radius 8.2 km, centered on Sample General Hospital."
  )
  render_onepager(
    data, template = "syndromic_alert", theme = "uk",
    output = out_pdf, keep_typst = FALSE
  )

  expect_true(file.exists(out_pdf))
})
