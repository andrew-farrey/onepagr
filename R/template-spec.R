#' Drop a trailing `//` comment from one line of Typst source
#'
#' Internal. A `//` starts a comment unless it is inside a `"` string
#' literal or directly follows a colon (the `://` of a URL, which Typst also
#' treats as text). Only a line containing `//` is scanned character by
#' character.
#'
#' @param line Character. One line of Typst source.
#' @return Character, the line without its trailing comment.
#' @noRd
strip_typst_comment <- function(line) {
  if (!grepl("//", line, fixed = TRUE)) {
    return(line)
  }
  chars <- strsplit(line, "", fixed = TRUE)[[1]]
  n <- length(chars)
  in_string <- FALSE
  i <- 1L
  while (i <= n) {
    ch <- chars[i]
    if (in_string && ch == "\\") {
      i <- i + 2L
      next
    }
    if (ch == "\"") {
      in_string <- !in_string
    } else if (
      !in_string && ch == "/" && i < n && chars[i + 1L] == "/" &&
        !(i > 1L && chars[i - 1L] == ":")
    ) {
      return(substr(line, 1L, i - 1L))
    }
    i <- i + 1L
  }
  line
}

# One parsed spec per template file, kept for the session and keyed by the
# file's content hash, so editing a template invalidates it.
.spec_cache <- new.env(parent = emptyenv())

#' Describe a template once: its tokens, defaults, and where each is used
#'
#' Internal. Every token function reads this object instead of re-reading
#' and re-scanning the file. The spec is cached per file and rebuilt when
#' the file's content changes.
#'
#' Token kinds: `required` (used in the template body, no default),
#' `conditional` (used only inside another token's default text, no default
#' of its own: needed only while that default is in use), and `optional`
#' (declared with `// optional-token: name = default`).
#'
#' @param path Character. Path to a .typ file.
#' @return A list with `path`, `tokens` (data frame: `token`, `kind`,
#'   `default`, `needed_by`), `defaults` (named list), `occurrences` (data
#'   frame: `token`, `line`, `in_string`), `allow_empty` (character), and
#'   `designed_pages` (integer or `NA`).
#' @noRd
template_spec <- function(path) {
  key <- normalizePath(path, winslash = "/", mustWork = TRUE)
  stamp <- unname(tools::md5sum(key))
  cached <- .spec_cache[[key]]
  if (!is.null(cached) && identical(cached$stamp, stamp)) {
    return(cached$spec)
  }
  spec <- parse_template_spec(key)
  assign(key, list(stamp = stamp, spec = spec), envir = .spec_cache)
  spec
}

token_pattern <- "\\{\\{\\{\\s*([^}]*?)\\s*\\}\\}\\}"

check_token_name <- function(name, path) {
  if (!grepl("^[A-Za-z0-9_]+$", name)) {
    stop(
      "Invalid token name \"", name, "\" in ", basename(path),
      ": use letters, digits and underscores only.",
      call. = FALSE
    )
  }
  name
}

tokens_in <- function(text, path) {
  found <- regmatches(text, gregexpr(token_pattern, text, perl = TRUE))
  lapply(found, function(m) {
    vapply(
      sub(token_pattern, "\\1", m, perl = TRUE),
      check_token_name, character(1), path = path, USE.NAMES = FALSE
    )
  })
}

parse_template_spec <- function(path) {
  raw <- readLines(path, warn = FALSE, encoding = "UTF-8")
  code <- vapply(raw, strip_typst_comment, character(1), USE.NAMES = FALSE)

  # Defaults: `// optional-token: name = default`.
  found <- regmatches(raw, regexec(
    "^\\s*//\\s*optional-token:\\s*([^\\s=]+)\\s*=\\s*(.*?)\\s*$", raw,
    perl = TRUE
  ))
  found <- found[lengths(found) == 3]
  defaults <- stats::setNames(
    lapply(found, function(f) f[[3]]),
    vapply(found, function(f) check_token_name(f[[2]], path), character(1))
  )

  # Every token used in code, with the line it is on and whether it sits
  # inside a "string literal" (odd number of unescaped quotes before it).
  per_line <- tokens_in(code, path)
  positions <- gregexpr(token_pattern, code, perl = TRUE)
  occ <- do.call(rbind, lapply(seq_along(code), function(k) {
    if (length(per_line[[k]]) == 0) {
      return(NULL)
    }
    starts <- as.integer(positions[[k]])
    in_string <- vapply(starts, function(s) {
      before <- substr(code[k], 1L, s - 1L)
      quotes <- gregexpr("(?<!\\\\)\"", before, perl = TRUE)[[1]]
      (if (quotes[1] == -1L) 0L else length(quotes)) %% 2L == 1L
    }, logical(1))
    data.frame(
      token = per_line[[k]], line = k, in_string = in_string,
      stringsAsFactors = FALSE
    )
  }))
  if (is.null(occ)) {
    occ <- data.frame(
      token = character(0), line = integer(0), in_string = logical(0),
      stringsAsFactors = FALSE
    )
  }

  default_refs <- lapply(defaults, function(d) {
    unique(unlist(tokens_in(d, path)))
  })
  body <- unique(occ$token)
  referenced <- unique(unlist(default_refs, use.names = FALSE))
  optional <- names(defaults)
  required <- setdiff(body, optional)
  conditional <- setdiff(referenced, c(body, optional))

  needed_by <- vapply(conditional, function(tok) {
    users <- names(default_refs)[vapply(default_refs, function(r) tok %in% r, NA)]
    paste(users, collapse = ", ")
  }, character(1))

  tokens <- data.frame(
    token = c(required, conditional, optional),
    kind = rep(
      c("required", "conditional", "optional"),
      c(length(required), length(conditional), length(optional))
    ),
    default = c(
      rep(NA_character_, length(required) + length(conditional)),
      unlist(defaults, use.names = FALSE)
    ),
    needed_by = c(
      rep(NA_character_, length(required)),
      unname(needed_by),
      rep(NA_character_, length(optional))
    ),
    row.names = NULL,
    stringsAsFactors = FALSE
  )

  empty <- regmatches(raw, regexec(
    "^\\s*//\\s*allow-empty:\\s*(.+?)\\s*$", raw, perl = TRUE
  ))
  empty <- empty[lengths(empty) == 2]
  allow_empty <- unique(trimws(unlist(
    strsplit(vapply(empty, function(e) e[[2]], character(1)), ",", fixed = TRUE)
  )))

  pages <- regmatches(raw, regexec(
    "^\\s*//\\s*designed-pages:\\s*([0-9]+)\\s*$", raw
  ))
  pages <- pages[lengths(pages) == 2]
  designed_pages <- if (length(pages) == 0) {
    NA_integer_
  } else {
    as.integer(pages[[1]][[2]])
  }

  list(
    path = path, tokens = tokens, defaults = defaults, occurrences = occ,
    allow_empty = allow_empty, designed_pages = designed_pages
  )
}
