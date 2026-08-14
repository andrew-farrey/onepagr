# Structured Field Enrichment — One-Pager Variant
# Retooled from structured_field_plot.R for the EMS_DOFSS_Onepager_UKbrand
# template rather than a PowerPoint slide.
#
# Same underlying data prep as structured_field_plot.R (top-5 fields per
# instrument, same field_label_short recoding) -- duplicated here rather
# than sourced, so this script has no load-order dependency on that file.
# If the field-label mapping changes (e.g. a data fix upstream), update
# both files.
#
# What's different from the slide version, and why:
#   - Wide/short (9.5 x 3.6in) instead of 4:3 (10 x 7.5in): the one-pager
#     has ~8.4in of usable width and almost no vertical slack, so a tall
#     chart is the wrong shape for it regardless of how good it looks on
#     a slide.
#   - Smaller fonts, sized for an ~8.4in embedded width, not a projected
#     slide viewed from across a room.
#   - Caption trimmed to just the 2025-linkage-correction note. The
#     generic "data are provisional... KIPRC... DOFSS=" boilerplate is
#     dropped because the one-pager template already has its own
#     Disclaimer and Footnote sections with that exact text -- repeating
#     it in the chart would be the same duplicate-content problem fixed
#     elsewhere on this page already.
#
# Re-run this whenever plot_structured_field_diff_df changes upstream.

library(dplyr)
library(ggplot2)
library(ragg)
library(scales)
library(stringr)
library(tidytext)


# -------------------------------------------------------------------------
# Caption
# -------------------------------------------------------------------------

caption_onepager <- stringr::str_wrap(
  paste0(
    "2025 results do not yet incorporate 49 newly linked decedents or ",
    "additional EMS encounters identified for 294 previously linked ",
    "decedents."
  ),
  width = 120
)


# -------------------------------------------------------------------------
# Data prep (identical to structured_field_plot.R)
# -------------------------------------------------------------------------

plot_structured_field_top5_df <- plot_structured_field_diff_df %>%
  mutate(
    instrument = as.character(instrument),
    field_label = as.character(field_label)
  ) %>%
  filter(
    !str_detect(
      field_label,
      regex("no\\s+intervention|intervention\\s+or\\s+unknown", ignore_case = TRUE)
    )
  ) %>%
  group_by(instrument) %>%
  # top 3, not top 5: this needs to be a fair space trade against the
  # couple of bullets it replaced, not a net addition to the page
  slice_max(order_by = mean_pct_diff, n = 3, with_ties = FALSE) %>%
  ungroup() %>%
  mutate(
    field_label_short = case_when(
      str_detect(field_label, regex("substance abuse problem.*yes", ignore_case = TRUE)) ~
        "Substance use problem",
      str_detect(field_label, regex("second mental illness", ignore_case = TRUE)) ~
        "Second mental health\ndiagnosis",
      str_detect(field_label, regex("first mental illness", ignore_case = TRUE)) ~
        "First mental health\ndiagnosis",
      str_detect(field_label, regex("coroner|medical examiner|\\bCME\\b", ignore_case = TRUE)) ~
        "CME circumstances\navailable",
      str_detect(field_label, regex("current diagnosed mental health problem", ignore_case = TRUE)) ~
        "Current mental-health\nproblem",
      str_detect(field_label, regex("ever treated for.*mental health", ignore_case = TRUE)) ~
        "Ever treated for a\nmental-health problem",
      str_detect(field_label, regex("other mental health diagnosis", ignore_case = TRUE)) ~
        "Other mental-health\ndiagnosis",
      str_detect(field_label, regex("alcohol dependence|alcohol problem", ignore_case = TRUE)) ~
        "Alcohol dependence\nor problem",
      str_detect(field_label, regex("other pain|acute.*chronic|chronic.*acute", ignore_case = TRUE)) ~
        "Acute or chronic\npain history",
      str_detect(field_label, regex("major injury", ignore_case = TRUE)) ~
        "History of\nmajor injury",
      str_detect(field_label, regex("presence of pulse|pulse on", ignore_case = TRUE)) ~
        "Pulse on first responder\narrival",
      str_detect(field_label, regex("heart disease", ignore_case = TRUE)) ~
        "Heart-disease history",
      str_detect(field_label, regex("CPR|LUCAS", ignore_case = TRUE)) ~
        "CPR or LUCAS\nprovided",
      str_detect(field_label, regex("rescue breathing|BVM", ignore_case = TRUE)) ~
        "Rescue breathing\nor BVM",
      str_detect(field_label, regex("epinephrine", ignore_case = TRUE)) ~
        "Epinephrine\nadministered",
      str_detect(field_label, regex("provided oxygen|oxygen provided|oxygen", ignore_case = TRUE)) ~
        "Oxygen provided",
      str_detect(field_label, regex("breathing problem", ignore_case = TRUE)) ~
        "Other breathing\nproblem",
      TRUE ~ str_wrap(field_label, width = 24)
    ),
    difference_per_100 = mean_pct_diff * 100,
    field_label_plot = tidytext::reorder_within(
      field_label_short, difference_per_100, instrument
    )
  )


