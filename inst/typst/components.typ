// Reusable layout building blocks shared across onepagr templates. Every
// template imports from here rather than redefining these -- keeps the
// visual language (and any future accessibility fix to one of these
// patterns) consistent across all templates instead of drifting per-file.
//
// Every function here takes `theme` (and `theme-grad` where gradients are
// needed) as an explicit argument, rather than importing a theme file
// internally. That's deliberate, not just verbose: see theme.typ's header
// comment for the real bug this avoids -- an internal
// `#import "theme.typ": *` here would always win over whatever theme a
// calling template imported, since Typst resolves names lexically to
// where a function is DEFINED, not where it's called. Confirmed by direct
// test, not assumed: a first version of this file did exactly that, and
// swapping a template's theme import silently had zero effect on
// anything rendered through these shared components.
//
// KNOWN TYPST ESCAPING GOTCHAS -- markup-body text substituted via a
// whisker token or hardcoded template prose can trip Typst's markup
// parser if it starts with (or contains) a character that ALSO starts a
// markup construct. Confirmed directly, not theoretical, each time:
// a bare "@" starts label-reference syntax (county_choropleth/
// template.typ's contact-email header comment), a bare "$" starts math
// mode (disclaimer_text), and a bare "*" starts bold-emphasis markup,
// breaking the compile with "unclosed delimiter" (county_choropleth's
// footnote, which needs a literal footnote-marker asterisk). Escape with
// a leading backslash ("\@", "\$", "\*") wherever a literal one of these
// characters is needed inside markup body text -- and note this only
// fixes a token spliced into markup SOURCE text; a token substituted
// into a quoted Typst STRING argument instead needs no escaping at all
// (see county_choropleth's contact-email comment for why those two
// substitution contexts behave differently).

// Stat card: a big number over a small label. fill/stroke/radius/inset are
// applied by the enclosing grid() itself (sizes to the row's resolved
// height automatically). Do NOT wrap this in its own rect(height:100%) --
// that has no fixed height to resolve against inside an auto-sized grid
// row and blows up to the page's remaining space instead.
#let stat-card(theme, num, label, color: none) = align(center)[
  #text(size: 22pt, weight: "bold", fill: if color == none { theme.brand-blue } else { color })[#num] \
  #text(size: 8pt, fill: theme.text-secondary)[#label]
]

// Callout box: a big number/value with explanatory body text, left-border
// accent stripe.
#let callout(theme, theme-grad, num, body-text, color: none, bg: none, text-color: none) = rect(
  fill: if bg == none { theme-grad.callout-bg-grad } else { bg },
  stroke: (left: theme.stroke-accent-left + (if color == none { theme.brand-blue } else { color }), rest: theme.stroke-border + theme.box-border),
  radius: theme.radius-card, inset: (x: 8pt, y: 6pt), width: 100%,
)[
  #text(size: 20pt, weight: "bold", fill: if color == none { theme.brand-blue } else { color })[#num] \
  #text(size: 8.5pt, fill: if text-color == none { rgb("#1a3a7a") } else { text-color })[#body-text]
]

