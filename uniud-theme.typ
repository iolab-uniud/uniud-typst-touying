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
// Warning veri del compilatore: la dipendenza arriva gia' con Touying.
#import "@preview/uniwarn:0.1.1"

// -----------------------------------------------------------------------------
// Design tokens
// -----------------------------------------------------------------------------

// Colori e loghi stanno in un modulo a parte, condiviso con la dispensa A4.
// `import *` li rimette in circolo, quindi `uniud-blue` e compagni restano
// esportati da questo file come sempre.
#import "uniud-tokens.typ": *

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
  // Riga del numero di slide. Nello stile "02" sta sotto l'area di testo, nel
  // margine inferiore lasciato libero dalla banda; nello stile "01" si allinea
  // ai ricorrenti, sulle colonne che loro non usano.
  slide-number-top: auto,
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
    slide-number-top: if slide-number-top != auto {
      slide-number-top
    } else if banded { 100.0 - v-margin } else if meta-top != auto { meta-top } else { 90.69 },
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

#let _info-or-empty(value) = if value == none or value == auto { [] } else { value }

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

// What goes in a recurring slot. The corporate masters carry place and date,
// the speaker and the structure. A lecture is better served by the title of the
// lecture where the speaker's name would go — the room already knows who is
// talking, and what it needs is a running head telling it which lecture this is
// — so `short-title`, once given, takes that slot on its own.
#let _meta-value(self, key) = {
  if type(key) != str { return key }
  let info = self.info
  // Touying leaves the short forms at `auto` when they are not given.
  let given(v) = v != none and v != auto
  let pick(a, b) = {
    let first = info.at(a, default: none)
    _info-or-empty(if given(first) { first } else { info.at(b, default: none) })
  }
  if key == "date" {
    utils.display-info-date(self)
  } else if key == "author" {
    _info-or-empty(info.at("author", default: none))
  } else if key == "institution" {
    _info-or-empty(info.at("institution", default: none))
  } else if key == "title" {
    _info-or-empty(info.at("title", default: none))
  } else if key == "short-title" {
    pick("short-title", "title")
  } else if key == "subtitle" {
    _info-or-empty(info.at("subtitle", default: none))
  } else if key == "short-subtitle" {
    pick("short-subtitle", "subtitle")
  } else if key in ("", "none") {
    []
  } else {
    panic("unknown recurring item \"" + key + "\"")
  }
}

// The three recurring blocks, each on its own grid position.
#let _meta-block(self, ink) = {
  let g = self.store.uniud-layout
  let spec = self.store.at("meta", default: auto)
  let spec = if spec != auto {
    spec
  } else if self.info.at("short-title", default: none) not in (none, auto) {
    ("date", "short-title", "institution")
  } else {
    ("date", "author", "institution")
  }
  let values = spec.map(key => _meta-value(self, key))
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

// Numero di slide, in basso a destra.
//
// Sta dentro `_chrome`, quindi compare solo sulle slide che hanno i ricorrenti:
// copertina, slide di sezione, focus e citazioni ne restano fuori da se'. Quelle
// slide congelano anche il contatore di Touying, percio' la numerazione scorre
// senza salti sulle sole slide di contenuto.
#let _slide-number(self, ink) = {
  let spec = self.store.at("slide-numbering", default: none)
  if spec == none { return none }
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  place(
    top + left,
    dx: _pc(_col(g, g.columns - 2)),
    dy: _pc(g.slide-number-top),
    block(
      width: _pc(_span(g, 3)),
      {
        // I ricorrenti hanno il filetto sopra il testo: lo stesso stacco tiene
        // il numero sulla loro riga invece che un filo piu' in alto.
        v(t.rule + t.rule-gap)
        align(
          right,
          context {
            let current = utils.slide-counter.get().first()
            let total = utils.last-slide-counter.final().first()
            let rendered = if type(spec) == function {
              spec(current, total)
            } else {
              // `numbering("1", 12, 48)` darebbe "1248": il totale si passa
              // solo se il modello ha davvero due simboli di conteggio ("1/1").
              let symbols = spec.matches(regex("[1aAiI]")).len()
              if symbols >= 2 { numbering(spec, current, total) } else { numbering(spec, current) }
            }
            _typeset(t, "meta", ink, rendered)
          },
        )
      },
    ),
  )
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
    // Il numero sta sempre fuori dalla banda, quindi vuole comunque l'inchiostro scuro.
    #_slide-number(self, self.colors.neutral-darkest)
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
// Overflow
// -----------------------------------------------------------------------------

