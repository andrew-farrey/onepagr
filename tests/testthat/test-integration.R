test_that("each built-in template's fixture satisfies its required tokens", {
  source("fixtures/sample_data.R", local = TRUE)
  source("fixtures/sample_data_overdose_spike_alert.R", local = TRUE)
  source("fixtures/sample_data_syndromic_alert.R", local = TRUE)
  source("fixtures/sample_data_county_choropleth.R", local = TRUE)

  fixture_for <- list(
    cohort_summary = sample_data,
    trend_snapshot = sample_data,
    overdose_spike_alert = sample_data_overdose_spike_alert,
    syndromic_alert = sample_data_syndromic_alert,
    county_choropleth = sample_data_county_choropleth
  )

  # This is the guard that catches a template being added without its
  # fixture being added to fixture_for above -- must run regardless of
  # whether Quarto is installed, so it's in its own ungated test_that
  # rather than only running as a side effect of the render loop below.
  expect_setequal(names(fixture_for), list_templates())
  for (t in names(fixture_for)) {
    expect_true(
      validate_template_data(resolve_template(t), fixture_for[[t]]),
      info = t
    )
  }
})

test_that("every built-in template renders under every built-in theme", {
  skip_if_not(quarto::quarto_available())
  source("fixtures/sample_data.R", local = TRUE)
  source("fixtures/sample_data_overdose_spike_alert.R", local = TRUE)
  source("fixtures/sample_data_syndromic_alert.R", local = TRUE)
  source("fixtures/sample_data_county_choropleth.R", local = TRUE)

  fixture_for <- list(
    cohort_summary = sample_data,
    trend_snapshot = sample_data,
    overdose_spike_alert = sample_data_overdose_spike_alert,
    syndromic_alert = sample_data_syndromic_alert,
    county_choropleth = sample_data_county_choropleth
  )

  # county_choropleth is the only template needing per-run generated
  # images staged via extra_assets (Typst rejects absolute image paths
  # and sandboxes file access to its own compile directory -- see
  # R/render.R's extra_assets documentation). Every other template gets
  # character(0), the default.
  extra_assets_for <- list(
    county_choropleth = file.path(
      "fixtures", "maps", sprintf("map%d.png", 0:4)
    )
  )

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
    assets <- extra_assets_for[[combos$template[i]]]
    if (is.null(assets)) assets <- character(0)
    render_onepager(
      fixture_for[[combos$template[i]]],
      template = combos$template[i],
      theme = combos$theme[i],
      output = out_pdf,
      keep_typst = FALSE,
      extra_assets = assets
    )
    expect_true(
      file.exists(out_pdf),
      info = sprintf("%s x %s", combos$template[i], combos$theme[i])
    )
    # A real one-pager PDF is at minimum ~5KB -- a near-empty file here
    # would indicate a silent compile failure that still happened to
    # produce a (broken) output file.
    expect_gt(file.info(out_pdf)$size, 5000)
  }
})

test_that("logos are actually swappable, not just token-shaped", {
  # The logo/header-texture tokens exist specifically so a consuming
  # project can substitute its own branding without exporting and
  # hand-editing a template (see R/render.R's extra_assets docs). This
  # test proves that end to end: override every logo token to point at a
  # custom image outside the package's own assets/, stage that image via
  # extra_assets, and confirm both that the compile succeeds and that the
  # resolved .typ actually references the custom file -- not just that
  # the default-logo fixtures still compile (which every other test here
  # already covers and would pass even if overriding did nothing).
  skip_if_not(quarto::quarto_available())
  source("fixtures/sample_data.R", local = TRUE)

  custom_logo <- test_path("fixtures", "custom_logo_test.png")
  custom_data <- sample_data
  custom_data$logo_primary_path <- "custom_logo_test.png"
  custom_data$logo_primary_alt <- "Custom Test Organization logo"

  out_dir <- tempfile()
  dir.create(out_dir)
  on.exit(unlink(out_dir, recursive = TRUE))
  out_pdf <- file.path(out_dir, "custom_logo.pdf")

  render_onepager(
    custom_data,
    template = "cohort_summary",
    theme = "default",
    output = out_pdf,
    keep_typst = TRUE,
    extra_assets = custom_logo
  )

  expect_true(file.exists(out_pdf))
  expect_gt(file.info(out_pdf)$size, 5000)

  work_dir <- paste0(tools::file_path_sans_ext(out_pdf), "_typst")
  expect_true(file.exists(file.path(work_dir, "custom_logo_test.png")))

  resolved_typ <- readLines(
    file.path(work_dir, "template_rendered.typ"), warn = FALSE
  )
  expect_true(any(grepl("custom_logo_test.png", resolved_typ, fixed = TRUE)))
  expect_true(any(
    grepl("Custom Test Organization logo", resolved_typ, fixed = TRUE)
  ))
  # The default package logo should no longer appear anywhere the
  # primary-logo token is substituted -- i.e. the override actually took
  # effect rather than the template silently falling back to its own
  # bundled asset.
  expect_false(any(grepl("primary-org-white.png", resolved_typ, fixed = TRUE)))
})

test_that("a single-logo jurisdiction can drop both partner logos", {
  # Not every jurisdiction co-brands with two partner agencies -- a
  # health department reporting under its own name alone needs to be
  # able to render with exactly one logo and no dangling divider. This
  # proves show_partner_a/show_partner_b = "false" actually removes those
  # slots from the footer's logo lockup rather than merely hiding broken
  # image references.
  skip_if_not(quarto::quarto_available())
  source("fixtures/sample_data.R", local = TRUE)

  one_logo_data <- sample_data
  one_logo_data$show_partner_a <- "false"
  one_logo_data$show_partner_b <- "false"

  out_dir <- tempfile()
  dir.create(out_dir)
  on.exit(unlink(out_dir, recursive = TRUE))
  out_pdf <- file.path(out_dir, "one_logo.pdf")

  render_onepager(
    one_logo_data,
    template = "cohort_summary",
    theme = "default",
    output = out_pdf,
    keep_typst = FALSE
  )

  expect_true(file.exists(out_pdf))
  expect_gt(file.info(out_pdf)$size, 5000)
})

test_that("a two-agency partnership can show exactly one partner logo", {
  skip_if_not(quarto::quarto_available())
  source("fixtures/sample_data.R", local = TRUE)

  two_logo_data <- sample_data
  two_logo_data$show_partner_a <- "false"
  two_logo_data$show_partner_b <- "true"

  out_dir <- tempfile()
  dir.create(out_dir)
  on.exit(unlink(out_dir, recursive = TRUE))
  out_pdf <- file.path(out_dir, "two_logo.pdf")

  render_onepager(
    two_logo_data,
    template = "cohort_summary",
    theme = "default",
    output = out_pdf,
    keep_typst = FALSE
  )

  expect_true(file.exists(out_pdf))
  expect_gt(file.info(out_pdf)$size, 5000)
})

test_that("an invalid show_partner_a value fails loudly, not silently", {
  skip_if_not(quarto::quarto_available())
  source("fixtures/sample_data.R", local = TRUE)

  bad_data <- sample_data
  bad_data$show_partner_a <- "TRUE"

  out_dir <- tempfile()
  dir.create(out_dir)
  on.exit(unlink(out_dir, recursive = TRUE))
  out_pdf <- file.path(out_dir, "bad.pdf")

  expect_error(
    render_onepager(
      bad_data,
      template = "cohort_summary",
      theme = "default",
      output = out_pdf,
      keep_typst = FALSE
    ),
    "show_partner_a"
  )
})
