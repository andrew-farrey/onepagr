#' Render a onepagr one-pager to PDF
#'
#' The quick path: given data, a built-in template name, and a theme,
#' produces a finished PDF with a single call. Validates `data` against
#' the target template's required tokens before compiling (see
#' [compile_typst()]), so a missing value raises a clear R error instead
#' of silently rendering blank.
#'
#' By default (`keep_typst = TRUE`) the resolved, whisker-substituted
#' `.typ` file is written next to `output`, along with the theme,
#' components, and assets it was compiled with, self-contained and
#' independently recompilable, not hidden in a disposable tempdir. Set
#' `keep_typst = FALSE` to compile in a disposable tempdir instead and
#' return only the PDF.
#'
#' @param data Named list of whisker substitution values. For alert-style
#'   templates (`overdose_spike_alert`, `syndromic_alert`), the
#'   `severity_level` token must be the literal lowercase string
#'   `"warning"` or `"critical"`, and any `show_*` toggle token (e.g.
#'   `show_resources`, `show_cluster`) must be the literal lowercase
#'   string `"true"` or `"false"`. These are substituted directly into
#'   Typst string comparisons, so an R logical (which whisker coerces to
#'   `"TRUE"`/`"FALSE"`, uppercase) or any other value fails the compile
#'   loudly with a Typst `panic()` rather than silently rendering with
#'   the wrong severity styling or a mis-toggled section.
#' @param template Character. A built-in template name (see [list_templates()]).
#' @param theme Character. A built-in theme name, or a path to a custom
#'   theme .typ file (see [resolve_theme()]). Default `"default"`.
#' @param theme_path Character or `NULL`. Explicit theme file path
#'   override; when supplied, `theme` is ignored. Default `NULL`.
#' @param output Character. Path to write the compiled PDF to.
#' @param keep_typst Logical. Whether to leave the resolved `.typ` tree
#'   next to `output` (`TRUE`, default) or use a disposable tempdir
#'   (`FALSE`).
#' @param extra_assets Character vector of file paths to stage into the
#'   compile work directory alongside the theme/components/package assets,
#'   for per-run generated images (e.g. charts/maps produced fresh by
#'   the calling script) that a template's own `#image()` calls need to
#'   reference. Typst's compiler sandboxes file access to the directory
#'   being compiled from and rejects absolute filesystem paths outright
#'   (confirmed directly: `#image("C:/abs/path/map.png")` fails to
#'   compile with "path contains invalid component" even after fixing
#'   Windows backslashes to forward slashes: this isn't a path-syntax
#'   issue, Typst does not permit escaping its compile root at all). Each
#'   file is copied in by its basename (overwriting on conflict); pass
#'   just that basename as the corresponding whisker token's value (e.g.
#'   `extra_assets = "path/to/map0.png"` pairs with a template token value
#'   of `"map0.png"`, not the original full path). Default `character(0)`
#'   (no extra assets, e.g. for templates whose images are all static
#'   package assets).
#' @param font_dir Character or `NULL`. Passed through to
#'   [compile_typst()]'s `font_dir` argument, a directory of font files
#'   to make available for this compile, in addition to system fonts, for
#'   a theme's `text-font`/`heading-font` tokens that name a font not
#'   installed system-wide (e.g. a Posit Workbench deployment without
#'   permission to install fonts at the OS level). Default `NULL`.
#' @return Character, the `output` path, invisibly.
#' @examples
#' \dontrun{
#' # Needs Quarto (bundling Typst) on the system: see check_quarto().
#' # logo_*_path/header_texture_path below point at onepagr's own bundled
#' # placeholder assets (staged automatically); swap in your own images
#' # via extra_assets for real use: see vignette("theming").
#' data <- list(
#'   doc_title = "OVERDOSE SPIKE ALERT",
#'   doc_subtitle = "Sample County Surveillance",
#'   org_full = "Sample Health Department",
#'   contact_url = "https://example.org/",
#'   contact_email = "contact@example.org",
#'   logo_primary_path = "assets/primary-org-white.png",
#'   logo_primary_alt = "Sample Health Department logo",
#'   logo_partner_a_path = "assets/partner-org-a-white.png",
#'   logo_partner_a_alt = "Partner Organization A logo",
#'   show_partner_a = "false",
#'   logo_partner_b_path = "assets/partner-org-b-white.png",
#'   logo_partner_b_alt = "Partner Organization B logo",
#'   show_partner_b = "false",
#'   header_texture_path = "assets/header-texture.png",
#'   severity_level = "critical",
#'   alert_area = "Sample County",
#'   alert_issued_at = "August 26, 2026, 9:00 AM",
#'   n_events = "14",
#'   window_days = "3",
#'   n_spikes = "2",
#'   spike_window_days = "30",
#'   threshold = "8",
#'   narrative_text = "Sample County has recorded 14 suspected overdoses.",
#'   geo_breakdown_text = "- Northside: 6 events\n- Downtown: 5 events",
#'   actions_text = "- Increase naloxone distribution in the affected area",
#'   show_resources = "true",
#'   resources_text = "Sample Health Department, (555) 123-4567.",
#'   footnote_sources = "Sample Overdose Detection Mapping System"
#' )
#' render_onepager(
#'   data, template = "overdose_spike_alert", theme = "uk",
#'   output = file.path(tempdir(), "alert.pdf")
#' )
#' }
#' @export
render_onepager <- function(data, template, theme = "default",
                            theme_path = NULL, output, keep_typst = TRUE,
                            extra_assets = character(0), font_dir = NULL) {
  template_path <- resolve_template(template)
  template_src_dir <- dirname(template_path)
  theme_src <- resolve_theme(theme, theme_path)
  components_src <- system.file("typst", "components.typ", package = "onepagr")
  assets_src <- system.file("typst", "assets", package = "onepagr")

  if (!dir.exists(dirname(output))) {
    dir.create(dirname(output), recursive = TRUE)
  }

  if (isTRUE(keep_typst)) {
    work_dir <- paste0(tools::file_path_sans_ext(output), "_typst")
    dir.create(work_dir, showWarnings = FALSE)
  } else {
    work_dir <- tempfile()
    dir.create(work_dir)
    on.exit(unlink(work_dir, recursive = TRUE), add = TRUE)
  }

  file.copy(
    list.files(template_src_dir, full.names = TRUE), work_dir, overwrite = TRUE
  )
  # The template's own #import line reads a literal "theme.typ": copying
  # the resolved theme to that literal name in work_dir is what makes
  # theme swapping take effect without editing the template's import line.
  file.copy(theme_src, file.path(work_dir, "theme.typ"), overwrite = TRUE)
  file.copy(components_src, work_dir, overwrite = TRUE)
  if (dir.exists(assets_src)) {
    file.copy(assets_src, work_dir, recursive = TRUE, overwrite = TRUE)
  }
  if (length(extra_assets) > 0) {
    missing <- extra_assets[!file.exists(extra_assets)]
    if (length(missing) > 0) {
      stop(
        "extra_assets file(s) not found: ", paste(missing, collapse = ", "),
        call. = FALSE
      )
    }
    file.copy(extra_assets, work_dir, overwrite = TRUE)
  }

  staged_template <- file.path(work_dir, basename(template_path))
  compile_typst(staged_template, data, output, font_dir = font_dir)
}
