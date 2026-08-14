// Alternate theme, demonstrating that re-skinning a template is genuinely
// just swapping which theme file gets imported -- same `theme` dictionary
// keys as theme.typ, different values, same `theme-grad` derivation
// pattern. A template that does `#import "theme.typ": theme, theme-grad`
// can be re-skinned by changing that one line to
// `#import "theme-alt.typ": theme, theme-grad`; nothing else in the
// template needs to change, and nothing in components.typ needs to
// change either, since every component takes `theme` as an explicit
// argument rather than importing one itself -- see theme.typ's header
// comment for why that matters. Warm palette here, deliberately distinct
// from theme.typ's cool blue, so a side-by-side compile makes the swap
// obvious.

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
  border-color: rgb("#D6CCC2"),
  box-border: rgb("#A89A8C"),
  text-secondary: rgb("#5C5248"),
  // Re-verified against THIS theme's own card-bg (not copied from
  // theme.typ's value) -- every theme file needs its own >=4.5:1 check
  // against its own card-bg, since darkening the same amount from a
  // different base color doesn't guarantee the same contrast ratio holds.
  text-muted: rgb("#4A4038"),
  body-font: "Liberation Sans",
  body-size: 10pt,
)

#let theme-grad = (
  card-bg-grad: gradient.linear(theme.card-bg, theme.card-bg.darken(10%), angle: 20deg),
  callout-bg-grad: gradient.linear(theme.callout-bg, theme.callout-bg.darken(10%), angle: 20deg),
  lessons-bg-grad: gradient.linear(theme.lessons-bg, theme.lessons-bg.darken(10%), angle: 20deg),
  disclaimer-bg-grad: gradient.linear(theme.disclaimer-bg, theme.disclaimer-bg.darken(10%), angle: 20deg),
  brand-blue-grad: gradient.linear(theme.brand-blue, theme.brand-midnight, angle: 20deg),
  brand-sky-grad: gradient.linear(theme.brand-sky, theme.brand-sky.darken(15%), angle: 20deg),
)
