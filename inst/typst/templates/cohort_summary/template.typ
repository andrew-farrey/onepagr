// Sample One-Pager: "Cohort Summary" template -- whisker-tokenized Typst,
// rendered by render_onepager_typst.R via whisker::whisker.render().
// All placeholder tokens map to named elements in that script's `data`
// list -- edit values there, never hardcode numbers directly in this file.
// The reader-facing text is tokenized too: section headings, captions,
// paragraphs, bullets, bar labels and alt text are optional tokens that
// default to the text shown here (see the optional-token blocks below, or
// template_tokens("cohort_summary") in R).
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
// theme.typ's `theme`/`theme-grad` dictionaries (onepagr's render/export
// functions stage the theme chosen via their `theme`/`theme_path`
// argument into a local file literally named theme.typ next to this
// template before compiling -- nothing in this file needs to change to
// re-skin) and its reusable widgets (stat-card, callout, bar-row,
// domain-bar, page-footer, apply-base-styles) from components.typ (shared
// across every onepagr template, not just this one). Every component
// takes `theme`/`theme-grad` as an explicit argument rather than importing
// a theme itself -- see theme.typ's header comment for the real bug that
// design avoids. apply-base-styles must wrap the ENTIRE document body,
// including the #pagebreak() below, not be called standalone -- see its
// comment in components.typ.
#import "theme.typ": theme, theme-grad
#import "components.typ": *
// designed-pages: 2
// Optional data: type and spacing controls (see the theming vignette).
// Empty means "use the theme's value".
// optional-token: min_font_size =
// optional-token: font_scale =
// optional-token: space_scale =
#let theme = apply-scales(theme, "{{{min_font_size}}}", "{{{font_scale}}}", "{{{space_scale}}}")

