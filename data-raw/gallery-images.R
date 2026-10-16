# Regenerates the gallery images in man/figures/ from the current templates
# and themes. Run from the package root: Rscript data-raw/gallery-images.R
#
# Layout matches the existing gallery: every PNG is 900 px wide, a 256-color
# indexed palette. Two-page templates are shown front and back side by side
# (450 px per page); one-page templates are shown at full width. The theme
# comparison images are page 1 of trend_snapshot in each built-in theme.

suppressMessages({
  devtools::load_all(".", quiet = TRUE)
  library(pdftools)
  library(magick)
})

out_dir <- "man/figures"
work <- file.path(tempdir(), "gallery")
dir.create(work, showWarnings = FALSE, recursive = TRUE)
maps <- normalizePath(file.path("tests", "testthat", "fixtures", "maps",
                                sprintf("map%d.png", 0:4)))

render <- function(template, theme) {
  pdf <- file.path(work, paste0(template, "__", theme, ".pdf"))
  args <- list(template, data = example_data(template), output = pdf, theme = theme)
  if (template == "county_choropleth") args$extra_assets <- maps
  do.call(render_onepager, args)
  pdf
}

page_png <- function(pdf, page, width_px) {
  dpi <- width_px / 8.5  # US Letter, 8.5 in wide
  stem <- tools::file_path_sans_ext(basename(pdf))
  f <- file.path(work, sprintf("%s_p%d_%d.png", stem, page, width_px))
  pdf_convert(pdf, pages = page, format = "png", dpi = dpi, filenames = f, verbose = FALSE)
  image_read(f)
}

save_gallery <- function(img, name) {
  img <- image_quantize(img, max = 256, colorspace = "sRGB", dither = TRUE)
  image_write(img, file.path(out_dir, name), format = "png8")
}

two_page <- function(template, name, theme = "default") {
  pdf <- render(template, theme)
  pages <- c(page_png(pdf, 1, 450), page_png(pdf, 2, 450))
  save_gallery(image_append(pages), name)
}
one_page <- function(template, name, theme = "default") {
  save_gallery(page_png(render(template, theme), 1, 900), name)
}

two_page("cohort_summary", "example-cohort-summary.png")
two_page("county_choropleth", "example-county-choropleth.png")
two_page("trend_snapshot", "example-trend-snapshot.png")
one_page("overdose_spike_alert", "example-overdose-spike-alert.png")
one_page("syndromic_alert", "example-syndromic-alert.png")
for (th in c("default", "uk", "kdph")) {
  one_page("trend_snapshot", sprintf("example-trend-snapshot-theme-%s.png", th), theme = th)
}

for (f in list.files(out_dir, "^example-.*\\.png$", full.names = TRUE)) {
  info <- image_info(image_read(f))
  cat(sprintf(
    "%-46s %4d x %4d  %4.0f KB\n",
    basename(f), info$width, info$height, file.size(f) / 1024
  ))
}