// Prima di comporre una slide il tema ne misura il corpo: se non sta nell'area
// di testo lo riduce quanto basta e lo segnala, invece di lasciarlo traboccare
// (o, nelle slide a flusso, di spezzarlo su una pagina in piu').
//
//   mode    "shrink" riduce e segnala, "mark" segnala soltanto,
//           "error" interrompe la compilazione, "ignore" lascia correre
//   min     riduzione massima consentita: sotto questa soglia il testo
//           diventa illeggibile e conviene tagliare il contenuto
//   marker  badge di avviso sulle slide che sforano
#let _overflow-defaults = (mode: "shrink", min: 70%, marker: true, warn: true)

// Sopra questo fattore la riduzione e' rumore: il contenuto stava gia'
// riempiendo la regione esatta, non sforandola.
#let _overflow-deadband = 0.97

#let _overflow-namespace = uniwarn.register-namespace("uniud-touying", panic: false)
#let _overflow-warn = uniwarn.warning.with(
  namespace: "uniud-touying",
  prefix: "[uniud-touying] ",
)

#let _overflow-config(self, overflow) = {
  let cfg = (
    _overflow-defaults
      + self.store.at("overflow", default: (:))
      + self.store.at("overflow-override", default: (:))
  )
  if overflow == auto {
    cfg
  } else if type(overflow) == dictionary {
    cfg + overflow
  } else {
    cfg + (mode: overflow)
  }
}

// Badge rosso fuori dal flusso, in fondo a destra dell'area misurata.
#let _overflow-badge(factor) = place(
  bottom + right,
  dy: 1em,
  block(
    fill: rgb("#D62828"),
    inset: (x: .4em, y: .25em),
    radius: .15em,
    text(
      size: 8pt,
      fill: uniud-white,
      weight: "bold",
      tracking: 0pt,
      spacing: 100%,
      top-edge: "ascender",
      bottom-edge: "descender",
      if factor == none { "OVERFLOW" } else { "OVERFLOW " + str(calc.round(factor * 100)) + "%" },
    ),
  ),
)

/// Adatta `body` allo spazio disponibile secondo la politica di overflow.
///
/// - overflow: `auto` per la politica corrente del tema, oppure una delle
///   modalita' ("shrink", "mark", "error", "ignore") o un dizionario parziale.
/// - scale: percentuale fissa; salta misura e avvisi, e' la riduzione manuale.
#let _fit(self, body, overflow: auto, scale: auto) = {
  let cfg = _overflow-config(self, overflow)
  if scale != auto {
    let k = scale / 100%
    layout(size => std.scale(
      x: scale,
      y: scale,
      origin: top + left,
      reflow: true,
      block(width: size.width / k, height: size.height / k, body),
    ))
  } else if cfg.mode == "ignore" {
    body
  } else {
    layout(size => {
      // A fattore k il corpo dispone di size / k, che la scala riporta poi
      // alle dimensioni reali: misurare in quella regione tiene conto sia del
      // testo che, rimpicciolito, occupa meno righe, sia di cio' che si
      // impagina per regioni (`columns`), che misurato senza un'altezza
      // risulterebbe alto quanto la somma delle colonne.
      //
      // In una regione con altezza definita `measure` si ferma all'altezza
      // disponibile: il contenuto che la satura e' quello che sfora. La
      // regione di prova deve essere alta esattamente quanto quella vera,
      // altrimenti cio' che si impagina per regioni (`columns`) si dispone in
      // un altro modo e la misura non dice piu' niente di utile.
      let too-tall(k) = {
        let h = size.height / k
        measure(width: size.width / k, height: h, body).height > h - 0.25pt
      }
      if not too-tall(1.0) {
        body
      } else if cfg.mode == "error" {
        panic(
          "uniud-touying: il contenuto non sta nella slide a pagina "
            + str(here().page())
            + ". Riduci il testo, usa `scale:`, oppure passa a overflow: \"shrink\".",
        )
      } else if cfg.mode == "mark" {
        body
        if cfg.warn {
          _overflow-warn("contenuto in overflow a pagina " + str(here().page()))
        }
        if cfg.marker { _overflow-badge(none) }
      } else {
        let lo = cfg.min / 100%
        if too-tall(lo) {
          // Nemmeno la soglia basta. Ridurre comunque non salverebbe la
          // slide: un blocco scalato non si spezza, quindi il testo in
          // eccesso sparirebbe invece di finire sulla pagina dopo. Meglio
          // lasciare il contenuto dov'e' e limitarsi a segnalarlo.
          body
          if cfg.warn {
            _overflow-warn(
              "contenuto in overflow a pagina "
                + str(here().page())
                + ": non entra nemmeno al "
                + str(calc.round(lo * 100))
                + "%, alleggerisci la slide",
            )
          }
          if cfg.marker { _overflow-badge(none) }
        } else {
          // Invariante: `lo` sta, `hi` no. Otto bisezioni bastano a scendere
          // sotto il mezzo per cento di errore residuo.
          let hi = 1.0
          let lo = lo
          for _ in range(8) {
            let mid = (lo + hi) / 2
            if too-tall(mid) { hi = mid } else { lo = mid }
          }
          let factor = lo
          if factor >= _overflow-deadband {
            // Saturava la regione ma bastava una briciola: e' il caso del
            // contenuto che la riempie esatta (tipicamente `columns`).
            // Ridurlo dell'un per cento non serve a nessuno, segnalarlo
            // ancora meno.
            return body
          }
          std.scale(
            x: factor * 100%,
            y: factor * 100%,
            origin: top + left,
            reflow: true,
            block(width: size.width / factor, height: size.height / factor, body),
          )
          if cfg.warn {
            _overflow-warn(
              "contenuto in overflow a pagina "
                + str(here().page())
                + ", ridotto al "
                + str(calc.round(factor * 100))
                + "%",
            )
          }
          if cfg.marker { _overflow-badge(factor) }
        }
      }
    })
  }
}

