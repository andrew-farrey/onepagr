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

test_that("county_choropleth stays at exactly 2 pages", {
  # This template's whole point is a front-and-back one-pager -- a silent
  # regression here previously went undetected because no test actually
  # checked the page count: adding the WHAT SVI MEASURES section pushed
  # the front page's content past one page with zero error or warning
  # from render_onepager(), just an unwanted third page in the output.
  skip_if_not(quarto::quarto_available())
  skip_if_not(requireNamespace("pdftools", quietly = TRUE))
  out_pdf <- tempfile(fileext = ".pdf")
  source("fixtures/sample_data_county_choropleth.R", local = TRUE)
  maps <- file.path("fixtures", "maps", sprintf("map%d.png", 0:4))
  render_onepager(
    sample_data_county_choropleth,
    template = "county_choropleth", theme = "default",
    output = out_pdf, keep_typst = FALSE,
    extra_assets = maps
  )
  expect_equal(pdftools::pdf_info(out_pdf)$pages, 2)
})

test_that("county_choropleth stays at 2 pages with an unusual aspect ratio", {
  # The headline map and the 4 component maps are all sized from the
  # source image's own aspect ratio -- capped at a fixed height with
  # fit: "contain" specifically so a jurisdiction whose map export isn't
  # the wide, short shape a real Kentucky county map happens to have
  # doesn't silently blow the page budget. This uses a deliberately
  # extreme tall/narrow (1:2) placeholder to prove that cap actually
  # holds, not just that today's roughly-square test fixtures happen to
  # fit.
  skip_if_not(quarto::quarto_available())
  skip_if_not(requireNamespace("pdftools", quietly = TRUE))
  map_dir <- tempfile()
  dir.create(map_dir)
  on.exit(unlink(map_dir, recursive = TRUE))
  tall_maps <- file.path(map_dir, sprintf("map%d.png", 0:4))
  for (f in tall_maps) {
    grDevices::png(f, width = 300, height = 600)
    graphics::plot.new()
    graphics::rect(0, 0, 1, 1, col = "steelblue", border = NA)
    grDevices::dev.off()
  }

  out_pdf <- tempfile(fileext = ".pdf")
  source("fixtures/sample_data_county_choropleth.R", local = TRUE)
  render_onepager(
    sample_data_county_choropleth,
    template = "county_choropleth", theme = "default",
    output = out_pdf, keep_typst = FALSE,
    extra_assets = tall_maps
  )
  expect_equal(pdftools::pdf_info(out_pdf)$pages, 2)
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
