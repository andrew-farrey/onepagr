#' Export a built-in template for customization
#'
#' Copies a template's full self-contained folder (`template.typ` plus
#' the resolved `theme.typ`, `components.typ`, and assets it needs to
#' compile independently) into `dest`, before any real data exists -- for
#' exploration, hand-editing, or handing to an AI coding assistant to
#' extend. That last case is a deliberate design goal, not an
#' afterthought: `render_onepager()` also never hides the `.typ` source
#' it compiles from by default, precisely so a real, readable, working
#' template is always sitting somewhere an AI assistant (or a
#' collaborator) can be pointed at to build a variation of it. Once
#' exported, the copy is the user's own; nothing in onepagr
#' auto-regenerates over it. Compile an exported template directly with
#' [compile_typst()].
#'
#' @param template Character. A built-in template name (see [list_templates()]).
#' @param dest Character. Directory to copy the template into. Created
#'   recursively if it doesn't exist.
#' @param theme Character. A built-in theme name, or a path to a custom
#'   theme .typ file, to resolve and copy in as `theme.typ`. Default
#'   `"default"`.
#' @return Character, `dest`, invisibly.
#' @export
export_template <- function(template, dest, theme = "default") {
  template_path <- resolve_template(template)
  template_src_dir <- dirname(template_path)
  theme_src <- resolve_theme(theme)
  components_src <- system.file("typst", "components.typ", package = "onepagr")
  assets_src <- system.file("typst", "assets", package = "onepagr")

  if (!dir.exists(dest)) {
    dir.create(dest, recursive = TRUE)
  }

  file.copy(
    list.files(template_src_dir, full.names = TRUE), dest, overwrite = TRUE
  )
  file.copy(theme_src, file.path(dest, "theme.typ"), overwrite = TRUE)
  file.copy(components_src, dest, overwrite = TRUE)
  if (dir.exists(assets_src)) {
    file.copy(assets_src, dest, recursive = TRUE, overwrite = TRUE)
  }

  invisible(dest)
}
