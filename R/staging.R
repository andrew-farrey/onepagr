#' Copy files, and stop if any copy failed
#'
#' Internal. `file.copy()` reports a failed copy (a read-only or full disk, a
#' locked file on Windows) only through its return value, so the compile
#' would otherwise run against a partial tree.
#'
#' @param from,to,... Passed to [file.copy()].
#' @return `invisible(TRUE)`.
#' @noRd
copy_or_stop <- function(from, to, ...) {
  ok <- suppressWarnings(file.copy(from, to, ...))
  if (!all(ok)) {
    stop(
      "Could not copy ", paste(basename(from)[!ok], collapse = ", "),
      " into ", to, ". Check that the folder is writable and the disk is ",
      "not full.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

#' Copy a template's self-contained tree into a folder
#'
#' Internal, shared by [export_template()] and [render_onepager()]: the
#' template's own files, the resolved theme as `theme.typ`, `components.typ`,
#' and the bundled assets.
#'
#' @param template_path Character. Path to the template's `template.typ`.
#' @param theme_src Character. Path to the resolved theme file.
#' @param dest Character. An existing folder.
#' @return `invisible(dest)`.
#' @noRd
stage_template_files <- function(template_path, theme_src, dest) {
  copy_or_stop(
    list.files(dirname(template_path), full.names = TRUE), dest,
    overwrite = TRUE
  )
  # The template's own #import line reads a literal "theme.typ": copying the
  # resolved theme to that name is what makes theme swapping take effect
  # without editing the template.
  copy_or_stop(theme_src, file.path(dest, "theme.typ"), overwrite = TRUE)
  components_src <- system.file("typst", "components.typ", package = "onepagr")
  copy_or_stop(components_src, dest, overwrite = TRUE)
  assets_src <- system.file("typst", "assets", package = "onepagr")
  if (dir.exists(assets_src)) {
    copy_or_stop(assets_src, dest, recursive = TRUE, overwrite = TRUE)
  }
  invisible(dest)
}

#' Check the extra assets before anything is staged
#'
#' Internal. Every file must exist; none may share a file name with another
#' extra asset or with a file onepagr stages itself (`theme.typ`,
#' `components.typ`, the template's own files), because assets are copied in
#' by file name and would silently replace it.
#'
#' @param extra_assets Character vector of file paths.
#' @param template_path Character. Path to the template's `template.typ`.
#' @return `invisible(extra_assets)`.
#' @noRd
check_extra_assets <- function(extra_assets, template_path) {
  if (length(extra_assets) == 0) {
    return(invisible(extra_assets))
  }
  missing <- extra_assets[!file.exists(extra_assets)]
  if (length(missing) > 0) {
    stop(
      "extra_assets file(s) not found: ", paste(missing, collapse = ", "),
      call. = FALSE
    )
  }
  file_names <- basename(extra_assets)
  reserved <- c("theme.typ", "components.typ", list.files(dirname(template_path)))
  clash <- unique(intersect(file_names, reserved))
  if (length(clash) > 0) {
    stop(
      "extra_assets file name(s) would replace a package file: ",
      paste(clash, collapse = ", "), ". Rename the file(s).",
      call. = FALSE
    )
  }
  duplicated_names <- unique(file_names[duplicated(file_names)])
  if (length(duplicated_names) > 0) {
    stop(
      "Two or more extra_assets share the file name ",
      paste(duplicated_names, collapse = ", "), ". Rename one of them.",
      call. = FALSE
    )
  }
  invisible(extra_assets)
}

#' Create a fresh `<output>_typst` work folder
#'
#' Internal. The folder is a build artifact, so an earlier one is removed
#' first, but only when it carries the marker file this function leaves in
#' every folder it creates. Anything else at that path, including an
#' `export_template()` copy (which holds the same `theme.typ` and
#' `components.typ`) or a work folder from an earlier onepagr version, is
#' left alone and reported.
#'
#' @param output Character. The PDF path the folder belongs to.
#' @return Character, the new folder's path.
#' @noRd
fresh_work_dir <- function(output) {
  work_dir <- paste0(tools::file_path_sans_ext(output), "_typst")
  marker <- ".onepagr-work-folder"
  if (file.exists(work_dir)) {
    ours <- dir.exists(work_dir) && file.exists(file.path(work_dir, marker))
    if (!ours) {
      stop(
        "\"", work_dir, "\" already exists and is not an onepagr work ",
        "folder, so it was left alone. Remove it or choose another output ",
        "path.",
        call. = FALSE
      )
    }
    unlink(work_dir, recursive = TRUE)
  }
  dir.create(work_dir)
  file.create(file.path(work_dir, marker))
  work_dir
}
