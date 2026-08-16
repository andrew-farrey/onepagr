test_that("every built-in template renders under every built-in theme", {
  skip_if_not(quarto::quarto_available())
  source("fixtures/sample_data.R", local = TRUE)
  source("fixtures/sample_data_overdose_spike_alert.R", local = TRUE)
  source("fixtures/sample_data_syndromic_alert.R", local = TRUE)

  fixture_for <- list(
    cohort_summary = sample_data,
    trend_snapshot = sample_data,
    overdose_spike_alert = sample_data_overdose_spike_alert,
    syndromic_alert = sample_data_syndromic_alert
  )

  expect_setequal(names(fixture_for), list_templates())

  out_dir <- tempfile()
  dir.create(out_dir)
  on.exit(unlink(out_dir, recursive = TRUE))

  combos <- expand.grid(
    template = list_templates(),
    theme = list_themes(),
    stringsAsFactors = FALSE
  )

  for (i in seq_len(nrow(combos))) {
    out_pdf <- file.path(
      out_dir, sprintf("%s_%s.pdf", combos$template[i], combos$theme[i])
    )
    render_onepager(
      fixture_for[[combos$template[i]]],
      template = combos$template[i],
      theme = combos$theme[i],
      output = out_pdf,
      keep_typst = FALSE
    )
    expect_true(
      file.exists(out_pdf),
      info = sprintf("%s x %s", combos$template[i], combos$theme[i])
    )
    # A real one-pager PDF is at minimum tens of KB -- a near-empty file
    # here would indicate a silent compile failure that still happened
    # to produce a (broken) output file.
    expect_gt(file.info(out_pdf)$size, 5000)
  }
})
