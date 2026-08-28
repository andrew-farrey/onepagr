# Shared stub data for smoke-testing any onepagr reference template. Both
# onepager_template.typ and template_trend_snapshot.typ deliberately use
# the same token names, so this one data list drives either -- see
# test_render_stub.R and test_trend_snapshot.R.
#
# All values are placeholder/fictional; see the "SAMPLE CONTENT NOTICE" at
# the top of onepager_template.typ.

sample_data <- list(
  doc_title = "SAMPLE ONE-PAGER: PROGRAM DATA LINKAGE SUMMARY",
  doc_subtitle = "Sample Record Linkage . Sample Region, Q3 2022-2025 . Primary Sample Organization",
  org_full = "Primary Sample Organization",
  contact_url = "https://example.org/",
  contact_email = "contact@example.org",
  # Defaults match the package's own built-in assets exactly -- override
  # any of these (paired with render_onepager()'s extra_assets argument
  # for your own image files) to swap in your own branding without
  # exporting and hand-editing the template.
  logo_partner_a_path = "assets/partner-org-a-white.png",
  logo_partner_a_alt = "Partner Organization A logo",
  show_partner_a = "true",
  logo_primary_path = "assets/primary-org-white.png",
  logo_primary_alt = "Primary Organization logo",
  logo_partner_b_path = "assets/partner-org-b-white.png",
  logo_partner_b_alt = "Partner Organization B logo",
  show_partner_b = "true",
  header_texture_path = "assets/header-texture.png",
  strip_data = "Sample System A . Sample System B . Sample System C",
  strip_period = "Q3 2022-2025",
  strip_design = "Retrospective Linkage Cohort",
  strip_geography = "Sample Region (120 Counties)",
  n_decedents = "5,267",
  n_ems_total = "24,906",
  pct_linked = "84%",
  n_prior_ems = "21,021",
  n_eligible_decedents = "6,260",
  n_unlinked_decedents = "993",
  n_coroner_counties = "120",
  pct_linked_male_width = "64.6", n_male = "3,400",
  pct_linked_female_width = "35.4", n_female = "1,867",
  pct_linked_appalachian_width = "31.2", n_appalachian = "1,643",
  pct_linked_nonappalachian_width = "68.8", n_nonappalachian = "3,624",
  pct_linked_age_lt25_width = "8", n_age_lt25 = "421",
  pct_linked_age_25_34_width = "22", n_age_25_34 = "1,159",
  pct_linked_age_35_44_width = "27", n_age_35_44 = "1,422",
  pct_linked_age_45_54_width = "24", n_age_45_54 = "1,264",
  pct_linked_age_55_64_width = "14", n_age_55_64 = "737",
  pct_linked_age_65plus_width = "5", n_age_65plus = "264",
  pct_linked_white_width = "86", n_white = "4,527",
  pct_linked_black_width = "10.7", n_black = "574",
  pct_linked_other_width = "1.3", n_other = "66",
  wc_linked_median = "188", wc_unlinked_median = "121",
  domain_diff_scene = "6.8", domain_diff_history = "5.8",
  domain_diff_drug = "2.4", domain_diff_medication = "1.2", domain_diff_mental = "0.8",
  n_prior_od_ems = "5,189",
  tl1_yr = "Late 2019", tl1_label = "Pilot: 75 sample cases randomly sampled from linked records; feasibility confirmed",
  tl2_yr = "2019-2022", tl2_label = "Sample System B joined to sample case records in batch; linkage infrastructure built out",
  tl3_yr = "Q3 2022-Present", tl3_label = "Reviewers began using linked encounter data to inform case records; operational start of analysis period",
  pct_any_prior_enc = "76.9%", pct_od_prior_enc = "38.1%",
  mean_prior_enc = "4", median_prior_enc = "2",
  n_od_ems_denom = "5,189",
  pct_naloxone_width = "70.2", pct_naloxone = "70.2%",
  pct_no_naloxone_width = "29.8", pct_no_naloxone = "29.8%",
  n_naloxone_enc = "3,643", n_no_naloxone_enc = "1,546",
  pct_decedent_nax = "30.8%",
  timing_denom = "2,009", median_days = "330", timing_iqr = "53-941", mean_days = "575.1",
  pct_30d_width = "20.8", n_30d = "417",
  pct_90d_width = "29.8", n_90d = "598",
  pct_365d_width = "52.8", n_365d = "1,061",
  pct_gt365d_width = "47.2", n_gt365d = "948",
  lessons_learned_text = "This sample program's experience demonstrates how both centralized and decentralized data systems can improve case tracking through record linkage. Linked encounter records provide an ongoing, population-level archive, documenting recent activity, intervention details, and timing since the last known related event, which fills documentation gaps regardless of the source system's own structure. Among cases with a prior qualifying encounter, 20.8% had a contact within 30 days of the reference event, underscoring the linkage source's role as both a surveillance data source and a frontline touchpoint.",
  disclaimer_text = "These findings are based on preliminary sample data for illustration only. Numbers do not represent any real program, agency, or population. This is placeholder content demonstrating the onepagr template structure.",
  footnote_sources = "Sample System A . Sample System B . Sample System C",
  contact = "Primary Sample Organization at contact\\@example.org"
)
