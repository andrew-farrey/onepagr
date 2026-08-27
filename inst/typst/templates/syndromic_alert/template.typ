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

// Route contact_email through a variable rather than splicing
// {{{contact_email}}} directly into markup body wherever it's displayed.
// "\@"-escaping the token only fixes Typst's "@" label-syntax parsing
// for a value substituted into markup SOURCE text -- substituted into a
// quoted Typst STRING argument instead (page-footer's contact-email
// parameter, or a "mailto:" string), "\@" is not a recognized string
// escape and the literal backslash renders/breaks the link. Interpolating
// an already-evaluated string via #variable-name sidesteps this
// entirely -- confirmed directly while building county_choropleth's
// template, see that file's identical comment. Keep contact_email
// UNESCAPED in the R-side data.
#let contact-email = "{{{contact_email}}}"

#let footer = page-footer(
  theme, theme-grad,
  "assets/partner-org-a-white.png", "Partner Organization A logo",
  "assets/primary-org-white.png", "Primary Organization logo",
  "assets/partner-org-b-white.png", "Partner Organization B logo",
  "{{{org_full}}}", "{{{contact_url}}}", contact-email,
)

// See overdose_spike_alert/template.typ's identical comment on this
// pattern -- severity_level must be the literal lowercase string
// "warning" or "critical". severity-palette() panics loudly on anything
// else instead of silently falling through -- see components.typ's
// severity-palette() comment.
#let severity = severity-palette(theme, "{{{severity_level}}}")

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

#block(breakable: false, fill: severity.bg, stroke: (left: theme.stroke-accent-left + severity.color, rest: theme.stroke-border + theme.box-border), radius: theme.radius-card, inset: (x: 10pt, y: 8pt), width: 100%)[
  #text(size: 11pt, weight: "bold", fill: severity.text)[⚠ ALERT] #h(1em)
  #text(size: 9pt, fill: severity.text)[{{{alert_condition}}} #sym.dot.c {{{alert_facility_region}}} #sym.dot.c issued {{{alert_issued_at}}}]
]

#v(theme.space-md)

// The big 28pt number uses severity.text (the darker text-optimized
// variant), not the vivid severity.color -- same contrast fix as
// overdose_spike_alert's HEADLINE STATS block, see that file's comment.
#block(breakable: false)[
  #grid(columns: (1fr, 1fr), column-gutter: 8pt,
    fill: theme-grad.card-bg-grad, inset: 10pt,
    stroke: (x, ..) => (top: theme.stroke-accent + severity.color, rest: theme.stroke-border + theme.box-border),
    [
      #text(size: 28pt, weight: "bold", fill: severity.text)[{{{n_observed}}}] \
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
    // "Today" sits on the dark navy brand-blue-grad fill (column x == 4
    // above) -- stat-card's own colors (severity.color for the number,
    // theme.text-secondary for the label) are tuned for the light card
    // background and fail contrast here. stat-card has no label-color
    // parameter, so this cell is built manually instead of via
    // stat-card(), using the same single-wrap `text(fill: white)[...]`
    // pattern trend_snapshot/template.typ uses for its own highlighted
    // grid cell (see its "KEY DATES IN THE TRACKED WINDOW" block): the
    // inner #text() calls set only size/weight, not fill, so they
    // inherit white from the wrapper rather than fighting an explicit
    // fill of their own. See this file's fixed HEADLINE STATS comment
    // above for the same underlying contrast-fix rationale.
    align(center)[
      #text(fill: white)[
        #text(size: 22pt, weight: "bold")[{{{trend_d0}}}] \
        #text(size: 8pt)[Today]
      ]
    ],
  )
]

#v(theme.space-md)

// ============================================================
// ALERT DETAILS -- H1 heading required for PDF/UA-1 structure: without
// this, the five sections below (WHAT'S HAPPENING through RESOURCES)
// would improperly nest as children of "TREND LEADING TO ALERT" in the
// document's accessibility outline instead of being siblings of it. See
// overdose_spike_alert/template.typ's identical heading.
// ============================================================
= ALERT DETAILS
#v(theme.space-sm)

#text-box(theme, theme-grad, [WHAT'S HAPPENING], [{{{narrative_text}}}])

#v(theme.space-sm)

// Optional -- see overdose_spike_alert/template.typ's identical comment
// on show_resources for why cluster_text still needs a value ("") even
// when show_cluster is false.
#if bool-token("show_cluster", "{{{show_cluster}}}") [
  // brand-accent-text, not brand-accent -- see
  // overdose_spike_alert/template.typ's identical comment on this exact
  // fix.
  #text-box(theme, theme-grad, [CLUSTER DETECTION], [{{{cluster_text}}}], color: theme.brand-accent-text)
  #v(theme.space-sm)
]

#text-box(theme, theme-grad, [FACILITY / GEOGRAPHIC BREAKDOWN], [{{{geo_breakdown_text}}}])

#v(theme.space-sm)

// brand-accent-text, not brand-accent -- see
// overdose_spike_alert/template.typ's identical comment on this exact
// fix.
#text-box(theme, theme-grad, [RECOMMENDED ACTIONS], [{{{actions_text}}}], color: theme.brand-accent-text)

#if bool-token("show_resources", "{{{show_resources}}}") [
  #v(theme.space-sm)
  #text-box(theme, theme-grad, [RESOURCES], [{{{resources_text}}}])
]

#v(theme.space-sm)
#text(size: 7pt, fill: theme.text-muted)[*Data sources:* {{{footnote_sources}}} #h(0.5em)|#h(0.5em) *Contact:* {{{org_full}}} at #link("mailto:" + contact-email)[#contact-email]]
] // close body #pad(x: theme.content-pad-x)

] // close #apply-base-styles body
