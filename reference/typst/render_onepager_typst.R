# EMS-DOFSS Linkage One-Pager: Typst Renderer ----
# Renders onepager_template.typ via whisker (Mustache) + Typst's native
# PDF backend -- no browser, no chrome_print(), no HTML intermediary.
# All {{tokens}} in the template map to named elements in `data` below.
#
# PREREQUISITE: run "DOFSS-EMS Linkage One Pager Analysis - Fixed 22Q3-25.R"
# first, in the same R session, so the objects this script reads from
# (cohort_qa, sex_composition, race_composition, age_composition,
# region_composition, encounter_naloxone_stats, time_stats,
# time_to_death_df, one_pager_summary, narrative_text_metrics_enhanced,
# plot_narrative_domain_df, n_decedents, n_ems_total, etc.) already exist
# in the global environment. This script does not re-run that pipeline
# itself -- same division of labor as whisker/render_onepager_UKbrand.R,
# just targeting Typst instead of HTML. Re-run the analysis script first
# any time the underlying data changes, then re-run this script; the
# rendered PDF is never hand-edited or treated as a static artifact.
#
# WHY A PURE .typ TEMPLATE (not a .qmd):
# Routing this through Quarto's markdown/pandoc layer caused three real
# bugs during prototyping: par.justify defaulting to true (stretched
# short bold headers into ugly wide word-gaps), a hyphenation glyph
# rendering as a literal "4" character, and page-margin YAML merging
# unexpectedly with in-body #set page() calls. Compiling the .typ
# directly via `quarto typst compile` sidesteps all three -- full control,
# no inherited template defaults.

library(whisker)
library(readr)
library(here)

# Fallback so this script doesn't depend on .Renviron being correctly set
# for whatever session runs it. Prefers the user-local Quarto install
# (bundles a current Typst -- Workbench's system Quarto is frozen on an
# old version, currently Typst 0.10.0, several breaking releases behind)
# over whatever "quarto" resolves to on PATH, but falls back to PATH if
# that local install isn't present -- e.g. on a machine without it.
quarto_local <- path.expand("~/opt/quarto-1.10.18/bin/quarto")
if (Sys.getenv("QUARTO_PATH") == "") {
  Sys.setenv(QUARTO_PATH = if (file.exists(quarto_local)) quarto_local else unname(Sys.which("quarto")))
}


# Paths — the ONE place to edit if this project's layout differs ----
# Assumes typst/ sits as a sibling folder to plots/ inside the SAME
# project root (i.e. this whole repo moved/deployed together on Posit
# Workbench, not just the typst/ folder in isolation). If typst/ is ever
# deployed standalone, or the chart lives somewhere else on Workbench,
# change path_chart_source below -- nothing else in this script needs to
# know about it.

path_template     <- here("typst", "onepager_template.typ")
path_typ_out      <- here("typst", "onepager.typ")
path_pdf_out      <- here("typst", "onepager.pdf")
path_bbox_script  <- here("typst", "add_figure_bbox.py")
path_assets       <- here("typst", "assets")
path_chart_source <- here("plots", "structured_field_diff_onepager.png")


# Helpers ----

fmt_n   <- function(x) formatC(x, format = "d", big.mark = ",")
fmt_pct <- function(x, digits = 1) paste0(round(x, digits), "%")


# Keep the structured-field chart current every run ----
# Logos live directly in typst/assets/ and rarely change, so they're
# committed there like any other static asset -- no copy step, no second
# "source of truth" to keep in sync. The structured-field chart and
# narrative-domain data DO change whenever the analysis is re-run, so it's
# copied fresh from plots/ on every render rather than trusting a static
# snapshot to have been kept up to date. Fails loudly (not a silent skip)
# if plots/ doesn't have it yet, since a missing chart would otherwise
# surface later as a much more confusing Typst "file not found" error.

if (!file.exists(path_chart_source)) {
  stop(
    "Structured-field chart not found at expected path:\n  ", path_chart_source,
    "\nEither the chart script (plot_structured_field_diff_onepager.R) ",
    "hasn't been run yet, or update path_chart_source at the top of this ",
    "script if this project's layout differs from plots/ sitting next to typst/."
  )
}

file.copy(
  path_chart_source,
  file.path(path_assets, "structured_field_diff_onepager.png"),
  overwrite = TRUE
)
# header-texture.png has no upstream source (extracted once from the HTML
# template's embedded CSS background) -- not refreshed here, just kept in
# typst/assets/ as a static brand asset alongside the logos.


