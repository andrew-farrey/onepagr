test_that("an organization name renders as typed in every template's footer", {
  skip_if_no_onepagr_typst()
  skip_if_not_installed("pdftools")
  org <- "District #2 <Partners> $5 Health"
  for (template in list_templates()) {
    data <- example_data(template)
    data$org_full <- org
    out <- tempfile(fileext = ".pdf")
    on.exit(unlink(out), add = TRUE)
    render_onepager(
      data, template, output = out, keep_typst = FALSE,
      extra_assets = if (template == "county_choropleth") example_maps() else character(0)
    )
    text <- gsub("\\s+", " ", paste(pdftools::pdf_text(out), collapse = " "))
    expect_true(grepl(org, text, fixed = TRUE), info = template)
    expect_identical(pdftools::pdf_info(out)$keys$Author, org, info = template)
  }
})

test_that("org_full in the footer is read from a string in every template", {
  for (template in list_templates()) {
    occ <- template_spec(resolve_template(template))$occurrences
    expect_true(all(occ$in_string[occ$token == "org_full"]), info = template)
  }
})