// Composition bar row: label, proportional bar, "% . n=" text AFTER the
// bar (not inside the fill) -- composition shares can range very wide
// (e.g. 1% to 86%), too wide a range for text-inside-the-fill to hold up
// at the low end.
#let bar-row(theme, label, pct, n, label-width: 75pt, muted: false) = grid(
  columns: (label-width, 1fr, auto),
  column-gutter: 8pt,
  align: (right, left, left),
  [#text(size: 8.5pt, fill: theme.text-secondary)[#label]],
  box(fill: white, stroke: theme.stroke-hairline + theme.border-color, radius: 3pt, height: 14pt, width: 100%)[
    #box(fill: if muted { theme.text-muted } else { theme.brand-blue }, stroke: theme.stroke-fill + black, radius: 3pt, height: 100%, width: pct * 1%)
  ],
  [#text(size: 8.5pt, fill: black, weight: "bold")[#pct% #sym.dot.c n = #n]],
)

// Compact bar for raw-magnitude values (not percentages) against a fixed
// max, e.g. a mean additional-mentions-per-record metric.
#let domain-bar(theme, label, value, max: 8.0, label-width: 82pt) = grid(
  columns: (label-width, 1fr, auto),
  column-gutter: 6pt,
  align: (right, left, left),
  [#text(size: 7.5pt, fill: theme.text-secondary)[#label]],
  box(fill: white, stroke: theme.stroke-hairline + theme.border-color, radius: 3pt, height: 12pt, width: 100%)[
    #box(fill: theme.brand-blue, stroke: theme.stroke-fill + black, radius: 3pt, height: 100%, width: (value / max * 100) * 1%)
  ],
  [#text(size: 7.5pt, fill: black, weight: "bold")[+#value units]],
)

// Repeating page footer -- Typst's native #set page(footer:) prints this
// on every page automatically (page 1 included). Takes the logo image
// paths and alt text as arguments rather than hardcoding them, so a
// consuming project supplies its own logos without editing this function.
//
// The header-texture.png background pattern is wrapped in #pdf.artifact()
// (Typst's built-in PDF module, no import needed, requires Typst 0.15+),
// per Typst's own PDF/UA guidance: "wrap all decorative elements without a
// semantic meaning in pdf.artifact." An Artifact is excluded from the tag
// tree entirely (correct for pure decoration), rather than tagged as a
// Figure that would still need a bounding box.
//
// PDF/UA-1 flatly prohibits links inside artifacts, and page furniture
// wired via `set page(footer:)` is page furniture that Typst
// automatically tags as an Artifact -- confirmed directly via
// `--pdf-standard ua-1`'s own compile error ("PDF artifacts may not
// contain links") during prototyping. Typst auto-detects and auto-links
// bare URL-looking text too (contact-url and contact-email both trigger
// this even though neither is an explicit #link() call), so
// `strip-links: true` (the default) applies `show link: it => it.body`
// to strip any link -- explicit or auto-detected -- back down to plain,
// inert text, for templates that still wire this footer via
// `set page(footer:)` (see apply-base-styles()'s own comment on which
// templates still do).
//
// For a template that instead self-places this footer as real body
// content (not page furniture, not an Artifact -- see
// county_choropleth/template.typ for the pattern), pass
// `strip-links: false`. Getting this wrong in that direction is a REAL,
// PAC-confirmed accessibility bug, not a hypothetical: this rule
// originally stripped links unconditionally, for every caller, because
// it was ALWAYS true that this footer rendered inside an Artifact. Once
// county_choropleth/cohort_summary/trend_snapshot stopped doing that (to
// fix the footer-logos-untagged bug -- see apply-base-styles()'s
// comment), the ORIGINAL reason for stripping links no longer applied to
// them, but the rule kept stripping anyway -- a real PAC run against the
// fixed templates flagged exactly this ("Link in text does not have a
// 'Link' element", 4 instances on county_choropleth: contact-url and
// contact-email, both pages), confirming sighted users saw URL/email-
// shaped text with no actual accessible link underneath. `strip-links`
// is the fix: `false` lets the same auto-detected links stay real
// `/Link` elements when they're no longer inside an artifact, verified
// directly (a scoped `show link:` rule inside one branch of an #if
// still correctly applies to a content value interpolated from outside
// that branch -- confirmed with a minimal repro, not assumed from how
// the equivalent function-scoping issue elsewhere in this file works,
// since content values and function returns follow different rules).
//
// Resolves a show_* toggle token to a real Typst boolean, or fails
// loudly if it isn't the expected literal lowercase string. Same
// silent-coercion hazard as severity-palette() below -- see that
// function's comment. Defined here, above page-footer(), rather than
// alongside severity-palette() further down: Typst evaluates top-level
// #let bindings in file order, so page-footer() (which calls
// bool-token()) needs this defined earlier in the file, not just earlier
// in reading order of "related" functions.
#let bool-token(name, value) = {
  if value == "true" { true }
  else if value == "false" { false }
  else { panic(name + " must be the literal lowercase string \"true\" or \"false\", got: " + repr(value)) }
}

// Logo lockup: tight gutter + thin dividers reads as one combined
// co-branded lockup while remaining separately alt-tagged images -- more
// precise for screen-reader users than flattening into one raster (which
// would lose per-organization identification), and each logo stays
// independently resizable and swappable.
//
// Not every jurisdiction has a three-organization design like KIPRC's --
// a single health department running its own reports has exactly one
// logo, and a two-agency partnership has two. show-partner-a/
// show-partner-b are show_*-style boolean tokens (see bool-token() above)
// that drop the corresponding slot from the lockup entirely, rather than
// rendering an empty or placeholder image in its place: the primary
// logo is always shown, partner-a/partner-b are each optional. The
// dividers and grid column count are computed from however many logos
// are actually visible, so a one-logo jurisdiction gets a plain single
// image with no dangling divider on either side.
#let page-footer(theme, theme-grad, logo-a, logo-a-alt, show-partner-a, logo-primary, logo-primary-alt, logo-b, logo-b-alt, show-partner-b, org-full, contact-url, contact-email, texture: "assets/header-texture.png", strip-links: true) = box(width: 100%, fill: theme-grad.brand-blue-grad, clip: true, stroke: (top: theme.stroke-accent + theme.brand-midnight), inset: (x: 20pt, y: 10pt))[
  #place(top + right, dx: 40pt, dy: -30pt)[
    #pdf.artifact(kind: "background")[#image(texture, width: 200pt)]
  ]
  // Dividers between logos used to be their own grid cell (a bare
  // line()) -- harmless visually, but PAC flagged it ("possibly
  // inappropriate use of a Div structure element"): every grid() cell
  // gets tagged /Div regardless of its content, so a divider cell with
  // no taggable content inside becomes an empty /Div. Confirmed directly
  // that wrapping the line in #pdf.artifact() does NOT fix this -- the
  // cell's own /Div wrapper persists even when its content is excluded
  // from the tag tree, since the Div comes from the grid CELL, not the
  // content. The actual fix is structural: don't give the divider its
  // own cell at all. A left border stroke on each non-first logo's own
  // cell produces the identical visual divider with zero extra cells,
  // confirmed directly (a minimal repro with a bordered box in place of
  // a separate line-cell produced no empty /Div at all).
  #let logo-lockup = {
    let logos = ()
    if bool-token("show_partner_a", show-partner-a) { logos.push((logo-a, logo-a-alt)) }
    logos.push((logo-primary, logo-primary-alt))
    if bool-token("show_partner_b", show-partner-b) { logos.push((logo-b, logo-b-alt)) }
    let cells = ()
    for (i, l) in logos.enumerate() {
      let logo-img = image(l.at(0), height: 32pt, alt: l.at(1))
      cells.push(
        if i > 0 {
          // right: 8pt, not 0 -- the divider stroke sits at this box's
          // LEFT edge, so a left-only inset put 15pt of gap between the
          // divider and the logo but only the 7pt column-gutter (which
          // is outside this box entirely) between the logo and the NEXT
          // divider, visibly off-center toward the right divider.
          // Confirmed directly in the svi-linkage-code consuming project
          // (rendering this cell in isolation showed the logo sitting
          // closer to its right-hand divider than its left) -- same bug,
          // same box/inset/gutter structure, ported back here. 8pt (15pt
          // inset minus the 7pt gutter it's compensating for) equalizes
          // the two gaps at 15pt each.
          box(inset: (left: 15pt, right: 8pt), stroke: (left: 0.6pt + white.transparentize(45%)))[#logo-img]
        } else {
          logo-img
        }
      )
    }
    grid(columns: (auto,) * cells.len(), column-gutter: 7pt, align: horizon, ..cells)
  }
  // Explicit #link() calls, not bare #contact-url/#contact-email
  // interpolation -- confirmed directly that Typst's auto-link detection
  // (which DOES catch a literal URL typed straight into markup source)
  // does NOT fire on a URL that arrives as a function-parameter string
  // and gets interpolated via #variable-name, even though it displays
  // identically. Without an explicit #link(), there is no link element
  // here at all for `strip-links` to have any effect on, stripped or
  // not -- confirmed by a real PAC run flagging exactly this ("Link in
  // text does not have a 'Link' element") even after strip-links: false
  // was added, which is what caught this. contact-email uses the same
  // "mailto:" + contact-email pattern already proven safe elsewhere in
  // this package (see county_choropleth/template.typ's own footnote).
  #let org-info = align(right)[#text(fill: white, size: 8pt)[*#org-full* \ #link(contact-url)[#contact-url] \ #link("mailto:" + contact-email)[#contact-email]]]
  #grid(columns: (auto, 1fr), align: horizon,
    logo-lockup,
    if strip-links [
      #show link: it => it.body
      #org-info
    ] else [
      #org-info
    ]
  )
]