// Optional data: section headings and box labels. Each defaults to the
// text shown here, so a report needs to supply one only to reword it. A
// value is set as Typst markup: put a backslash before @, $, * , _ , # or
// a backtick to show it literally.
// optional-token: heading_glance = SAMPLE COHORT AT A GLANCE #sym.dash.en {{{strip_period}}} CASES
// optional-token: heading_background = BACKGROUND & RATIONALE
// optional-token: heading_data_adds = WHAT THIS DATA ADDS
// optional-token: heading_capture = WHO IS CAPTURED BY LINKAGE?
// optional-token: heading_timeline = IMPLEMENTATION TIMELINE
// optional-token: heading_key_findings = KEY FINDINGS
// optional-token: heading_prior_history = PRIOR ENCOUNTER HISTORY AMONG LINKED CASES
// optional-token: heading_intervention_docs = SAMPLE INTERVENTION DOCUMENTATION IN PRIOR QUALIFYING ENCOUNTERS (N = {{{n_od_ems_denom}}})
// optional-token: heading_completeness = STRUCTURED FIELD COMPLETENESS: LINKED VS. UNLINKED RECORDS
// optional-token: heading_richer_records = LONGER, RICHER RECORDS AMONG LINKED CASES
// optional-token: heading_timing = TIMING FROM LAST PRIOR QUALIFYING ENCOUNTER TO REFERENCE DATE (AMONG CASES WITH A PRIOR QUALIFYING ENCOUNTER, N = {{{timing_denom}}})
// optional-token: heading_lessons = LESSONS LEARNED & IMPLICATIONS
// optional-token: heading_disclaimer = DISCLAIMER
// Optional data: the reader-facing text. Each one defaults to the text
// shown here. Prefixes: strip_label_ and footer_label_ (metadata strip and
// footer labels), stat_ (captions on numbers), bar_ (bar-row labels),
// text_ (paragraphs, bullets and notes), alt_ (chart and map alt text),
// chips_ (a list of short items separated by |), figure_path and
// map_title0. A default may refer to data tokens, as {{{n_total}}} does.
// optional-token: strip_label_data = DATA
// optional-token: strip_label_period = PERIOD
// optional-token: strip_label_design = DESIGN
// optional-token: strip_label_geography = GEOGRAPHY
// optional-token: stat_cohort_cases = Sample cases in the cohort
// optional-token: stat_encounters_total = All-cause total linked encounters across the cohort
// optional-token: stat_pct_linked = Cases linked to #sym.gt.eq 1 encounter, {{{strip_period}}}
// optional-token: stat_prior_encounters = Prior all-cause encounters before the reference date
// optional-token: text_glance_note = Of {{{n_eligible_decedents}}} eligible cases in the sample region, {{{n_unlinked_decedents}}} were not linked to any encounter and are not reflected in the demographic profile below.
// optional-token: text_background_1 = The Primary Organization's Sample Case Records System tracks qualifying cases across the sample region and feeds into a broader national tracking system. Local reporting agencies are independently staffed and are not required to follow a single standardized documentation process. How much gets documented, and how well, can vary significantly from one reporting jurisdiction to another, and often leaves the case records system with limited history and context detail.
// optional-token: text_background_2 = The linked encounter source, by contrast, records what happened at the time of the encounter itself, not after the fact. If a case had an earlier, related encounter, that encounter record can supply exactly the history and context detail that's often missing from the case records system alone.
// optional-token: text_data_adds_1 = Location, disposition, and other-party presence at the time of the encounter
// optional-token: text_data_adds_2 = Documentation of interventions performed
// optional-token: text_data_adds_3 = Demographics, history, and social context
// optional-token: text_data_adds_4 = A longitudinal record of prior related encounters, including timing since the most recent one
// optional-token: text_linked_callout = Linked cases' records also ran longer and richer: median word count *{{{wc_linked_median}}}* vs. *{{{wc_unlinked_median}}}* unlinked, with consistent gains across all five topic areas (see Key Findings, page 2).
// optional-token: text_prior_callout = Prior _related_ encounters identified across {{{n_decedents}}} linked cases, before each case's reference date #sym.dash.em each one a point of contact with the linked encounter source. (A single case may account for more than one encounter.)
// optional-token: label_group_a = GROUP A & REGION
// optional-token: bar_a_1 = Category 1
// optional-token: bar_a_2 = Category 2
// optional-token: bar_a_3 = Sub-region 1
// optional-token: bar_a_4 = Sub-region 2
// optional-token: label_group_b = GROUP B
// optional-token: bar_b_1 = Category A
// optional-token: bar_b_2 = Category B
// optional-token: bar_b_3 = Other\*
// optional-token: text_small_subgroup_note = \*Small subgroup within the linked cohort; interpret with caution.
// optional-token: text_demographic_note = *Note:* Demographic breakdown of the linked case cohort (n = {{{n_decedents}}}), {{{strip_period}}}.
// optional-token: label_group_c = GROUP C
// optional-token: bar_c_1 = Under 25
// optional-token: bar_c_2 = 25#sym.dash.en 34
// optional-token: bar_c_3 = 35#sym.dash.en 44
// optional-token: bar_c_4 = 45#sym.dash.en 54
// optional-token: bar_c_5 = 55#sym.dash.en 64
// optional-token: bar_c_6 = 65 and over
// optional-token: stat_any_prior = Had #sym.gt.eq 1 prior related encounter
// optional-token: stat_qualifying_prior = Had #sym.gt.eq 1 prior _qualifying_ encounter
// optional-token: text_mean_median_prior = Mean prior related encounters per case: *{{{mean_prior_enc}}}* #sym.dot.c Median: *{{{median_prior_enc}}}*
// optional-token: stat_intervention_documented = intervention documented
// optional-token: stat_encounters_with = encounters with intervention
// optional-token: stat_no_intervention = none
// optional-token: stat_encounters_without = without intervention
// optional-token: text_cases_intervention = Among _cases_: *{{{pct_decedent_nax}}}* had #sym.gt.eq 1 prior intervention-documented encounter
// optional-token: text_completeness_intro = Linked cases' records more often have complete history and context since there are one or more linked encounter records from which to pull that information. Bars show the average size of that gap between linked and unlinked cases by category, per 100 cases.
// optional-token: figure_path = assets/structured_field_diff_onepager.png
// optional-token: alt_completeness_chart = Bar chart comparing structured-field completeness between linked and unlinked case records across sample categories, split into two facet groups. Linked records show more additional informative structured-field entries per 100 cases in every category shown.
// optional-token: text_richer_intro = A linked encounter record gives reviewers more real-world detail to draw from -- about the case, the setting, and the context. The word-count comparison on page 1 measures overall record length; the bars below measure additional domain-specific terms per record, on average, compared to unlinked cases (main record; secondary record about the same), {{{strip_period}}}.
// optional-token: bar_domain_1 = Context
// optional-token: bar_domain_2 = History
// optional-token: bar_domain_3 = Category A
// optional-token: bar_domain_4 = Category B
// optional-token: bar_domain_5 = Category C
// optional-token: stat_median_days = Median days (IQR: {{{timing_iqr}}})
// optional-token: stat_mean_days = Mean days
// optional-token: bar_timing_1 = #sym.lt.eq 30 days
// optional-token: bar_timing_2 = #sym.lt.eq 90 days
// optional-token: bar_timing_3 = #sym.lt.eq 365 days
// optional-token: bar_timing_4 = #sym.gt 365 days
// optional-token: footer_label_sources = Data sources:
// optional-token: footer_label_period = Period:
// optional-token: footer_label_contact = Contact:
// optional-token: footer_contact_joiner = at

