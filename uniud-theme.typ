// =============================================================================
// UniUD corporate theme for Touying 0.7.4
// =============================================================================
//
// Reference: "Manuale di identità visiva UniUD", sections 3.1 and 3.2, and the
// two official UniUD PowerPoint masters. The two corporate layouts differ in
// where the recurring items ("elementi ricorrenti": place and date, speaker,
// department) sit, and `style` selects one by that:
//
//   "01" / "bottom"  recurring items along the bottom of the slide, no band
//   "02" / "top"     recurring items inside a blue band at the top (default)
//
// Both share the same 12-column grid, the same type scale and the same logo
// treatment, so a deck switches between them with a single parameter.
//
// Both masters are 24384000 x 13716000 EMU, i.e. exactly the 1920x1080 pt
// canvas (67,73 x 38,10 cm) the manual draws on. Every geometry constant below
// is that canvas measured out of the two .pptx files and expressed as a
// percentage of the slide, so the theme adapts to any aspect ratio:
//
//   1,9 cm margin      -> 2.805 % of the width / 5.0 % of the height
//   0,6 cm gutter      -> 0.886 % of the width / 1.575 % of the height
//   12 column grid     -> column = 7.054 %, step = 7.940 %
//   7 cm colour band   -> 18.37 % of the height
//   9,5 cm text anchor -> 24.93 % of the height
//
// Typography follows the manual as well (pages 048-049 and 111-127):
//
//   title            Work Sans Bold      85/88 pt   tracking -20/1000
//   subtitle         Work Sans Medium    51/54 pt   tracking  -5/1000
//   text only        Work Sans Medium    85/88 pt   tracking -10/1000
//   text + images    Work Sans Medium    54/60 pt   tracking  -5/1000
//   section number   Work Sans Bold     221 pt      tracking -20/1000
//   recurring items  Work Sans Bold      16/16 pt   UPPERCASE, 3 pt rule
//
// Sizes are stored as multiples of `base-size`, never as nested `em`, so
// nesting can never rescale them by accident. `base-size` is 44 pt on the
// corporate canvas, i.e. 4.074 % of the slide height, and by default it is
// derived from the actual page height - Touying's presentation papers are
// 473.56 pt high at 16:9 and 595.28 pt at 4:3, so a fixed pt value would make
// the corporate proportions drift from one aspect ratio to the next.

#import "@preview/touying:0.7.4": *

// -----------------------------------------------------------------------------
// Corporate palette - Manuale di identità visiva, p. 037 and p. 148
// -----------------------------------------------------------------------------

/// Blu UNIUD, Pantone 072 U. The manual prescribes #0000ff both for print and
/// for the web; the shipped PowerPoint master actually uses #0433ff, exported
/// below as `uniud-blue-ppt` for pixel comparisons with the corporate deck.
#let uniud-blue = rgb("#0000FF")
#let uniud-blue-ppt = rgb("#0433FF")

/// Grigio UNIUD, Pantone 877 U (print) and its web counterpart.
#let uniud-gray = rgb("#B3B6B7")
#let uniud-gray-web = rgb("#CDCDCE")

#let uniud-black = rgb("#000000")
#let uniud-white = rgb("#FFFFFF")

/// 70 % black, the "grigio scuro" the manual uses for secondary text.
#let uniud-dark-gray = rgb("#4D4D4D")

#let _full-logo-blue = "assets/uniud-full-blue.svg"
#let _full-logo-white = "assets/uniud-full-white.svg"
#let _compact-logo-blue = "assets/uniud-compact-blue.png"
#let _compact-logo-white = "assets/uniud-compact-white.png"

// Syntax highlighting restricted to the corporate palette: blue for keywords,
// types and literals, 70 % black for strings, grey italic for comments.
#let _code-theme = "assets/uniud-code.tmTheme"

// -----------------------------------------------------------------------------
// Normalized geometry
// -----------------------------------------------------------------------------

#let _pc(x) = x * 1%

/// Height of the Touying page for an aspect ratio, mirroring
/// `utils.page-args-from-aspect-ratio`. Used to keep the corporate type
/// proportions identical at every aspect ratio.
#let _slide-height(aspect-ratio) = {
  if aspect-ratio == "16-9" {
    473.56pt
  } else if aspect-ratio == "4-3" {
    595.28pt
  } else {
    let parts = aspect-ratio.split("-")
    841.89pt * float(parts.at(1)) / float(parts.at(0))
  }
}

/// `base-size` as a fraction of the slide height: 44 pt on the 1080 pt
/// corporate canvas.
#let _base-fraction = 44 / 1080

