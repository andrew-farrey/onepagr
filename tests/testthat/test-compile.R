test_that("extract_required_tokens finds triple-brace tokens in order", {
  tmp <- tempfile(fileext = ".typ")
  writeLines(c("#text[{{{doc_title}}}]", "#text[{{{n_decedents}}} cases]"), tmp)
  on.exit(unlink(tmp))
  expect_equal(extract_required_tokens(tmp), c("doc_title", "n_decedents"))
})

test_that("extract_required_tokens ignores double-brace tokens", {
  tmp <- tempfile(fileext = ".typ")
  writeLines("#text[{{not_required}}] {{{is_required}}}", tmp)
  on.exit(unlink(tmp))
  expect_equal(extract_required_tokens(tmp), "is_required")
})

test_that("extract_required_tokens deduplicates repeated tokens", {
  tmp <- tempfile(fileext = ".typ")
  writeLines("{{{n_decedents}}} ... {{{n_decedents}}} again", tmp)
  on.exit(unlink(tmp))
  expect_equal(extract_required_tokens(tmp), "n_decedents")
})

test_that("extract_required_tokens ignores an example inside a // comment", {
  tmp <- tempfile(fileext = ".typ")
  writeLines(
    c(
      "// documented as {{{token}}} triple-brace syntax",
      "{{{real_token}}}"
    ),
    tmp
  )
  on.exit(unlink(tmp))
  expect_equal(extract_required_tokens(tmp), "real_token")
})

test_that("validate_template_data passes when all tokens present/non-NA", {
  tmp <- tempfile(fileext = ".typ")
  writeLines("{{{doc_title}}}", tmp)
  on.exit(unlink(tmp))
  expect_true(validate_template_data(tmp, list(doc_title = "Sample")))
})

test_that("validate_template_data errors listing every missing token", {
  tmp <- tempfile(fileext = ".typ")
  writeLines("{{{doc_title}}} {{{n_decedents}}}", tmp)
  on.exit(unlink(tmp))
  expect_error(
    validate_template_data(tmp, list(doc_title = "Sample")),
    "n_decedents"
  )
})

test_that("validate_template_data treats NA as missing", {
  tmp <- tempfile(fileext = ".typ")
  writeLines("{{{doc_title}}}", tmp)
  on.exit(unlink(tmp))
  expect_error(
    validate_template_data(tmp, list(doc_title = NA)),
    "doc_title"
  )
})

test_that("compile_typst produces a PDF end-to-end", {
  skip_if_not(quarto::quarto_available())
  tmp_dir <- tempfile()
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE))
  typ_path <- file.path(tmp_dir, "minimal.typ")
  # --pdf-standard ua-1 enforces PDF/UA-1's required document title, so
  # even this minimal fixture needs a title set -- confirmed directly:
  # omitting it fails compilation with "PDF/UA-1 error: missing document
  # title".
  writeLines(
    c("#set document(title: [Test])", "#text[{{{greeting}}}]"), typ_path
  )
  out_pdf <- file.path(tmp_dir, "out.pdf")
  result <- compile_typst(typ_path, list(greeting = "Hello"), out_pdf)
  expect_true(file.exists(out_pdf))
  expect_equal(result, out_pdf)
})

test_that("compile_typst validates before attempting to compile", {
  tmp_dir <- tempfile()
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE))
  typ_path <- file.path(tmp_dir, "minimal.typ")
  writeLines("#text[{{{greeting}}}]", typ_path)
  out_pdf <- file.path(tmp_dir, "out.pdf")
  expect_error(
    compile_typst(typ_path, list(), out_pdf),
    "greeting"
  )
  expect_false(file.exists(out_pdf))
})

test_that("compile_typst errors clearly when Quarto isn't found", {
  tmp_dir <- tempfile()
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE))
  typ_path <- file.path(tmp_dir, "minimal.typ")
  writeLines(
    c("#set document(title: [Test])", "#text[{{{greeting}}}]"), typ_path
  )
  out_pdf <- file.path(tmp_dir, "out.pdf")

  testthat::local_mocked_bindings(
    quarto_path = function() NULL,
    .package = "quarto"
  )
  expect_error(
    compile_typst(typ_path, list(greeting = "Hello"), out_pdf),
    "Quarto was not found"
  )
})

test_that("compile_typst rejects a font_dir that does not exist", {
  tmp_dir <- tempfile()
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE))
  typ_path <- file.path(tmp_dir, "minimal.typ")
  writeLines(
    c("#set document(title: [Test])", "#text[{{{greeting}}}]"), typ_path
  )
  out_pdf <- file.path(tmp_dir, "out.pdf")
  expect_error(
    compile_typst(
      typ_path, list(greeting = "Hello"), out_pdf,
      font_dir = file.path(tmp_dir, "no_such_dir")
    ),
    "font_dir"
  )
  expect_false(file.exists(out_pdf))
})

