test_that("overdose_spike_alert renders end-to-end", {
  skip_if_not(quarto::quarto_available())
  out_dir <- tempfile()
  dir.create(out_dir)
  on.exit(unlink(out_dir, recursive = TRUE))
  out_pdf <- file.path(out_dir, "alert.pdf")

  source("fixtures/sample_data_overdose_spike_alert.R", local = TRUE)
  render_onepager(
    sample_data_overdose_spike_alert,
    template = "overdose_spike_alert", theme = "uk",
    output = out_pdf, keep_typst = FALSE
  )

  expect_true(file.exists(out_pdf))
  expect_gt(file.info(out_pdf)$size, 5000)
})

test_that("overdose_spike_alert respects show_resources = false", {
  skip_if_not(quarto::quarto_available())
  out_dir <- tempfile()
  dir.create(out_dir)
  on.exit(unlink(out_dir, recursive = TRUE))
  out_pdf <- file.path(out_dir, "alert.pdf")

  source("fixtures/sample_data_overdose_spike_alert.R", local = TRUE)
  data <- sample_data_overdose_spike_alert
  data$show_resources <- "false"
  data$resources_text <- ""
  render_onepager(
    data, template = "overdose_spike_alert", theme = "default",
    output = out_pdf, keep_typst = FALSE
  )

  expect_true(file.exists(out_pdf))
})