/// Corporate 12-column grid and vertical anchors, in percent of the slide.
///
/// Horizontal values are percentages of the slide width, vertical values are
/// percentages of the slide height, so the same numbers hold for 16:9, 16:10
/// and 4:3.
///
/// Every value left to `auto` takes the default of the chosen corporate
/// `style` ("01" or "02").
#let uniud-layout(
  style: "02",
  columns: 12,
  h-margin: 2.805, // 1,9 cm
  v-margin: 5.0, // 1,9 cm
  gutter: 0.886, // 0,6 cm horizontally
  row-gutter: 1.575, // 0,6 cm vertically
  band-height: auto, // colour band ("02" only)
  anchor: auto, // cap line of the first line of every title / text block
  content-bottom: auto, // bottom margin of the content area
  media-anchor: auto, // top of the image zones (top margin in "01")
  content-column: 5, // titles and text blocks start on column 5 (23,4 cm)
  // Grid position of the three recurring blocks, as (column, columns wide).
  // Style "02" packs them in the band on columns 7-12; style "01" spreads them
  // along the bottom on columns 1, 5 and 7, exactly like its master.
  meta-blocks: auto,
  // Section number: gap between its right edge and the title column, and how
  // far its cap line sits below the anchor (both masters agree on 0.9).
  number-gap: 2.3,
  number-offset: 0.9,
  // Logo boxes, as placed in both masters. The bundled artwork is the same
  // artwork the masters use, so these reproduce the corporate placement.
  logo-width: 23.08, // extended logo on the cover, 15,6 cm
  logo-left: 2.60,
  logo-top: 4.06,
  compact-logo-width: 12.61, // compact logo
  compact-logo-left: 2.39,
  compact-logo-top: 4.47,
  logo-align: left, // corner the logo is aligned to: `left` or `right`
  // Gap between the last title baseline and the cap line of the subtitle.
  title-gap: 4.0,
  media-top: auto, // top of the image band in `text-two-media-slide`
  // Top of the recurring block: the top margin in style "02" (the manual puts
  // the rule on the margin; pass 12.4 to sit as low as the PowerPoint master)
  // and the 35 cm anchor in style "01".
  meta-top: auto,
) = {
  // "bottom" and "top" are semantic spellings of the two corporate masters.
  let style = if style == "bottom" { "01" } else if style == "top" { "02" } else { style }
  assert(
    style in ("01", "02"),
    message: "unknown UniUD style \"" + repr(style) + "\"; expected \"01\"/\"bottom\" or \"02\"/\"top\"",
  )
  let banded = style == "02"
  let band = if band-height != auto { band-height } else if banded { 18.80 } else { 0.0 }
  let top-anchor = if anchor != auto { anchor } else if banded { 27.2 } else { 19.2 }
  let bottom = if content-bottom != auto {
    content-bottom
  } else if banded { v-margin } else { 12.53 }
  (
    style: style,
    columns: columns,
    h-margin: h-margin,
    v-margin: v-margin,
    gutter: gutter,
    row-gutter: row-gutter,
    band-height: band,
    anchor: top-anchor,
    content-bottom: bottom,
    content-column: content-column,
    meta-blocks: if meta-blocks != auto {
      meta-blocks
    } else if banded { ((7, 2), (9, 2), (11, 2)) } else { ((1, 2), (5, 2), (7, 3)) },
    number-gap: number-gap,
    number-offset: number-offset,
    logo-width: logo-width,
    logo-left: logo-left,
    logo-top: logo-top,
    compact-logo-width: compact-logo-width,
    compact-logo-left: compact-logo-left,
    compact-logo-top: compact-logo-top,
    logo-align: logo-align,
    title-gap: title-gap,
    media-top: if media-top != auto { media-top } else if banded { 54.60 } else { 49.64 },
    // With no band, the image zones start at the top margin instead.
    media-anchor: if media-anchor != auto {
      media-anchor
    } else if banded { top-anchor } else { v-margin },
    meta-top: if meta-top != auto { meta-top } else if banded { 5.17 } else { 90.69 },
  )
}

/// Width of one grid column, in percent of the slide width.
#let _colw(g) = (100 - 2 * g.h-margin - (g.columns - 1) * g.gutter) / g.columns

/// Left edge of grid column `i` (1-based), in percent of the slide width.
#let _col(g, i) = g.h-margin + (i - 1) * (_colw(g) + g.gutter)

/// Width of `n` adjacent columns, gutters included.
#let _span(g, n) = n * _colw(g) + (n - 1) * g.gutter

/// Right edge of the type area.
#let _right(g) = 100 - g.h-margin

/// Bottom edge of the content area.
#let _bottom(g) = 100 - g.content-bottom

/// Height of the content area.
#let _content-height(g) = _bottom(g) - g.anchor

/// A fraction of the content area, as a percentage of the slide height.
#let _row(g, f) = g.anchor + f * _content-height(g)

/// A fraction of the image area, which in style "01" starts at the top margin.
#let _media-row(g, f) = g.media-anchor + f * (_bottom(g) - g.media-anchor)

// -----------------------------------------------------------------------------
// Typography
// -----------------------------------------------------------------------------

/// Corporate type scale.
///
/// - base: reference size; every role is a multiple of it, mirroring the pt
///   values of the manual on the 1080 pt corporate canvas, where the base is
///   44 pt. `uniud-theme` derives it from the slide height.
/// - cap-height: cap height of the corporate font as a fraction of the em
///   (0.66 for Work Sans). Line spacing is computed from the cap height so that
///   the first line of every block lands exactly on the anchor and the baseline
///   grid matches the "85/88" style specifications of the manual.
#let uniud-type(base: 22pt, cap-height: 0.66, meta-line: 1.0) = (
  base: base,
  cap-height: cap-height,
  // 3 pt rule and 0,2 cm offset of the recurring items, scaled to the slide.
  rule: 0.0682 * base,
  rule-gap: 0.1289 * base,
  title: (size: 1.932, line: 88 / 85, tracking: -0.020, spacing: 90%, weight: "bold"),
  subtitle: (size: 1.159, line: 54 / 51, tracking: -0.005, spacing: 95%, weight: "medium"),
  number: (size: 5.023, line: 1.0, tracking: -0.020, spacing: 100%, weight: "bold"),
  // "Slide di solo testo": Work Sans Medium 85/88.
  body-large: (size: 1.932, line: 88 / 85, tracking: -0.010, spacing: 90%, weight: "medium"),
  // "Slide testo + immagini" and side captions: Work Sans Medium 54/60.
  body: (size: 1.227, line: 60 / 54, tracking: -0.005, spacing: 95%, weight: "medium"),
  // Recurring items: Work Sans Bold 16/16 (style "02") or 16/19 (style "01"),
  // uppercase.
  meta: (size: 0.364, line: meta-line, tracking: 0.0, spacing: 100%, weight: "bold"),
  // Slide heading (`== ...`), not part of the corporate master.
  heading: (size: 1.227, line: 60 / 54, tracking: -0.005, spacing: 95%, weight: "bold"),
)

