// Sample One-Pager: "Trend Snapshot" template -- a second onepagr template,
// deliberately structured differently from onepager_template.typ's
// cohort-comparison rhythm. Where that one contrasts two groups (linked
// vs. unlinked) at a single point in time, this one tracks ONE metric
// across several time periods -- a different informational shape, not
// just a reskin of the same layout.
//
// Same rules as onepager_template.typ: pure Typst (no Quarto/pandoc
// wrapper), whisker-tokenized ({{{token}}} triple-brace, never {{token}}
// -- double-brace HTML-escapes and will corrupt any token containing
// "&"), static prose NOT tokenized. See onepager_template.typ's header
// comment for the fuller rationale on both of those, not repeated here.
//
// SAMPLE CONTENT NOTICE: every organization/program/dataset name and
// figure here is placeholder/fictional -- see onepager_template.typ.
//
// Shares theme.typ and components.typ with the cohort_summary template,
// same explicit theme/theme-grad-passed-as-argument pattern -- see
// theme.typ's header comment for why that (not a wildcard import) is
// what actually makes re-skinning work through shared components.
// apply-base-styles MUST wrap the entire document body including
// #pagebreak(); see components.typ's comment on that function before
// changing this file's structure.
#import "theme.typ": theme, theme-grad
#import "components.typ": *

// Template-specific tuning values -- unlike theme.typ's systemic tokens,
// these are specific to how THIS template's content happens to lay out,
// not something a different brand theme needs to know about. See this
// package's design doc, Section 3, for the full rationale on this split.
#let layout = (
  // Right column (bullets + callout) is shorter than the left column's
  // two paragraphs in the WHAT CHANGED / WHY IT MATTERS section, so that
  // grid row's height is set by the left column, leaving leftover space
  // below the bullets. This gap centers the callout box within that
  // leftover space -- measured directly against the real two-paragraph
  // prose via #context position probes; adjust if that paragraph's
  // length changes.
  narrative-callout-gap: 7pt,
)

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
  "assets/primary-org-white.png", "Partner Organization logo",
  "assets/partner-org-b-white.png", "Partner Organization B logo",
  "{{{org_full}}}", "{{{contact_url}}}", contact-email,
)

#apply-base-styles([{{{doc_title}}}], "{{{org_full}}}", theme, footer)[

// ============================================================
// HEADER (identical pattern to onepager_template.typ -- page furniture
// is exactly where sharing a look across templates matters most)
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
    *METRIC* {{{strip_design}}}  #h(1.5em)
    *COVERAGE* {{{strip_geography}}}
  ]
]

#pad(x: theme.content-pad-x)[
#v(theme.space-md)

// ============================================================
// HERO METRIC -- one dominant number + trend framing, not four
// side-by-side stat cards. Different visual center of gravity from
// onepager_template.typ's opening row.
// ============================================================
#block(breakable: false, fill: theme-grad.card-bg-grad, stroke: (top: theme.stroke-accent + theme.brand-blue, rest: theme.stroke-border + theme.box-border), inset: 10pt, width: 100%)[
  #grid(columns: (auto, 1fr), column-gutter: 18pt, align: horizon,
    [
      #text(size: 40pt, weight: "bold", fill: theme.brand-blue)[{{{pct_linked}}}]
    ],
    [
      #text(size: 10pt, weight: "bold")[{{{n_decedents}}} sample metric value, {{{strip_period}}}]
      #v(theme.space-xs)
      #text(size: 8pt, fill: theme.text-secondary)[Tracking {{{n_ems_total}}} total observations across the period below. Trend shown against {{{n_eligible_decedents}}} eligible units in the sample region.]
    ]
  )
]

#v(theme.space-md)
= TREND ACROSS PERIOD
#v(theme.space-sm)

