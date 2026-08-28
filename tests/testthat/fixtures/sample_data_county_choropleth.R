# map0_path..map4_path are basenames only, not full paths -- Typst's
# compiler sandboxes file access to its own compile directory and
# rejects absolute paths outright, so these must resolve to files
# render_onepager()'s extra_assets parameter stages into that directory
# (see R/render.R). The actual PNG files live in
# tests/testthat/fixtures/maps/ and are passed to render_onepager()'s
# extra_assets argument by tests that use this fixture, not referenced
# by path here.
sample_data_county_choropleth <- list(
  doc_title = "SAMPLE COUNTY VULNERABILITY SNAPSHOT",
  doc_subtitle = "Social Vulnerability and Overdose Mortality . Sample Region",
  org_full = "Primary Sample Organization",
  contact_url = "https://example.org/",
  contact_email = "contact@example.org",
  strip_data = "Sample SVI Index . Sample Vital Records",
  strip_period = "2020-2024",
  strip_design = "County Cross-Sectional",
  strip_geography = "Sample State (120 Counties)",
  n_statewide_od_deaths = "2,250",
  statewide_od_rate = "48.6",
  n_high_svi_counties = "40",
  data_vintage = "2022 vintage",
  map0_path = "map0.png",
  map0_caption = paste(
    "Sample finding: high SVI and high overdose death rates cluster",
    "together in the sample region's eastern counties."
  ),
  map1_path = "map1.png",
  map_title1 = "Unemployment vs. Overdose Death Rate",
  map1_caption = "Sample finding: strongest association in sample sub-region A.",
  map2_path = "map2.png",
  map_title2 = "Uninsured Rate vs. Overdose Death Rate",
  map2_caption = "Sample finding: strongest association in sample sub-region B.",
  map3_path = "map3.png",
  map_title3 = "Poverty Rate vs. Overdose Death Rate",
  map3_caption = "Sample finding: strongest association in sample sub-region C.",
  map4_path = "map4.png",
  map_title4 = "Housing Cost Burden vs. Overdose Death Rate",
  map4_caption = "Sample finding: strongest association in sample sub-region D.",
  disclaimer_text = paste(
    "These findings are based on preliminary sample data for illustration",
    "only. Numbers do not represent any real program, agency, or",
    "population. This is placeholder content demonstrating the onepagr",
    "template structure."
  ),
  footnote_sources = "Sample SVI Index . Sample Vital Records System"
)