/// Apply one role of the type scale. Sizes are absolute, so nesting is safe.
#let _typeset(t, role, ink, body) = {
  let s = t.at(role)
  set text(
    size: s.size * t.base,
    weight: s.weight,
    fill: ink,
    tracking: s.tracking * 1em,
    spacing: s.spacing,
    top-edge: "cap-height",
    bottom-edge: "baseline",
  )
  set par(
    leading: (s.line - t.cap-height) * 1em,
    spacing: (s.line - t.cap-height + 0.45) * 1em,
  )
  body
}

#let _info-or-empty(value) = if value == none { [] } else { value }

// -----------------------------------------------------------------------------
// Recurring items ("ricorrenti")
// -----------------------------------------------------------------------------

// Rule of 3 pt, text block 0,2 cm below it, uppercase Work Sans Bold.
#let _meta-cell(self, value, ink) = {
  let t = self.store.uniud-type
  if value == none { return [] }
  block(
    width: 100%,
    breakable: false,
    {
      block(width: 100%, height: t.rule, fill: ink, above: 0pt, below: t.rule-gap)
      _typeset(t, "meta", ink, upper(value))
    },
  )
}

// The three recurring blocks, each on its own grid position.
#let _meta-block(self, ink) = {
  let g = self.store.uniud-layout
  let values = (
    utils.display-info-date(self),
    self.info.author,
    self.info.institution,
  )
  for (i, spec) in g.meta-blocks.enumerate() {
    let (column, span) = spec
    place(
      top + left,
      dx: _pc(_col(g, column)),
      dy: _pc(g.meta-top),
      block(width: _pc(_span(g, span)), _meta-cell(self, values.at(i), ink)),
    )
  }
}

// The logo, on the corner given by `logo-align`.
#let _logo(self, file, x, y, width) = {
  let g = self.store.uniud-layout
  if g.logo-align == right {
    place(top + right, dx: -_pc(x), dy: _pc(y), image(file, width: _pc(width)))
  } else {
    place(top + left, dx: _pc(x), dy: _pc(y), image(file, width: _pc(width)))
  }
}

#let _compact-logo(self, logo) = {
  let g = self.store.uniud-layout
  _logo(self, logo, g.compact-logo-left, g.compact-logo-top, g.compact-logo-width)
}

/// Recurring chrome of a content slide: the blue band in style "02", the logo
/// and the recurring items. In style "01" there is no band, so the items are
/// black and the logo is the blue one, as the manual prescribes.
#let _chrome(self) = {
  let g = self.store.uniud-layout
  let banded = g.band-height > 0
  block(width: 100%, height: 100%)[
    #if banded {
      place(
        top + left,
        block(width: 100%, height: _pc(g.band-height), fill: self.colors.primary),
      )
    }
    #_compact-logo(self, if banded { _compact-logo-white } else { _compact-logo-blue })
    #_meta-block(self, if banded { self.colors.neutral-lightest } else { self.colors.neutral-darkest })
  ]
}

// Title + optional subtitle, stacked with an exact gap.
//
// The two blocks flow: a one line title leaves the subtitle high on the slide,
// a two or three line title pushes it down, and nothing is ever positioned at a
// hard-coded height. `above`/`below` are pinned to 0 pt so the only vertical
// space between them is `title-gap`.
#let _title-stack(
  self,
  title,
  subtitle,
  title-ink,
  subtitle-ink,
  title-role: "title",
  subtitle-role: "subtitle",
) = {
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  block(
    width: _pc(_span(g, 8)),
    breakable: false,
    {
      block(above: 0pt, below: 0pt, _typeset(t, title-role, title-ink, _info-or-empty(title)))
      if subtitle != none and subtitle != [] {
        v(_pc(g.title-gap), weak: false)
        block(above: 0pt, below: 0pt, _typeset(t, subtitle-role, subtitle-ink, subtitle))
      }
    },
  )
}

// -----------------------------------------------------------------------------
// Slide plumbing
// -----------------------------------------------------------------------------

// Left grid column of the body: the corporate text measure on column 5, or the
// first column when the deck is set `wide`. Covers and section slides do not go
// through here: they keep the corporate placement in both cases.
#let _body-column(self, wide: auto) = {
  let wide = if wide == auto { self.store.wide } else { wide }
  if wide { 1 } else { self.store.uniud-layout.content-column }
}

// Number of columns the body spans, from `_body-column` to the right margin.
#let _body-span(self, wide: auto) = {
  self.store.uniud-layout.columns + 1 - _body-column(self, wide: wide)
}

/// Switch the width of the body from this point of the document onwards.
/// Use it with `#show:`, which is the only way to reach the slides Touying
/// builds from a `== Heading`, since those take no arguments:
///
/// ```typst
/// #show: wide-mode(true)
/// == Una slide larga
/// #show: wide-mode(false)
/// == Di nuovo nella misura corporate
/// ```
///
/// Slides called explicitly take a `wide:` argument instead, which overrides
/// both the deck default and this switch for that one slide.
#let wide-mode(wide) = body => touying-set-config(
  config-store(wide: wide),
  // The marker lands at the end of the slide that precedes it, so the change
  // has to be deferred to the next one.
  defer: true,
  body,
)