# Derive wordcount tokens from narrative_text_metrics_enhanced ----
# Pooled linked-vs-unlinked comparison over the full analytic window,
# main narrative only.

wc_pooled <- narrative_text_metrics_enhanced |>
  dplyr::filter(narrative_source == "narrative_main") |>
  dplyr::group_by(ems_linked) |>
  dplyr::summarise(median_words = stats::median(n_words, na.rm = TRUE), .groups = "drop")

wc_pull_pooled <- function(linked) {
  round(wc_pooled$median_words[wc_pooled$ems_linked == linked])
}

wc_linked_median   <- wc_pull_pooled(TRUE)
wc_unlinked_median <- wc_pull_pooled(FALSE)


# Derive domain term token values from plot_narrative_domain_df ----
# Averages mean_domain_diff across all three narrative sources per domain.
# All five domains shown on the one-pager now (page 2), not just two.

domain_avg <- plot_narrative_domain_df |>
  dplyr::group_by(domain) |>
  dplyr::summarise(avg_diff = mean(mean_domain_diff), .groups = "drop")

domain_pull <- function(d) {
  round(domain_avg$avg_diff[domain_avg$domain == d], 1)
}

domain_diff_scene      <- domain_pull("Scene Context Terms")
domain_diff_history    <- domain_pull("History Terms")
domain_diff_drug       <- domain_pull("Drug-Related Terms")
domain_diff_medication <- domain_pull("Medication Terms")
domain_diff_mental     <- domain_pull("Mental Health Terms")


# Derive naloxone tokens from encounter_naloxone_stats ----
n_od_enc       <- encounter_naloxone_stats$n_prior_od_encounters
pct_nax_raw    <- encounter_naloxone_stats$n_with_naloxone    / n_od_enc * 100
pct_no_nax_raw <- encounter_naloxone_stats$n_without_naloxone / n_od_enc * 100


# Derive timing tokens from time_stats / time_to_death_df ----
n_gt365d_count <- n_time_denom - time_stats$n_365d

timing_median_raw <- round(median(time_to_death_df$days_from_last_prior_od_to_death, na.rm = TRUE), 1)
timing_q1_raw <- round(quantile(time_to_death_df$days_from_last_prior_od_to_death, 0.25, na.rm = TRUE), 1)
timing_q3_raw <- round(quantile(time_to_death_df$days_from_last_prior_od_to_death, 0.75, na.rm = TRUE), 1)

pct_30d_raw    <- time_stats$n_30d  / n_time_denom * 100
pct_90d_raw    <- time_stats$n_90d  / n_time_denom * 100
pct_365d_raw   <- time_stats$n_365d / n_time_denom * 100
pct_gt365d_raw <- n_gt365d_count    / n_time_denom * 100


# Derive demographic/geographic composition tokens from *_composition ----
# Denominator for every % and n below is the linked cohort itself
# (n_decedents), pulled from *_composition tables (composition share, not
# linkage rate) -- "who are we linking?" not "who links more/less?".

demo_pct <- function(tbl, group_col, cat) tbl[["pct_linked"]][tbl[[group_col]] == cat]
demo_n   <- function(tbl, group_col, cat) tbl[["n"]][tbl[[group_col]] == cat]


# ============================================================
# DATA — edit values here, never touch onepager_template.typ
# ============================================================

