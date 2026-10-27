test_that("a default may refer to an optional token declared below it", {
  path <- write_typ(c(
    "// optional-token: heading_a = Results for {{{label_b}}}",
    "// optional-token: label_b = Sample County",
    "{{{heading_a}}}"
  ))
  filled <- fill_token_defaults(path, list())
  expect_identical(filled$heading_a, "Results for Sample County")
  expect_identical(filled$label_b, "Sample County")
})

test_that("a default refers to a supplied value whichever order they are in", {
  path <- write_typ(c(
    "// optional-token: heading_a = Results for {{{label_b}}}",
    "// optional-token: label_b = Sample County",
    "{{{heading_a}}}"
  ))
  filled <- fill_token_defaults(path, list(label_b = "North"))
  expect_identical(filled$heading_a, "Results for North")
})

test_that("defaults that refer to each other in a loop are an error", {
  path <- write_typ(c(
    "// optional-token: a = A {{{b}}}",
    "// optional-token: b = B {{{a}}}",
    "{{{a}}}"
  ))
  expect_error(fill_token_defaults(path, list()), "loop")
})

test_that("a chain of references is followed to the end", {
  path <- write_typ("#text[{{{note}}}]")
  filled <- fill_token_defaults(
    path, list(note = "A {{{b}}}", b = "B {{{c}}}", c = "C")
  )
  expect_identical(filled$note, "A B C")
  expect_identical(filled$b, "B C")
})

test_that("values that refer to each other in a loop are an error", {
  path <- write_typ("#text[{{{a}}}]")
  expect_error(
    fill_token_defaults(path, list(a = "x {{{b}}}", b = "y {{{a}}}")),
    "loop"
  )
})

test_that("only triple-brace references are substituted inside a value", {
  path <- write_typ("#text[{{{note}}}]")
  filled <- fill_token_defaults(path, list(
    note = "{{{b}}} and {{c}} and {{#flag}}hidden{{/flag}}",
    b = "B", c = "<a&b>", flag = "yes"
  ))
  expect_identical(
    filled$note, "B and {{c}} and {{#flag}}hidden{{/flag}}"
  )
})

test_that("a missing referenced name fills as blank, as before", {
  path <- write_typ("#text[{{{note}}}]")
  filled <- fill_token_defaults(path, list(note = "Area: {{{nobody}}}."))
  expect_identical(filled$note, "Area: .")
})

test_that("warn_unknown_tokens stays silent for a name a value refers to", {
  path <- write_typ("#text[{{{note}}}]")
  expect_no_warning(
    warn_unknown_tokens(
      path, list(note = "Area: {{{area_name}}}", area_name = "North")
    )
  )
  expect_no_warning(
    warn_unknown_tokens(
      path, list(note = "A {{{b}}}", b = "B {{{c}}}", c = "C")
    )
  )
})

test_that("warn_unknown_tokens still flags a name nothing refers to", {
  path <- write_typ("#text[{{{note}}}]")
  expect_warning(
    warn_unknown_tokens(path, list(note = "x", area_name = "North")),
    "area_name"
  )
})

test_that("a bracket that arrives through a reference is caught in R", {
  path <- write_typ(c("#set document(title: [T])", "#text[{{{note}}}]"))
  expect_error(
    compile_typst(
      path, list(note = "x {{{b}}}", b = "oops ]"), tempfile(fileext = ".pdf")
    ),
    "unbalanced"
  )
})

test_that("a missing token at the end of a chain of references is an error", {
  path <- write_typ("#text[{{{note}}}]")
  data <- list(note = "A {{{b}}}", b = "B {{{c}}}")
  expect_error(
    validate_template_data(path, data), "required token\\(s\\) for .*: c$"
  )
  data$c <- "C"
  expect_no_error(validate_template_data(path, data))
  expect_identical(fill_token_defaults(path, data)$note, "A B C")
})

test_that("a value only another template uses cannot stop this render", {
  path <- write_typ("#text[{{{note}}}]")
  data <- list(note = "fine", other = "see {{{other}}}")
  filled <- fill_token_defaults(path, data)
  expect_identical(filled$note, "fine")
  expect_identical(filled$other, "see {{{other}}}")
  expect_no_error(validate_template_data(path, data))
})

test_that("a loop this template reaches is still an error", {
  path <- write_typ("#text[{{{note}}}]")
  expect_error(
    fill_token_defaults(path, list(note = "x {{{b}}}", b = "y {{{note}}}")),
    "loop"
  )
  expect_error(fill_token_defaults(path, list(note = "x {{{note}}}")), "loop")
})

test_that("a shared data list renders every built-in template's own values", {
  # One list holding two templates' values, with a value that refers to itself
  # in a token the other template does not use.
  data <- c(
    example_data("cohort_summary"),
    list(only_for_another_template = "see {{{only_for_another_template}}}")
  )
  path <- resolve_template("cohort_summary")
  expect_no_error(fill_token_defaults(path, data))
})

test_that("a bracket in a default that is used is caught in R", {
  path <- write_typ(c(
    "#set document(title: [T])",
    "// optional-token: heading = a closing ] bracket",
    "#text[{{{heading}}}]"
  ))
  expect_error(
    compile_typst(path, list(), tempfile(fileext = ".pdf")), "unbalanced"
  )
})