// A slide whose body is absolutely positioned on the full page.
#let _canvas-slide(self, config, body, chrome: true, fill: uniud-white, freeze: false) = {
  let page-config = config-page(
    fill: fill,
    foreground: if chrome { _chrome(self) } else { none },
    header: none,
    footer: none,
    margin: 0pt,
  )
  let common-config = if freeze { config-common(freeze-slide-counter: true) } else { (:) }
  let self = utils.merge-dicts(self, common-config, page-config, config)
  touying-slide(self: self, config: config, body)
}

/// Generic content slide: blue band plus the corporate text area
/// (column 5 to the right margin, top anchor at 9,5 cm).
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  let self = utils.merge-dicts(
    self,
    config-page(
      foreground: _chrome(self),
      header: none,
      footer: none,
      margin: (
        top: _pc(g.anchor),
        bottom: _pc(g.content-bottom),
        left: _pc(_col(g, _body-column(self))),
        right: _pc(g.h-margin),
      ),
    ),
    config-common(subslide-preamble: self.store.subslide-preamble),
    config,
  )
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})

// -----------------------------------------------------------------------------
// Cover ("copertina", manual pp. 115-116)
// -----------------------------------------------------------------------------

/// Corporate cover slide. `variant` is "blue" or "white".
#let title-slide(
  config: (:),
  variant: "blue",
  title: auto,
  subtitle: auto,
) = touying-slide-wrapper(self => {
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  let blue = variant == "blue"
  let background = if blue { self.colors.primary } else { self.colors.neutral-lightest }
  let ink = if blue { self.colors.neutral-lightest } else { self.colors.primary }
  let subtitle-ink = if blue { self.colors.neutral-light } else { uniud-dark-gray }
  let logo = if blue { _full-logo-white } else { _full-logo-blue }
  let info-title = if title == auto { self.info.title } else { title }
  let info-subtitle = if subtitle == auto { self.info.subtitle } else { subtitle }

  let body = block(width: 100%, height: 100%)[
    #_logo(self, logo, g.logo-left, g.logo-top, g.logo-width)
    #_meta-block(self, ink)
    // Title and subtitle flow in a single block: a two or three line title
    // simply pushes the subtitle down instead of colliding with it.
    #place(
      top + left,
      dx: _pc(_col(g, g.content-column)),
      dy: _pc(g.anchor),
      _title-stack(self, info-title, info-subtitle, ink, subtitle-ink),
    )
  ]

  _canvas-slide(self, config, body, chrome: false, fill: background, freeze: true)
})

// -----------------------------------------------------------------------------
// Section slides (manual pp. 126-127)
// -----------------------------------------------------------------------------

// Independent counter for the automatic section slides. This avoids relying on
// the heading counter at the exact instant Touying creates the section slide.
#let _uniud-section-counter = counter("uniud-section")

// Per-section overrides, keyed by section number, filled in by `next-section`.
#let _uniud-section-overrides = state("uniud-section-overrides", (:))

/// Override the appearance of the *next* automatic section slide.
///
/// Place it immediately before the `= Heading` it applies to; everything not
/// given falls back to the global theme setting, and the colour cycle is
/// unaffected, so the sections after the override keep their own colours.
///
/// ```typst
/// #next-section(variant: "white")
/// = Conclusioni
/// ```
///
/// - variant: "blue", "black", "gray", "white", or `auto` to keep the global one.
/// - show-number: show the big section number, or `auto` for the global setting.
#let next-section(variant: auto, show-number: auto) = context {
  let n = str(_uniud-section-counter.get().first() + 1)
  _uniud-section-overrides.update(overrides => {
    let entry = overrides.at(n, default: (:))
    if variant != auto { entry.insert("variant", variant) }
    if show-number != auto { entry.insert("show-number", show-number) }
    overrides.insert(n, entry)
    overrides
  })
}

// Background / ink combinations. The manual allows blue, black, gray and white
// backgrounds and requires every element to stay perfectly legible, so the
// secondary text is dark on the two light backgrounds.
#let _section-style(self, number, variant: auto) = {
  let chosen = if variant != auto {
    variant
  } else {
    let mode = self.store.section-variant
    if mode == "cycle" {
      let variants = self.store.section-variants
      variants.at(calc.rem(number - 1, variants.len()))
    } else if type(mode) == function {
      // A function receives the section number and returns the variant.
      mode(number)
    } else {
      mode
    }
  }

  let styles = (
    blue: (
      background: self.colors.primary,
      title: self.colors.neutral-lightest,
      number: self.colors.neutral-lightest,
      subtitle: self.colors.neutral-light,
      meta: self.colors.neutral-lightest,
      logo: _compact-logo-white,
    ),
    black: (
      background: self.colors.neutral-darkest,
      title: self.colors.neutral-lightest,
      number: self.colors.neutral-lightest,
      subtitle: self.colors.neutral-light,
      meta: self.colors.neutral-lightest,
      logo: _compact-logo-white,
    ),
    gray: (
      background: self.colors.neutral-light,
      title: self.colors.primary,
      number: self.colors.primary,
      subtitle: self.colors.neutral-darkest,
      meta: self.colors.primary,
      logo: _compact-logo-blue,
    ),
    white: (
      background: self.colors.neutral-lightest,
      title: self.colors.primary,
      number: self.colors.primary,
      subtitle: uniud-dark-gray,
      meta: self.colors.primary,
      logo: _compact-logo-blue,
    ),
  )
  assert(
    chosen in styles,
    message: "unknown UniUD section variant \"" + repr(chosen) + "\"; expected blue, black, gray or white",
  )
  styles.at(chosen)
}