test_that("compile_typst compiles successfully with a font_dir supplied", {
  skip_if_not(quarto::quarto_available())
  tmp_dir <- tempfile()
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE))
  font_dir <- file.path(tmp_dir, "fonts")
  dir.create(font_dir)

  typ_path <- file.path(tmp_dir, "minimal.typ")
  writeLines(
    c("#set document(title: [Test])", "#text[{{{greeting}}}]"), typ_path
  )
  out_pdf <- file.path(tmp_dir, "out.pdf")
  result <- compile_typst(
    typ_path, list(greeting = "Hello"), out_pdf, font_dir = font_dir
  )
  expect_true(file.exists(out_pdf))
  expect_equal(result, out_pdf)
})

test_that("extract_token_defaults reads optional-token markers only", {
  tmp <- tempfile(fileext = ".typ")
  writeLines(
    c(
      "// optional-token: logo_height = 32",
      "  // optional-token: logo_dy =   -4  ",
      "// optional-token: blank =",
      "// an ordinary comment that mentions optional-token: nothing = here",
      "{{{logo_height}}} {{{logo_dy}}} {{{doc_title}}}"
    ),
    tmp
  )
  on.exit(unlink(tmp))
  expect_equal(
    extract_token_defaults(tmp),
    list(logo_height = "32", logo_dy = "-4", blank = "")
  )
})

test_that("extract_token_defaults returns an empty list when none are declared", {
  tmp <- tempfile(fileext = ".typ")
  writeLines("{{{doc_title}}}", tmp)
  on.exit(unlink(tmp))
  expect_length(extract_token_defaults(tmp), 0)
})

test_that("extract_required_tokens leaves out tokens with a declared default", {
  tmp <- tempfile(fileext = ".typ")
  writeLines(
    c("// optional-token: logo_height = 32", "{{{logo_height}}} {{{doc_title}}}"),
    tmp
  )
  on.exit(unlink(tmp))
  expect_equal(extract_required_tokens(tmp), "doc_title")
  expect_true(validate_template_data(tmp, list(doc_title = "x")))
})

test_that("template_tokens lists required tokens first, then defaults", {
  tmp <- tempfile(fileext = ".typ")
  writeLines(
    c(
      "// optional-token: heading_x = Results (N = {{{n_total}}})",
      "// optional-token: blank =",
      "{{{heading_x}}} {{{doc_title}}} {{{blank}}}"
    ),
    tmp
  )
  on.exit(unlink(tmp))
  out <- template_tokens(tmp)
  expect_equal(names(out), c("token", "required", "default"))
  expect_equal(out$token, c("doc_title", "n_total", "heading_x", "blank"))
  expect_equal(out$required, c(TRUE, TRUE, FALSE, FALSE))
  expect_equal(
    out$default, c(NA, NA, "Results (N = {{{n_total}}})", "")
  )
})

test_that("template_tokens accepts a built-in template name", {
  out <- template_tokens("cohort_summary")
  expect_true(all(c("doc_title", "heading_glance") %in% out$token))
  expect_equal(out$default[out$token == "heading_disclaimer"], "DISCLAIMER")
  expect_false(anyDuplicated(out$token) > 0)
  expect_error(template_tokens("no_such_template"), "not a built-in template")
})

test_that("no built-in template uses a double-brace token", {
  # Double braces HTML-escape their value and are invisible to
  # extract_required_tokens(), so a missing value would go unnoticed.
  for (template in list_templates()) {
    lines <- readLines(resolve_template(template), warn = FALSE)
    lines <- sub("//.*$", "", lines)
    double_brace <- "(?<!\\{)\\{\\{[A-Za-z0-9_.]+\\}\\}(?!\\})"
    expect_false(any(grepl(double_brace, lines, perl = TRUE)), info = template)
  }
})

test_that("warn_unknown_tokens flags a typo and suggests the token", {
  tmp <- tempfile(fileext = ".typ")
  writeLines(
    c(
      "// optional-token: heading_glance = AT A GLANCE",
      "{{{heading_glance}}} {{{doc_title}}}"
    ),
    tmp
  )
  on.exit(unlink(tmp))
  data <- list(doc_title = "x", heading_glnce = "y")
  expect_warning(
    warn_unknown_tokens(tmp, data),
    "\"heading_glnce\" was ignored.*Did you mean \"heading_glance\"[?]"
  )
})