// Generic labeled free-text box: a heading label plus free-form body
// content, for sections whose content varies too much in shape to force
// into a fixed structured layout (narrative context, recommended
// actions, resource/response listings, cluster-detection detail). The
// body argument can contain arbitrary Typst markup -- bullet lists,
// #link() calls, even embedded #bar-row()/#domain-bar() calls -- since
// it's passed through as content, not re-parsed or restricted. See
// docs/superpowers/specs/2026-08-16-spike-alert-templates-design.md,
// Section 5, for the full rationale for one generic component instead
// of several narrow ones.
//
// Same accessible-heading fix as the LESSONS LEARNED/DISCLAIMER pattern
// in cohort_summary/trend_snapshot: the show rule is a `set`-style rule
// (styling only), never a content-replacing `it => ...` rule, so the
// heading keeps tagging as a standalone /H2 rather than getting wrapped
// in /P. Scoped locally to this box so it doesn't affect any other
// heading elsewhere in the document.
#let text-box(theme, theme-grad, label, body, color: none, bg: none, text-color: none, height: auto) = rect(
  fill: if bg == none { theme-grad.card-bg-grad } else { bg },
  stroke: (top: theme.stroke-accent + (if color == none { theme.brand-midnight } else { color }), rest: theme.stroke-border + theme.box-border),
  inset: 7pt, width: 100%, height: height,
)[
  #show heading: set text(size: 8pt, weight: "bold", fill: if color == none { theme.brand-midnight } else { color }, tracking: 0.5pt)
  == #label
  #v(theme.space-xs)
  #text(size: 8.5pt, fill: if text-color == none { black } else { text-color })[#body]
]