#let _section-canvas(self, number, title, subtitle, variant: auto, show-number: true) = {
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  let style = _section-style(self, number, variant: variant)
  // The number is flush right against the title column, so it stays clear of
  // the title for one, two or three digits alike.
  let number-right = _col(g, g.content-column) - g.number-gap

  block(width: 100%, height: 100%, fill: style.background)[
    #_compact-logo(self, style.logo)
    #_meta-block(self, style.meta)
    #if show-number {
      place(
        top + right,
        dx: -_pc(100 - number-right),
        dy: _pc(g.anchor + g.number-offset),
        _typeset(t, "number", style.number, str(number)),
      )
    }
    #place(
      top + left,
      dx: _pc(_col(g, g.content-column)),
      dy: _pc(g.anchor),
      _title-stack(self, title, subtitle, style.title, style.subtitle),
    )
  ]
}

/// Explicit corporate section slide.
/// `variant`: "blue", "black", "gray", "white", or `auto` for the global setting.
#let section-slide(
  config: (:),
  number: 1,
  variant: auto,
  show-number: auto,
  title: none,
  subtitle: none,
) = touying-slide-wrapper(self => {
  let numbered = if show-number == auto { self.store.section-numbering } else { show-number }
  let canvas = _section-canvas(
    self,
    number,
    title,
    subtitle,
    variant: variant,
    show-number: numbered,
  )
  let style = _section-style(self, number, variant: variant)
  _canvas-slide(self, config, canvas, chrome: false, fill: style.background, freeze: true)
})

/// Automatic section slide used by Touying for level-1 headings.
///
/// The content that follows a `= Heading` up to the next `==` becomes the
/// section subtitle (Touying's `receive-body-for-new-section-slide-fn`), which
/// is why regular slide content must live under a `== Heading`.
#let new-section-slide(
  config: (:),
  level: 1,
  numbered: true,
  body,
) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(header: none, footer: none, margin: 0pt),
    config,
  )

  let main-body = [
    #_uniud-section-counter.step()
    #context {
      let number = _uniud-section-counter.get().first()
      let override = _uniud-section-overrides.get().at(str(number), default: (:))
      _section-canvas(
        self,
        number,
        utils.display-current-heading(level: level, numbered: false),
        body,
        variant: override.at("variant", default: auto),
        show-number: override.at("show-number", default: self.store.section-numbering),
      )
    }
  ]

  touying-slide(self: self, config: config, main-body)
})

// -----------------------------------------------------------------------------
// Media helpers
// -----------------------------------------------------------------------------

/// Corporate image placeholder / media container.
#let media-box(
  width: 100%,
  height: 100%,
  fill: uniud-gray-web,
  inset: 0pt,
  ..body,
) = block(
  width: width,
  height: height,
  fill: fill,
  inset: inset,
  clip: true,
  body.pos().join(),
)

#let _placed(dx, dy, width, height, body) = place(
  top + left,
  dx: _pc(dx),
  dy: _pc(dy),
  block(width: _pc(width), height: _pc(height), body),
)

// -----------------------------------------------------------------------------
// Corporate slide archetypes (manual pp. 117-125)
// -----------------------------------------------------------------------------

/// "Slide di solo testo": Work Sans Medium 85/88 on columns 5-12.
#let text-slide(config: (:), role: "body-large", wide: auto, body) = touying-slide-wrapper(self => {
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  let canvas = block(width: 100%, height: 100%)[
    #_placed(
      _col(g, _body-column(self, wide: wide)),
      g.anchor,
      _span(g, _body-span(self, wide: wide)),
      _content-height(g),
      _typeset(t, role, uniud-black, body),
    )
  ]
  _canvas-slide(self, config, canvas)
})

/// "Slide testo + immagini", variant a: text on top, two images below.
#let text-two-media-slide(config: (:), text-body, left-media, right-media) = touying-slide-wrapper(self => {
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  let media-height = _bottom(g) - g.media-top
  let canvas = block(width: 100%, height: 100%)[
    #_placed(
      _col(g, g.content-column),
      g.anchor,
      _span(g, 8),
      g.media-top - g.anchor - g.row-gutter,
      _typeset(t, "body", uniud-black, text-body),
    )
    #_placed(_col(g, 5), g.media-top, _span(g, 4), media-height, left-media)
    #_placed(_col(g, 9), g.media-top, _span(g, 4), media-height, right-media)
  ]
  _canvas-slide(self, config, canvas)
})

/// "Slide testo + immagini", variant b: caption on the left, one large image.
#let caption-media-slide(config: (:), caption, media) = touying-slide-wrapper(self => {
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  let canvas = block(width: 100%, height: 100%)[
    #_placed(
      _col(g, 1),
      g.anchor,
      _span(g, 4),
      _bottom(g) - g.anchor,
      _typeset(t, "body", uniud-black, caption),
    )
    #_placed(_col(g, 5), g.media-anchor, _span(g, 8), _bottom(g) - g.media-anchor, media)
  ]
  _canvas-slide(self, config, canvas)
})

/// "Slide testo + immagini", variant c: caption on the left, 2x2 image grid.
#let caption-grid-slide(config: (:), caption, a, b, c, d) = touying-slide-wrapper(self => {
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  let row-height = (_bottom(g) - g.media-anchor - g.row-gutter) / 2
  let row2 = g.media-anchor + row-height + g.row-gutter
  let canvas = block(width: 100%, height: 100%)[
    #_placed(
      _col(g, 1),
      g.anchor,
      _span(g, 4),
      _bottom(g) - g.anchor,
      _typeset(t, "body", uniud-black, caption),
    )
    #_placed(_col(g, 5), g.media-anchor, _span(g, 4), row-height, a)
    #_placed(_col(g, 9), g.media-anchor, _span(g, 4), row-height, b)
    #_placed(_col(g, 5), row2, _span(g, 4), row-height, c)
    #_placed(_col(g, 9), row2, _span(g, 4), row-height, d)
  ]
  _canvas-slide(self, config, canvas)
})

