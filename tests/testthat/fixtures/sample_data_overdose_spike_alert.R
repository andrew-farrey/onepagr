sample_data_overdose_spike_alert <- list(
  doc_title = "SAMPLE OVERDOSE SPIKE ALERT",
  doc_subtitle = "Sample Region Overdose Surveillance . Primary Sample Organization",
  org_full = "Primary Sample Organization",
  contact_url = "https://example.org/",
  contact_email = "contact\\@example.org",
  severity_level = "critical",
  alert_area = "Sample County",
  alert_issued_at = "August 16, 2026, 9:00 AM",
  n_events = "14",
  window_days = "3",
  n_spikes = "2",
  spike_window_days = "30",
  threshold = "8",
  narrative_text = paste(
    "Sample County has recorded 14 suspected overdoses in the past 3",
    "days, exceeding the county's spike threshold of 8 events. This is",
    "the second spike alert issued for this area in the past 30 days.",
    "Local response partners are coordinating an enhanced outreach",
    "effort in the affected area."
  ),
  geo_breakdown_text = paste(
    "- Northside: 6 events",
    "- Downtown: 5 events",
    "- Eastside: 3 events",
    sep = "\n"
  ),
  actions_text = paste(
    "- Increase naloxone distribution in the affected area",
    "- Alert local emergency departments and EMS to the ongoing spike",
    "- Share this alert with harm reduction and outreach partners",
    sep = "\n"
  ),
  show_resources = "true",
  resources_text = paste0(
    "Sample County Health Department, 123 Main Street, (555) 123-4567. ",
    "#link(\"https://example.org/naloxone\")",
    "[Naloxone distribution sites in Sample County]"
  ),
  footnote_sources = "Sample Overdose Detection Mapping System"
)
