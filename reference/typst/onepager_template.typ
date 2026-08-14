// Sample One-Pager: "Cohort Summary" template -- whisker-tokenized Typst,
// rendered by render_onepager_typst.R via whisker::whisker.render().
// All placeholder tokens map to named elements in that script's `data`
// list -- edit values there, never hardcode numbers directly in this file.
// Static analytical prose (Background & Rationale paragraphs, "What This
// Data Adds" bullets, section headers) is NOT tokenized -- only
// data-derived values are tokens.
//
// This is a pure Typst file (no Quarto/pandoc wrapper). That's deliberate:
// routing this through Quarto's markdown layer caused three real bugs
// during prototyping of the real project this template generalizes --
// par.justify defaulting to true (stretched bold headers into ugly wide
// word-gaps), a hyphenation glyph rendering as a literal "4" character, and
// page-margin YAML merging unexpectedly with in-body #set page() calls.
// Compile directly with `quarto typst compile` (bundles Typst, no separate
// install) or a standalone `typst compile` if available.
//
// SAMPLE CONTENT NOTICE: every organization name, program name, dataset
// name, and figure in this file is placeholder/fictional, standing in for
// real content a consuming project would supply via
// render_onepager_typst.R and its own analysis output. The layout,
// styling, and accessibility patterns are the real, load-bearing part of
// this file -- the words and numbers are filler.
//
// THEME/COMPONENT ARCHITECTURE: this file pulls its color palette from
// theme.typ's `theme`/`theme-grad` dictionaries (swap that import for
// theme-alt.typ to re-skin every visual in this document -- nothing else
// needs to change) and its reusable widgets (stat-card, callout, bar-row,
// domain-bar, page-footer, apply-base-styles) from components.typ (shared
// across every onepagr template, not just this one). Every component
// takes `theme`/`theme-grad` as an explicit argument rather than importing
// a theme itself -- see theme.typ's header comment for the real bug that
// design avoids. apply-base-styles must wrap the ENTIRE document body,
// including the #pagebreak() below, not be called standalone -- see its
// comment in components.typ.
#import "theme.typ": theme, theme-grad
#import "components.typ": *

#let footer = page-footer(
  theme, theme-grad,
  "assets/partner-org-a-white.png", "Partner Organization A logo",
  "assets/primary-org-white.png", "Primary Organization logo",
  "assets/partner-org-b-white.png", "Partner Organization B logo",
  "{{{org_full}}}", "{{{contact_url}}}", "{{{contact_email}}}",
)

#apply-base-styles([{{{doc_title}}}], "{{{org_full}}}", theme, footer)[

// ============================================================
// HEADER
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
#block(fill: theme.brand-midnight, inset: (x: 20pt, y: 6pt), width: 100%, above: 0pt)[
  #text(fill: white, size: 8pt)[
    *DATA* {{{strip_data}}}  #h(1.5em)
    *PERIOD* {{{strip_period}}}  #h(1.5em)
    *DESIGN* {{{strip_design}}}  #h(1.5em)
    *GEOGRAPHY* {{{strip_geography}}}
  ]
]

#pad(x: 0.25in)[
#v(4pt)

// ============================================================
// COHORT AT A GLANCE
// ============================================================
= SAMPLE COHORT AT A GLANCE #sym.dash.en {{{strip_period}}} CASES
#v(3pt)

#let stat-card-colors = (theme.brand-blue, theme.brand-blue, theme.brand-accent, theme.brand-midnight)
#block(breakable: false)[
  #grid(
    columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 6pt,
    fill: theme-grad.card-bg-grad, inset: 6pt,
    stroke: (x, ..) => (top: 3pt + stat-card-colors.at(x), rest: 1pt + theme.box-border),
    stat-card(theme, [{{{n_decedents}}}], [Sample cases in the cohort]),
    stat-card(theme, [{{{n_ems_total}}}], [All-cause total linked encounters across the cohort]),
    stat-card(theme, [{{{pct_linked}}}], [Cases linked to #sym.gt.eq 1 encounter, {{{strip_period}}}], color: theme.brand-accent),
    stat-card(theme, [{{{n_prior_ems}}}], [Prior all-cause encounters before the reference date], color: theme.brand-midnight),
  )
]

