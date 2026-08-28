# Reproducible hex sticker for the onepagr R package (man/figures/logo.png).
#
# The sticker is generated with hexSticker. The accessibility/checkmark glyph
# is Microsoft's open-source Fluent System Icon (MIT; see ICON-LICENSE.md in
# this directory). The document and report bars are original shapes, and the
# palette is copied directly from onepagr's own built-in `default.typ` theme
# so the logo feels native to the package's actual output rather than an
# unrelated brand.
#
# Run from the package root:
#   source("data-raw/hex-sticker/make_logo.R")

library(ggplot2)
library(hexSticker)

src_dir <- "data-raw/hex-sticker"
figures_dir <- "man/figures"

# Render the official monochrome Fluent SVG in white for placement inside the
# green badge. Keeping the unmodified source SVG beside this script makes the
# provenance and reproduction path explicit.
fluent_svg_file <- file.path(
  src_dir,
  "microsoft-fluent-accessibility-checkmark-20-regular.svg"
)
fluent_svg <- paste(readLines(fluent_svg_file, warn = FALSE), collapse = "\n")
fluent_svg_white <- sub("#212121", "#FFFFFF", fluent_svg, fixed = TRUE)
fluent_icon_png <- tempfile(fileext = ".png")
rsvg::rsvg_png(
  charToRaw(fluent_svg_white),
  fluent_icon_png,
  width = 512,
  height = 512
)

# Palette drawn directly from onepagr's built-in accessible default theme.
onepagr_colours <- c(
  blue = "#0C68F0",
  midnight = "#052C65",
  green = "#198754",
  green_dark = "#0A3622",
  sky = "#9EC5FE",
  paper = "#FFFFFF",
  ink = "#343A40",
  grey = "#E9ECEF",
  critical = "#DC3545",
  warning = "#FFC107"
)

# A compact, high-contrast report glyph. An offset page suggests a
# front-and-back handout; colored rules suggest varied report content.
# The critical/warning bars are deliberately shortened to end clear of the
# accessibility badge's footprint (x ~ 0.49-0.81) rather than running under
# it -- an earlier draft let the badge clip them, which read as visual
# collision rather than intentional layering, and weakened the "four
# distinct pieces of content" cue the bars are meant to give.
report_icon <- ggplot() +
  # Back page
  annotate(
    "polygon",
    x = c(0.19, 0.66, 0.77, 0.77, 0.19),
    y = c(0.13, 0.13, 0.24, 0.87, 0.87),
    fill = onepagr_colours[["sky"]], colour = onepagr_colours[["midnight"]],
    linewidth = 1.2
  ) +
  # Front page with folded corner
  annotate(
    "polygon",
    x = c(0.28, 0.66, 0.82, 0.82, 0.28),
    y = c(0.19, 0.19, 0.35, 0.95, 0.95),
    fill = onepagr_colours[["paper"]], colour = onepagr_colours[["midnight"]],
    linewidth = 1.5
  ) +
  # Fold line
  annotate(
    "segment", x = 0.66, xend = 0.66, y = 0.19, yend = 0.35,
    colour = onepagr_colours[["midnight"]], linewidth = 1.3
  ) +
  annotate(
    "segment", x = 0.66, xend = 0.82, y = 0.35, yend = 0.35,
    colour = onepagr_colours[["midnight"]], linewidth = 1.3
  ) +
  # Report title and accessible content blocks
  annotate(
    "segment", x = 0.37, xend = 0.68, y = 0.77, yend = 0.77,
    colour = onepagr_colours[["midnight"]], linewidth = 3.8,
    lineend = "round"
  ) +
  annotate(
    "segment", x = 0.40, xend = 0.75, y = 0.65, yend = 0.65,
    colour = onepagr_colours[["blue"]], linewidth = 3.2,
    lineend = "round"
  ) +
  annotate(
    "segment", x = 0.40, xend = 0.57, y = 0.55, yend = 0.55,
    colour = onepagr_colours[["critical"]], linewidth = 3.2,
    lineend = "round"
  ) +
  annotate(
    "segment", x = 0.40, xend = 0.51, y = 0.45, yend = 0.45,
    colour = onepagr_colours[["warning"]], linewidth = 3.2,
    lineend = "round"
  ) +
  # Accessibility/check badge
  annotate(
    "point", x = 0.79, y = 0.84,
    shape = 21, size = 17, stroke = 1.2,
    fill = onepagr_colours[["green"]], colour = onepagr_colours[["green_dark"]]
  ) +
  # Official Microsoft Fluent Accessibility Checkmark Regular icon
  ggimage::geom_image(
    data = data.frame(x = 0.79, y = 0.84, image = fluent_icon_png),
    aes(x = x, y = y, image = image),
    size = 0.454,
    asp = 1
  ) +
  coord_fixed(xlim = c(0.10, 0.90), ylim = c(0.08, 1.02), clip = "off") +
  theme_void() +
  theme(plot.margin = margin(0, 0, 0, 0))

sticker_png <- tempfile(fileext = ".png")
hexSticker::sticker(
  subplot = report_icon,
  package = "onepagr",
  filename = sticker_png,
  s_x = 1.00,
  s_y = 1.05,
  s_width = 1.012,
  s_height = 1.0925,
  p_x = 1.00,
  p_y = 0.46,
  p_color = "#FFFFFF",
  p_family = "sans",
  p_fontface = "bold",
  p_size = 26,
  h_fill = onepagr_colours[["blue"]],
  # The accessibility green remains visible around the blue hex on both
  # bright and dark display backgrounds.
  h_color = onepagr_colours[["green"]],
  h_size = 2.2,
  spotlight = TRUE,
  l_x = 0.72,
  l_y = 1.50,
  l_width = 2.0,
  l_height = 1.1,
  l_alpha = 0.12,
  url = "",
  white_around_sticker = FALSE,
  dpi = 600
)

# man/figures/logo.png at 240px wide is the usethis::use_logo() convention
# for an R package README/pkgdown hex logo.
if (!dir.exists(figures_dir)) dir.create(figures_dir, recursive = TRUE)
magick::image_read(sticker_png) |>
  magick::image_resize("240x") |>
  magick::image_write(file.path(figures_dir, "logo.png"), format = "png")

message("Created: ", file.path(figures_dir, "logo.png"))