/// Cambia la politica di overflow da questo punto del documento in avanti.
/// Come `wide-mode`, e' l'unico modo di raggiungere le slide che Touying
/// costruisce da un `== Titolo`:
///
/// ```typst
/// #show: overflow-mode("ignore")     // lascia traboccare
/// #show: overflow-mode(marker: false) // riduci in silenzio
/// #show: overflow-mode(auto)          // torna alle impostazioni del tema
/// ```
#let overflow-mode(mode: auto, min: auto, marker: auto, warn: auto, ..args) = {
  let mode = if args.pos().len() > 0 { args.pos().at(0) } else { mode }
  let override = (:)
  if mode != auto { override.mode = mode }
  if min != auto { override.min = min }
  if marker != auto { override.marker = marker }
  if warn != auto { override.warn = warn }
  body => touying-set-config(
    config-store(overflow-override: override),
    // Il marcatore cade in fondo alla slide precedente: il cambio vale
    // dalla successiva.
    defer: true,
    body,
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
  overflow: auto,
  scale: auto,
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
    // Il controllo di overflow avvolge il corpo gia' composto, intestazione
    // della sottoslide inclusa.
    setting: body => _fit(self, setting(body), overflow: overflow, scale: scale),
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

// Didascalie: un solo stile per `#figure` e per i media del tema.
#let _caption-size = 0.7em
#let _caption-gap = 0.7em

#let _caption(body) = block(
  width: 100%,
  align(center, text(size: _caption-size, fill: uniud-dark-gray, body)),
)

// Dove va il testo che accompagna le immagini negli archetipi corporate:
// "bottom" sotto l'immagine, "side" nella colonna laterale del master.
#let _caption-at(self, caption-at) = {
  if caption-at == auto { self.store.at("caption-at", default: "bottom") } else { caption-at }
}

// Impila la didascalia sotto il media, dentro l'altezza gia' assegnata: il
// media prende quello che resta, non quello che vorrebbe.
#let _with-caption(caption, body) = {
  if caption == none {
    body
  } else {
    grid(rows: (1fr, auto), row-gutter: _caption-gap, body, _caption(caption))
  }
}

/// Corporate image placeholder / media container.
///
/// `caption` mette la didascalia sotto l'immagine, nello stesso stile delle
/// didascalie di `#figure`, e la sottrae all'altezza del riquadro.
#let media-box(
  width: 100%,
  height: 100%,
  fill: uniud-gray-web,
  inset: 0pt,
  caption: none,
  ..body,
) = {
  let media = block(
    width: 100%,
    height: 100%,
    fill: fill,
    inset: inset,
    clip: true,
    body.pos().join(),
  )
  block(width: width, height: height, _with-caption(caption, media))
}

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
#let text-slide(
  config: (:),
  role: "body-large",
  wide: auto,
  overflow: auto,
  scale: auto,
  body,
) = touying-slide-wrapper(self => {
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  let canvas = block(width: 100%, height: 100%)[
    #_placed(
      _col(g, _body-column(self, wide: wide)),
      g.anchor,
      _span(g, _body-span(self, wide: wide)),
      _content-height(g),
      _typeset(t, role, uniud-black, _fit(self, body, overflow: overflow, scale: scale)),
    )
  ]
  _canvas-slide(self, config, canvas)
})