// Template-specific tuning values -- unlike theme.typ's systemic tokens,
// these are specific to how THIS template's content happens to lay out,
// not something a different brand theme needs to know about. See this
// package's design doc, Section 3, for the full rationale on this split.
#let layout = (
  // Right column (bullets + callout) is shorter than the left column's
  // two paragraphs in the BACKGROUND & RATIONALE / WHAT THIS DATA ADDS
  // section, so that grid row's height is set by the left column,
  // leaving leftover space below the bullets. This gap centers the
  // callout box within that leftover space -- measured directly against
  // the real two-paragraph prose via #context position probes; adjust if
  // that paragraph's length changes.
  narrative-callout-gap: sp(theme, 7pt),
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

// Logo paths/alt-text and the header texture are tokens, not hardcoded
// literals, specifically so a consuming project can swap in its own
// branding without exporting and hand-editing this file: pass your own
// image files via render_onepager()'s extra_assets argument, and set
// these tokens to whatever basenames those files land under. Defaults
// (in this package's own fixtures) point at the built-in package
// assets, unchanged from before this became configurable.
// strip-links: false -- see the identical comment in
// county_choropleth/template.typ (same rationale: this template
// self-places the footer as real body content, not page(footer:)
// furniture, so the default link-stripping no longer applies).
// Optional data: a single-logo report needs only the primary logo. Both
// partner logos are off by default. Their path and alt text default to
// empty on purpose: a partner switched on without a path or alt text
// fails loudly in page-footer() instead of rendering a placeholder.
// optional-token: show_partner_a = false
// optional-token: logo_partner_a_path =
// optional-token: logo_partner_a_alt =
// optional-token: show_partner_b = false
// optional-token: logo_partner_b_path =
// optional-token: logo_partner_b_alt =
// optional-token: header_texture_path = assets/header-texture.png
#let footer = page-footer(
  theme, theme-grad,
  "{{{logo_partner_a_path}}}", "{{{logo_partner_a_alt}}}", "{{{show_partner_a}}}",
  "{{{logo_primary_path}}}", "{{{logo_primary_alt}}}",
  "{{{logo_partner_b_path}}}", "{{{logo_partner_b_alt}}}", "{{{show_partner_b}}}",
  "{{{org_full}}}", "{{{contact_url}}}", contact-email,
  strip-links: false,
)