# -------------------------------------------------------------------------
# Plot -- wide/short banner, smaller fonts, trimmed caption (see header)
# -------------------------------------------------------------------------

plot_structured_field_diff_onepager <- ggplot(
  plot_structured_field_top5_df,
  aes(x = difference_per_100, y = field_label_plot, fill = instrument)
) +
  geom_vline(xintercept = 0, color = "grey35", linewidth = 0.4, linetype = "dashed") +
  geom_col(width = 0.7, color = "black", linewidth = 0.3) +
  geom_text(
    # Spells out "linked decedents" directly on each bar rather than
    # relying on the reader to carry that context over from the axis
    # title or panel heading while scanning the bars themselves -- same
    # number, same metric, just fewer inference steps to read it.
    aes(label = paste0(
      "+", scales::number(difference_per_100, accuracy = 0.1), " per 100 linked decedents"
    )),
    hjust = -0.08, size = 3.2, fontface = "bold", color = "black"
  ) +
  facet_wrap(~instrument, scales = "free_y", nrow = 1) +
  tidytext::scale_y_reordered() +
  # The longer "+X per 100 linked decedents" label clipped badly at the
  # old limit of 42 (confirmed against the actual rendered PNG -- roughly
  # half of "linked decedents" was cut off past the bar's own end).
  # Raised further than the original 48-50 guess to actually clear it;
  # re-check the rendered PNG and raise further if any label still runs
  # off the right edge, rather than shortening the label back down.
  scale_x_continuous(
    breaks = c(0, 10, 20, 30),
    labels = scales::label_number(accuracy = 1),
    limits = c(0, 60),
    expand = expansion(mult = c(0, 0))
  ) +
  scale_fill_manual(values = pal_instr, guide = "none") +
  coord_cartesian(clip = "off") +
  # No title/subtitle/caption: this image sits directly under an HTML
  # <figcaption> in the template that already carries the description
  # and the 2025-provisional-correction note (see caption_onepager,
  # which is exported for that HTML caption to use, not baked into the
  # PNG). Baking the same text into the image too would be the same
  # duplicate-content problem already fixed once elsewhere on this page.
  labs(x = "Additional Informative Records per 100 Linked Decedents (vs. Unlinked)", y = NULL) +
  pub_theme +
  theme(
    strip.background = element_rect(fill = "grey95", color = "black", linewidth = 0.4),
    strip.text = element_text(
      size = 10.5, face = "bold", color = "black",
      margin = margin(t = 3, r = 3, b = 3, l = 3)
    ),
    axis.title.x = element_text(size = 9, color = "black", margin = margin(t = 5)),
    axis.text.x = element_text(size = 8, color = "grey20"),
    axis.text.y = element_text(
      size = 8.5, color = "grey20", lineheight = 0.9, margin = margin(r = 5)
    ),
    axis.ticks.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    panel.spacing.x = grid::unit(0.5, "in"),
    # r = 30 was sized for the old, shorter "+X per 100" bar label; the
    # right facet sits against the image's own outer edge with only this
    # margin as buffer. 110 fully cleared the longer "+X per 100 linked
    # decedents" label but left some visible dead space on the right;
    # splitting the difference against the original clipping point (30).
    # Still an estimate since I can't render this plot myself -- re-check
    # and nudge again if needed.
    plot.margin = margin(t = 6, r = 70, b = 4, l = 8)
  )

plot_structured_field_diff_onepager

# Height dropped from 3.6in to 1.7in: no title/subtitle/caption block, and
# 3 bars per facet instead of 5. Re-check against the actual rendered
# one-pager and adjust if it still reads as too tall/short.
ggsave(
  filename = "plots/structured_field_diff_onepager.png",
  plot = plot_structured_field_diff_onepager,
  width = 9.5,
  height = 1.7,
  units = "in",
  dpi = 300,
  bg = "white",
  device = ragg::agg_png
)