/// "Slide testo + immagini", variant a: text on top, two images below.
#let text-two-media-slide(
  config: (:),
  overflow: auto,
  scale: auto,
  text-body,
  left-media,
  right-media,
) = touying-slide-wrapper(self => {
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  let media-height = _bottom(g) - g.media-top
  let canvas = block(width: 100%, height: 100%)[
    #_placed(
      _col(g, g.content-column),
      g.anchor,
      _span(g, 8),
      g.media-top - g.anchor - g.row-gutter,
      _typeset(t, "body", uniud-black, _fit(self, text-body, overflow: overflow, scale: scale)),
    )
    #_placed(_col(g, 5), g.media-top, _span(g, 4), media-height, left-media)
    #_placed(_col(g, 9), g.media-top, _span(g, 4), media-height, right-media)
  ]
  _canvas-slide(self, config, canvas)
})

/// "Slide testo + immagini", variant b: one large image with its caption.
///
/// `caption-at` sceglie dove va il testo: `bottom` sotto l'immagine (default
/// del tema), `side` nella colonna di sinistra come nel master PowerPoint.
#let caption-media-slide(
  config: (:),
  caption-at: auto,
  overflow: auto,
  scale: auto,
  caption,
  media,
) = touying-slide-wrapper(self => {
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  let at = _caption-at(self, caption-at)
  let text-body(body) = _typeset(
    t,
    "body",
    uniud-black,
    _fit(self, body, overflow: overflow, scale: scale),
  )
  let canvas = if at == "side" {
    block(width: 100%, height: 100%)[
      #_placed(_col(g, 1), g.anchor, _span(g, 4), _bottom(g) - g.anchor, text-body(caption))
      #_placed(_col(g, 5), g.media-anchor, _span(g, 8), _bottom(g) - g.media-anchor, media)
    ]
  } else {
    block(width: 100%, height: 100%)[
      #_placed(
        _col(g, 1),
        g.anchor,
        _span(g, g.columns),
        _bottom(g) - g.anchor,
        grid(
          rows: (1fr, auto),
          row-gutter: _caption-gap,
          media,
          text-body(caption),
        ),
      )
    ]
  }
  _canvas-slide(self, config, canvas)
})

/// "Slide testo + immagini", variant c: 2x2 image grid with its caption.
#let caption-grid-slide(
  config: (:),
  caption-at: auto,
  overflow: auto,
  scale: auto,
  caption,
  a,
  b,
  c,
  d,
) = touying-slide-wrapper(self => {
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  let at = _caption-at(self, caption-at)
  let text-body(body) = _typeset(
    t,
    "body",
    uniud-black,
    _fit(self, body, overflow: overflow, scale: scale),
  )
  let canvas = if at == "side" {
    let row-height = (_bottom(g) - g.media-anchor - g.row-gutter) / 2
    let row2 = g.media-anchor + row-height + g.row-gutter
    block(width: 100%, height: 100%)[
      #_placed(_col(g, 1), g.anchor, _span(g, 4), _bottom(g) - g.anchor, text-body(caption))
      #_placed(_col(g, 5), g.media-anchor, _span(g, 4), row-height, a)
      #_placed(_col(g, 9), g.media-anchor, _span(g, 4), row-height, b)
      #_placed(_col(g, 5), row2, _span(g, 4), row-height, c)
      #_placed(_col(g, 9), row2, _span(g, 4), row-height, d)
    ]
  } else {
    block(width: 100%, height: 100%)[
      #_placed(
        _col(g, 1),
        g.anchor,
        _span(g, g.columns),
        _bottom(g) - g.anchor,
        grid(
          rows: (1fr, auto),
          row-gutter: _caption-gap,
          grid(
            columns: (1fr, 1fr),
            rows: (1fr, 1fr),
            column-gutter: _caption-gap,
            row-gutter: _caption-gap,
            a, b, c, d,
          ),
          text-body(caption),
        ),
      )
    ]
  }
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
#let _code-lines(spec) = {
  if spec == none {
    ()
  } else if type(spec) == int {
    (spec,)
  } else if type(spec) == array {
    spec.map(_code-lines).flatten()
  } else if type(spec) == str {
    spec
      .split(",")
      .map(part => part.trim())
      .filter(part => part != "")
      .map(part => {
        if part.contains("-") {
          let (a, b) = part.split("-")
          // An open range, "5-", runs to the end of the listing.
          range(int(a.trim()), if b.trim() == "" { 1000 } else { int(b.trim()) + 1 })
        } else {
          (int(part),)
        }
      })
      .flatten()
  } else {
    ()
  }
}