data <- list(

  # -- Document metadata ----------------------------------------
  doc_title    = "LINKING EMS TO OVERDOSE FATALITY SURVEILLANCE DATA IN KENTUCKY",
  doc_subtitle = paste0(
    "KStARS–DOFSS/SUDORS Record Linkage · Kentucky, Q3 2022–2025 ",
    "· Kentucky Injury Prevention and Research Center"
  ),
  org_full      = "Kentucky Injury Prevention and Research Center (KIPRC)",
  contact_url   = "https://kiprc.uky.edu/",
  # "@" is Typst's label/reference syntax trigger -- literal "\@" is
  # required in any value that gets inserted into the .typ body, or Typst
  # errors with "label `<...>` does not exist".
  contact_email = "KIPRC\\@uky.edu",

  # -- Metadata strip -------------------------------------------
  strip_data      = "DOFSS · SUDORS · KStARS",
  strip_period    = "Q3 2022–2025",
  strip_design    = "Retrospective Linkage Cohort",
  strip_geography = "Statewide (120 Counties)",

  # -- Cohort stat cards ----------------------------------------
  n_decedents = fmt_n(n_decedents),
  n_ems_total = fmt_n(n_ems_total),
  pct_linked  = fmt_pct(pct_linked_decedents, digits = 0),
  n_prior_ems = fmt_n(n_prior_ems),

  n_eligible_decedents = fmt_n(cohort_qa$eligible_decedents),
  n_unlinked_decedents = fmt_n(cohort_qa$unlinked_decedents),

  n_coroner_counties = "120",

  # -- Who is captured by EMS linkage (composition, not rate) ----
  pct_linked_male_width = as.character(round(demo_pct(sex_composition, "sex_category", "Male"), 1)),
  n_male                = fmt_n(demo_n(sex_composition, "sex_category", "Male")),
  pct_linked_female_width = as.character(round(demo_pct(sex_composition, "sex_category", "Female"), 1)),
  n_female                = fmt_n(demo_n(sex_composition, "sex_category", "Female")),

  pct_linked_appalachian_width = as.character(round(demo_pct(region_composition, "region_category", "Appalachian KY"), 1)),
  n_appalachian                = fmt_n(demo_n(region_composition, "region_category", "Appalachian KY")),
  pct_linked_nonappalachian_width = as.character(round(demo_pct(region_composition, "region_category", "Non-Appalachian KY"), 1)),
  n_nonappalachian                = fmt_n(demo_n(region_composition, "region_category", "Non-Appalachian KY")),

  pct_linked_age_lt25_width  = as.character(round(demo_pct(age_composition, "age_group", "<25"), 1)),
  n_age_lt25                 = fmt_n(demo_n(age_composition, "age_group", "<25")),
  pct_linked_age_25_34_width = as.character(round(demo_pct(age_composition, "age_group", "25-34"), 1)),
  n_age_25_34                = fmt_n(demo_n(age_composition, "age_group", "25-34")),
  pct_linked_age_35_44_width = as.character(round(demo_pct(age_composition, "age_group", "35-44"), 1)),
  n_age_35_44                = fmt_n(demo_n(age_composition, "age_group", "35-44")),
  pct_linked_age_45_54_width = as.character(round(demo_pct(age_composition, "age_group", "45-54"), 1)),
  n_age_45_54                = fmt_n(demo_n(age_composition, "age_group", "45-54")),
  pct_linked_age_55_64_width = as.character(round(demo_pct(age_composition, "age_group", "55-64"), 1)),
  n_age_55_64                = fmt_n(demo_n(age_composition, "age_group", "55-64")),
  pct_linked_age_65plus_width = as.character(round(demo_pct(age_composition, "age_group", "65+"), 1)),
  n_age_65plus                = fmt_n(demo_n(age_composition, "age_group", "65+")),

  pct_linked_white_width = as.character(round(demo_pct(race_composition, "race_category", "White"), 1)),
  n_white                = fmt_n(demo_n(race_composition, "race_category", "White")),
  pct_linked_black_width = as.character(round(demo_pct(race_composition, "race_category", "Black"), 1)),
  n_black                = fmt_n(demo_n(race_composition, "race_category", "Black")),
  pct_linked_other_width = as.character(round(demo_pct(race_composition, "race_category", "Other"), 1)),
  n_other                = fmt_n(demo_n(race_composition, "race_category", "Other")),

  # -- Narrative depth (word count + domain-term enrichment) -----
  wc_linked_median   = as.character(wc_linked_median),
  wc_unlinked_median = as.character(wc_unlinked_median),

  domain_diff_scene      = as.character(domain_diff_scene),
  domain_diff_history    = as.character(domain_diff_history),
  domain_diff_drug       = as.character(domain_diff_drug),
  domain_diff_medication = as.character(domain_diff_medication),
  domain_diff_mental     = as.character(domain_diff_mental),

  # -- Background / rationale -----------------------------------
  n_prior_od_ems = fmt_n(n_od_enc),

  # -- Implementation timeline ------------------------------------
  tl1_yr    = "Late 2019",
  tl1_label = "Pilot: 75 overdose deaths randomly sampled from linked records; feasibility confirmed (not yet used by abstractors)",
  tl2_yr    = "2019–2022",
  tl2_label = "Kentucky State Ambulance Reporting system joined to DOFSS records in batch; linkage infrastructure built out",
  tl3_yr    = "Q3 2022–Present",
  tl3_label = "Abstractors used linked EMS data to inform DOFSS/SUDORS records; operational start of analysis period",

  # -- Key Findings: prior EMS encounter history ------------------
  pct_any_prior_enc = fmt_pct(one_pager_summary$pct_with_prior_encounter),
  pct_od_prior_enc  = fmt_pct(one_pager_summary$pct_with_prior_od),
  mean_prior_enc    = as.character(round(one_pager_summary$mean_prior_encounters, 1)),
  median_prior_enc  = as.character(round(one_pager_summary$median_prior_encounters, 1)),

  # -- Key Findings: naloxone documentation ------------------------
  n_od_ems_denom        = fmt_n(n_od_enc),
  pct_naloxone_width    = as.character(round(pct_nax_raw, 1)),
  pct_naloxone          = fmt_pct(pct_nax_raw),
  pct_no_naloxone_width = as.character(round(pct_no_nax_raw, 1)),
  pct_no_naloxone       = fmt_pct(pct_no_nax_raw),
  n_naloxone_enc        = fmt_n(encounter_naloxone_stats$n_with_naloxone),
  n_no_naloxone_enc     = fmt_n(encounter_naloxone_stats$n_without_naloxone),
  pct_decedent_nax      = fmt_pct(one_pager_summary$pct_with_prior_od_with_naloxone),

  # -- Key Findings: timing to death --------------------------------
  timing_denom = fmt_n(n_time_denom),
  median_days  = as.character(timing_median_raw),
  timing_iqr   = paste0(timing_q1_raw, "–", timing_q3_raw),
  mean_days    = as.character(round(time_stats$mean_days, 1)),

  pct_30d_width    = as.character(round(pct_30d_raw, 1)),
  n_30d            = fmt_n(time_stats$n_30d),
  pct_90d_width    = as.character(round(pct_90d_raw, 1)),
  n_90d            = fmt_n(time_stats$n_90d),
  pct_365d_width   = as.character(round(pct_365d_raw, 1)),
  n_365d           = fmt_n(time_stats$n_365d),
  pct_gt365d_width = as.character(round(pct_gt365d_raw, 1)),
  n_gt365d         = fmt_n(n_gt365d_count),

  # -- Lessons learned ----------------------------------------------
  lessons_learned_text = paste0(
    "Kentucky's experience demonstrates how both centralized and ",
    "decentralized death investigation systems can improve overdose ",
    "fatality surveillance through EMS record linkage. EMS records ",
    "provide an ongoing, population-level archive of medical ",
    "encounters, documenting recent overdose activity, naloxone ",
    "administration, bystander involvement, and timing since the last ",
    "known nonfatal episode, which fills documentation gaps ",
    "regardless of whether death investigation is coroner-based or ",
    "medical-examiner-based. Among decedents with a prior ",
    "overdose-related EMS encounter, ",
    fmt_pct(time_stats$n_30d / n_time_denom * 100),
    " had a contact within 30 days of their fatal overdose, ",
    "underscoring EMS's role as both a surveillance data source and a ",
    "frontline touchpoint for secondary overdose prevention and ",
    "treatment linkage."
  ),

  # -- Disclaimer -----------------------------------------------------
  # Linkage-correction caveat folded directly into the disclaimer text
  # (rather than a separate chart-caption token) -- one place, not two.
  disclaimer_text = paste0(
    "These findings are based on preliminary linked data. Numbers may not match ",
    "previously reported figures due to differences in record linkage methodology, ",
    "reporting period, or case definition. A subsequent linkage correction identified ",
    "49 additional linked decedents and additional EMS encounters for 294 previously ",
    "linked decedents, not yet incorporated into this abstraction. Data are subject ",
    "to revision. This project is supported by the Centers for Disease Control and ",
    "Prevention (CDC) of the U.S. Department of Health and Human Services (HHS) as ",
    # "$" is Typst's math-mode delimiter -- an unescaped "$" with no
    # matching close swallows everything after it into an unterminated
    # math expression, which is what actually caused the "unclosed
    # delimiter" errors cascading back to #pad(...)[ on an earlier line.
    "part of cooperative agreement 1 NU17CE010186 totaling \\$16,222,256 with 0% ",
    "financed with nongovernmental sources. The contents are those of the author(s) ",
    "and do not necessarily represent the official views of, nor an endorsement by, ",
    "CDC, HHS, or the U.S. government. For more information, please visit CDC.gov."
  ),

  # -- Footnote -------------------------------------------------------
  footnote_sources = paste0(
    "Drug Overdose Fatality Surveillance System (DOFSS) · ",
    "CDC State Unintentional Drug Overdose Reporting System (SUDORS) · ",
    "Kentucky State Ambulance Reporting System (KStARS)"
  )

) # end data list