#v(3pt)
#text(size: 7.5pt, fill: theme.text-muted)[Of {{{n_eligible_decedents}}} eligible cases in the sample region, {{{n_unlinked_decedents}}} were not linked to any encounter and are not reflected in the demographic profile below.]

// ============================================================
// BACKGROUND & RATIONALE / WHAT THIS DATA ADDS
// ============================================================
#v(4pt)
#grid(columns: (55fr, 45fr), column-gutter: 16pt,
  [
    = BACKGROUND & RATIONALE
  ],
  [
    = WHAT THIS DATA ADDS
  ]
)
#v(3pt)

#grid(columns: (55fr, 45fr), column-gutter: 16pt,
  [
    #text(size: 8.5pt)[The Primary Organization's Sample Case Records System tracks qualifying cases across the sample region and feeds into a broader national tracking system. Local reporting agencies are independently staffed and are not required to follow a single standardized documentation process. How much gets documented, and how well, can vary significantly from one reporting jurisdiction to another, and often leaves the case records system with limited history and context detail.]
    #v(6pt)
    #text(size: 8.5pt)[The linked encounter source, by contrast, records what happened at the time of the encounter itself, not after the fact. If a case had an earlier, related encounter, that encounter record can supply exactly the history and context detail that's often missing from the case records system alone.]
  ],
  [
    #text(size: 8.5pt)[
      - Location, disposition, and other-party presence at the time of the encounter
      - Documentation of interventions performed
      - Demographics, history, and social context
      - A longitudinal record of prior related encounters, including timing since the most recent one
    ]
    // Right column (bullets + this box) is shorter than the left column's
    // two paragraphs, so this grid row's height ends up set by the left
    // column, leaving leftover space below the bullets on this side.
    // 7pt (up from 3pt) centers the box within that leftover space --
    // measured directly against the real two-paragraph prose via #context
    // position probes; re-measure if this paragraph's length changes.
    #v(7pt)
    #rect(fill: theme-grad.callout-bg-grad, stroke: 1pt + theme.box-border, inset: (x: 8pt, y: 5pt), width: 100%)[
      #text(size: 7.5pt, fill: rgb("#1a3a7a"))[Linked cases' records also ran longer and richer: median word count *{{{wc_linked_median}}}* vs. *{{{wc_unlinked_median}}}* unlinked, with consistent gains across all five topic areas (see Key Findings, page 2).]
    ]
  ]
)

#v(3pt)
#callout(theme, theme-grad, [{{{n_prior_od_ems}}}], [Prior _related_ encounters identified across {{{n_decedents}}} linked cases, before each case's reference date #sym.dash.em each one a point of contact with the linked encounter source. (A single case may account for more than one encounter.)])

// ============================================================
// WHO IS CAPTURED BY LINKAGE?
// ============================================================
#v(4pt)
= WHO IS CAPTURED BY LINKAGE?
#v(3pt)

#rect(fill: theme-grad.card-bg-grad, stroke: (top: 3pt + theme.brand-midnight, rest: 1pt + theme.box-border), inset: 7pt, width: 100%)[
  #grid(columns: (1fr, 1fr), column-gutter: 16pt,
    [
      #text(size: 8pt, weight: "bold", tracking: 0.5pt)[GROUP A & REGION]
      #v(2pt)
      #bar-row(theme, [Category 1], {{{pct_linked_male_width}}}, "{{{n_male}}}")
      #bar-row(theme, [Category 2], {{{pct_linked_female_width}}}, "{{{n_female}}}")
      #v(2pt) #line(length: 100%, stroke: 0.5pt + theme.border-color) #v(2pt)
      #bar-row(theme, [Sub-region 1], {{{pct_linked_appalachian_width}}}, "{{{n_appalachian}}}")
      #bar-row(theme, [Sub-region 2], {{{pct_linked_nonappalachian_width}}}, "{{{n_nonappalachian}}}")
    ],
    [
      #text(size: 8pt, weight: "bold", tracking: 0.5pt)[GROUP B]
      #v(2pt)
      #bar-row(theme, [Category A], {{{pct_linked_white_width}}}, "{{{n_white}}}", label-width: 50pt)
      #bar-row(theme, [Category B], {{{pct_linked_black_width}}}, "{{{n_black}}}", label-width: 50pt)
      #bar-row(theme, [Other\*], {{{pct_linked_other_width}}}, "{{{n_other}}}", label-width: 50pt, muted: true)
      #v(3pt)
      #text(size: 7pt, fill: theme.text-muted)[\*Small subgroup within the linked cohort; interpret with caution.]
      #v(4pt)
      #text(size: 7pt, fill: theme.text-muted)[*Note:* Demographic breakdown of the linked case cohort (n = {{{n_decedents}}}), {{{strip_period}}}.]
    ]
  )
]

