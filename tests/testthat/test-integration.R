test_that("every built-in template renders under every built-in theme", {
  skip_if_not(quarto::quarto_available())
  source("fixtures/sample_data.R", local = TRUE)

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
      sample_data,
      template = combos$template[i],
      theme = combos$theme[i],
      output = out_pdf,
      keep_typst = FALSE
    )
    expect_true(
      file.exists(out_pdf),
      info = sprintf("%s x %s", combos$template[i], combos$theme[i])
    )
    # A real 2-page one-pager PDF is at minimum tens of KB -- a
    # near-empty file here would indicate a silent compile failure that
    # still happened to produce a (broken) output file.
    expect_gt(file.info(out_pdf)$size, 10000)
  }
})
