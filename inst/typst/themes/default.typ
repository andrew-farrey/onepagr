// Generic default theme -- a brand-neutral palette (not tied to any real
// organization), included so onepagr works out of the box before a
// consuming project supplies its own theme. Same dictionary keys as
// themes/uk.typ; see that file's header comment for the full rationale
// on why this is a dictionary, not loose #let bindings.
#let theme = (
  brand-blue: rgb("#8A1538"),
  brand-midnight: rgb("#4A0E1F"),
  brand-accent: rgb("#B8860B"),
  brand-sky: rgb("#E8C4A0"),
  card-bg: rgb("#EDE6E0"),
  callout-bg: rgb("#F2DCC9"),
  lessons-bg: rgb("#F2DCC9"),
  lessons-text: rgb("#5C2A0A"),
  disclaimer-bg: rgb("#FFEEBF"),
  disclaimer-border: rgb("#C8A000"),
  disclaimer-text: rgb("#6b5900"),
  border-color: rgb("#D6CCC2"),
  box-border: rgb("#A89A8C"),
  text-secondary: rgb("#5C5248"),
  // Re-verified against THIS theme's own card-bg (not copied from
  // uk.typ's value) -- every theme file needs its own >=4.5:1 check
  // against its own card-bg.
  text-muted: rgb("#4A4038"),

  // DRAFT VALUES -- see themes/uk.typ's identical note on severity colors.
  severity-warning: rgb("#C8A000"),
  severity-warning-bg: rgb("#FFEEBF"),
  severity-warning-text: rgb("#6b5900"),
  severity-critical: rgb("#B3261E"),
  severity-critical-bg: rgb("#F9DEDC"),
  severity-critical-text: rgb("#5c1512"),

  body-font: "Liberation Sans",
  body-size: 10pt,

  space-xs: 2pt,
  space-sm: 3pt,
  space-md: 4pt,
  space-lg: 7pt,

  stroke-hairline: 0.5pt,
  stroke-border: 1pt,
  stroke-accent: 3pt,
  stroke-accent-left: 4pt,
  stroke-fill: 0.75pt,

  radius-card: (top-right: 4pt, bottom-right: 4pt),

  content-pad-x: 0.25in,
)

#let theme-grad = (
  card-bg-grad: gradient.linear(theme.card-bg, theme.card-bg.darken(10%), angle: 20deg),
  callout-bg-grad: gradient.linear(theme.callout-bg, theme.callout-bg.darken(10%), angle: 20deg),
  lessons-bg-grad: gradient.linear(theme.lessons-bg, theme.lessons-bg.darken(10%), angle: 20deg),
  disclaimer-bg-grad: gradient.linear(theme.disclaimer-bg, theme.disclaimer-bg.darken(10%), angle: 20deg),
  brand-blue-grad: gradient.linear(theme.brand-blue, theme.brand-midnight, angle: 20deg),
  brand-sky-grad: gradient.linear(theme.brand-sky, theme.brand-sky.darken(15%), angle: 20deg),
)