#v(3pt)
#rect(fill: theme-grad.card-bg-grad, stroke: (top: 3pt + theme.brand-midnight, rest: 1pt + theme.box-border), inset: 7pt, width: 100%)[
  #text(size: 8pt, weight: "bold", tracking: 0.5pt)[GROUP C]
  #v(2pt)
  #bar-row(theme, [Under 25], {{pct_linked_age_lt25_width}}, "{{n_age_lt25}}", label-width: 60pt)
  #bar-row(theme, [25#sym.dash.en 34], {{pct_linked_age_25_34_width}}, "{{n_age_25_34}}", label-width: 60pt)
  #bar-row(theme, [35#sym.dash.en 44], {{pct_linked_age_35_44_width}}, "{{n_age_35_44}}", label-width: 60pt)
  #bar-row(theme, [45#sym.dash.en 54], {{pct_linked_age_45_54_width}}, "{{n_age_45_54}}", label-width: 60pt)
  #bar-row(theme, [55#sym.dash.en 64], {{pct_linked_age_55_64_width}}, "{{n_age_55_64}}", label-width: 60pt)
  #bar-row(theme, [65 and over], {{pct_linked_age_65plus_width}}, "{{n_age_65plus}}", label-width: 60pt)
]

// ============================================================
// IMPLEMENTATION TIMELINE
// ============================================================
#v(4pt)
#block(breakable: false)[
  = IMPLEMENTATION TIMELINE
  #v(3pt)

  #grid(columns: (1fr, auto, 1fr, auto, 1fr), column-gutter: 6pt, align: horizon,
    inset: (x, y) => if calc.rem(x, 2) == 0 { 10pt } else { 0pt },
    fill: (x, ..) => if x == 2 { theme-grad.brand-blue-grad } else if calc.rem(x, 2) == 0 { theme-grad.callout-bg-grad } else { none },
    stroke: (x, ..) => if x == 2 { 1pt + theme.brand-midnight } else if calc.rem(x, 2) == 0 { 1pt + theme.box-border } else { none },
    [#align(center)[#text(size: 1.15em)[*{{tl1_yr}}*] \ #v(2pt) #text(size: 8.5pt)[{{tl1_label}}]]],
    text(size: 20pt, weight: "bold", fill: theme.brand-blue)[#sym.arrow.r],
    [#align(center)[#text(fill: white)[#text(size: 1.15em)[*{{tl2_yr}}*] \ #v(2pt) #text(size: 8.5pt)[{{tl2_label}}]]]],
    text(size: 20pt, weight: "bold", fill: theme.brand-blue)[#sym.arrow.r],
    [#align(center)[#text(size: 1.15em)[*{{tl3_yr}}*] \ #v(2pt) #text(size: 8.5pt)[{{tl3_label}}]]],
  )
]

] // close page-1 body #pad(x: 0.25in) -- pagebreak() can't be nested in a container
#pagebreak()
#pad(x: 0.25in)[
#v(3pt)

// ============================================================
// KEY FINDINGS (page 2)
// ============================================================
= KEY FINDINGS

#block(breakable: false)[
  #grid(columns: (1fr, 1fr), column-gutter: 6pt,
    fill: theme-grad.card-bg-grad, inset: 7pt, stroke: (top: 3pt + theme.brand-midnight, rest: 1pt + theme.box-border),
    [
      == PRIOR ENCOUNTER HISTORY AMONG LINKED CASES
      #v(4pt)
      #grid(columns: (1fr, 1fr),
        [#text(size: 24pt, weight: "bold", fill: theme.brand-blue)[{{{pct_any_prior_enc}}}] \ #text(size: 8pt, fill: theme.text-secondary)[Had #sym.gt.eq 1 prior related encounter]],
        align(right)[#text(size: 24pt, weight: "bold", fill: theme.brand-accent)[{{{pct_od_prior_enc}}}] \ #text(size: 8pt, fill: theme.text-secondary)[Had #sym.gt.eq 1 prior _qualifying_ encounter]],
      )
      #v(12pt)
      #rect(fill: theme-grad.callout-bg-grad, stroke: 1pt + theme.box-border, inset: 6pt, width: 100%)[
        #text(size: 8.5pt)[Mean prior related encounters per case: *{{{mean_prior_enc}}}* #sym.dot.c Median: *{{{median_prior_enc}}}*]
      ]
    ],
    [
      == SAMPLE INTERVENTION DOCUMENTATION IN PRIOR QUALIFYING ENCOUNTERS (N = {{{n_od_ems_denom}}})
      #v(4pt)
      #grid(columns: ({{{pct_naloxone_width}}}%, {{{pct_no_naloxone_width}}}%),
        box(fill: theme-grad.brand-blue-grad, stroke: 0.75pt + black, inset: 6pt, height: 38pt, width: 100%)[#align(horizon)[
          #text(fill: white, size: 8pt, weight: "bold")[{{{pct_naloxone}}} intervention documented] \
          #text(fill: white, size: 7pt)[{{{n_naloxone_enc}}} encounters with intervention]
        ]],
        box(fill: theme-grad.brand-sky-grad, stroke: 0.75pt + black, inset: 6pt, height: 38pt, width: 100%)[#align(horizon)[
          #text(fill: theme.brand-midnight, size: 8pt, weight: "bold")[{{{pct_no_naloxone}}} none] \
          #text(fill: theme.brand-midnight, size: 7pt)[{{{n_no_naloxone_enc}}} without intervention]
        ]],
      )
      #v(12pt)
      #text(size: 8.5pt)[Among _cases_: *{{{pct_decedent_nax}}}* had #sym.gt.eq 1 prior intervention-documented encounter]
    ],
  )
]