/// "Slide solo immagini": free mosaic on the base grid.
#let mosaic-slide(config: (:), a, b, c, d, e, f) = touying-slide-wrapper(self => {
  let g = self.store.uniud-layout
  let canvas = block(width: 100%, height: 100%)[
    #let y = _media-row.with(g)
    #_placed(_col(g, 1), y(0.0), _span(g, 4), y(.588) - y(0.0), a)
    #_placed(_col(g, 3), y(.617), _span(g, 2), y(1.0) - y(.617), b)
    #_placed(_col(g, 5), y(.153), _span(g, 3), y(1.0) - y(.153), c)
    #_placed(_col(g, 8), y(0.0), _span(g, 2), y(.378) - y(0.0), d)
    #_placed(_col(g, 10), y(0.0), _span(g, 3), y(.378) - y(0.0), e)
    #_placed(_col(g, 8), y(.404), _span(g, 4), y(1.0) - y(.404), f)
  ]
  _canvas-slide(self, config, canvas)
})

/// Full-bleed media slide.
///
/// With `chrome: false` the recurring items disappear, as the manual prescribes
/// for full-screen images, and only the logo stays; `logo` picks the version
/// that contrasts with the picture ("white", "blue" or `none`). Style "01"
/// drops the chrome by default, exactly like slide 8 of its PowerPoint master.
#let full-media-slide(config: (:), chrome: auto, logo: "white", body) = touying-slide-wrapper(self => {
  let g = self.store.uniud-layout
  let with-chrome = if chrome == auto { g.style == "02" } else { chrome }
  let logo-file = if logo == "blue" { _compact-logo-blue } else { _compact-logo-white }
  let canvas = block(width: 100%, height: 100%)[
    #body
    #if not with-chrome and logo != none { _compact-logo(self, logo-file) }
  ]
  _canvas-slide(self, config, canvas, chrome: with-chrome)
})

/// Full-bleed emphasis slide in UniUD blue.
#let focus-slide(
  config: (:),
  background: auto,
  foreground: auto,
  body,
) = touying-slide-wrapper(self => {
  let t = self.store.uniud-type
  let bg = if background == auto { self.colors.primary } else { background }
  let fg = if foreground == auto { self.colors.neutral-lightest } else { foreground }
  let logo = if fg == self.colors.neutral-lightest { _compact-logo-white } else { _compact-logo-blue }
  let canvas = block(width: 100%, height: 100%)[
    #_compact-logo(self, logo)
    #align(center + horizon, block(width: 80%, _typeset(t, "title", fg, body)))
  ]
  _canvas-slide(self, config, canvas, chrome: false, fill: bg, freeze: true)
})

// -----------------------------------------------------------------------------
// Teaching helpers
//
// These are not part of the corporate masters, which only cover institutional
// presentations. They are built out of the same design system - the 3 pt rule
// above a text block, the corporate palette and the corporate type scale - so a
// lecture still looks like a UniUD deck.
//
// Most of them are *elements*: they go inside an ordinary slide, under a
// `== Heading`, so slide titles keep working the usual way.
// -----------------------------------------------------------------------------

// The corporate "filetto + intestazione" idiom, reused as a block header.
#let _label-rule(ink, title, gap: .5em) = {
  block(width: 100%, height: .068em, fill: ink, above: 0pt, below: .129em)
  if title != none {
    block(
      above: 0pt,
      below: gap,
      text(size: .55em, weight: "bold", fill: ink, tracking: .02em, upper(title)),
    )
  }
}

/// Titled block for definitions, theorems, examples and remarks.
///
/// ```typst
/// #callout(title: [Definizione])[Un grafo è una coppia ...]
/// #callout(title: [Attenzione], accent: uniud-black, fill: uniud-gray.lighten(80%))[...]
/// ```
///
/// - title: label above the block; `none` draws the rule alone.
/// - accent: colour of the rule and of the label.
/// - fill: optional background.
#let callout(title: none, accent: uniud-blue, fill: none, body) = block(
  width: 100%,
  fill: fill,
  inset: if fill == none { 0pt } else { (x: .5em, y: .45em) },
  breakable: false,
  {
    _label-rule(accent, title)
    body
  },
)

/// Two or more blocks side by side, separated by the corporate column gutter.
///
/// For text that should *flow* from one column into the next, use Typst's own
/// `#columns(2)[...]` instead.
#let side-by-side(gutter: .6em, align-items: top, ..bodies) = {
  let items = bodies.pos()
  grid(
    columns: (1fr,) * items.len(),
    column-gutter: gutter,
    align: align-items,
    ..items
  )
}