#let _code-frame(
  caption: none,
  numbered: false,
  lines: (),
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
        fill: if it.number in lines { mark } else { none },
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

#let _code-steps-fn(self: none, start: 1, steps: (), ..args, body) = {
  // Senza rivelazione i passi decadono: resta il codice, senza evidenziazioni.
  if self.store.at("flat", default: false) {
    return _code-frame(lines: (), ..args.named(), body)
  }
  let i = calc.clamp(self.subslide - start, 0, steps.len() - 1)
  _code-frame(lines: _code-lines(steps.at(i)), ..args.named(), body)
}

#let code-box(
  caption: none,
  numbered: false,
  highlight: (),
  steps: none,
  start: auto,
  fill: auto,
  stroke: none,
  ink: uniud-black,
  size: .8em,
  body,
) = {
  let args = (
    caption: caption,
    numbered: numbered,
    fill: fill,
    stroke: stroke,
    ink: ink,
    size: size,
  )
  if steps == none {
    _code-frame(lines: _code-lines(highlight), ..args, body)
  } else if start == auto {
    touying-fn-wrapper(
      _code-steps-fn,
      last-subslide: repetitions => (
        repetitions + steps.len() - 1,
        (start: repetitions),
      ),
      steps: steps,
      ..args,
      body,
    )
  } else {
    touying-fn-wrapper(
      _code-steps-fn,
      last-subslide: start + steps.len() - 1,
      start: start,
      steps: steps,
      ..args,
      body,
    )
  }
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

// -----------------------------------------------------------------------------
// Progressive reveal
//
// Touying already knows how to walk a slide through subslides (`#pause`,
// `uncover`, `only`, `effect`, `item-by-item`). What is missing for a lecture
// is a *corporate* vocabulary on top of it: emphasise a fragment for one step
// and let it fall back to normal, walk a list keeping the current item dark and
// the rest out of the way, light up a group of code lines at a time.
// -----------------------------------------------------------------------------

/// Fake defocus.
///
/// Typst has no blur filter, so this approximates one: the same content is
/// drawn several times, each copy offset by a fraction of an em on a circle,
/// with nothing sharp underneath. At reading distance it reads as out of
/// focus. It stays opt-in because the text really is in the PDF `layers` times:
/// selection, copy-paste and search see every copy.
// Is this content block-level, i.e. can it wrap over several lines?
#let _blockish(body) = (
  type(body) == content
    and body.func() in (list, enum, terms, block, table, grid, figure, quote)
)

// A veil of the page colour laid *over* the content, sized to it. Written by
// hand rather than with Touying's `cover-with-rect`, which on Typst 0.13
// evaluates the `title` element and so is unusable there.
#let _veil(body, fill, inline: false, clip: false) = {
  let over = place(top + left, rect(width: 100%, height: 100%, fill: fill))
  if inline {
    box(clip: clip, { body; over })
  } else {
    block(width: 100%, breakable: false, clip: clip, { body; over })
  }
}

#let _defocus(body, alpha: 30%, fill: uniud-white, inline: false, radius: .12em, layers: 8, rings: 2) = {
  // Each copy carries only a fraction of the ink, so that the copies together
  // add up to `alpha`: 1 - (1 - per)^n = alpha.
  let copies = layers * rings
  let per = 1 - calc.pow(1 - alpha / 100%, 1 / copies)
  // `clip`: the veil covers the copy's box, and the few pixels of a tall glyph
  // that overshoot it would stay at full ink and read as specks above the line.
  let veil(b) = _veil(
    b,
    utils.update-alpha(fill, 100% - per * 100%),
    inline: inline,
    clip: true,
  )
  let ghosts = {
    for r in range(rings) {
      let rad = radius * (r + 1) / rings
      for i in range(layers) {
        let a = 2 * calc.pi * i / layers + r * calc.pi / layers
        place(dx: rad * calc.cos(a), dy: rad * calc.sin(a), veil(body))
      }
    }
    // Nothing is drawn here: it only reserves the space the copies float over.
    hide(body)
  }
  if inline { box(ghosts) } else { block(width: 100%, ghosts) }
}

