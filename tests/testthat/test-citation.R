cited_year <- function(meta) {
  path <- system.file("CITATION", package = "onepagr")
  cit <- utils::readCitationFile(path, meta = c(list(Version = "9.9.9"), meta))
  cit$year
}

test_that("the cited year is the year the package was published", {
  expect_identical(
    cited_year(list(
      "Date/Publication" = "2027-02-03 09:00:00 UTC",
      Date = "2026-01-01", Packaged = "2025-12-31 10:00:00 UTC; someone"
    )),
    "2027"
  )
})

test_that("the cited year falls back to the date, then the packaging date", {
  expect_identical(
    cited_year(list(Date = "2026-01-01", Packaged = "2025-12-31 10:00:00 UTC; x")),
    "2026"
  )
  expect_identical(
    cited_year(list(Packaged = "2024-05-01 10:00:00 UTC; someone")), "2024"
  )
})

test_that("the cited year is the current year only when nothing else is known", {
  expect_identical(cited_year(list()), format(Sys.Date(), "%Y"))
})
