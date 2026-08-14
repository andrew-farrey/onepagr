# Reference pattern: smoke-test a Typst one-pager template with stub data,
# with no live analysis pipeline (database connection, upstream R objects)
# required. Confirms the MECHANICS work end-to-end -- whisker token
# substitution, then `quarto typst compile` -- not that any number means
# anything. All values are placeholder/fictional; see the
# "SAMPLE CONTENT NOTICE" at the top of onepager_template.typ.
#
# Run from this file's own directory (reference/).

library(whisker)
library(readr)
source("sample_data.R")

path_template <- file.path("typst", "onepager_template.typ")
path_typ_out  <- file.path("typst", "onepager_TEST.typ")
path_pdf_out  <- file.path("typst", "onepager_TEST.pdf")

template <- read_file(path_template)
output <- whisker.render(template, sample_data)
write_file(output, path_typ_out)
cat("Wrote:", path_typ_out, "\n")

result <- system2("quarto", args = c("typst", "compile", shQuote(path_typ_out), shQuote(path_pdf_out)), stdout = TRUE, stderr = TRUE)
cat(result, sep = "\n")

if (file.exists(path_pdf_out)) {
  cat("SUCCESS: PDF compiled at", path_pdf_out, "\n")
} else {
  cat("FAILURE: PDF was not produced.\n")
}
