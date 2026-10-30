# Escape plain text for use in a content token

A value for a token that sits in the body of a template is Typst markup:
`*bold*` and `_italic_` work, and `#link(...)` embeds a link. That is
what you want for formatted text. For plain text from a database or a
free-text field, use `typst_escape()` so that characters Typst would
treat as markup (`#`, `$`, `*`, `_`, a backtick, `<`, `>`, `@`, `[`,
`]`, `~`, `/` and the backslash itself) show up literally instead of
breaking the compile. A slash is escaped so that `//` in the text, which
Typst reads as the start of a comment, cannot drop the rest of the line.
`-`, `.`, `+`, `=`, `'` and `"` are escaped too, so Typst's text
shortcuts leave the text as typed: `--` stays two hyphens rather than an
en dash, `-?` is not turned into an invisible soft hyphen, `...` is not
an ellipsis character, quotes stay straight, and a line that starts with
`-`, `+`, `=` or `1.` is not read as a list or heading.

## Usage

``` r
typst_escape(x)
```

## Arguments

- x:

  Character vector of plain text.

## Value

Character vector with a backslash before each special character; `NA`
stays `NA`.

## Details

Tokens that sit inside a quoted string in a template (organization
names, alt text, contact details, file paths) are escaped for you and do
not need this.

## Examples

``` r
typst_escape("Cost: $5 (see #3) [draft]")
#> [1] "Cost: \\$5 (see \\#3) \\[draft\\]"
```
