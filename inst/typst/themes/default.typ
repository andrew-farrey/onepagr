// Generic default theme -- a brand-neutral palette (not tied to any real
// organization), included so onepagr works out of the box before a
// consuming project supplies its own theme. Same dictionary keys as
// themes/uk.typ; see that file's header comment for the full rationale
// on why this is a dictionary, not loose #let bindings.
//
// PALETTE SOURCE: Bootstrap 5.3's own base color variables
// (https://github.com/twbs/bootstrap/blob/v5.3.3/scss/_variables.scss),
// chosen deliberately over a real institution's brand colors (ASU,
// University of Minnesota, etc. were considered) specifically because
// this theme's whole job is to be brand-NEUTRAL -- shipping a real
// university's palette as "the default" would misrepresent an
// affiliation this package doesn't have. Bootstrap's own palette is
// about as recognizable-as-generic as a color scheme gets.
//
// EVERY value below is WCAG AA-verified against its actual usage in
// this package's templates (not just eyeballed) -- computed via the
// real sRGB relative-luminance contrast formula, checked against BOTH
// ends of every gradient this token is used within (theme-grad below
// darkens 10% from the light end), at the ACTUAL text size each token
// is used at in the shipped templates (normal text needs 4.5:1, large
// text -- 18pt+ regular or 14pt+ bold -- needs 3:1). This matters
// because this file replaces an earlier version whose severity-*
// tokens were shipped as unverified drafts and genuinely failed PAC's
// WCAG check once a real alert template used them (2.0:1 on one
// pairing) -- see this package's plan/spec docs for that incident.
// Re-verify any value you change here the same way; a color that looks
// "close enough" by eye is not evidence.
//
// bg-tint / text-shade values are derived using Bootstrap's own
// $-bg-subtle (mix with white, 80% weight) / $-text-emphasis (mix with
// black, 60% weight) formulas from the same source file -- Bootstrap's
// own considered choice for exactly this kind of bg+text pairing, not
// an ad hoc guess.
#let theme = (
  // -- Palette ----------------------------------------------------------
  // Bootstrap $primary (#0d6efd), darkened ~5% from the literal
  // upstream value -- the unmodified value measures white-text contrast
  // of 4.501:1 against the 4.5:1 requirement (used for the header
  // band's white title text on brand-blue-grad): too thin a margin to
  // trust against any future rendering/rounding difference. This
  // darkening only IMPROVES every other pairing brand-blue is used in.
  brand-blue: rgb("#0C68F0"),
  // Bootstrap $primary shaded 60% toward black (shade-color formula).
  brand-midnight: rgb("#052C65"),
  // Bootstrap $success (#198754) -- large-text/decorative use only (stat
  // numbers, strokes); see brand-accent-text below for small-text use.
  brand-accent: rgb("#198754"),
  // brand-accent shaded 60% toward black -- the text-safe variant, for
  // any small-text (normal, <14pt bold/18pt) use of the accent color,
  // e.g. a text-box section-label heading. Needed because brand-accent
  // itself only clears WCAG's 3:1 LARGE-text threshold (verified
  // 3.05-3.82:1 against card-bg, both gradient ends), not the 4.5:1
  // normal-text threshold that small headings require.
  brand-accent-text: rgb("#0A3622"),
  // Bootstrap $primary tinted 60% toward white.
  brand-sky: rgb("#9EC5FE"),
  // Bootstrap gray-200.
  card-bg: rgb("#E9ECEF"),
  // Bootstrap $primary tinted 85% toward white (a touch lighter than
  // Bootstrap's own 80% $primary-bg-subtle, to keep it visually
  // distinct from card-bg above).
  callout-bg: rgb("#DBE9FF"),
  lessons-bg: rgb("#DBE9FF"),
  // Bootstrap $primary shaded 60% toward black -- same value as
  // brand-midnight (both need to be "dark, safe text on a light tint");
  // kept as separate keys since a replacement theme might reasonably
  // want these to diverge.
  lessons-text: rgb("#052C65"),
  // Bootstrap $warning tinted 80% toward white ($warning-bg-subtle).
  disclaimer-bg: rgb("#FFF3CD"),
  // Bootstrap $warning, unmodified -- border/decorative use only.
  disclaimer-border: rgb("#FFC107"),
  // Bootstrap $warning shaded 60% toward black ($warning-text-emphasis).
  disclaimer-text: rgb("#664D03"),
  // Bootstrap gray-300.
  border-color: rgb("#DEE2E6"),
  // Bootstrap gray-400.
  box-border: rgb("#CED4DA"),
  // Bootstrap gray-700.
  text-secondary: rgb("#495057"),
  // Bootstrap gray-800 -- every theme file needs its own >=4.5:1 check
  // against its own card-bg, re-verified here (9.7:1 light end, 7.7:1
  // darkened end -- comfortable margin).
  text-muted: rgb("#343A40"),

  // -- Severity/threshold colors (for alert-style templates) ------------
  // Bootstrap's own $warning / $danger families, using the same
  // tint-80%/shade-60% subtle+text-emphasis formulas as disclaimer-*
  // above. WCAG-verified (not draft): severity-warning-text on
  // severity-warning-bg = 7.21:1; severity-critical-text on
  // severity-critical-bg = 10.22:1; both text variants also verified
  // >=3:1 (large-text threshold) when used directly on card-bg for the
  // alert templates' 28pt headline stat numbers, both gradient ends.
  severity-warning: rgb("#FFC107"),
  severity-warning-bg: rgb("#FFF3CD"),
  severity-warning-text: rgb("#664D03"),
  severity-critical: rgb("#DC3545"),
  severity-critical-bg: rgb("#F8D7DA"),
  severity-critical-text: rgb("#58151C"),

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