// Four-period trend strip -- same "sequence of boxed cells" visual idiom
// as onepager_template.typ's IMPLEMENTATION TIMELINE, but reused here to
// show metric progression instead of a project milestone sequence. This
// is the kind of intentional component reuse the shared components.typ
// file is meant to enable: same visual grammar, different meaning.
#block(breakable: false)[
  #grid(columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 6pt, align: horizon,
    fill: theme-grad.card-bg-grad, inset: 8pt,
    stroke: (x, ..) => (top: theme.stroke-accent + theme.brand-blue, rest: theme.stroke-border + theme.box-border),
    stat-card(theme, [{{{pct_linked_male_width}}}%], [Period 1]),
    stat-card(theme, [{{{pct_linked_female_width}}}%], [Period 2]),
    stat-card(theme, [{{{pct_linked_appalachian_width}}}%], [Period 3], color: theme.brand-accent),
    stat-card(theme, [{{{pct_linked_nonappalachian_width}}}%], [Period 4 (current)], color: theme.brand-midnight),
  )
]

#v(theme.space-sm)
#text(size: 7.5pt, fill: theme.text-muted)[Values shown are the sample metric's share of {{{n_eligible_decedents}}} eligible units per period, {{{strip_period}}}. Not cumulative -- each period is measured independently.]

// ============================================================
// WHAT CHANGED / WHY IT MATTERS -- two-column narrative idiom reused
// from onepager_template.typ's Background & Rationale section, applied
// to a trend-explanation framing instead of a data-source-comparison
// framing.
// ============================================================
#v(theme.space-md)
#grid(columns: (55fr, 45fr), column-gutter: 16pt,
  [
    = WHAT CHANGED
  ],
  [
    = WHY IT MATTERS
  ]
)
#v(theme.space-sm)

#grid(columns: (55fr, 45fr), column-gutter: 16pt,
  [
    #text(size: 8.5pt)[The sample metric moved from {{{pct_linked_male_width}}}% in Period 1 to {{{pct_linked_nonappalachian_width}}}% by Period 4, the most recent period tracked. That shift coincides with a documented process change partway through the tracked window -- see Key Dates below for the specific timing.]
    #v(6pt)
    #text(size: 8.5pt)[A change of this size, sustained across more than one period rather than appearing in a single period alone, is unlikely to reflect measurement noise on its own. Confirming that requires the same kind of denominator and comparison-group discipline used throughout this template family -- see the disclaimer for this snapshot's specific caveats.]
  ],
  [
    #text(size: 8.5pt)[
      - Top sample driver category: Category 1
      - Second driver: Category 2
      - Third driver: Category 3
    ]
    #v(layout.narrative-callout-gap)
    #rect(fill: theme-grad.callout-bg-grad, stroke: 1pt + theme.box-border, inset: (x: 8pt, y: 5pt), width: 100%)[
      #text(size: 7.5pt, fill: theme.lessons-text)[Ranked by contribution to the overall shift; see the ranked breakdown below for the full per-category comparison.]
    ]
  ]
)

// ============================================================
// TOP DRIVERS -- ranked bar-row list, reused component from
// onepager_template.typ's demographic panel, applied to a ranking
// rather than a demographic composition.
// ============================================================
#v(theme.space-sm)
#rect(fill: theme-grad.card-bg-grad, stroke: (top: theme.stroke-accent + theme.brand-midnight, rest: theme.stroke-border + theme.box-border), inset: 7pt, width: 100%)[
  #text(size: 8pt, weight: "bold", tracking: 0.5pt)[TOP DRIVERS OF THE PERIOD-OVER-PERIOD CHANGE]
  #v(theme.space-xs)
  #bar-row(theme, [Category 1], {{{pct_linked_white_width}}}, "{{{n_white}}}", label-width: 80pt)
  #bar-row(theme, [Category 2], {{{pct_linked_black_width}}}, "{{{n_black}}}", label-width: 80pt)
  #bar-row(theme, [Category 3], {{{pct_linked_other_width}}}, "{{{n_other}}}", label-width: 80pt, muted: true)
]