// footer is placed explicitly per page below (#place(bottom + center,
// float: true)), NOT passed here -- see apply-base-styles()'s own
// comment in components.typ and county_choropleth/template.typ (where
// this pattern was verified first, including why `float: true` is
// required, not optional) for why: page(footer:) content is
// unconditionally excluded from the PDF's accessibility tree, alt text
// or not. margin-bottom is 0pt, not just "reduced" from
// apply-base-styles()'s 0.85in default -- that default reserved room for
// the OLD page(footer:) footer specifically, which the floated footer no
// longer needs, and unlike that old mechanism, this one does NOT
// tolerate a small positive margin as a safety buffer: any margin-bottom
// above 0pt shows up as a literal visible white gap between the footer's
// own fill and the true bottom edge of the page, since the footer is now
// real content sized to its own height rather than furniture that fills
// whatever margin region it's given. Caught on county_choropleth by a
// real analyst reviewing real output (not by any check in this
// package), confirmed pixel-exact there, fixed here for consistency
// across the whole template family rather than leaving this template
// with a different, undecided gap. Confirmed directly (real compile,
// checked page count and the PDF's own structure tree) that this
// template still holds at 2 pages at 0pt and gains real tagged /Figure
// entries for its footer logos. This template has no
// headline-map-height-equivalent adjustable element the way
// county_choropleth does, so its own margin/content cliff has NOT been
// independently swept the same rigorous way -- if this page's content
// grows in the future (more text, more bar-rows), re-verify the page
// count directly rather than assuming this margin still holds.
#apply-base-styles([{{{doc_title}}}], "{{{org_full}}}", theme, margin-bottom: 0pt)[

// ============================================================
// HEADER
// ============================================================
#block(width: 100%, fill: theme-grad.brand-blue-grad, clip: true, inset: (x: sp(theme, 20pt), y: sp(theme, 10pt)), above: 0pt, below: 0pt)[
  #place(top + right, dx: 40pt, dy: -30pt)[
    #pdf.artifact(kind: "other")[#image("{{{header_texture_path}}}", width: 260pt)]
  ]
  #grid(columns: (auto, 1fr), column-gutter: sp(theme, 14pt), align: horizon,
    image("{{{logo_primary_path}}}", height: 28pt, alt: "{{{logo_primary_alt}}}"),
    [
      #text(fill: white, size: fs(theme, 12pt), weight: "bold")[{{{doc_title}}}] \
      #text(fill: white.transparentize(15%), size: fs(theme, 9pt))[{{{doc_subtitle}}}]
    ]
  )
]
#block(fill: theme.brand-midnight, inset: (x: sp(theme, 20pt), y: sp(theme, 6pt)), width: 100%, above: 0pt)[
  #text(fill: white, size: fs(theme, 8pt))[
    *{{{strip_label_data}}}* {{{strip_data}}}  #h(1.5em)
    *{{{strip_label_period}}}* {{{strip_period}}}  #h(1.5em)
    *{{{strip_label_design}}}* {{{strip_design}}}  #h(1.5em)
    *{{{strip_label_geography}}}* {{{strip_geography}}}
  ]
]

#pad(x: theme.content-pad-x)[
#v(theme.space-md)

// ============================================================
// COHORT AT A GLANCE
// ============================================================
= {{{heading_glance}}}
#v(theme.space-sm)

#let stat-card-colors = (theme.brand-blue, theme.brand-blue, theme.brand-accent, theme.brand-midnight)
#block(breakable: false)[
  #grid(
    columns: (1fr, 1fr, 1fr, 1fr), column-gutter: sp(theme, 6pt),
    fill: theme-grad.card-bg-grad, inset: sp(theme, 6pt),
    stroke: (x, ..) => (top: theme.stroke-accent + stat-card-colors.at(x), rest: theme.stroke-border + theme.box-border),
    stat-card(theme, [{{{n_decedents}}}], [{{{stat_cohort_cases}}}]),
    stat-card(theme, [{{{n_ems_total}}}], [{{{stat_encounters_total}}}]),
    stat-card(theme, [{{{pct_linked}}}], [{{{stat_pct_linked}}}], color: theme.brand-accent),
    stat-card(theme, [{{{n_prior_ems}}}], [{{{stat_prior_encounters}}}], color: theme.brand-midnight),
  )
]

#v(theme.space-sm)
#text(size: fs(theme, 7.5pt), fill: theme.text-muted)[{{{text_glance_note}}}]