#v(2pt)
#rect(fill: theme-grad.card-bg-grad, stroke: (top: 3pt + theme.brand-midnight, rest: 1pt + theme.box-border), inset: 7pt, width: 100%)[
  == STRUCTURED FIELD COMPLETENESS: LINKED VS. UNLINKED RECORDS
  #v(2pt)
  #text(size: 7.5pt, fill: theme.text-secondary)[Linked cases' records more often have complete history and context since there are one or more linked encounter records from which to pull that information. Bars show the average size of that gap between linked and unlinked cases by category, per 100 cases.]
  #v(3pt)
  #figure(
    box(stroke: 1pt + black, width: 100%)[#image("assets/structured_field_diff_onepager.png", width: 100%)],
    alt: "Bar chart comparing structured-field completeness between linked and unlinked case records across sample categories, split into two facet groups. Linked records show more additional informative structured-field entries per 100 cases in every category shown.",
  )
]

#v(2pt)
#rect(fill: theme-grad.card-bg-grad, stroke: (top: 3pt + theme.brand-midnight, rest: 1pt + theme.box-border), inset: 7pt, width: 100%)[
  == LONGER, RICHER RECORDS AMONG LINKED CASES
  #v(2pt)
  #text(size: 7.5pt, fill: theme.text-secondary)[A linked encounter record gives reviewers more real-world detail to draw from — about the case, the setting, and the context. The word-count comparison on page 1 measures overall record length; the bars below measure additional domain-specific terms per record, on average, compared to unlinked cases (main record; secondary record about the same), {{{strip_period}}}.]
  #v(3pt)
  #domain-bar(theme, [Context], {{{domain_diff_scene}}})
  #domain-bar(theme, [History], {{{domain_diff_history}}})
  #domain-bar(theme, [Category A], {{{domain_diff_drug}}})
  #domain-bar(theme, [Category B], {{{domain_diff_medication}}})
  #domain-bar(theme, [Category C], {{{domain_diff_mental}}})
]