// ============================================================
// PROCESS TIMELINE -- ties back to "a documented process change partway
// through the tracked window" in WHAT CHANGED above. Same boxed-sequence
// idiom as onepager_template.typ's IMPLEMENTATION TIMELINE and this
// template's own four-period trend strip above -- a third reuse of the
// same visual grammar, now for "what happened when" rather than "what's
// the current value" or "what's the project's build-out history."
// ============================================================
#v(theme.space-md)
#block(breakable: false)[
  = KEY DATES IN THE TRACKED WINDOW
  #v(theme.space-sm)

  #grid(columns: (1fr, auto, 1fr, auto, 1fr), column-gutter: 6pt, align: horizon,
    inset: (x, y) => if calc.rem(x, 2) == 0 { 10pt } else { 0pt },
    fill: (x, ..) => if x == 2 { theme-grad.brand-blue-grad } else if calc.rem(x, 2) == 0 { theme-grad.callout-bg-grad } else { none },
    stroke: (x, ..) => if x == 2 { 1pt + theme.brand-midnight } else if calc.rem(x, 2) == 0 { 1pt + theme.box-border } else { none },
    [#align(center)[#text(size: 1.15em)[*{{tl1_yr}}*] \ #v(theme.space-xs) #text(size: 8.5pt)[Window opens; baseline period begins]]],
    text(size: 20pt, weight: "bold", fill: theme.brand-blue)[#sym.arrow.r],
    [#align(center)[#text(fill: white)[#text(size: 1.15em)[*{{tl2_yr}}*] \ #v(theme.space-xs) #text(size: 8.5pt)[{{tl2_label}}]]]],
    text(size: 20pt, weight: "bold", fill: theme.brand-blue)[#sym.arrow.r],
    [#align(center)[#text(size: 1.15em)[*{{tl3_yr}}*] \ #v(theme.space-xs) #text(size: 8.5pt)[Current period; most recent value shown above]]],
  )
]

] // close page-1 body #pad(x: theme.content-pad-x) -- pagebreak() can't be nested in a container
#pagebreak()
#pad(x: theme.content-pad-x)[
#v(theme.space-sm)

// ============================================================
// DETAILED BREAKDOWN (page 2)
// ============================================================
= DETAILED BREAKDOWN

#block(breakable: false)[
  #grid(columns: (1fr, 1fr), column-gutter: 6pt,
    fill: theme-grad.card-bg-grad, inset: 7pt, stroke: (top: theme.stroke-accent + theme.brand-midnight, rest: theme.stroke-border + theme.box-border),
    [
      == SUB-METRIC A ACROSS THE TRACKED PERIOD
      #v(theme.space-md)
      #grid(columns: (1fr, 1fr),
        [#text(size: 24pt, weight: "bold", fill: theme.brand-blue)[{{{pct_any_prior_enc}}}] \ #text(size: 8pt, fill: theme.text-secondary)[Current period value]],
        align(right)[#text(size: 24pt, weight: "bold", fill: theme.brand-accent)[{{{pct_od_prior_enc}}}] \ #text(size: 8pt, fill: theme.text-secondary)[_Prior_ period value]],
      )
      #v(12pt)
      #rect(fill: theme-grad.callout-bg-grad, stroke: 1pt + theme.box-border, inset: 6pt, width: 100%)[
        #text(size: 8.5pt)[Mean per-period value: *{{{mean_prior_enc}}}* #sym.dot.c Median: *{{{median_prior_enc}}}*]
      ]
    ],
    [
      == SUB-METRIC B DOCUMENTATION (N = {{{n_od_ems_denom}}})
      #v(theme.space-md)
      #grid(columns: ({{{pct_naloxone_width}}}%, {{{pct_no_naloxone_width}}}%),
        box(fill: theme-grad.brand-blue-grad, stroke: 0.75pt + black, inset: 6pt, height: 38pt, width: 100%)[#align(horizon)[
          #text(fill: white, size: 8pt, weight: "bold")[{{{pct_naloxone}}} documented] \
          #text(fill: white, size: 7pt)[{{{n_naloxone_enc}}} observations]
        ]],
        box(fill: theme-grad.brand-sky-grad, stroke: 0.75pt + black, inset: 6pt, height: 38pt, width: 100%)[#align(horizon)[
          #text(fill: theme.brand-midnight, size: 8pt, weight: "bold")[{{{pct_no_naloxone}}} none] \
          #text(fill: theme.brand-midnight, size: 7pt)[{{{n_no_naloxone_enc}}} without]
        ]],
      )
      #v(12pt)
      #text(size: 8.5pt)[Overall: *{{{pct_decedent_nax}}}* of tracked units had #sym.gt.eq 1 documented observation]
    ],
  )
]