/// Code frame.
///
/// ```typst
/// #code-box(caption: [mergesort.py], numbered: true, highlight: (3,))[
///   ```python
///   def merge_sort(a):
///       ...
///   ```
/// ]
/// ```
///
/// - caption: optional label above the frame.
/// - numbered: show line numbers.
/// - highlight: line numbers to emphasise.
/// - fill / ink: background and text colour; `output-box` inverts them.
///   `fill: none` plus a `stroke` gives the outlined variant on white.
/// - stroke: optional frame, e.g. `.06em + uniud-gray`.
/// - size: type size, relative to the surrounding text.
#let code-box(
  caption: none,
  numbered: false,
  highlight: (),
  fill: auto,
  stroke: none,
  ink: uniud-black,
  size: .8em,
  body,
) = {
  let bg = if fill == auto { uniud-gray.lighten(80%) } else { fill }
  let negative = ink != uniud-black
  let accent = if negative { ink } else { uniud-blue }
  let mark = if negative { uniud-blue } else { uniud-blue.lighten(85%) }
  block(
    width: 100%,
    fill: bg,
    stroke: stroke,
    inset: (x: .55em, y: .5em),
    breakable: false,
    {
      if caption != none {
        block(
          above: 0pt,
          below: .45em,
          text(size: .55em, weight: "bold", fill: accent, tracking: .02em, upper(caption)),
        )
      }
      set text(size: size, fill: ink)
      set par(leading: .45em, justify: false)
      show raw.line: it => block(
        width: 100%,
        above: 0pt,
        below: 0pt,
        inset: (x: .2em, y: .08em),
        fill: if it.number in highlight { mark } else { none },
        if numbered {
          grid(
            columns: (1.4em, 1fr),
            column-gutter: .7em,
            align: (right, left),
            text(fill: uniud-gray, str(it.number)),
            it.body,
          )
        } else {
          it.body
        },
      )
      // The corporate syntax colours assume a light background; on the negative
      // frame the text keeps `ink` instead.
      if negative { body } else { { set raw(theme: _code-theme); body } }
    },
  )
}

/// Terminal / result frame: a `code-box` in negative, to pair with the code
/// that produced it.
#let output-box(caption: none, numbered: false, size: .8em, body) = code-box(
  caption: caption,
  numbered: numbered,
  fill: uniud-black,
  ink: uniud-white,
  size: size,
  body,
)

/// Corporate table: no vertical rules, a blue rule under the header row and
/// hairlines between the rows.
#let uniud-table(..args) = {
  set text(size: .85em)
  show table.cell.where(y: 0): set text(weight: "bold", fill: uniud-blue)
  table(
    stroke: (x, y) => (
      top: if y == 0 { none } else if y == 1 { .06em + uniud-blue } else { .02em + uniud-gray },
      rest: none,
    ),
    inset: (x: .45em, y: .5em),
    align: left,
    ..args
  )
}

/// Agenda slide listing the level-1 sections, numbered like the section slides.
///
/// - title: optional heading.
/// - cols: split the list over this many columns.
/// - column / span: grid slot of the list. By default it follows the deck: the
///   corporate text measure, or the whole width when the theme is set `wide`.
#let outline-slide(
  config: (:),
  title: none,
  cols: 1,
  wide: auto,
  column: auto,
  span: auto,
) = touying-slide-wrapper(self => {
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  let column = if column == auto { _body-column(self, wide: wide) } else { column }
  let width = if span == auto { g.columns + 1 - column } else { span }
  let canvas = block(width: 100%, height: 100%)[
    #_placed(
      _col(g, column),
      g.anchor,
      _span(g, width),
      _content-height(g),
      {
        if title != none {
          block(below: .8em, _typeset(t, "heading", self.colors.primary, title))
        }
        context {
          let entries = query(heading.where(level: 1))
            .enumerate()
            .map(((i, section)) => grid(
              columns: (1.3em, 1fr),
              column-gutter: .5em,
              align: (left, left),
              text(weight: "bold", fill: self.colors.primary, str(i + 1)),
              section.body,
            ))
          _typeset(
            t,
            "body",
            uniud-black,
            if cols > 1 {
              columns(cols, entries.join(parbreak()))
            } else {
              entries.join(parbreak())
            },
          )
        }
      },
    )
  ]
  _canvas-slide(self, config, canvas)
})

/// Quotation slide.
#let quote-slide(
  config: (:),
  attribution: none,
  variant: "white",
  wide: auto,
  body,
) = touying-slide-wrapper(self => {
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  let blue = variant == "blue"
  let bg = if blue { self.colors.primary } else { self.colors.neutral-lightest }
  let ink = if blue { self.colors.neutral-lightest } else { self.colors.primary }
  let second = if blue { self.colors.neutral-light } else { uniud-dark-gray }
  let canvas = block(width: 100%, height: 100%, fill: bg)[
    #_compact-logo(self, if blue { _compact-logo-white } else { _compact-logo-blue })
    #_meta-block(self, ink)
    #_placed(
      _col(g, _body-column(self, wide: wide)),
      g.anchor,
      _span(g, _body-span(self, wide: wide)),
      _content-height(g),
      {
        block(above: 0pt, below: 1.2em, _typeset(t, "subtitle", ink, body))
        if attribution != none {
          block(width: 32%, _label-rule(second, attribution, gap: 0pt))
        }
      },
    )
  ]
  _canvas-slide(self, config, canvas, chrome: false, fill: bg, freeze: true)
})

/// Bibliography slide. Extra arguments go straight to Typst's `bibliography`,
/// so the usual `#references-slide(title: [Riferimenti], "refs.bib", style: "ieee")`
/// works; `cols: 2` splits a long list.
#let references-slide(
  config: (:),
  title: none,
  cols: 1,
  size: .78em,
  wide: auto,
  column: auto,
  span: auto,
  ..args,
) = touying-slide-wrapper(self => {
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  let column = if column == auto { _body-column(self, wide: wide) } else { column }
  let width = if span == auto { g.columns + 1 - column } else { span }
  let canvas = block(width: 100%, height: 100%)[
    #_placed(
      _col(g, column),
      g.anchor,
      _span(g, width),
      _content-height(g),
      {
        if title != none {
          block(below: .8em, _typeset(t, "heading", self.colors.primary, title))
        }
        set text(size: size)
        set bibliography(title: none)
        if cols > 1 {
          columns(cols, bibliography(..args))
        } else {
          bibliography(..args)
        }
      },
    )
  ]
  _canvas-slide(self, config, canvas)
})

