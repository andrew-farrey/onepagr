test_that("county_choropleth renders end-to-end with extra_assets", {
  skip_if_not(quarto::quarto_available())
  out_dir <- tempfile()
  dir.create(out_dir)
  on.exit(unlink(out_dir, recursive = TRUE))
  out_pdf <- file.path(out_dir, "choropleth.pdf")

  source("fixtures/sample_data_county_choropleth.R", local = TRUE)
  maps <- file.path("fixtures", "maps", sprintf("map%d.png", 0:4))
  render_onepager(
    sample_data_county_choropleth,
    template = "county_choropleth", theme = "uk",
    output = out_pdf, keep_typst = FALSE,
    extra_assets = maps
  )

  expect_true(file.exists(out_pdf))
  expect_gt(file.info(out_pdf)$size, 5000)
})

test_that("county_choropleth errors clearly on a missing extra_assets file", {
  source("fixtures/sample_data_county_choropleth.R", local = TRUE)
  out_pdf <- tempfile(fileext = ".pdf")
  expect_error(
    render_onepager(
      sample_data_county_choropleth,
      template = "county_choropleth", theme = "uk",
      output = out_pdf, keep_typst = FALSE,
      extra_assets = "fixtures/maps/does-not-exist.png"
    ),
    "extra_assets file"
  )
})