// ============================================================
// BACKGROUND & RATIONALE / WHAT THIS DATA ADDS
// ============================================================
#v(theme.space-md)
#grid(columns: (55fr, 45fr), column-gutter: sp(theme, 16pt),
  [
    = {{{heading_background}}}
  ],
  [
    = {{{heading_data_adds}}}
  ]
)
#v(theme.space-sm)

#grid(columns: (55fr, 45fr), column-gutter: sp(theme, 16pt),
  [
    #text(size: fs(theme, 8.5pt))[{{{text_background_1}}}]
    #v(sp(theme, 6pt))
    #text(size: fs(theme, 8.5pt))[{{{text_background_2}}}]
  ],
  [
    #text(size: fs(theme, 8.5pt))[
      - {{{text_data_adds_1}}}
      - {{{text_data_adds_2}}}
      - {{{text_data_adds_3}}}
      - {{{text_data_adds_4}}}
    ]
    // Right column (bullets + this box) is shorter than the left column's
    // two paragraphs, so this grid row's height ends up set by the left
    // column, leaving leftover space below the bullets on this side.
    // 7pt (up from 3pt) centers the box within that leftover space --
    // measured directly against the real two-paragraph prose via #context
    // position probes; re-measure if this paragraph's length changes.
    #v(layout.narrative-callout-gap)
    #rect(fill: theme-grad.callout-bg-grad, stroke: 1pt + theme.box-border, inset: (x: sp(theme, 8pt), y: sp(theme, 5pt)), width: 100%)[
      #text(size: fs(theme, 7.5pt), fill: theme.lessons-text)[{{{text_linked_callout}}}]
    ]
  ]
)

#v(theme.space-sm)
#callout(theme, theme-grad, [{{{n_prior_od_ems}}}], [{{{text_prior_callout}}}])

// ============================================================
// WHO IS CAPTURED BY LINKAGE?
// ============================================================
#v(theme.space-md)
= {{{heading_capture}}}
#v(theme.space-sm)

#rect(fill: theme-grad.card-bg-grad, stroke: (top: theme.stroke-accent + theme.brand-midnight, rest: theme.stroke-border + theme.box-border), inset: sp(theme, 7pt), width: 100%)[
  #grid(columns: (1fr, 1fr), column-gutter: sp(theme, 16pt),
    [
      #text(size: fs(theme, 8pt), weight: "bold", tracking: fd(theme, 0.5pt))[{{{label_group_a}}}]
      #v(theme.space-xs)
      #bar-row(theme, [{{{bar_a_1}}}], {{{pct_linked_male_width}}}, "{{{n_male}}}")
      #bar-row(theme, [{{{bar_a_2}}}], {{{pct_linked_female_width}}}, "{{{n_female}}}")
      #v(theme.space-xs) #line(length: 100%, stroke: 0.5pt + theme.border-color) #v(theme.space-xs)
      #bar-row(theme, [{{{bar_a_3}}}], {{{pct_linked_appalachian_width}}}, "{{{n_appalachian}}}")
      #bar-row(theme, [{{{bar_a_4}}}], {{{pct_linked_nonappalachian_width}}}, "{{{n_nonappalachian}}}")
    ],
    [
      #text(size: fs(theme, 8pt), weight: "bold", tracking: fd(theme, 0.5pt))[{{{label_group_b}}}]
      #v(theme.space-xs)
      #bar-row(theme, [{{{bar_b_1}}}], {{{pct_linked_white_width}}}, "{{{n_white}}}", label-width: 50pt)
      #bar-row(theme, [{{{bar_b_2}}}], {{{pct_linked_black_width}}}, "{{{n_black}}}", label-width: 50pt)
      #bar-row(theme, [{{{bar_b_3}}}], {{{pct_linked_other_width}}}, "{{{n_other}}}", label-width: 50pt, muted: true)
      #v(theme.space-sm)
      #text(size: fs(theme, 7pt), fill: theme.text-muted)[{{{text_small_subgroup_note}}}]
      #v(theme.space-md)
      #text(size: fs(theme, 7pt), fill: theme.text-muted)[{{{text_demographic_note}}}]
    ]
  )
]