test_that("warn_unknown_tokens flags an unrelated name without a suggestion", {
  tmp <- tempfile(fileext = ".typ")
  writeLines("{{{doc_title}}}", tmp)
  on.exit(unlink(tmp))
  warning_text <- tryCatch(
    warn_unknown_tokens(tmp, list(doc_title = "x", zzz_unrelated_zzz = "y")),
    warning = function(w) conditionMessage(w)
  )
  expect_match(warning_text, "\"zzz_unrelated_zzz\" was ignored")
  expect_no_match(warning_text, "Did you mean")
})

test_that("warn_unknown_tokens stays silent for known and shared names", {
  tmp <- tempfile(fileext = ".typ")
  writeLines("{{{doc_title}}}", tmp)
  on.exit(unlink(tmp))
  # heading_glance belongs to a built-in template, not this one: a data list
  # shared across templates must not warn.
  expect_no_warning(
    warn_unknown_tokens(
      tmp, list(doc_title = "x", heading_glance = "y", n_decedents = "1")
    )
  )
  expect_no_warning(warn_unknown_tokens(tmp, list(doc_title = "x")))
})

test_that("extract_required_tokens counts tokens a default refers to", {
  tmp <- tempfile(fileext = ".typ")
  writeLines(
    c(
      "// optional-token: heading_x = Results (N = {{{n_total}}})",
      "{{{heading_x}}} {{{doc_title}}}"
    ),
    tmp
  )
  on.exit(unlink(tmp))
  expect_equal(extract_required_tokens(tmp), c("doc_title", "n_total"))
})

test_that("fill_token_defaults renders a default against the data", {
  tmp <- tempfile(fileext = ".typ")
  writeLines(
    c(
      "// optional-token: heading_x = Results (N = {{{n_total}}}) & more",
      "// optional-token: heading_y = Plain",
      "{{{heading_x}}} {{{heading_y}}} {{{n_total}}}"
    ),
    tmp
  )
  on.exit(unlink(tmp))
  out <- fill_token_defaults(tmp, list(n_total = "12", heading_y = "Mine"))
  expect_equal(out$heading_x, "Results (N = 12) & more")
  expect_equal(out$heading_y, "Mine")
  # A supplied value is taken literally, never rendered again.
  out <- fill_token_defaults(tmp, list(n_total = "12", heading_x = "{{{n_total}}}"))
  expect_equal(out$heading_x, "{{{n_total}}}")
})

test_that("compile_typst fills an omitted optional token from its default", {
  skip_if_not(quarto::quarto_available())
  dir <- tempfile()
  dir.create(dir)
  on.exit(unlink(dir, recursive = TRUE))
  typ <- file.path(dir, "probe.typ")
  writeLines(
    c(
      "// optional-token: size = 12",
      "#set document(title: [Probe])",
      "#text[size {{{size}}}]"
    ),
    typ
  )
  rendered <- file.path(dir, "probe_rendered.typ")
  out <- file.path(dir, "probe.pdf")

  compile_typst(typ, list(), out)
  expect_match(paste(readLines(rendered), collapse = "\n"), "size 12")

  compile_typst(typ, list(size = "20"), out)
  expect_match(paste(readLines(rendered), collapse = "\n"), "size 20")

  # NULL, empty, and NA all count as "not passed".
  for (unset in list(NULL, character(0), NA)) {
    compile_typst(typ, list(size = unset), out)
    expect_match(paste(readLines(rendered), collapse = "\n"), "size 12")
  }
})

test_that("compile_typst does not report success from a stale output file", {
  skip_if_not(quarto::quarto_available())
  dir <- tempfile()
  dir.create(dir)
  on.exit(unlink(dir, recursive = TRUE))
  good <- file.path(dir, "good.typ")
  writeLines(c("#set document(title: [ok])", "hello"), good)
  out <- file.path(dir, "out.pdf")

  compile_typst(good, list(), out)
  expect_true(file.exists(out))

  bad <- file.path(dir, "bad.typ")
  writeLines("#unknown-function()", bad)
  expect_error(compile_typst(bad, list(), out), "Typst compilation failed")
  expect_false(file.exists(out))
})

test_that("compile_typst errors when it cannot clear the existing output path", {
  skip_if_not(quarto::quarto_available())
  dir <- tempfile()
  dir.create(dir)
  on.exit(unlink(dir, recursive = TRUE))
  good <- file.path(dir, "good.typ")
  writeLines(c("#set document(title: [ok])", "hello"), good)
  # A directory at the output path: unlink() without recursive = TRUE will not
  # remove it, the same way a locked file survives on Windows.
  out <- file.path(dir, "out.pdf")
  dir.create(out)
  expect_error(compile_typst(good, list(), out), "Cannot replace the existing output file")
})