/// Text pushed into the background: lighter, or defocused.
///
/// On a block — a list item, a frame — the lightening is a veil of the page
/// colour laid over the content, so it washes out everything underneath at the
/// same rate: bold lead-ins, blue keywords, code frames. On an inline fragment,
/// where a veil would break the line, the text colour is faded instead. Either
/// way it is transparency, not grey, so it works on any background and prints
/// as grey in black and white.
///
/// - alpha: how much of the content is left, 100 % being untouched.
/// - blur: defocus it as well.
/// - fill: colour of the veil; the page colour by default.
/// - inline: `auto` decides from the content.
#let dimmed(body, alpha: 30%, blur: false, fill: uniud-white, inline: auto) = {
  let inline = if inline == auto { not _blockish(body) } else { inline }
  if blur {
    // Defocusing spreads the same ink over a wider area, so it needs a little
    // more of it to read as strongly as the plain veil.
    _defocus(body, alpha: calc.min(alpha * 1.5, 100%), fill: fill, inline: inline)
  } else if inline {
    context text(fill: utils.update-alpha(text.fill, alpha), body)
  } else {
    _veil(body, utils.update-alpha(fill, 100% - alpha))
  }
}

/// Emphasise a fragment on the given subslides only; before and after it is
/// ordinary text.
///
/// ```typst
/// Il costo è #alert-at("2")[$Theta(n log n)$] nel caso peggiore.
/// ```
///
/// - subslides: same syntax as Touying's `only` — `2`, `(1, 3)`, `"2-4"`, `"3-"`.
/// - fill: colour of the emphasis.
#let alert-at(subslides, body, fill: uniud-blue) = effect(
  text.with(fill: fill, weight: "medium"),
  subslides,
  body,
)

/// Highlighter over a fragment, on the given subslides only.
#let mark-at(subslides, body, fill: uniud-blue.lighten(85%)) = effect(
  highlight.with(fill: fill, extent: .08em),
  subslides,
  body,
)

/// Strike a fragment through on the given subslides — a claim being corrected,
/// a step being cancelled out.
#let strike-at(subslides, body) = effect(strike, subslides, body)

/// Push a fragment into the background on the given subslides: the opposite
/// move, useful to make everything else recede around what matters now.
// Passa dal wrapper di Touying invece che da `effect` per una ragione sola:
// dentro il wrapper c'e' `self`, e quindi si puo' sapere se la rivelazione
// progressiva e' spenta. Avvolgere `effect` in un `context` non si puo':
// Touying riconosce i propri marcatori nel corpo della slide e un `context`
// glieli nasconde.
#let _dim-at-fn(self: none, subslides: (), alpha: 30%, blur: false, body) = {
  if self.store.at("flat", default: false) { return body }
  if utils.check-visible(self.subslide, subslides) {
    dimmed(body, alpha: alpha, blur: blur)
  } else {
    body
  }
}

#let dim-at(subslides, body, alpha: 30%, blur: false) = touying-fn-wrapper(
  _dim-at-fn,
  subslides: subslides,
  alpha: alpha,
  blur: blur,
  body,
)


// The items of a list / enum / terms, whichever way it was written.
#let _reveal-items(cont) = {
  if utils.is-sequence(cont) {
    cont.children.filter(c => (
      type(c) == content and c.func() in (list.item, enum.item, terms.item)
    ))
  } else if type(cont) == content and cont.func() in (list, enum, terms) {
    cont.children
  } else {
    ()
  }
}

// Rebuild the container with the styled items, keeping its own settings.
#let _reveal-restyle(cont, style) = {
  let one(item, time) = if item.func() == terms.item {
    terms.item(style(time, item.term), style(time, item.description))
  } else {
    utils.reconstruct(item, style(time, item.body))
  }
  if utils.is-sequence(cont) {
    let i = 0
    let out = ()
    for child in cont.children {
      if type(child) == content and child.func() in (list.item, enum.item, terms.item) {
        out.push(one(child, i))
        i += 1
      } else {
        out.push(child)
      }
    }
    out.sum(default: [])
  } else {
    utils.reconstruct-table-like(
      cont,
      cont.children.enumerate().map(((i, item)) => one(item, i)),
    )
  }
}

#let _focus-list-fn(
  self: none,
  start: 1,
  alpha: 30%,
  blur: false,
  weight: "medium",
  mode: "current",
  cont,
) = {
  // Senza rivelazione la lista e' una lista: nessun elemento in primo piano,
  // nessuno sullo sfondo.
  if self.store.at("flat", default: false) { return cont }
  let current = self.subslide - start
  _reveal-restyle(cont, (i, it) => {
    let done = if mode == "cumulative" { i <= current } else { i == current }
    if done {
      if i == current and weight != none { text(weight: weight, it) } else { it }
    } else {
      // A list item is block-level: it can wrap, so it takes the veil.
      dimmed(it, alpha: alpha, blur: blur, inline: false)
    }
  })
}

