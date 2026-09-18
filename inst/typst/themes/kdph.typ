// Kentucky Department for Public Health (KDPH) theme. An UNOFFICIAL
// implementation of the color, font, and outline rules in the "KDPH Data
// Visualization Style Guidelines, 2026" (Data Modernization Initiatives).
// It is not produced, reviewed, or endorsed by KDPH. Same dictionary keys
// as themes/default.typ and themes/uk.typ; see uk.typ's header comment for
// why a theme is a dictionary and not loose #let bindings.
//
// SCOPE, AND WHAT THIS THEME CANNOT DO
// The guide is explicit that its palette is for data visualization and
// "does not replace the KDPH Branding Guidelines." The header band, stat
// cards, and callouts in these templates are page chrome, not charts, so
// this theme applies the guide's palette to them as the closest published
// KDPH color system. Review the result against the KDPH Branding Guidelines
// before any external release. Logos are data, not theme settings: per the
// guide, standalone external products carry the Kentucky Public Health
// logo, listed first when another program's logo is also present, and
// external products carrying it need Commissioner's Office approval before
// distribution. Supply the logo through the logo_* tokens.
//
// PALETTE MAPPING (guide names in parentheses)
//   brand-midnight   Grosbeak Navy #012a5c: text, outlines, header band.
//   brand-blue       Wild Indigo Blue #4c6dc1: headings, big numbers, bar
//                    fills. The guide's own single-series color for
//                    histograms, scatter plots, and single lines.
//   brand-accent     Deep River Teal #28655a. Leaf Green #76933c (the more
//                    obvious KDPH green) was measured and REJECTED: it
//                    reaches only 2.8 to 3.1 against light card backgrounds,
//                    under the 3:1 that large accent numbers need. Teal is
//                    also in the guide's categorical palette.
//   brand-sky        KY Sky Blue #62bcf0, as a background with navy text.
//   card-bg          Pearl Grey #ebebeb ("special data" neutral).
//   callout-bg       Lightest Pale Blue #e5f3fa.
//   disclaimer-bg    Threshold Greige #e3e1d3 (the guide's reference color).
//   box-border       Deep Grey #a4a4a4.
//   text-secondary   Grosbeak Navy. The guide allows black, dark gray, or
//                    dark blue text on light backgrounds.
//   text-muted       #4d4d4d, a dark gray outside the palette (the guide
//                    names no small-text gray; palette grays are too light).
// The severity-* colors are copied from default.typ: the guide defines no
// alert colors, and alert semantics (amber, red) should stay recognizable.
//
// FONT
// The guide's preferred family is Calibri; Arial, Object Sans, Open Sans,
// Montserrat, and Now are also approved. body-font is a fallback list that
// Typst tries in order: Calibri, then Carlito (an open font with identical
// metrics, common on Linux), then Liberation Sans (Arial-compatible, and
// what the fixed-page layouts were tuned against, so it is the safe worst
// case). Typst prints a warning, not an error, for a family it cannot find.
// Calibri is narrower and reads smaller than Arial at the same point size.
// If small text (footnotes are 7pt) looks too small, use "Arial" here.
//
// OUTLINES
// The guide requires data-visualization outlines of at least 3 CSS pixels
// (0.8 mm, 2.25 pt). stroke-fill controls the outline on the package's bar
// components, so it is set to 2.25 pt.
//
// VERIFIED CONTRAST
// WCAG relative-luminance ratios, computed against the exact colors Typst
// resolves, at BOTH ends of every gradient (worst case shown). The guide
// itself requires WCAG 2.1 AA; these also meet 2.2 AA.
//   white on the header band ............ 7.5 (needs 4.5)
//   the 85% white subtitle on the band .. 6.0 (needs 4.5)
//   indigo 9pt headings on white ........ 4.9 (needs 4.5)
//   big numbers, indigo / teal / navy ... 3.7 / 5.1 / 10.6 (needs 3.0)
//   small text, navy / teal / #4d4d4d ... 10.6 / 5.1 / 6.3 (needs 4.5)
//   navy on the sky-blue box ............ 4.9 (needs 4.5)
//   navy on disclaimer and lessons boxes  9.7 / 11.2 (needs 4.5)
//   indigo bar fill against a card ...... 3.7 (needs 3.0)
// Rendered output was compiled with --pdf-standard ua-1 and checked with
// PAC (PDF Accessibility Checker) on the built-in templates' sample
// content. That run caught a contrast failure in county_choropleth's
// derived SVI label ramp (now computed per theme), which the token table
// above did not cover. Re-run PAC on your own content before relying on
// this theme for production products.
#let theme = (
  // Palette
  brand-blue: rgb("#4c6dc1"),
  brand-midnight: rgb("#012a5c"),
  map-border-color: rgb("#012a5c"),
  brand-accent: rgb("#28655a"),
  brand-accent-text: rgb("#28655a"),
  brand-sky: rgb("#62bcf0"),
  card-bg: rgb("#ebebeb"),
  callout-bg: rgb("#e5f3fa"),
  lessons-bg: rgb("#e5f3fa"),
  lessons-text: rgb("#012a5c"),
  disclaimer-bg: rgb("#e3e1d3"),
  disclaimer-border: rgb("#a4a4a4"),
  disclaimer-text: rgb("#012a5c"),
  border-color: rgb("#ebebeb"),
  box-border: rgb("#a4a4a4"),
  text-secondary: rgb("#012a5c"),
  text-muted: rgb("#4d4d4d"),

  // Severity/threshold colors (for alert-style templates)
  // Copied unchanged from default.typ, where each pairing is documented.
  severity-warning: rgb("#FFC107"),
  severity-warning-bg: rgb("#FFF3CD"),
  severity-warning-text: rgb("#664D03"),
  severity-critical: rgb("#DC3545"),
  severity-critical-bg: rgb("#F8D7DA"),
  severity-critical-text: rgb("#58151C"),

  // Typography
  body-font: ("Calibri", "Carlito", "Liberation Sans"),
  body-size: 10pt,

  // Spacing scale (systemic #v() rhythm, identical across templates)
  space-xs: 2pt,
  space-sm: 3pt,
  space-md: 4pt,
  space-lg: 7pt,

  // Stroke-width scale
  stroke-hairline: 0.5pt,
  stroke-border: 1pt,
  stroke-accent: 3pt,
  stroke-accent-left: 4pt,
  stroke-fill: 2.25pt,

  // Box radius
  radius-card: (top-right: 4pt, bottom-right: 4pt),

  // Page/content margin
  content-pad-x: 0.25in,
)

// Gradients
// Background gradients darken by only 5% (default.typ uses 10%) so text
// contrast holds with margin at the darker end. The header band starts from
// a darkened brand-blue, not brand-blue itself, so that the 85%-opaque
// white subtitle stays at or above 4.5:1 at the band's lighter end.
#let theme-grad = (
  card-bg-grad: gradient.linear(theme.card-bg, theme.card-bg.darken(5%), angle: 20deg),
  callout-bg-grad: gradient.linear(theme.callout-bg, theme.callout-bg.darken(5%), angle: 20deg),
  lessons-bg-grad: gradient.linear(theme.lessons-bg, theme.lessons-bg.darken(5%), angle: 20deg),
  disclaimer-bg-grad: gradient.linear(theme.disclaimer-bg, theme.disclaimer-bg.darken(5%), angle: 20deg),
  brand-blue-grad: gradient.linear(theme.brand-blue.darken(25%), theme.brand-midnight, angle: 20deg),
  brand-sky-grad: gradient.linear(theme.brand-sky, theme.brand-sky.darken(15%), angle: 20deg),
)
