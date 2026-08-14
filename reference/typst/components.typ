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
  stroke: (left: 4pt + (if color == none { theme.brand-blue } else { color }), rest: 1pt + theme.box-border),
  radius: (top-right: 4pt, bottom-right: 4pt), inset: (x: 8pt, y: 6pt), width: 100%,
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
  box(fill: white, stroke: 0.5pt + theme.border-color, radius: 3pt, height: 14pt, width: 100%)[
    #box(fill: if muted { theme.text-muted } else { theme.brand-blue }, stroke: 0.75pt + black, radius: 3pt, height: 100%, width: pct * 1%)
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
  box(fill: white, stroke: 0.5pt + theme.border-color, radius: 3pt, height: 12pt, width: 100%)[
    #box(fill: theme.brand-blue, stroke: 0.75pt + black, radius: 3pt, height: 100%, width: (value / max * 100) * 1%)
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
// PDF/UA-1 flatly prohibits links inside artifacts, and this whole
// repeating footer is page furniture that Typst automatically tags as an
// Artifact -- confirmed directly via `--pdf-standard ua-1`'s own compile
// error ("PDF artifacts may not contain links") during prototyping. Typst
// auto-detects and auto-links bare URL-looking text too, so
// `show link: it => it.body` strips any link -- explicit or auto-detected
// -- back down to plain, inert text for everything in this footer. If a
// real clickable contact URL is needed, put it in the page body instead,
// which isn't page furniture and has no such restriction.
//
// Three-logo "tri-fold" lockup: tight gutter + thin dividers reads as one
// combined co-branded lockup while remaining three separately alt-tagged
// images -- more precise for screen-reader users than flattening into one
// raster (which would lose per-organization identification), and each
// logo stays independently resizable and swappable.
#let page-footer(theme, theme-grad, logo-a, logo-a-alt, logo-primary, logo-primary-alt, logo-b, logo-b-alt, org-full, contact-url, contact-email, texture: "assets/header-texture.png") = box(width: 100%, fill: theme-grad.brand-blue-grad, clip: true, stroke: (top: 3pt + theme.brand-midnight), inset: (x: 20pt, y: 10pt))[
  #show link: it => it.body
  #place(top + right, dx: 40pt, dy: -30pt)[
    #pdf.artifact(kind: "background")[#image(texture, width: 200pt)]
  ]
  #let logo-divider = line(length: 22pt, angle: 90deg, stroke: 0.6pt + white.transparentize(45%))
  #grid(columns: (auto, 1fr), align: horizon,
    grid(columns: (auto, auto, auto, auto, auto), column-gutter: 7pt, align: horizon,
      image(logo-a, height: 24pt, alt: logo-a-alt),
      logo-divider,
      image(logo-primary, height: 24pt, alt: logo-primary-alt),
      logo-divider,
      image(logo-b, height: 24pt, alt: logo-b-alt),
    ),
    align(right)[#text(fill: white, size: 8pt)[*#org-full* \ #contact-url \ #contact-email]]
  )
]

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
// `#apply-base-styles(doc-title, org-full, theme, footer)[...entire
// document content...]`, not as a standalone call with content written
// separately after it.
//
// Semantic headings drive real screen-reader navigation structure. Styling
// is applied via `show heading: set text(...)`, NOT a content-replacing
// `show heading: it => ...` rule. Verified directly against a compiled
// PDF's own structure tree (pypdf, walking /StructTreeRoot): a totally
// unstyled default heading tags as a standalone /H1 sibling next to the
// body /P that follows it -- correct. The instant ANY content-replacing
// `it => ...` rule intercepts a heading (even a no-op `it => it.body`
// pass-through), Typst re-wraps the realized output in an enclosing /P,
// producing /P > /H1 -- an "inappropriate use of a P structure element"
// that PDF/UA checkers will flag. A `set`-style rule applies styling
// without ever re-realizing the heading's content, so Typst's own correct
// standalone /H1 tagging survives untouched.
//
// Typst's built-in heading stylesheet also applies its own (much larger)
// above/below block spacing via a `set` rule independent of any
// content-replacing rule -- resetting it to this document's own block
// spacing prevents it silently pushing a tight one-page layout onto an
// extra page.
#let apply-base-styles(doc-title, org-full, theme, footer, body) = {
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
    margin: (x: 0pt, top: 0pt, bottom: 0.85in), paper: "us-letter",
    footer: footer,
  )
  body
}
