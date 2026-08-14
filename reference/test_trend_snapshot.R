# Smoke-test for template_trend_snapshot.typ -- same stub data as
# test_render_stub.R (both templates deliberately use the same token
# names), just pointed at the second template. Run from this file's own
# directory (reference/).

library(whisker)
library(readr)
source("sample_data.R")

path_template <- file.path("typst", "template_trend_snapshot.typ")
path_typ_out  <- file.path("typst", "trend_TEST.typ")
path_pdf_out  <- file.path("typst", "trend_TEST.pdf")

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
