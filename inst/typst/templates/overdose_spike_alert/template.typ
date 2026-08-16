// overdose_spike_alert -- anomaly/threshold framing: an observed value
// crossed a threshold in a specific place/time, here's what to do about
// it. Modeled on ODMAP-style overdose spike bulletins -- see this
// package's design doc,
// docs/superpowers/specs/2026-08-16-spike-alert-templates-design.md,
// Section 6, for the full field list and rationale.
//
// Unlike cohort_summary/trend_snapshot, this template uses NATURAL
// pagination -- no #pagebreak() -- since alert bulletins vary in length
// by how much needs to be said, rather than being curated to a fixed
// page count. Content just flows to however many pages it needs.
//
// SAMPLE CONTENT NOTICE: every organization/program name and figure in
// this file is placeholder/fictional -- see cohort_summary/template.typ's
// header comment for the fuller rationale (not repeated here).
//
// Same theme/component architecture as every onepagr template: theme.typ
// supplies theme/theme-grad as an explicit dictionary (never a wildcard
// import inside components.typ -- see theme.typ's header comment for the
// lexical-scoping bug that avoids), components.typ supplies shared
// widgets. apply-base-styles MUST wrap the entire document body.
#import "theme.typ": theme, theme-grad
#import "components.typ": *

#let footer = page-footer(
  theme, theme-grad,
  "assets/partner-org-a-white.png", "Partner Organization A logo",
  "assets/primary-org-white.png", "Primary Organization logo",
  "assets/partner-org-b-white.png", "Partner Organization B logo",
  "{{{org_full}}}", "{{{contact_url}}}", "{{{contact_email}}}",
)

// severity_level ("warning" or "critical") selects which theme severity
// token triple drives the banner and headline stat colors -- data-driven
// rather than fixed per template, since real alerts vary in urgency.
// Same substituted-into-code-position pattern as the existing templates'
// {{{pct_naloxone_width}}}% grid-column tokens: severity_level lands as
// a literal string directly in Typst code, not just markup content. The
// R caller MUST supply the literal lowercase string "warning" or
// "critical" here, not an R logical -- severity-palette() panics loudly
// otherwise instead of silently falling through -- see this plan's
// Global Constraints and components.typ's severity-palette() comment.
#let severity = severity-palette(theme, "{{{severity_level}}}")

#apply-base-styles([{{{doc_title}}}], "{{{org_full}}}", theme, footer)[

// ============================================================
// HEADER (same idiom as cohort_summary/trend_snapshot)
// ============================================================
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

// ============================================================
// SEVERITY BANNER -- replaces the DATA/PERIOD/DESIGN/GEOGRAPHY metadata
// strip band used by cohort_summary/trend_snapshot: the banner already
// carries the equivalent what/where/when framing for this template
// shape, so a separate strip band would be redundant.
// ============================================================
#block(breakable: false, fill: severity.bg, stroke: (left: theme.stroke-accent-left + severity.color, rest: theme.stroke-border + theme.box-border), radius: theme.radius-card, inset: (x: 10pt, y: 8pt), width: 100%)[
  #text(size: 11pt, weight: "bold", fill: severity.text)[⚠ SPIKE ALERT] #h(1em)
  #text(size: 9pt, fill: severity.text)[{{{alert_area}}} #sym.dot.c issued {{{alert_issued_at}}}]
]

#v(theme.space-md)

// ============================================================
// HEADLINE STATS -- the big 28pt numbers use severity.text (the darker
// text-optimized variant), not the vivid severity.color, since
// severity.color only clears WCAG contrast against card-bg at the 3:1
// large-text minimum for severity-critical, and FAILS it outright for
// severity-warning (~2.0:1) -- see themes/uk.typ and themes/default.typ
// header comments on the severity-*-text tokens.
// ============================================================
#block(breakable: false)[
  #grid(columns: (1fr, 1fr), column-gutter: 8pt,
    fill: theme-grad.card-bg-grad, inset: 10pt,
    stroke: (x, ..) => (top: theme.stroke-accent + severity.color, rest: theme.stroke-border + theme.box-border),
    [
      #text(size: 28pt, weight: "bold", fill: severity.text)[{{{n_events}}}] \
      #text(size: 8.5pt, fill: theme.text-secondary)[overdoses in the last {{{window_days}}} days]
    ],
    [
      #text(size: 28pt, weight: "bold", fill: severity.text)[{{{n_spikes}}}] \
      #text(size: 8.5pt, fill: theme.text-secondary)[spikes in the last {{{spike_window_days}}} days]
    ],
  )
]

#v(theme.space-xs)
#text(size: 7.5pt, fill: theme.text-muted)[Spike threshold: #sym.gt.eq {{{threshold}}} overdoses. {{{alert_area}}} met or exceeded this threshold, triggering this alert.]

#v(theme.space-md)

// ============================================================
// ALERT DETAILS -- H1 heading required for PDF/UA-1 structure
// ============================================================
= ALERT DETAILS
#v(theme.space-sm)

// ============================================================
// WHAT'S HAPPENING
// ============================================================
#text-box(theme, theme-grad, [WHAT'S HAPPENING], [{{{narrative_text}}}])

#v(theme.space-sm)

// ============================================================
// GEOGRAPHIC BREAKDOWN -- free text, not a fixed set of bar-row slots:
// which sub-areas are affected varies alert-to-alert and isn't bounded
// to a fixed count. The caller can embed real #bar-row(theme, ...) calls
// directly in geo_breakdown_text for the proportional-bar visual
// treatment, or plain text/bullets -- see design doc Section 6.
// ============================================================
#text-box(theme, theme-grad, [GEOGRAPHIC BREAKDOWN], [{{{geo_breakdown_text}}}])

#v(theme.space-sm)

// ============================================================
// RECOMMENDED ACTIONS
// ============================================================
#text-box(theme, theme-grad, [RECOMMENDED ACTIONS], [{{{actions_text}}}], color: theme.brand-accent)

// ============================================================
// LOCAL RESPONSE RESOURCES -- optional, gated on show_resources. The R
// data list must still supply resources_text (as "" when unused) even
// when show_resources is false: validate_template_data() doesn't parse
// Typst #if blocks, so every {{{token}}} in this file always needs SOME
// value -- see design doc Section 3.
// ============================================================
#if bool-token("show_resources", "{{{show_resources}}}") [
  #v(theme.space-sm)
  #text-box(theme, theme-grad, [LOCAL RESPONSE RESOURCES], [{{{resources_text}}}])
]

#v(theme.space-sm)
#text(size: 7pt, fill: theme.text-muted)[*Data sources:* {{{footnote_sources}}} #h(0.5em)|#h(0.5em) *Contact:* {{{org_full}}} at #link("mailto:{{{contact_email}}}")[{{{contact_email}}}]]
] // close body #pad(x: theme.content-pad-x)

] // close #apply-base-styles body