/// A list walked one item at a time, with the current item in full ink and the
/// others pushed into the background.
///
/// Unlike Touying's `item-by-item`, nothing is hidden: the whole list is on the
/// slide from the first step, so its shape and length are visible and the page
/// never reflows. What changes is where the eye is sent.
///
/// ```typst
/// #focus-list[
///   - Divide
///   - Impera
///   - Combina
/// ]
/// #focus-list(mode: "cumulative", blur: true)[ ... ]
/// ```
///
/// - start: subslide of the first item; `auto` continues from the current
///   `#pause` position.
/// - mode: `"current"` keeps only the current item in the foreground,
///   `"cumulative"` keeps everything already walked through.
/// - alpha: how much ink is left on the backgrounded items.
/// - blur: defocus them instead of lightening them.
/// - weight: weight of the current item; `none` leaves it alone.
#let focus-list(
  start: auto,
  mode: "current",
  alpha: 30%,
  blur: false,
  weight: "medium",
  body,
) = {
  let n = _reveal-items(body).len()
  let args = (alpha: alpha, blur: blur, weight: weight, mode: mode)
  if n == 0 {
    body
  } else if start == auto {
    touying-fn-wrapper(
      _focus-list-fn,
      last-subslide: repetitions => (repetitions + n - 1, (start: repetitions)),
      ..args,
      body,
    )
  } else {
    touying-fn-wrapper(
      _focus-list-fn,
      last-subslide: start + n - 1,
      start: start,
      ..args,
      body,
    )
  }
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
#let content-slide(
  config: (:),
  title: none,
  wide: auto,
  overflow: auto,
  scale: auto,
  body,
) = touying-slide-wrapper(self => {
  let g = self.store.uniud-layout
  let t = self.store.uniud-type
  let canvas = block(width: 100%, height: 100%)[
    #_placed(
      _col(g, _body-column(self, wide: wide)),
      g.anchor,
      _span(g, _body-span(self, wide: wide)),
      _content-height(g),
      _fit(
        self,
        {
          if title != none {
            block(below: .8em, _typeset(t, "heading", self.colors.primary, title))
          }
          body
        },
        overflow: overflow,
        scale: scale,
      ),
    )
  ]
  _canvas-slide(self, config, canvas)
})

/// `content-slide` pinned to the whole width.
#let wide-slide(config: (:), title: none, overflow: auto, scale: auto, body) = content-slide(
  config: config,
  title: title,
  wide: true,
  overflow: overflow,
  scale: scale,
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
  // Contents of the three recurring blocks: keywords ("date", "author",
  // "institution", "title", "short-title", "subtitle", "" for an empty slot) or
  // explicit content. `auto` follows the masters, except that a deck with a
  // `short-title` puts it where the speaker would be.
  meta: auto,
  // Flatten every slide to its last subslide: one page per slide, for the PDF
  // that gets handed out or printed.
  handout: false,
  // Rivelazione progressiva. Con `false` ogni slide sta su una pagina sola e
  // tutto e' in chiaro: niente passi, niente elementi sullo sfondo, niente
  // evidenziazioni di percorso. Implica `handout: true`.
  incremental: true,
  // Cosa fare quando il contenuto non sta nell'area di testo: "shrink" lo
  // riduce fino a `overflow-min` e lo segnala, "mark" segnala soltanto,
  // "error" ferma la compilazione, "ignore" lascia traboccare.
  // Dove vanno le didascalie degli archetipi con immagini: "bottom" sotto
  // l'immagine, "side" nella colonna laterale come nel master PowerPoint.
  caption-at: "bottom",
  // Dati della carta intestata per la dispensa A4: dipartimento, indirizzo,
  // dicitura istituzionale. Sulle slide non ha effetto — le vede solo
  // `uniud-handout.typ`.
  letterhead: (:),
  // Numerazione delle slide: `none` non numera, una stringa e' un modello di
  // `numbering` ("1", "I"; con due simboli, "1/1", riceve numero e totale),
  // una funzione riceve `(numero, totale)`.
  slide-numbering: none,
  overflow: "shrink",
  overflow-min: 70%,
  overflow-marker: true,
  overflow-warn: true,
  ..args,
  body,
) = {
  // `--input uniud-incremental=false` spegne i passi senza toccare il
  // documento, come `--input uniud-handout=a4` per la dispensa: cosi' le
  // attivita' dell'editor valgono per qualunque lezione.
  let incremental = if sys.inputs.at("uniud-incremental", default: none) == "false" {
    false
  } else {
    incremental
  }
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
  set figure(gap: _caption-gap)
  show figure.caption: set text(size: _caption-size, fill: uniud-dark-gray)
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
      handout: handout or not incremental,
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
      flat: not incremental,
      caption-at: caption-at,
      slide-numbering: slide-numbering,
      overflow: (
        mode: overflow,
        min: overflow-min,
        marker: overflow-marker,
        warn: overflow-warn,
      ),
      overflow-override: (:),
      meta: meta,
      subslide-preamble: block(
        below: (60 / 54 - cap-height + 0.6) * 1em,
        _typeset(t, "heading", primary, utils.display-current-heading(level: 2)),
      ),
    ),
    ..args,
  )

  body
}

