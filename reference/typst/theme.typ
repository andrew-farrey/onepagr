// Default theme -- the swappable design-token layer. A consuming project
// re-skins every onepagr template by writing its own version of this file
// (same `theme` dictionary keys, different values) and importing THAT
// dictionary under the same local name instead.
//
// WHY A DICTIONARY, NOT A WILDCARD `#import "theme.typ": *` OF LOOSE
// #let bindings: tried the loose-bindings version first and it's
// actually broken for shared components, confirmed by direct test, not
// assumed. Typst's `set`/`show`/name resolution is lexically scoped to
// where a function is DEFINED, not where it's called -- so if
// components.typ (shared across templates) did its own internal
// `#import "theme.typ": *`, every component function's color references
// would always resolve to THAT import, regardless of which theme the
// calling template imported. A template swapping its own import line to
// theme-alt.typ silently had zero effect on anything rendered through a
// shared component, because components.typ's own hardcoded import won.
// Passing a single `theme` dictionary explicitly into every component
// call sidesteps this entirely: there's no ambient/ambiguous name to
// shadow, just one value threaded through function arguments like any
// other data.
//
// This is the Typst-side half of the token system described in
// ../../CLAUDE.md: the OTHER half is a project-local config (YAML or an R
// list) that a future render script would read to decide WHICH theme file
// to import -- that R-side selection logic doesn't exist yet (open design
// question), but this Typst-side token dictionary is real and working now.

#let theme = (
  // -- Palette ----------------------------------------------------------
  brand-blue: rgb("#0033A0"),
  brand-midnight: rgb("#002147"),
  brand-accent: rgb("#00703C"),
  brand-sky: rgb("#9BBBD4"),
  card-bg: rgb("#E2E4E8"),
  callout-bg: rgb("#D3E1F7"),
  lessons-bg: rgb("#D3E1F7"),
  lessons-text: rgb("#1a3a7a"),
  disclaimer-bg: rgb("#FFEEBF"),
  disclaimer-border: rgb("#C8A000"),
  border-color: rgb("#C8C9CB"),
  box-border: rgb("#9C9D9F"),
  text-secondary: rgb("#555550"),
  // Darkened from a lighter starting value -- that measured ~4.3:1 against
  // card-bg, just under WCAG AA's 4.5:1 minimum for normal text, and even
  // less against the darker end of the card-bg gradient. This value holds
  // comfortably above 4.5:1 against both. Any replacement theme should
  // re-verify its own text-muted/card-bg pairing against 4.5:1, not just
  // copy this value -- it's only correct for THIS card-bg.
  text-muted: rgb("#4D4A44"),

  // -- Typography ---------------------------------------------------------
  // Linux servers (Posit Workbench included) often don't have Arial
  // installed. Confirmed directly against a real Workbench deployment
  // (fc-list): Arial, DejaVu Sans, and Helvetica were ALL absent there --
  // only Liberation Sans was actually installed. Typst logs a warning (not
  // an error) for every named family it can't find, so an untested
  // fallback list just produces silent, pointless warnings on every
  // compile. Liberation Sans is metric-compatible with Arial by design, so
  // pinning to it directly is a safe default; broaden this only after
  // confirming what's actually installed on the target deployment
  // environment.
  body-font: "Liberation Sans",
  body-size: 10pt,
)

// -- Gradients --------------------------------------------------------
// Kept as a SEPARATE dictionary, not merged into `theme` above, because
// Typst gradients aren't simple values you'd want cluttering a dictionary
// meant to also be easy to read/diff as a palette definition. Derived
// mechanically from `theme` above -- a replacement theme file should
// derive its own `theme-grad` the same way, not hand-pick different
// darken()/angle values, so the "10% darker, 20deg" visual language stays
// consistent across every theme.
#let theme-grad = (
  card-bg-grad: gradient.linear(theme.card-bg, theme.card-bg.darken(10%), angle: 20deg),
  callout-bg-grad: gradient.linear(theme.callout-bg, theme.callout-bg.darken(10%), angle: 20deg),
  lessons-bg-grad: gradient.linear(theme.lessons-bg, theme.lessons-bg.darken(10%), angle: 20deg),
  disclaimer-bg-grad: gradient.linear(theme.disclaimer-bg, theme.disclaimer-bg.darken(10%), angle: 20deg),
  brand-blue-grad: gradient.linear(theme.brand-blue, theme.brand-midnight, angle: 20deg),
  brand-sky-grad: gradient.linear(theme.brand-sky, theme.brand-sky.darken(15%), angle: 20deg),
)