#v(theme.space-xs)
#rect(fill: theme-grad.card-bg-grad, stroke: (top: theme.stroke-accent + theme.brand-midnight, rest: theme.stroke-border + theme.box-border), inset: 7pt, width: 100%)[
  == PER-CATEGORY CHANGE, CURRENT VS. PRIOR PERIOD
  #v(theme.space-xs)
  #text(size: 7.5pt, fill: theme.text-secondary)[Bars show the per-category change between the current and prior tracked period, per 100 sample units.]
  #v(theme.space-sm)
  #figure(
    box(stroke: 1pt + black, width: 100%)[#image("assets/structured_field_diff_onepager.png", width: 100%)],
    alt: "Bar chart comparing per-category values between the current and prior tracked period across sample categories, split into two facet groups.",
  )
]

#v(theme.space-xs)
#rect(fill: theme-grad.card-bg-grad, stroke: (top: theme.stroke-accent + theme.brand-midnight, rest: theme.stroke-border + theme.box-border), inset: 7pt, width: 100%)[
  == MAGNITUDE OF CHANGE BY DOMAIN
  #v(theme.space-xs)
  #text(size: 7.5pt, fill: theme.text-secondary)[Additional domain-specific terms per record, current vs. prior period, {{{strip_period}}}.]
  #v(theme.space-sm)
  #domain-bar(theme, [Context], {{{domain_diff_scene}}})
  #domain-bar(theme, [History], {{{domain_diff_history}}})
  #domain-bar(theme, [Category A], {{{domain_diff_drug}}})
]

#v(theme.space-xs)
#rect(fill: theme-grad.lessons-bg-grad, stroke: (left: theme.stroke-accent-left + theme.brand-blue, rest: theme.stroke-border + theme.box-border), radius: theme.radius-card, inset: 5pt, width: 100%)[
  // Was a plain styled #text() call -- visually reads as a section label
  // but tagged as an ordinary /P in the structure tree, not a heading. A
  // PAC AI-assisted check on the source project (score 0.84) flagged
  // exactly this pattern. Scoping the heading show-rule locally to this
  // block, rather than editing the document-wide level-2 rule, preserves
  // this box's specific color/tracking without affecting any other ==
  // heading elsewhere.
  #show heading: set text(size: 8pt, weight: "bold", fill: theme.lessons-text, tracking: 0.5pt)
  == IMPLICATIONS
  #v(theme.space-xs)
  #text(size: 8.5pt, fill: theme.lessons-text)[{{{lessons_learned_text}}}]
]

#v(theme.space-xs)
#rect(fill: theme-grad.disclaimer-bg-grad, stroke: (left: theme.stroke-accent-left + theme.disclaimer-border, rest: theme.stroke-border + theme.box-border), radius: theme.radius-card, inset: 5pt, width: 100%)[
  // Same fix as IMPLICATIONS above -- identical plain-#text()-as-
  // section-label pattern.
  #show heading: set text(size: 8pt, weight: "bold", fill: theme.disclaimer-text, tracking: 0.5pt)
  == DISCLAIMER
  #v(theme.space-xs)
  #text(size: 8pt, fill: theme.disclaimer-text)[{{{disclaimer_text}}}]
]

#v(theme.space-xs)
#text(size: 7pt, fill: theme.text-muted)[*Data sources:* {{{footnote_sources}}} #h(0.5em)|#h(0.5em) *Period:* {{{strip_period}}} #h(0.5em)|#h(0.5em) *Contact:* {{{org_full}}} at #link("mailto:" + contact-email)[#contact-email]]
] // close body #pad(x: theme.content-pad-x)

] // close #apply-base-styles body
