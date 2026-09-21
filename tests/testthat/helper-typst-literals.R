
# Returns the lines of a Typst source that still contain a bare pt literal in
# a category that must go through fs()/fd()/sp() (see components.typ).
bare_scaled_literals <- function(lines) {
  keys <- c(
    "size", "tracking", "inset", "column-gutter", "row-gutter", "gutter",
    "narrative-callout-gap"
  )
  value_after <- function(line, start) {
    chars <- strsplit(substring(line, start), "")[[1]]
    depth <- 0
    for (i in seq_along(chars)) {
      ch <- chars[[i]]
      if (ch %in% c("(", "[", "{")) {
        depth <- depth + 1
      } else if (ch %in% c(")", "]", "}")) {
        if (depth == 0) return(paste(chars[seq_len(i - 1)], collapse = ""))
        depth <- depth - 1
      } else if (ch == "," && depth == 0) {
        return(paste(chars[seq_len(i - 1)], collapse = ""))
      }
    }
    substring(line, start)
  }
  hits <- character(0)
  for (line in lines) {
    if (grepl("^\\s*//", line)) next
    code <- sub("(?<=\\s)//.*$", "", line, perl = TRUE)
    code <- gsub("(fs|fd|sp)\\(theme, -?[0-9.]+pt\\)", "", code)
    bad <- grepl("#v\\(\\s*-?[0-9.]+pt", code) ||
      grepl("(?<![\\w-])size:\\s*0?\\.[0-9]+em", code, perl = TRUE)
    for (key in keys) {
      starts <- gregexpr(paste0("(?<![\\w-])", key, ":\\s*"), code, perl = TRUE)[[1]]
      if (starts[[1]] == -1) next
      ends <- starts + attr(starts, "match.length")
      for (e in ends) {
        if (grepl("-?[0-9.]*[0-9]pt", value_after(code, e))) bad <- TRUE
      }
    }
    if (bad) hits <- c(hits, line)
  }
  hits
}
