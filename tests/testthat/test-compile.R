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
