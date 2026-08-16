// syndromic_alert -- anomaly/threshold framing, generalized beyond
// overdose: an observed value crossed a statistical threshold against a
// baseline, for a given syndrome/condition, in a specific place/time.
// Modeled on ESSENCE-style syndromic surveillance alerts, but
// deliberately NOT overdose- or ESSENCE-specific -- alert_condition is a
// free token so this template also fits influenza-like illness,
// heat/cold events, or any other syndrome. See this package's design
// doc, docs/superpowers/specs/2026-08-16-spike-alert-templates-design.md,
// Section 7.
//
// Natural pagination (no #pagebreak()) -- same rationale as
// overdose_spike_alert/template.typ.
//
// SAMPLE CONTENT NOTICE: see cohort_summary/template.typ's header
// comment.
#import "theme.typ": theme, theme-grad
#import "components.typ": *

#let footer = page-footer(
  theme, theme-grad,
  "assets/partner-org-a-white.png", "Partner Organization A logo",
  "assets/primary-org-white.png", "Primary Organization logo",
  "assets/partner-org-b-white.png", "Partner Organization B logo",
  "{{{org_full}}}", "{{{contact_url}}}", "{{{contact_email}}}",
)

// See overdose_spike_alert/template.typ's identical comment on this
// pattern -- severity_level must be the literal lowercase string
// "warning" or "critical".
#let severity-color = if "{{{severity_level}}}" == "critical" { theme.severity-critical } else { theme.severity-warning }
#let severity-bg = if "{{{severity_level}}}" == "critical" { theme.severity-critical-bg } else { theme.severity-warning-bg }
#let severity-text-color = if "{{{severity_level}}}" == "critical" { theme.severity-critical-text } else { theme.severity-warning-text }

#apply-base-styles([{{{doc_title}}}], "{{{org_full}}}", theme, footer)[

#block(width: 100%, fill: theme-grad.brand-blue-grad, clip: true, inset: (x: 20pt, y: 10pt), above: 0pt, below: 0pt)[
  #place(top + right, dx: 40pt, dy: -30pt)[
    #pdf.artifact(kind: "background")[#image("assets/header-texture.png", width: 260pt)]
  ]
  #grid(columns: (auto, 1fr), column-gutter: 14pt, align: horizon,
    image("assets/primary-org-white.png", height: 28pt, alt: "Primary Organization logo"),
    [
      #text(fill: white, size: 12pt, weight: "bold")[{{{doc_title}}}] \
      #text(fill: white.transparentize(15%), size: 9pt)[{{{doc_subtitle}}}]
    ]
  )
]

#pad(x: theme.content-pad-x)[
#v(theme.space-md)

#block(breakable: false, fill: severity-bg, stroke: (left: theme.stroke-accent-left + severity-color, rest: theme.stroke-border + theme.box-border), radius: theme.radius-card, inset: (x: 10pt, y: 8pt), width: 100%)[
  #text(size: 11pt, weight: "bold", fill: severity-text-color)[⚠ ALERT] #h(1em)
  #text(size: 9pt, fill: severity-text-color)[{{{alert_condition}}} #sym.dot.c {{{alert_facility_region}}} #sym.dot.c issued {{{alert_issued_at}}}]
]

#v(theme.space-md)

#block(breakable: false)[
  #grid(columns: (1fr, 1fr), column-gutter: 8pt,
    fill: theme-grad.card-bg-grad, inset: 10pt,
    stroke: (x, ..) => (top: theme.stroke-accent + severity-color, rest: theme.stroke-border + theme.box-border),
    [
      #text(size: 28pt, weight: "bold", fill: severity-color)[{{{n_observed}}}] \
      #text(size: 8.5pt, fill: theme.text-secondary)[observed, vs. expected {{{n_expected}}}]
    ],
    [
      #text(size: 14pt, weight: "bold", fill: theme.brand-midnight)[{{{test_statistic_label}}}] \
      #text(size: 8.5pt, fill: theme.text-secondary)[{{{test_statistic_value}}}]
    ],
  )
]

#v(theme.space-md)

// ============================================================
// TREND LEADING TO ALERT -- boxed-sequence idiom, same visual grammar as
// trend_snapshot's 4-period grid, reused here for a fixed 5-day trailing
// window instead of calendar periods.
// ============================================================
= TREND LEADING TO ALERT
#v(theme.space-sm)
#block(breakable: false)[
  #grid(columns: (1fr, 1fr, 1fr, 1fr, 1fr), column-gutter: 4pt, align: horizon,
    fill: (x, ..) => if x == 4 { theme-grad.brand-blue-grad } else { theme-grad.card-bg-grad },
    inset: 8pt,
    stroke: (x, ..) => if x == 4 { theme.stroke-border + theme.brand-midnight } else { theme.stroke-border + theme.box-border },
    stat-card(theme, [{{{trend_d4}}}], [4 days ago]),
    stat-card(theme, [{{{trend_d3}}}], [3 days ago]),
    stat-card(theme, [{{{trend_d2}}}], [2 days ago]),
    stat-card(theme, [{{{trend_d1}}}], [Yesterday]),
    stat-card(theme, [{{{trend_d0}}}], [Today], color: severity-color),
  )
]

#v(theme.space-md)

#text-box(theme, theme-grad, [WHAT'S HAPPENING], [{{{narrative_text}}}])

#v(theme.space-sm)

// Optional -- see overdose_spike_alert/template.typ's identical comment
// on show_resources for why cluster_text still needs a value ("") even
// when show_cluster is false.
#if "{{{show_cluster}}}" == "true" [
  #text-box(theme, theme-grad, [CLUSTER DETECTION], [{{{cluster_text}}}], color: theme.brand-accent)
  #v(theme.space-sm)
]

#text-box(theme, theme-grad, [FACILITY / GEOGRAPHIC BREAKDOWN], [{{{geo_breakdown_text}}}])

#v(theme.space-sm)

#text-box(theme, theme-grad, [RECOMMENDED ACTIONS], [{{{actions_text}}}], color: theme.brand-accent)

#if "{{{show_resources}}}" == "true" [
  #v(theme.space-sm)
  #text-box(theme, theme-grad, [RESOURCES], [{{{resources_text}}}])
]

#v(theme.space-sm)
#text(size: 7pt, fill: theme.text-muted)[*Data sources:* {{{footnote_sources}}} #h(0.5em)|#h(0.5em) *Contact:* {{{org_full}}} at #link("mailto:{{{contact_email}}}")[{{{contact_email}}}]]
] // close body #pad(x: theme.content-pad-x)

] // close #apply-base-styles body
