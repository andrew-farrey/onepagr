// UK/KIPRC theme -- the real design-token dictionary this package
// generalizes from (see this repo's reference/typst/theme.typ). A
// consuming project re-skins every onepagr template by writing its own
// version of this file (same `theme` dictionary keys, different values)
// and passing `theme = "path/to/their-theme.typ"` (or `theme_path =`) to
// render_onepager()/export_template() instead of a built-in theme name.
//
// WHY A DICTIONARY, NOT A WILDCARD `#import "theme.typ": *` OF LOOSE
// #let bindings: Typst's `set`/`show`/name resolution is lexically scoped
// to where a function is DEFINED, not where it's called -- so if
// components.typ (shared across templates) did its own internal
// `#import "theme.typ": *`, every component function's color references
// would always resolve to THAT import, regardless of which theme the
// calling template imported. Passing a single `theme` dictionary
// explicitly into every component call sidesteps this entirely.
#let theme = (
  // -- Palette ----------------------------------------------------------
  brand-blue: rgb("#0033A0"),
  brand-midnight: rgb("#002147"),
  // Large-text/decorative use only (stat numbers, strokes) -- verified
  // >=3:1 against card-bg (both theme-grad ends: 4.88:1 light, 3.90:1
  // dark) but NOT the 4.5:1 normal-text threshold. See brand-accent-text
  // below for small-text use (e.g. a text-box heading).
  brand-accent: rgb("#00703C"),
  // brand-accent shaded ~20% toward black -- the text-safe variant.
  // Confirmed by direct compile+PAC run: the unshaded brand-accent was
  // used for a text-box heading in the first shipped alert template and
  // happened to render on the lighter part of its background gradient,
  // passing PAC by chance rather than by margin (the same color measures
  // 3.90:1 at the gradient's dark end, under the 4.5:1 normal-text
  // requirement that small heading text needs). This variant is
  // verified >=4.5:1 (6.15:1 light end, 4.91:1 dark end) at both ends.
  brand-accent-text: rgb("#005A30"),
  brand-sky: rgb("#9BBBD4"),
  card-bg: rgb("#E2E4E8"),
  callout-bg: rgb("#D3E1F7"),
  lessons-bg: rgb("#D3E1F7"),
  lessons-text: rgb("#1a3a7a"),
  disclaimer-bg: rgb("#FFEEBF"),
  disclaimer-border: rgb("#C8A000"),
  disclaimer-text: rgb("#6b5900"),
  border-color: rgb("#C8C9CB"),
  box-border: rgb("#9C9D9F"),
  text-secondary: rgb("#555550"),
  // Darkened from a lighter starting value that measured under WCAG AA's
  // 4.5:1 minimum against card-bg. Any replacement theme should
  // re-verify its own text-muted/card-bg pairing, not just copy this
  // value -- it's only correct for THIS card-bg.
  text-muted: rgb("#4D4A44"),

  // -- Severity/threshold colors (for alert-style templates) ------------
  // WCAG-verified (real sRGB contrast formula, not eyeballed):
  // severity-critical-text/-bg ground-truth confirmed via an actual PAC
  // run (overdose_spike_alert, uk theme, critical severity -- passed
  // clean). severity-warning-text/-bg was never actually exercised by
  // that PAC run (the fixture used "critical") -- computed directly
  // instead: 5.97:1 against severity-warning-bg, 4.32-5.40:1 against
  // card-bg at 28pt (large-text threshold 3:1), all comfortably passing.
  // check_theme_contrast() (follow-on theme-sourcing plan) will automate
  // this kind of check going forward.
  severity-warning: rgb("#C8A000"),
  severity-warning-bg: rgb("#FFEEBF"),
  severity-warning-text: rgb("#6b5900"),
  severity-critical: rgb("#B3261E"),
  severity-critical-bg: rgb("#F9DEDC"),
  severity-critical-text: rgb("#5c1512"),

  // -- Typography ---------------------------------------------------------
  // Linux servers (Posit Workbench included) often lack Arial/DejaVu
  // Sans/Helvetica; Liberation Sans is metric-compatible with Arial and
  // confirmed present. Broaden this only after confirming what's
  // installed on the target deployment environment.
  body-font: "Liberation Sans",
  body-size: 10pt,

  // -- Spacing scale (systemic #v() rhythm, identical across templates) --
  space-xs: 2pt,
  space-sm: 3pt,
  space-md: 4pt,
  space-lg: 7pt,

  // -- Stroke-width scale -------------------------------------------------
  stroke-hairline: 0.5pt,
  stroke-border: 1pt,
  stroke-accent: 3pt,
  stroke-accent-left: 4pt,
  stroke-fill: 0.75pt,

  // -- Box radius -----------------------------------------------------
  radius-card: (top-right: 4pt, bottom-right: 4pt),

  // -- Page/content margin ---------------------------------------------
  content-pad-x: 0.25in,
)

// -- Gradients --------------------------------------------------------
// Kept separate from `theme` -- Typst gradients aren't simple values you'd
// want cluttering a dictionary meant to also read as a palette definition.
// A replacement theme should derive its own theme-grad the same way.
#let theme-grad = (
  card-bg-grad: gradient.linear(theme.card-bg, theme.card-bg.darken(10%), angle: 20deg),
  callout-bg-grad: gradient.linear(theme.callout-bg, theme.callout-bg.darken(10%), angle: 20deg),
  lessons-bg-grad: gradient.linear(theme.lessons-bg, theme.lessons-bg.darken(10%), angle: 20deg),
  disclaimer-bg-grad: gradient.linear(theme.disclaimer-bg, theme.disclaimer-bg.darken(10%), angle: 20deg),
  brand-blue-grad: gradient.linear(theme.brand-blue, theme.brand-midnight, angle: 20deg),
  brand-sky-grad: gradient.linear(theme.brand-sky, theme.brand-sky.darken(15%), angle: 20deg),
)