// -----------------------------------------------------------------------------
// Modalità dispensa
// -----------------------------------------------------------------------------
//
// Con `--input uniud-handout=a4` le stesse sorgenti si compongono come
// documento A4 su carta intestata invece che come slide. I nomi pubblici
// vengono rilegati qui in coda alle versioni di `uniud-handout.typ`: `import *`
// esporta l'ultima definizione, quindi la lezione non cambia di una riga.
//
//   typst compile --input uniud-handout=a4 --font-path fonts lezione.typ

#import "uniud-handout.typ"

#let _handout-a4 = sys.inputs.at("uniud-handout", default: none) == "a4"

#let uniud-theme = if _handout-a4 { uniud-handout.uniud-theme } else { uniud-theme }
#let slide = if _handout-a4 { uniud-handout.slide } else { slide }
#let title-slide = if _handout-a4 { uniud-handout.title-slide } else { title-slide }
#let section-slide = if _handout-a4 { uniud-handout.section-slide } else { section-slide }
#let new-section-slide = if _handout-a4 { uniud-handout.new-section-slide } else { new-section-slide }
#let next-section = if _handout-a4 { uniud-handout.next-section } else { next-section }
#let content-slide = if _handout-a4 { uniud-handout.content-slide } else { content-slide }
#let wide-slide = if _handout-a4 { uniud-handout.wide-slide } else { wide-slide }
#let text-slide = if _handout-a4 { uniud-handout.text-slide } else { text-slide }
#let text-two-media-slide = if _handout-a4 { uniud-handout.text-two-media-slide } else { text-two-media-slide }
#let caption-media-slide = if _handout-a4 { uniud-handout.caption-media-slide } else { caption-media-slide }
#let caption-grid-slide = if _handout-a4 { uniud-handout.caption-grid-slide } else { caption-grid-slide }
#let mosaic-slide = if _handout-a4 { uniud-handout.mosaic-slide } else { mosaic-slide }
#let full-media-slide = if _handout-a4 { uniud-handout.full-media-slide } else { full-media-slide }
#let focus-slide = if _handout-a4 { uniud-handout.focus-slide } else { focus-slide }
#let quote-slide = if _handout-a4 { uniud-handout.quote-slide } else { quote-slide }
#let outline-slide = if _handout-a4 { uniud-handout.outline-slide } else { outline-slide }
#let references-slide = if _handout-a4 { uniud-handout.references-slide } else { references-slide }
#let media-box = if _handout-a4 { uniud-handout.media-box } else { media-box }
#let focus-list = if _handout-a4 { uniud-handout.focus-list } else { focus-list }
#let dimmed = if _handout-a4 { uniud-handout.dimmed } else { dimmed }
#let alert-at = if _handout-a4 { uniud-handout.alert-at } else { alert-at }
#let mark-at = if _handout-a4 { uniud-handout.mark-at } else { mark-at }
#let strike-at = if _handout-a4 { uniud-handout.strike-at } else { strike-at }
#let dim-at = if _handout-a4 { uniud-handout.dim-at } else { dim-at }
#let wide-mode = if _handout-a4 { uniud-handout.wide-mode } else { wide-mode }
#let overflow-mode = if _handout-a4 { uniud-handout.overflow-mode } else { overflow-mode }

// Questi vengono da Touying, non da qui: in modalità dispensa li copriamo,
// perché `import *` di questo file arriva dopo quello di Touying.
#let speaker-note = if _handout-a4 { uniud-handout.speaker-note } else { speaker-note }
#let pause = if _handout-a4 { uniud-handout.pause } else { pause }
#let meanwhile = if _handout-a4 { uniud-handout.meanwhile } else { meanwhile }