/// Content slide called explicitly, with its own `title` because it is not
/// produced by a `== Heading`.
///
/// `wide` overrides the deck for this slide alone: `true` runs the content area
/// from the first to the last column — useful for code, tables and wide
/// diagrams, which do not fit the corporate text measure — and `false` brings a
/// single slide back into that measure inside an otherwise wide deck.
#let content-slide(config: (:), title: none, wide: auto, body) = touying-slide-wrapper(self => {
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  let canvas = block(width: 100%, height: 100%)[
    #_placed(
      _col(g, _body-column(self, wide: wide)),
      g.anchor,
      _span(g, _body-span(self, wide: wide)),
      _content-height(g),
      {
        if title != none {
          block(below: .8em, _typeset(t, "heading", self.colors.primary, title))
        }
        body
      },
    )
  ]
  _canvas-slide(self, config, canvas)
})

/// `content-slide` pinned to the whole width.
#let wide-slide(config: (:), title: none, body) = content-slide(
  config: config,
  title: title,
  wide: true,
  body,
)

// -----------------------------------------------------------------------------
// Theme
// -----------------------------------------------------------------------------

/// UniUD Touying theme.
///
/// - style: corporate master, "01" (equivalently "bottom": recurring items along
///   the bottom, no band) or "02" ("top": recurring items in the blue band).
/// - aspect-ratio: "16-9", "16-10", "4-3", or any ratio supported by Touying.
/// - font: corporate font family. Use `none` to inherit the document font.
/// - code-font: monospaced family for `raw` blocks and inline code. The default
///   ships with Typst, so it is always available.
/// - math-font: family for equations. The default, Fira Math, matches Work Sans
///   and ships in `fonts/`; install it or compile with `--font-path fonts`.
///   Pass "New Computer Modern Math" for Typst's built-in serif math.
/// - base-size: reference text size; every corporate size is a multiple of it.
///   `auto` derives it from the slide height so the corporate proportions hold
///   at any aspect ratio.
/// - cap-height: cap height of `font`, as a fraction of the em (0.66 for
///   Work Sans). Line spacing and anchoring are derived from it.
/// - layout: normalized geometry, see `uniud-layout()`.
/// - type-scale: type scale, see `uniud-type()`. `auto` derives it from
///   `base-size` and `cap-height`.
/// - primary: corporate blue. Pass `uniud-blue-ppt` to match the PowerPoint
///   master exactly instead of the manual.
/// - section-variant: global colour policy - "cycle", one of "blue", "black",
///   "gray", "white", or a function `number => variant`. Individual sections
///   override it with `#next-section(variant: ..)` or `#section-slide(..)`.
/// - section-variants: sequence used when `section-variant` is "cycle".
/// - section-numbering: show the big section number.
/// - wide: let the body of the text slides use the whole width instead of the
///   corporate text measure on columns 5-12. It applies to `== Heading` slides,
///   `text-slide`, `outline-slide`, `references-slide` and `quote-slide`;
///   covers, section slides and the image layouts keep their corporate
///   placement either way. `#show: wide-mode(..)` switches it mid-deck and the
///   explicit slides take a `wide:` argument of their own.
#let uniud-theme(
  style: "02",
  aspect-ratio: "16-9",
  font: "Work Sans",
  code-font: "DejaVu Sans Mono",
  math-font: "Fira Math",
  base-size: auto,
  cap-height: 0.66,
  layout: auto,
  type-scale: auto,
  primary: uniud-blue,
  section-variant: "cycle",
  section-variants: ("blue", "black", "gray", "white"),
  section-numbering: true,
  wide: false,
  ..args,
  body,
) = {
  let layout = if layout == auto { uniud-layout(style: style) } else { layout }
  let style = layout.style
  // 44 pt on the corporate canvas, whatever the slide height actually is.
  let base-size = if base-size == auto {
    _base-fraction * _slide-height(aspect-ratio)
  } else {
    base-size
  }
  let t = if type-scale == auto {
    // The recurring items are 16/16 in style "02" and 16/19 in style "01".
    uniud-type(
      base: base-size,
      cap-height: cap-height,
      meta-line: if layout.style == "01" { 19 / 16 } else { 1.0 },
    )
  } else {
    type-scale
  }

  set text(size: base-size, fill: uniud-black, weight: "regular")
  set text(font: font) if font != none
  set par(leading: (60 / 54 - cap-height) * 1em)

  show raw: set text(font: code-font)
  show math.equation: set text(font: math-font)
  show link: set text(fill: primary)
  show cite: set text(fill: primary)
  // Slides rarely need numbered figures; `set figure(numbering: "1")` restores it.
  set figure(numbering: none)
  show figure.caption: set text(size: .7em, fill: uniud-dark-gray)
  show heading.where(level: 3): set text(size: 1em, weight: "bold", fill: primary)

  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      margin: (
        top: _pc(layout.anchor),
        bottom: _pc(layout.content-bottom),
        left: _pc(_col(layout, layout.content-column)),
        right: _pc(layout.h-margin),
      ),
      fill: uniud-white,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      receive-body-for-new-section-slide-fn: true,
      zero-margin-header: true,
      zero-margin-footer: true,
    ),
    config-methods(
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: primary,
      neutral-light: uniud-gray,
      neutral-lightest: uniud-white,
      neutral-darkest: uniud-black,
    ),
    config-store(
      uniud-layout: layout,
      uniud-type: t,
      section-variant: section-variant,
      section-variants: section-variants,
      section-numbering: section-numbering,
      wide: wide,
      subslide-preamble: block(
        below: (60 / 54 - cap-height + 0.6) * 1em,
        _typeset(t, "heading", primary, utils.display-current-heading(level: 2)),
      ),
    ),
    ..args,
  )

  body
}
