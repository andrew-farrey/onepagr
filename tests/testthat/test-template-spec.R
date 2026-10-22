write_typ <- function(lines, env = parent.frame()) {
  path <- tempfile(fileext = ".typ")
  writeLines(lines, path)
  withr::defer(unlink(path), envir = env)
  path
}

test_that("strip_typst_comment drops a trailing comment but not a string or URL", {
  expect_equal(strip_typst_comment("a // note"), "a ")
  expect_equal(
    strip_typst_comment('#link("https://x.org")[{{{t}}}]'),
    '#link("https://x.org")[{{{t}}}]'
  )
  expect_equal(
    strip_typst_comment("see https://x.org {{{t}}}"),
    "see https://x.org {{{t}}}"
  )
  expect_equal(strip_typst_comment('"a // b" // real'), '"a // b" ')
})

test_that("a token after a URL literal is found and not reported as ignored", {
  path <- write_typ(
    c("= {{{title}}}", '#link("https://example.org")[{{{link_text}}}]')
  )
  expect_equal(extract_required_tokens(path), c("title", "link_text"))
  expect_silent(
    warn_unknown_tokens(path, list(title = "a", link_text = "b"))
  )
})

test_that("a dotted token name is rejected with a clear message", {
  path <- write_typ("#text[{{{a.b}}}]")
  expect_error(template_spec(path), "Invalid token name")
  expect_error(template_spec(path), "a.b")
})

test_that("template_spec classifies required, conditional and optional tokens", {
  path <- write_typ(
    c(
      "// optional-token: heading_x = Results (N = {{{n_total}}})",
      "// optional-token: blank =",
      "{{{heading_x}}} {{{doc_title}}} {{{blank}}}"
    )
  )
  tokens <- template_spec(path)$tokens
  expect_equal(tokens$token, c("doc_title", "n_total", "heading_x", "blank"))
  expect_equal(
    tokens$kind, c("required", "conditional", "optional", "optional")
  )
  expect_equal(tokens$needed_by[tokens$token == "n_total"], "heading_x")
  expect_true(is.na(tokens$needed_by[tokens$token == "doc_title"]))
  expect_equal(tokens$default[tokens$token == "heading_x"],
               "Results (N = {{{n_total}}})")
})

test_that("the built-in cohort_summary has default-only tokens as conditional", {
  tokens <- template_spec(resolve_template("cohort_summary"))$tokens
  expect_equal(tokens$kind[tokens$token == "timing_denom"], "conditional")
  expect_false(is.na(tokens$needed_by[tokens$token == "timing_denom"]))
  expect_equal(tokens$kind[tokens$token == "heading_timing"], "optional")
})

test_that("template_spec records which occurrences sit inside a string", {
  path <- write_typ(
    c("#let f(a) = a", "#f(\"{{{in_str}}}\") [{{{in_body}}}] \"x {{{org}}}\" {{{org}}}")
  )
  occ <- template_spec(path)$occurrences
  expect_equal(occ$in_string[occ$token == "in_str"], TRUE)
  expect_equal(occ$in_string[occ$token == "in_body"], FALSE)
  expect_equal(occ$in_string[occ$token == "org"], c(TRUE, FALSE))
})

test_that("template_spec reads an allow-empty declaration", {
  path <- write_typ(
    c("// allow-empty: note, extra", "{{{note}}} {{{extra}}} {{{title}}}")
  )
  expect_equal(template_spec(path)$allow_empty, c("note", "extra"))
})

test_that("template_spec picks up a file that changes between calls", {
  path <- write_typ("{{{one}}}")
  expect_equal(template_spec(path)$tokens$token, "one")
  writeLines("{{{one}}} {{{two}}}", path)
  # Same path, new content and size: the cached spec must be invalidated.
  expect_equal(template_spec(path)$tokens$token, c("one", "two"))
})

test_that("template_tokens prefers a built-in name over a same-named file", {
  old <- setwd(tempdir())
  on.exit(setwd(old), add = TRUE)
  writeLines("#text[{{{zzz}}}]", "cohort_summary")
  on.exit(unlink("cohort_summary"), add = TRUE)
  expect_gt(nrow(template_tokens("cohort_summary")), 100)
})

test_that("template_tokens still accepts a path to a .typ file", {
  path <- write_typ("{{{only_token}}}")
  expect_equal(template_tokens(path)$token, "only_token")
})

test_that("template_tokens has a needed_by column", {
  path <- write_typ(
    c("// optional-token: h = N = {{{n}}}", "{{{h}}} {{{t}}}")
  )
  out <- template_tokens(path)
  expect_equal(names(out), c("token", "required", "default", "needed_by"))
  expect_equal(out$required, c(TRUE, FALSE, FALSE))
})
