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
    "severity-critical", "severity-critical-bg", "severity-critical-text"
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