#v(2pt)
#rect(fill: theme-grad.card-bg-grad, stroke: (top: 3pt + theme.brand-midnight, rest: 1pt + theme.box-border), inset: 7pt, width: 100%)[
  == TIMING FROM LAST PRIOR QUALIFYING ENCOUNTER TO REFERENCE DATE (AMONG CASES WITH A PRIOR QUALIFYING ENCOUNTER, N = {{{timing_denom}}})
  #v(2pt)
  #text(size: 16pt, weight: "bold", fill: theme.brand-blue)[{{{median_days}}}] #text(size:8pt)[Median days (IQR: {{{timing_iqr}}})]  #h(1.5em)
  #text(size: 14pt, weight: "bold", fill: theme.brand-midnight)[{{{mean_days}}}] #text(size:8pt)[Mean days]
  #v(3pt)
  #bar-row(theme, [#sym.lt.eq 30 days], {{pct_30d_width}}, "{{n_30d}}", label-width: 65pt)
  #bar-row(theme, [#sym.lt.eq 90 days], {{pct_90d_width}}, "{{n_90d}}", label-width: 65pt)
  #bar-row(theme, [#sym.lt.eq 365 days], {{pct_365d_width}}, "{{n_365d}}", label-width: 65pt)
  #bar-row(theme, [#sym.gt 365 days], {{pct_gt365d_width}}, "{{n_gt365d}}", label-width: 65pt, muted: true)
]

#v(2pt)
#rect(fill: theme-grad.lessons-bg-grad, stroke: (left: 4pt + theme.brand-blue, rest: 1pt + theme.box-border), radius: (top-right: 4pt, bottom-right: 4pt), inset: 5pt, width: 100%)[
  // Was a plain styled #text() call -- visually reads as a section label
  // but tagged as an ordinary /P in the structure tree, not a heading. A
  // PAC AI-assisted check on the source project (score 0.84) flagged
  // exactly this pattern: a structural element visually presenting as a
  // heading but tagged as P. Scoping the heading show-rule locally to
  // this block, rather than editing the document-wide level-2 rule,
  // preserves this box's specific color/tracking without affecting any
  // other == heading elsewhere.
  #show heading: set text(size: 8pt, weight: "bold", fill: theme.lessons-text, tracking: 0.5pt)
  == LESSONS LEARNED & IMPLICATIONS
  #v(2pt)
  #text(size: 8.5pt, fill: theme.lessons-text)[{{{lessons_learned_text}}}]
]

#v(2pt)
#rect(fill: theme-grad.disclaimer-bg-grad, stroke: (left: 4pt + theme.disclaimer-border, rest: 1pt + theme.box-border), radius: (top-right: 4pt, bottom-right: 4pt), inset: 5pt, width: 100%)[
  // Same fix as LESSONS LEARNED above -- identical plain-#text()-as-
  // section-label pattern.
  #show heading: set text(size: 8pt, weight: "bold", fill: rgb("#6b5900"), tracking: 0.5pt)
  == DISCLAIMER
  #v(2pt)
  #text(size: 8pt, fill: rgb("#6b5900"))[{{{disclaimer_text}}}]
]

#v(2pt)
#text(size: 7pt, fill: theme.text-muted)[*Data sources:* {{{footnote_sources}}} #h(0.5em)|#h(0.5em) *Period:* {{{strip_period}}} #h(0.5em)|#h(0.5em) *Contact:* {{{org_full}}} at #link("mailto:{{{contact_email}}}")[{{{contact_email}}}]]
] // close body #pad(x: 0.25in)

] // close #apply-base-styles body
