test_that("no bare systemic pt-literal spacing/stroke values remain", {
  template_files <- list.files(
    system.file("typst", "templates", package = "onepagr"),
    pattern = "\\.typ$", recursive = TRUE, full.names = TRUE
  )
  for (f in template_files) {
    text <- paste(readLines(f, warn = FALSE), collapse = "\n")
    bare_spacers <- regmatches(text, gregexpr("#v\\((2|3|4)pt\\)", text))[[1]]
    expect_length(bare_spacers, 0)
  }
})

test_that("every built-in theme defines the full systemic token set", {
  required_keys <- c(
    "space-xs", "space-sm", "space-md", "space-lg",
    "stroke-hairline", "stroke-border", "stroke-accent",
    "stroke-accent-left", "stroke-fill",
    "radius-card", "content-pad-x",
    "severity-warning", "severity-warning-bg", "severity-warning-text",
    "severity-critical", "severity-critical-bg", "severity-critical-text",
    "brand-accent-text"
  )
  theme_files <- list.files(
    system.file("typst", "themes", package = "onepagr"),
    pattern = "\\.typ$", full.names = TRUE
  )
  for (f in theme_files) {
    text <- paste(readLines(f, warn = FALSE), collapse = "\n")
    for (key in required_keys) {
      expect_match(text, paste0(key, ":"), fixed = TRUE, info = paste(f, key))
    }
  }
})

test_that("text-box is defined in components.typ", {
  text <- paste(
    readLines(
      system.file("typst", "components.typ", package = "onepagr"),
      warn = FALSE
    ),
    collapse = "\n"
  )
  expect_match(text, "#let text-box(", fixed = TRUE)
})

test_that("page-footer takes per-logo heights and dy with 32pt/0pt defaults", {
  text <- paste(
    readLines(
      system.file("typst", "components.typ", package = "onepagr"),
      warn = FALSE
    ),
    collapse = "\n"
  )
  for (arg in c("logo-a-height", "logo-height", "logo-b-height")) {
    expect_match(text, paste0(arg, ": 32pt"), fixed = TRUE)
  }
  for (arg in c("logo-a-dy", "logo-dy", "logo-b-dy")) {
    expect_match(text, paste0(arg, ": 0pt"), fixed = TRUE)
  }
})

test_that("page-footer defaults match explicit 32pt/0pt and overrides change output", {
  skip_if_not(quarto::quarto_available())
  skip_if_not(requireNamespace("pdftools", quietly = TRUE))
  dir <- tempfile()
  on.exit(unlink(dir, recursive = TRUE))
  export_template("county_choropleth", dir)

  render_footer <- function(extra_args, show_a = "true", show_b = "true") {
    typ <- file.path(dir, "footer_probe.typ")
    writeLines(
      c(
        "#import \"theme.typ\": theme, theme-grad",
        "#import \"components.typ\": *",
        "#set document(title: [Footer probe])",
        "#set page(width: 6in, height: 1.2in, margin: 0pt)",
        paste0(
          "#page-footer(theme, theme-grad, ",
          paste0("\"assets/partner-org-a-white.png\", \"Partner A\", \"", show_a, "\", "),
          "\"assets/primary-org-white.png\", \"Primary\", ",
          paste0("\"assets/partner-org-b-white.png\", \"Partner B\", \"", show_b, "\", "),
          "\"Org\", \"https://example.org/\", \"c@example.org\"",
          extra_args, ")"
        )
      ),
      typ
    )
    out <- tempfile(fileext = ".pdf")
    compile_typst(typ, list(), out)
    pdftools::pdf_render_page(out, 1, dpi = 100, numeric = TRUE)
  }

  default <- render_footer("")
  explicit <- render_footer(paste0(
    ", logo-a-height: 32pt, logo-height: 32pt, logo-b-height: 32pt",
    ", logo-a-dy: 0pt, logo-dy: 0pt, logo-b-dy: 0pt"
  ))
  resized <- render_footer(", logo-height: 20pt, logo-b-height: 40pt")
  nudged <- render_footer(", logo-b-dy: -5pt")

  expect_identical(default, explicit)
  expect_false(identical(default, resized))
  expect_false(identical(default, nudged))

  # A hidden partner's height must not affect the row: only the primary
  # logo is drawn here, so a huge partner height changes nothing.
  primary_only <- render_footer("", "false", "false")
  primary_only_tall_partners <- render_footer(
    ", logo-a-height: 60pt, logo-b-height: 60pt", "false", "false"
  )
  expect_identical(primary_only, primary_only_tall_partners)
  expect_false(identical(primary_only, default))
})

test_that("county_choropleth declares footer sizing tokens with neutral defaults", {
  text <- paste(
    readLines(resolve_template("county_choropleth"), warn = FALSE),
    collapse = "\n"
  )
  for (tok in c(
    "logo_a_height", "logo_height", "logo_b_height",
    "logo_a_dy", "logo_dy", "logo_b_dy"
  )) {
    expect_match(
      text, paste0("// optional-token: ", tok, " = "), fixed = TRUE
    )
  }
  defaults <- extract_token_defaults(resolve_template("county_choropleth"))
  expect_equal(unname(unlist(defaults[c("logo_a_height", "logo_height", "logo_b_height")])), rep("32", 3))
  expect_equal(unname(unlist(defaults[c("logo_a_dy", "logo_dy", "logo_b_dy")])), rep("0", 3))
})