#v(theme.space-sm)
#rect(fill: theme-grad.card-bg-grad, stroke: (top: theme.stroke-accent + theme.brand-midnight, rest: theme.stroke-border + theme.box-border), inset: sp(theme, 7pt), width: 100%)[
  #text(size: fs(theme, 8pt), weight: "bold", tracking: fd(theme, 0.5pt))[{{{label_group_c}}}]
  #v(theme.space-xs)
  #bar-row(theme, [{{{bar_c_1}}}], {{{pct_linked_age_lt25_width}}}, "{{{n_age_lt25}}}", label-width: 60pt)
  #bar-row(theme, [{{{bar_c_2}}}], {{{pct_linked_age_25_34_width}}}, "{{{n_age_25_34}}}", label-width: 60pt)
  #bar-row(theme, [{{{bar_c_3}}}], {{{pct_linked_age_35_44_width}}}, "{{{n_age_35_44}}}", label-width: 60pt)
  #bar-row(theme, [{{{bar_c_4}}}], {{{pct_linked_age_45_54_width}}}, "{{{n_age_45_54}}}", label-width: 60pt)
  #bar-row(theme, [{{{bar_c_5}}}], {{{pct_linked_age_55_64_width}}}, "{{{n_age_55_64}}}", label-width: 60pt)
  #bar-row(theme, [{{{bar_c_6}}}], {{{pct_linked_age_65plus_width}}}, "{{{n_age_65plus}}}", label-width: 60pt)
]