// Resolves a severity_level token to its full color triple, or fails
// loudly if the token isn't the expected literal lowercase string.
// Whisker coerces an R logical/typo to something other than "warning" or
// "critical" silently (e.g. R's TRUE becomes the string "TRUE", not
// "true") -- without this guard, an R caller's mistake here would
// silently downgrade a critical alert to warning styling with no error
// anywhere. See this package's design doc,
// docs/superpowers/specs/2026-08-16-spike-alert-templates-design.md,
// Section 4, for why severity is data-driven in the first place.
#let severity-palette(theme, level) = {
  if level == "critical" {
    (color: theme.severity-critical, bg: theme.severity-critical-bg, text: theme.severity-critical-text)
  } else if level == "warning" {
    (color: theme.severity-warning, bg: theme.severity-warning-bg, text: theme.severity-warning-text)
  } else {
    panic("severity_level must be the literal lowercase string \"warning\" or \"critical\", got: " + repr(level))
  }
}

// Shared document-level setup every template should apply: page metadata,
// typography defaults, and the accessible-heading show rules. Call this
// once near the top of a template, wrapping the ENTIRE document body
// (including any #pagebreak()) as its `body` argument -- see theme.typ's
// header comment on lexical scoping: a `set`/`show` rule written inside a
// function only applies to that function's OWN returned content, not to
// whatever comes after the function is called. Confirmed directly by
// test: `#let f() = { set text(fill: red) }` called as `#f()` followed by
// plain text does NOT turn that text red. The only correct way to apply a
// bundle of page-level set/show rules via one function call is to make
// the function take the rest of the document as a `body` parameter and
// return it from inside the same block where the rules were declared,
// which is what this function does. Call it as
// `#apply-base-styles(doc-title, org-full, theme)[...entire document
// content...]`, not as a standalone call with content written separately
// after it.
//
// `footer` is an OPTIONAL named argument, default `none` -- deliberately
// NOT wired into `set page(footer: ...)` by default anymore. Confirmed
// directly (a minimal repro: `#image(..., alt: "...")` inside
// `set page(footer: [...])`, compiled with `--pdf-standard ua-1
// --features a11y-extras`, structure-tree-walked with pypdf) that Typst
// unconditionally excludes ALL `page(footer:)` content from the PDF's tag
// tree, alt text or not -- there is no per-element override. For a
// template with a KNOWN, fixed page count (an explicit #pagebreak()
// between each page), don't pass `footer` here at all: instead call
// `#place(bottom + center)[#footer]` as a sibling statement at the end of
// each page's own content, which DOES produce a real tagged /Figure
// (confirmed the same way) -- see county_choropleth/template.typ for the
// pattern. For a template with variable/natural pagination (no
// #pagebreak(), page count depends on content length -- see
// overdose_spike_alert/syndromic_alert), there's no known safe point to
// self-place a footer once per page without knowing the page count in
// advance, so those templates still pass `footer: page-footer(...)` here
// to get the old automatic-every-page behavior. This is a real,
// documented accessibility gap for those two templates specifically
// (their footer logos are Artifact-excluded, same root cause as before)
// -- not silently different from the fixed-page templates, and not yet
// resolved; revisit if Typst ever exposes a way to detect page
// boundaries without an explicit #pagebreak().
#let apply-base-styles(doc-title, org-full, theme, body, footer: none, margin-bottom: 0.85in) = {
  set document(title: [#doc-title], author: org-full)
  set text(font: theme.body-font, size: theme.body-size)
  // Hyphenation rendered as a literal "4" glyph at line-break points on
  // one real deployment's Liberation Sans (no discretionary-hyphen glyph
  // available there). Disabling sidesteps it; re-verify this is still
  // needed if deploying to a different environment.
  set text(hyphenate: false)
  set par(justify: false)
  set block(spacing: 0.4em)
  set par(leading: 0.5em)
  set list(spacing: 0.35em)
  show heading: set block(spacing: 0.4em)
  show heading.where(level: 1): set text(size: 9pt, weight: "bold", fill: theme.brand-blue, tracking: 1pt)
  show heading.where(level: 2): set text(size: 7.5pt, weight: "bold")
  set page(
    margin: (x: 0pt, top: 0pt, bottom: margin-bottom), paper: "us-letter",
    footer: footer,
  )
  body
}