# Render ----

template <- read_file(path_template)
output   <- whisker.render(template, data)
write_file(output, path_typ_out)

message("Typst source written to: ", path_typ_out)


# Compile to PDF ----
# `quarto typst compile` invokes Quarto's bundled Typst binary directly on
# a .typ file -- no pandoc, no markdown conversion, no Quarto template
# defaults involved. Requires the `quarto` CLI on PATH (Typst 0.15.1+ here;
# `--pdf-standard ua-1` and the `a11y-extras` feature flag both require a
# recent-enough Typst -- this is why the local ~/opt/ Quarto install matters).
#
# `--pdf-standard ua-1` makes Typst *enforce* PDF/UA-1 conformance (not just
# tag the document) and writes the PDF/UA identifier PAC flagged as missing.
# Verified clean: compiles with zero PDF/UA-1 errors and the PDF's own
# MarkInfo reports Suspects=False (Typst's own conformance checker finds
# nothing questionable in the tagging).
# `--features a11y-extras` unlocks pdf.header-cell/data-cell/table-summary
# (not currently used here) -- harmless to leave on.
result <- system2(
  Sys.getenv("QUARTO_PATH", unset = "quarto"),
  args = c(
    "typst", "compile",
    "--pdf-standard", "ua-1",
    "--features", "a11y-extras",
    shQuote(path_typ_out), shQuote(path_pdf_out)
  ),
  stdout = TRUE, stderr = TRUE
)
cat(result, sep = "\n")