// ============================================================
// IMPLEMENTATION TIMELINE
// ============================================================
#v(theme.space-md)
#block(breakable: false)[
  = {{{heading_timeline}}}
  #v(theme.space-sm)

  // Color emphasis escalates left to right (empty -> light -> dark) and
  // peaks on the LAST box (x == 4), not the middle one -- per the source
  // project's editorial review, the reader's eye should land hardest on
  // the phase whose start date coincides with the analytic cohort's
  // start, not the intermediate build-out phase. Targeting columns by
  // exact index (x == 4, x == 2), not a symmetric calc.rem(x, 2)
  // alternation, since the two boxes don't get symmetric treatment.
  #grid(columns: (1fr, auto, 1fr, auto, 1fr), column-gutter: sp(theme, 6pt), align: horizon,
    inset: (x, y) => if calc.rem(x, 2) == 0 { sp(theme, 10pt) } else { sp(theme, 0pt) },
    fill: (x, ..) => if x == 4 { theme-grad.brand-blue-grad } else if x == 2 { theme-grad.callout-bg-grad } else { none },
    stroke: (x, ..) => if x == 4 { theme.stroke-border + theme.brand-midnight } else if calc.rem(x, 2) == 0 { theme.stroke-border + theme.box-border } else { none },
    [#align(center)[#text(size: 1.15em)[*{{{tl1_yr}}}*] \ #v(theme.space-xs) #text(size: fs(theme, 8.5pt))[{{{tl1_label}}}]]],
    text(size: fs(theme, 20pt), weight: "bold", fill: theme.brand-blue)[#sym.arrow.r],
    [#align(center)[#text(size: 1.15em)[*{{{tl2_yr}}}*] \ #v(theme.space-xs) #text(size: fs(theme, 8.5pt))[{{{tl2_label}}}]]],
    text(size: fs(theme, 20pt), weight: "bold", fill: theme.brand-blue)[#sym.arrow.r],
    [#align(center)[#text(fill: white)[#text(size: 1.15em)[*{{{tl3_yr}}}*] \ #v(theme.space-xs) #text(size: fs(theme, 8.5pt))[{{{tl3_label}}}]]]],
  )
]

] // close page-1 body #pad(x: theme.content-pad-x) -- pagebreak() can't be nested in a container
#place(bottom + center, float: true)[#footer]
#pagebreak()
#pad(x: theme.content-pad-x)[
#v(theme.space-sm)

// ============================================================
// KEY FINDINGS (page 2)
// ============================================================
= {{{heading_key_findings}}}

#block(breakable: false)[
  #grid(columns: (1fr, 1fr), column-gutter: sp(theme, 6pt),
    fill: theme-grad.card-bg-grad, inset: sp(theme, 7pt), stroke: (top: theme.stroke-accent + theme.brand-midnight, rest: theme.stroke-border + theme.box-border),
    [
      == {{{heading_prior_history}}}
      #v(theme.space-md)
      #grid(columns: (1fr, 1fr),
        [#text(size: fs(theme, 24pt), weight: "bold", fill: theme.brand-blue)[{{{pct_any_prior_enc}}}] \ #text(size: fs(theme, 8pt), fill: theme.text-secondary)[{{{stat_any_prior}}}]],
        align(right)[#text(size: fs(theme, 24pt), weight: "bold", fill: theme.brand-accent)[{{{pct_od_prior_enc}}}] \ #text(size: fs(theme, 8pt), fill: theme.text-secondary)[{{{stat_qualifying_prior}}}]],
      )
      #v(sp(theme, 12pt))
      #rect(fill: theme-grad.callout-bg-grad, stroke: 1pt + theme.box-border, inset: sp(theme, 6pt), width: 100%)[
        #text(size: fs(theme, 8.5pt))[{{{text_mean_median_prior}}}]
      ]
    ],
    [
      == {{{heading_intervention_docs}}}
      #v(theme.space-md)
      #grid(columns: ({{{pct_naloxone_width}}}%, {{{pct_no_naloxone_width}}}%),
        box(fill: theme-grad.brand-blue-grad, stroke: 0.75pt + black, inset: sp(theme, 6pt), height: fd(theme, 38pt), width: 100%)[#align(horizon)[
          #text(fill: white, size: fs(theme, 8pt), weight: "bold")[{{{pct_naloxone}}} {{{stat_intervention_documented}}}] \
          #text(fill: white, size: fs(theme, 7pt))[{{{n_naloxone_enc}}} {{{stat_encounters_with}}}]
        ]],
        box(fill: theme-grad.brand-sky-grad, stroke: 0.75pt + black, inset: sp(theme, 6pt), height: fd(theme, 38pt), width: 100%)[#align(horizon)[
          #text(fill: theme.brand-midnight, size: fs(theme, 8pt), weight: "bold")[{{{pct_no_naloxone}}} {{{stat_no_intervention}}}] \
          #text(fill: theme.brand-midnight, size: fs(theme, 7pt))[{{{n_no_naloxone_enc}}} {{{stat_encounters_without}}}]
        ]],
      )
      #v(sp(theme, 12pt))
      #text(size: fs(theme, 8.5pt))[{{{text_cases_intervention}}}]
    ],
  )
]

#v(theme.space-xs)
#rect(fill: theme-grad.card-bg-grad, stroke: (top: theme.stroke-accent + theme.brand-midnight, rest: theme.stroke-border + theme.box-border), inset: sp(theme, 7pt), width: 100%)[
  == {{{heading_completeness}}}
  #v(theme.space-xs)
  #text(size: fs(theme, 7.5pt), fill: theme.text-secondary)[{{{text_completeness_intro}}}]
  #v(theme.space-sm)
  #figure(
    box(stroke: 1pt + black, width: 100%)[#image("{{{figure_path}}}", width: 100%)],
    alt: "{{{alt_completeness_chart}}}",
  )
]

#v(theme.space-xs)
#rect(fill: theme-grad.card-bg-grad, stroke: (top: theme.stroke-accent + theme.brand-midnight, rest: theme.stroke-border + theme.box-border), inset: sp(theme, 7pt), width: 100%)[
  == {{{heading_richer_records}}}
  #v(theme.space-xs)
  #text(size: fs(theme, 7.5pt), fill: theme.text-secondary)[{{{text_richer_intro}}}]
  #v(theme.space-sm)
  #domain-bar(theme, [{{{bar_domain_1}}}], {{{domain_diff_scene}}})
  #domain-bar(theme, [{{{bar_domain_2}}}], {{{domain_diff_history}}})
  #domain-bar(theme, [{{{bar_domain_3}}}], {{{domain_diff_drug}}})
  #domain-bar(theme, [{{{bar_domain_4}}}], {{{domain_diff_medication}}})
  #domain-bar(theme, [{{{bar_domain_5}}}], {{{domain_diff_mental}}})
]

