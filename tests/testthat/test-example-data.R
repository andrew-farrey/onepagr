test_that("example_data returns a working list for every built-in template", {
  for (t in list_templates()) {
    expect_true(
      validate_template_data(resolve_template(t), example_data(t)),
      info = t
    )
  }
})

test_that("example_data is shared between cohort_summary and trend_snapshot", {
  expect_identical(
    example_data("cohort_summary"), example_data("trend_snapshot")
  )
})

test_that("example_data errors clearly on an unknown template", {
  expect_error(example_data("no_such_template"), "not a built-in template")
})

test_that("template_data defaults to every token, required and optional", {
  for (t in list_templates()) {
    info <- template_tokens(t)
    data <- template_data(t)
    expect_setequal(names(data), info$token)
    expect_setequal(attr(data, "required"), info$token[info$required])
  }
})

test_that("template_data with tokens = \"required\" returns only those", {
  info <- template_tokens("cohort_summary")
  data <- template_data("cohort_summary", "required")
  required_names <- info$token[info$required]
  expect_setequal(names(data), required_names)
  expect_setequal(attr(data, "required"), required_names)
  # Values come from the same example a user would otherwise have to
  # read out of a test fixture or the vignette by hand.
  expect_equal(data$n_decedents, example_data("cohort_summary")$n_decedents)
})

test_that("template_data with tokens = \"optional\" returns those at default", {
  info <- template_tokens("cohort_summary")
  data <- template_data("cohort_summary", "optional")
  optional_names <- info$token[!info$required]
  expect_setequal(names(data), optional_names)
  expect_length(attr(data, "required"), 0)
  expect_equal(
    data$heading_disclaimer,
    info$default[info$token == "heading_disclaimer"]
  )
})

test_that("template_data rejects an unrecognized tokens argument", {
  expect_error(
    template_data("cohort_summary", "everything"), "should be one of"
  )
})

test_that("template_data alone is enough to render every built-in template", {
  skip_if_not(quarto::quarto_available())
  out_dir <- tempfile()
  dir.create(out_dir)
  on.exit(unlink(out_dir, recursive = TRUE))

  extra_assets_for <- list(
    county_choropleth = file.path(
      "fixtures", "maps", sprintf("map%d.png", 0:4)
    )
  )

  for (t in list_templates()) {
    out_pdf <- file.path(out_dir, paste0(t, ".pdf"))
    assets <- extra_assets_for[[t]]
    if (is.null(assets)) assets <- character(0)
    render_onepager(
      template_data(t), template = t, theme = "default", output = out_pdf,
      keep_typst = FALSE, extra_assets = assets
    )
    expect_true(file.exists(out_pdf), info = t)
    expect_gt(file.info(out_pdf)$size, 5000, label = t)
  }
})