if (!file.exists(path_pdf_out)) {
  stop("Typst compilation failed -- see output above.")
}

message("PDF written to: ", path_pdf_out)


# Post-process: inject Figure bounding boxes ----
# Typst 0.15.1 tags meaningful images (KIPRC logo, structured-field chart)
# as /Figure structure elements but never writes a /BBox layout attribute --
# confirmed as a genuine Typst limitation, not a template bug, via direct
# testing of 5 different markup patterns and inspection of the real
# structure tree (see add_figure_bbox.py's header comment for the full
# account). PAC's stricter check flags this ("Figure element on a single
# page with no bounding box") even though Typst's own --pdf-standard ua-1
# checker doesn't. This computes each figure's real on-page rectangle from
# the compiled PDF's own content stream -- correct regardless of how the
# data-driven layout shifts a figure's vertical position year to year --
# and writes it directly into the structure tree. Requires Python 3 with
# `pip install pypdf` available on PATH.
path_pdf_fixed <- here("typst", "onepager_fixed.pdf")
# Prefer this exact interpreter first -- Workbench has multiple Python
# installs (`python3` on PATH resolves to a bare-bones one with no pip),
# and pypdf was deliberately installed for this specific one instead.
# Falls back to generic PATH resolution for portability to other machines.
python_candidates <- c("/usr/bin/python3.11", Sys.which(c("python3", "python")))
python_bin <- python_candidates[file.exists(python_candidates)][1]

if (is.na(python_bin) || is.null(python_bin)) {
  warning(
    "No `python3`/`python` found on PATH -- skipped the Figure bounding-box ",
    "fix. The PDF above is otherwise complete but will still fail PAC's ",
    "'Figure element with no bounding box' check. Install Python 3 and run: ",
    "pip install pypdf"
  )
} else {
  bbox_result <- system2(
    python_bin,
    args = c(shQuote(path_bbox_script), shQuote(path_pdf_out), shQuote(path_pdf_fixed)),
    stdout = TRUE, stderr = TRUE
  )
  cat(bbox_result, sep = "\n")
  if (file.exists(path_pdf_fixed)) {
    file.rename(path_pdf_fixed, path_pdf_out)
    message("Figure bounding boxes injected: ", path_pdf_out)
  } else {
    warning(
      "Figure bounding-box post-processing failed -- see output above. ",
      "The PDF at ", path_pdf_out, " is otherwise complete (missing only ",
      "this one fix)."
    )
  }
}