#v(theme.space-xs)
#rect(fill: theme-grad.card-bg-grad, stroke: (top: theme.stroke-accent + theme.brand-midnight, rest: theme.stroke-border + theme.box-border), inset: sp(theme, 7pt), width: 100%)[
  == {{{heading_timing}}}
  #v(theme.space-xs)
  #text(size: fs(theme, 16pt), weight: "bold", fill: theme.brand-blue)[{{{median_days}}}] #text(size:fs(theme, 8pt))[{{{stat_median_days}}}]  #h(1.5em)
  #text(size: fs(theme, 14pt), weight: "bold", fill: theme.brand-midnight)[{{{mean_days}}}] #text(size:fs(theme, 8pt))[{{{stat_mean_days}}}]
  #v(theme.space-sm)
  #bar-row(theme, [{{{bar_timing_1}}}], {{{pct_30d_width}}}, "{{{n_30d}}}", label-width: 65pt)
  #bar-row(theme, [{{{bar_timing_2}}}], {{{pct_90d_width}}}, "{{{n_90d}}}", label-width: 65pt)
  #bar-row(theme, [{{{bar_timing_3}}}], {{{pct_365d_width}}}, "{{{n_365d}}}", label-width: 65pt)
  #bar-row(theme, [{{{bar_timing_4}}}], {{{pct_gt365d_width}}}, "{{{n_gt365d}}}", label-width: 65pt)
]

#v(theme.space-xs)
#rect(fill: theme-grad.lessons-bg-grad, stroke: (left: theme.stroke-accent-left + theme.brand-blue, rest: theme.stroke-border + theme.box-border), radius: theme.radius-card, inset: sp(theme, 5pt), width: 100%)[
  // Was a plain styled #text() call -- visually reads as a section label
  // but tagged as an ordinary /P in the structure tree, not a heading. A
  // PAC AI-assisted check on the source project (score 0.84) flagged
  // exactly this pattern: a structural element visually presenting as a
  // heading but tagged as P. Scoping the heading show-rule locally to
  // this block, rather than editing the document-wide level-2 rule,
  // preserves this box's specific color/tracking without affecting any
  // other == heading elsewhere.
  #show heading: set text(size: fs(theme, 8pt), weight: "bold", fill: theme.lessons-text, tracking: fd(theme, 0.5pt))
  == {{{heading_lessons}}}
  #v(theme.space-xs)
  #text(size: fs(theme, 8.5pt), fill: theme.lessons-text)[{{{lessons_learned_text}}}]
]

#v(theme.space-xs)
#rect(fill: theme-grad.disclaimer-bg-grad, stroke: (left: theme.stroke-accent-left + theme.disclaimer-border, rest: theme.stroke-border + theme.box-border), radius: theme.radius-card, inset: sp(theme, 5pt), width: 100%)[
  // Same fix as LESSONS LEARNED above -- identical plain-#text()-as-
  // section-label pattern.
  #show heading: set text(size: fs(theme, 8pt), weight: "bold", fill: theme.disclaimer-text, tracking: fd(theme, 0.5pt))
  == {{{heading_disclaimer}}}
  #v(theme.space-xs)
  #text(size: fs(theme, 8pt), fill: theme.disclaimer-text)[{{{disclaimer_text}}}]
]

#v(theme.space-xs)
#text(size: fs(theme, 7pt), fill: theme.text-muted)[*{{{footer_label_sources}}}* {{{footnote_sources}}} #h(0.5em)|#h(0.5em) *{{{footer_label_period}}}* {{{strip_period}}} #h(0.5em)|#h(0.5em) *{{{footer_label_contact}}}* {{{org_full}}} {{{footer_contact_joiner}}} #link("mailto:" + contact-email)[#contact-email]]
] // close body #pad(x: theme.content-pad-x)
#place(bottom + center, float: true)[#footer]

] // close #apply-base-styles body
