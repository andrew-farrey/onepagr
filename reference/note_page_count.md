# Message when a render's page count differs from the template's design

Internal. Silent for templates that declare no `designed-pages` marker
(natural pagination) and when pdftools is not installed.

## Usage

``` r
note_page_count(template_path, output, template)
```

## Arguments

- template_path:

  Character. The staged template `.typ`.

- output:

  Character. The compiled PDF.

- template:

  Character. The template name, for the message.

## Value

`invisible(NULL)`.
