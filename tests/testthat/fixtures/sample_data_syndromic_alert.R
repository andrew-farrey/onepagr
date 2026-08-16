sample_data_syndromic_alert <- list(
  doc_title = "SAMPLE SYNDROMIC SURVEILLANCE ALERT",
  doc_subtitle = "Sample Regional Syndromic Surveillance Program",
  org_full = "Primary Sample Organization",
  contact_url = "https://example.org/",
  contact_email = "contact\\@example.org",
  severity_level = "warning",
  alert_condition = "Influenza-like illness",
  alert_facility_region = "Sample Region, all reporting facilities",
  alert_issued_at = "August 16, 2026, 9:00 AM",
  n_observed = "142",
  n_expected = "88",
  test_statistic_label = "EWMA",
  test_statistic_value = "3.1 SD above baseline",
  trend_d4 = "95",
  trend_d3 = "101",
  trend_d2 = "118",
  trend_d1 = "130",
  trend_d0 = "142",
  narrative_text = paste(
    "Emergency department visits for influenza-like illness across",
    "Sample Region have risen steadily over the past 5 days, crossing",
    "the EWMA control limit as of today. No single facility accounts",
    "for the increase; the pattern is broad-based across the region."
  ),
  show_cluster = "false",
  cluster_text = "",
  geo_breakdown_text = paste(
    "- Sample General Hospital: 38 visits",
    "- Sample Regional Medical Center: 31 visits",
    "- Sample Community Clinic Network: 73 visits",
    sep = "\n"
  ),
  actions_text = paste(
    "- Encourage continued reporting from all sentinel sites",
    "- Consider public messaging on respiratory illness precautions",
    "- Monitor for any change in severity or hospitalization rate",
    sep = "\n"
  ),
  show_resources = "true",
  resources_text = paste0(
    "#link(\"https://www.cdc.gov/flu/\")",
    "[CDC influenza surveillance and prevention guidance]"
  ),
  footnote_sources = "Sample Syndromic Surveillance Network"
)
