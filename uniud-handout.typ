// =============================================================================
// UniUD A4 handout
// =============================================================================
//
// La dispensa: le stesse sorgenti delle slide, composte come documento su carta
// intestata di dipartimento invece che come diapositive.
//
//   typst compile --input uniud-handout=a4 --font-path fonts lezione.typ
//
// Il flag arriva a `uniud-theme.typ`, che in coda al file rilega i propri nomi
// pubblici alle versioni definite qui. La sorgente della lezione non cambia
// di una riga.
//
// Riferimento: "Manuale di identita' visiva UniUD", 2.2 Carta intestata
// dipartimento (pp. 070-073).
//
//   p. 070  composizione: header con logo—acronimo del dipartimento, dicitura
//           estesa e indirizzo, filetto 1 pt sopra i blocchi di testo; footer
//           con dicitura istituzionale; 'segue foglio' con logo contratto in
//           testa e numerazione a pie' di pagina
//   p. 071  costruzione: 12 / 15 / 15,2 / 13 / 11 / 12 / 5 mm
//   p. 072  costruzione 'segue foglio': numero pagina Work Sans Regular 8/8
//   p. 073  compilazione: testo Work Sans Regular 10/12,5 pt, mozzo a 1/3 di
//           pagina, riferimenti Work Sans Regular 6/7,5 pt
//
// Le quote della p. 071 sono trascritte dal manuale ma la loro attribuzione ai
// singoli margini e' una lettura del disegno: stanno tutte in `uniud-paper()`,
// quindi si correggono da li' senza toccare il resto.

#import "uniud-tokens.typ": *

// -----------------------------------------------------------------------------
// Geometria del foglio
// -----------------------------------------------------------------------------

/// Costruzione della carta intestata, dalle quote di `uniud.lco` (ramo
/// `dipartimento`) e dal manuale 2.2. Tutte le misure dal vertice della pagina.
#let uniud-paper(
  margin-x: 25mm, // giustezza 160 mm: dentro i 45-90 caratteri per riga (manuale p. 047)
  margin-top: 45mm, // sotto la cornice della testata
  margin-bottom: 26mm,
  mark-left: 12mm,
  mark-top: 12mm,
  mark-height: 13mm, // ingombro del marchio di dipartimento
  head-rule-top: 12mm,
  block-top: 14mm,
  block-width: 40mm,
  block1-left: 107mm, // struttura, firmatario, sito
  block2-left: 155mm, // indirizzo
  continuation-width: 21.3mm, // wordmark UNI/UD del 'segue foglio'
  page-number-left: 176mm,
  footer-bottom: 15mm,
  // Conservato per compatibilita' con le configurazioni esistenti; la
  // dispensa non usa piu' il posizionamento da lettera.
  title-anchor: 33.3%,
) = (
  margin-x: margin-x,
  margin-top: margin-top,
  margin-bottom: margin-bottom,
  mark-left: mark-left,
  mark-top: mark-top,
  mark-height: mark-height,
  head-rule-top: head-rule-top,
  block-top: block-top,
  block-width: block-width,
  block1-left: block1-left,
  block2-left: block2-left,
  continuation-width: continuation-width,
  page-number-left: page-number-left,
  footer-bottom: footer-bottom,
  title-anchor: title-anchor,
)

/// Scala tipografica del documento, dalle pp. 071-073 del manuale.
#let uniud-paper-type(
  body: (size: 10pt, line: 12.5pt),
  meta: (size: 8pt, line: 8pt), // intestazioni della carta intestata
  fine: (size: 6pt, line: 7.5pt), // riferimenti a pie' di pagina
  page-number: (size: 8pt, line: 8pt),
  title: (size: 24pt, line: 26pt),
  subtitle: (size: 14pt, line: 17pt),
  chapter: (size: 18pt, line: 20pt),
  heading: (size: 12pt, line: 12pt),
) = (
  body: body,
  meta: meta,
  fine: fine,
  page-number: page-number,
  title: title,
  subtitle: subtitle,
  chapter: chapter,
  heading: heading,
)

// -----------------------------------------------------------------------------
// Stato: i dati che servono a testata e pie' di pagina
// -----------------------------------------------------------------------------

#let _paper = state("uniud-paper", uniud-paper())
#let _paper-type = state("uniud-paper-type", uniud-paper-type())
#let _letterhead = state("uniud-letterhead", (:))
#let _display-font = state("uniud-display-font", uniud-display-font)
#let _display-weight = state("uniud-display-weight", uniud-display-weight)
#let _deck-started = state("uniud-handout-deck-started", false)
#let _handout-info = state("uniud-handout-info", ())

// Cap height del Work Sans: le interlinee del manuale sono espresse come
// "corpo/interlinea", e con l'ancoraggio alla linea delle maiuscole lo spazio
// da lasciare fra le righe e' l'interlinea meno l'altezza delle maiuscole.
#let _cap-height = 0.66

#let _txt(spec, ink: uniud-black, weight: "regular", body) = text(
  size: spec.size,
  fill: ink,
  weight: weight,
  top-edge: "cap-height",
  bottom-edge: "baseline",
  par(leading: spec.line - _cap-height * spec.size, body),
)

// -----------------------------------------------------------------------------
// Testata e pie' di pagina
// -----------------------------------------------------------------------------
//
// La costruzione segue il pacchetto LaTeX `uniudletter` di Luca Di Gaspero
// (uniud.lco, ramo `dipartimento`), che e' la trascrizione gia' verificata del
// modello ufficiale: quote, colore e composizione del marchio vengono da li'.
//
//   marchio        (12 mm, 12 mm dal vertice), ingombro 13 mm
//   filetti 1 pt   a 12 mm dal bordo, 107→147 mm e 155→195 mm
//   blocchi testo  a 14 mm dal bordo, larghi 40 mm, in blu, 8/8 pt
//   segue foglio   wordmark UNI/UD largo 21,3 mm a (12 mm, 12 mm)
//   numerazione    "n di N" a 176 mm da sinistra e 15 mm dal fondo
//
// Il marchio di dipartimento non e' un file: e' il sigillo piu' l'acronimo
// composto tipograficamente, come nel pacchetto LaTeX e nel modello ufficiale.
// Tutte le misure derivano dall'unita' del manuale, u = ingombro * 4/21.

#let _dept-mark(g, acronym, font, weight) = {
  let u = g.mark-height * 4 / 21
  let seal = u * 21 / 4 // 5,25 u: il sigillo riempie l'ingombro
  let cap = u * 24 / 5 // 4,8 u: altezza dell'acronimo
  let raise = u * 9 / 40 // (5,25 - 4,8) / 2: centratura verticale
  box(height: g.mark-height, {
    box(image(_seal-blue, height: seal, width: seal))
    if acronym != none {
      h(u)
      box(
        baseline: raise,
        text(
          font: font,
          weight: weight,
          size: cap / 0.66, // l'altezza data e' quella delle maiuscole
          fill: uniud-blue,
          top-edge: "cap-height",
          bottom-edge: "baseline",
          acronym,
        ),
      )
    }
  })
}

// Wordmark contratto del 'segue foglio': UNI e UD su due righe, scalate
// insieme perche' il rapporto interno non dipenda dal font disponibile. Il
// manuale ne fissa la larghezza complessiva, quindi si misura e si scala.
#let _continuation-mark(width, font, weight) = context {
  let mark = text(
    font: font,
    weight: weight,
    size: 20pt,
    fill: uniud-blue,
    top-edge: "cap-height",
    bottom-edge: "baseline",
    par(leading: 0.06em)[UNI#linebreak()UD],
  )
  let k = width / measure(mark).width
  box(scale(x: k * 100%, y: k * 100%, origin: top + left, reflow: true, mark))
}

#let _head-rule(g, from, to) = place(
  top + left,
  dx: from,
  dy: g.head-rule-top,
  line(length: to - from, stroke: 1pt + uniud-blue),
)

#let _head-text(t, weight: "regular", body) = _txt(
  t.meta,
  ink: uniud-blue,
  weight: weight,
  body,
)

#let _display(value) = {
  if value == none or value == auto { [] } else if type(value) == datetime {
    value.display("[day]/[month]/[year]")
  } else { value }
}

// -----------------------------------------------------------------------------

#let _handout-frame() = context {
  // Testata e pie' di pagina leggono lo stato con `final()`, non con `get()`:
  // il tema aggiorna quei valori dentro il corpo, cioe' dopo che la prima
  // pagina ha gia' composto la propria cornice.
  let g = _paper.final()
  let t = _paper-type.final()
  let head = _letterhead.final()
  let font = _display-font.final()
  let weight = _display-weight.final()
  let page-number = here().page()
  let entries = _handout-info.final().filter(entry => entry.page <= page-number)
  let info = if entries.len() > 0 { entries.last().info } else { (:) }
  let first = page-number == 1

  if first {
    place(
      top + left,
      dx: g.mark-left,
      dy: g.mark-top,
      _dept-mark(g, head.at("acronym", default: none), font, weight),
    )
    _head-rule(g, g.block1-left, g.block1-left + g.block-width)
    _head-rule(g, g.block2-left, g.block2-left + g.block-width)
    place(
      top + left,
      dx: g.block1-left,
      dy: g.block-top,
      block(width: g.block-width, {
        let course = info.at("course", default: none)
        let academic-year = info.at("academic-year", default: none)
        if course != none and course != auto {
          _head-text(t, weight: "semibold", _display(course))
          if academic-year != none and academic-year != auto {
            v(1.5mm, weak: false)
            _head-text(t, _display(academic-year))
          }
        } else {
          let name = head.at("department", default: none)
          if name != none { _head-text(t, weight: "semibold", name) }
          let who = head.at("signature", default: none)
          if who != none { v(1.5mm, weak: false); _head-text(t, who) }
          let site = head.at("site", default: none)
          if site != none { v(1.5mm, weak: false); _head-text(t, weight: "semibold", site) }
        }
      }),
    )
    place(
      top + left,
      dx: g.block2-left,
      dy: g.block-top,
      block(width: g.block-width, {
        let degree = info.at("degree", default: none)
        if degree != none and degree != auto {
          _head-text(t, weight: "semibold", _display(degree))
        } else {
          for l in head.at("address", default: ()) { _head-text(t, l) }
        }
      }),
    )
    let foot = head.at("institution-line", default: none)
    if foot != none {
      place(
        bottom + left,
        dx: g.mark-left,
        dy: -g.footer-bottom,
        _txt(t.fine, ink: uniud-dark-gray, foot),
      )
    }
  } else {
    place(
      top + left,
      dx: g.mark-left,
      dy: g.mark-top,
      _continuation-mark(g.continuation-width, font, weight),
    )
    place(
      bottom + left,
      dx: g.page-number-left,
      dy: -g.footer-bottom,
      _txt(t.page-number, ink: uniud-blue, context [#counter(page).display() di #counter(page).final().first()]),
    )
  }

}

// -----------------------------------------------------------------------------
// Il tema
// -----------------------------------------------------------------------------

// `config-info(...)` di Touying arriva come dizionario posizionale: qui serve
// solo il suo contenuto.
#let _collect-info(args) = {
  let info = (:)
  for a in args.pos() {
    if type(a) == dictionary and "info" in a { info += a.info }
  }
  info
}

#let _fit-page(body) = layout(size => {
  let natural = measure(body)
  if natural.width <= size.width and natural.height <= size.height {
    body
  } else {
    let width-factor = if natural.width > size.width {
      size.width / natural.width
    } else { 1.0 }
    let height-factor = if natural.height > size.height {
      size.height / natural.height
    } else { 1.0 }
    let factor = calc.min(
      width-factor,
      height-factor,
    )
    scale(
      x: factor * 100%,
      y: factor * 100%,
      origin: top + left,
      reflow: true,
      body,
    )
  }
})

#let uniud-theme(
  font: "Work Sans",
  code-font: "DejaVu Sans Mono",
  math-font: "Fira Math",
  primary: uniud-blue,
  paper: auto,
  paper-type: auto,
  // Dati della carta intestata: acronimo, dipartimento, indirizzo, sito,
  // dicitura istituzionale.
  letterhead: (:),
  // Carattere e peso dei marchi composti — acronimo di dipartimento e wordmark
  // del 'segue foglio', che il manuale vuole entrambi in Gotham Bold. Chi ha
  // Gotham passa `("Gotham", "Work Sans")` e `"bold"`.
  display-font: uniud-display-font,
  display-weight: uniud-display-weight,
  // Le note del relatore finiscono nella dispensa, evidenziate.
  notes: true,
  ..args,
  body,
) = {
  let g = if paper == auto { uniud-paper() } else { paper }
  let t = if paper-type == auto { uniud-paper-type() } else { paper-type }
  let info = _collect-info(args)

  set page(
    paper: "a4",
    margin: (
      left: g.margin-x,
      right: g.margin-x,
      top: g.margin-top,
      bottom: g.margin-bottom,
    ),
    // La cornice e' posizionata sulla pagina intera, come l'overlay TikZ del
    // pacchetto LaTeX: cosi' le quote sono quelle del manuale, misurate dal
    // vertice del foglio e non dal margine.
    background: _handout-frame(),
    header: none,
    footer: none,
  )

  set text(size: t.body.size, fill: uniud-black)
  set text(font: font) if font != none
  set par(leading: t.body.line - _cap-height * t.body.size, justify: false, spacing: 1.1em)
  show raw: set text(font: code-font)
  show math.equation: set text(font: math-font)
  show link: set text(fill: primary)
  show cite: set text(fill: primary)
  set figure(numbering: none)
  show figure: it => _fit-page(it)
  show figure.caption: set text(size: 0.8em, fill: uniud-dark-gray)

  // `= Sezione` diventa titolo di capitolo, `== Slide` diventa il titolo del
  // paragrafo che quella slide occupava.
  show heading.where(level: 1): it => {
    block(above: 1.8em, below: 1.2em, {
      line(length: 100%, stroke: 2pt + primary)
      v(3mm, weak: false)
      _txt(t.chapter, ink: primary, weight: "bold", it.body)
    })
  }
  show heading.where(level: 2): it => block(
    above: 1.6em,
    below: 0.7em,
    _txt(t.heading, ink: primary, weight: "semibold", it.body),
  )
  show heading.where(level: 3): set text(size: 1em, weight: "bold", fill: primary)

  _paper.update(g)
  _paper-type.update(t)
  _letterhead.update(letterhead)
  _display-font.update(display-font)
  _display-weight.update(display-weight)
  // `--input uniud-handout-notes=no` (cioe' `--no-notes` dello script) ha
  // l'ultima parola sul parametro del tema.
  let notes = if sys.inputs.at("uniud-handout-notes", default: none) == "no" { false } else { notes }
  state("uniud-handout-notes").update(notes)

  // Ogni sorgente incluso invoca il tema una volta. Le sezioni scorrono nel
  // documento; solo un nuovo deck comincia su una pagina nuova.
  context {
    if _deck-started.get() { pagebreak(weak: true) }
    _deck-started.update(true)
  }
  context {
    let start-page = here().page()
    _handout-info.update(entries => entries + ((page: start-page, info: info),))
  }

  // La dispensa non e' una lettera: il titolo parte dall'inizio dell'area di
  // testo, subito sotto la testata istituzionale.
  block(below: 2em, {
    _txt(t.title, ink: primary, weight: "bold", _display(info.at("title", default: none)))
    let sub = _display(info.at("subtitle", default: none))
    if sub != [] {
      v(2mm, weak: false)
      _txt(t.subtitle, ink: uniud-black, weight: "medium", sub)
    }
    v(4mm, weak: false)
    _txt(
      (size: t.meta.size, line: t.meta.size * 1.45),
      ink: uniud-dark-gray,
      {
        let bits = (
          _display(info.at("author", default: none)),
          _display(info.at("institution", default: none)),
          _display(info.at("date", default: none)),
        ).filter(x => x != [])
        bits.join(linebreak())
      },
    )
  })

  body
}

// -----------------------------------------------------------------------------
// Gli archetipi delle slide, in versione documento
// -----------------------------------------------------------------------------
//
// Ogni funzione perde la geometria della diapositiva e tiene il contenuto:
// quello che sulla slide era una posizione qui diventa una gerarchia.

#let _figure(body, caption: none) = {
  let f = block(width: 100%, body)
  if caption == none { f } else { figure(f, caption: caption) }
}

// Segnaposto grigio: in pagina non puo' prendersi il 100 % dell'altezza, che
// sul foglio vuol dire tutta la pagina.
#let media-box(
  width: 100%,
  height: auto,
  fill: uniud-gray-web,
  inset: 0pt,
  caption: none,
  ..body,
) = {
  let content = body.pos().join()
  let h = if height == auto and content == none { 40mm } else { height }
  let media = block(width: width, height: h, fill: fill, inset: inset, clip: true, content)
  if caption == none { media } else { figure(media, caption: caption) }
}

#let _row(..items) = {
  let items = items.pos().filter(x => x != none)
  grid(
    columns: items.map(_ => 1fr),
    column-gutter: 4mm,
    ..items,
  )
}

// La copertina e' gia' la testata del documento.
#let title-slide(..args) = none
#let next-section(..args) = none

#let section-slide(title: none, subtitle: none, ..args) = {
  heading(level: 1, title)
  if subtitle != none { block(below: 1.2em, _txt((size: 11pt, line: 14pt), ink: uniud-dark-gray, subtitle)) }
}

#let new-section-slide(..args, body) = section-slide(title: body)

#let slide(..bodies) = bodies.pos().join()

#let content-slide(title: none, body) = {
  if title != none { heading(level: 2, title) }
  body
}

#let wide-slide(title: none, body) = content-slide(title: title, body)
#let text-slide(..args, body) = body

#let text-two-media-slide(..args) = {
  let p = args.pos()
  p.at(0, default: none)
  _row(p.at(1, default: none), p.at(2, default: none))
}

#let caption-media-slide(..args) = {
  let p = args.pos()
  p.at(1, default: none)
  p.at(0, default: none)
}

#let caption-grid-slide(..args) = {
  let p = args.pos()
  _row(p.at(1, default: none), p.at(2, default: none))
  _row(p.at(3, default: none), p.at(4, default: none))
  p.at(0, default: none)
}

#let mosaic-slide(..args) = {
  let p = args.pos()
  for chunk in p.chunks(2) { _row(..chunk) }
}

#let full-media-slide(..args) = args.pos().last()

// L'enfasi a piena pagina diventa un richiamo: sul foglio una pagina blu non
// avrebbe senso, ma il rilievo del passaggio si', ed e' quello che conta.
#let focus-slide(..args) = block(
  width: 100%,
  above: 1.4em,
  below: 1.4em,
  inset: (x: 5mm, y: 4mm),
  fill: uniud-blue,
  text(fill: uniud-white, weight: "semibold", size: 1.15em, args.pos().last()),
)

#let quote-slide(attribution: none, ..args) = {
  block(
    width: 100%,
    above: 1.4em,
    below: 1.4em,
    inset: (left: 5mm),
    stroke: (left: 2pt + uniud-blue),
    {
      text(style: "italic", args.pos().last())
      if attribution != none {
        v(2mm, weak: false)
        _txt((size: 9pt, line: 11pt), ink: uniud-dark-gray, attribution)
      }
    },
  )
}

#let outline-slide(title: none, ..args) = {
  if title != none { heading(level: 2, title) }
  outline(title: none, depth: 2)
}

#let references-slide(title: none, cols: 1, size: 1em, wide: auto, column: auto, span: auto, ..args) = {
  if title != none { heading(level: 2, title) }
  bibliography(..args)
}

// -----------------------------------------------------------------------------
// Rivelazione progressiva: sul foglio non c'e' nulla da rivelare
// -----------------------------------------------------------------------------

#let pause = none
#let meanwhile = none
#let uncover(..args) = args.pos().last()
#let only(..args) = args.pos().last()
#let alert-at(..args) = text(fill: uniud-blue, weight: "semibold", args.pos().last())
#let mark-at(..args) = highlight(fill: uniud-blue.lighten(85%), args.pos().last())
#let strike-at(..args) = strike(args.pos().last())
#let dim-at(..args) = args.pos().last()
#let dimmed(..args) = args.pos().last()
#let focus-list(..args) = args.pos().last()

#let wide-mode(..args) = body => body
#let overflow-mode(..args) = body => body

// -----------------------------------------------------------------------------
// Note del relatore
// -----------------------------------------------------------------------------
//
// Sulle slide restano fuori campo; nella dispensa sono meta' del valore, quindi
// entrano in pagina evidenziate e riconoscibili a colpo d'occhio.

#let speaker-note(..args) = context {
  if not state("uniud-handout-notes", true).final() {
    none
  } else {
    let body = args.pos().last()
    block(
      width: 100%,
      above: 1em,
      below: 1em,
      inset: (x: 4mm, y: 3mm),
      radius: 1mm,
      fill: uniud-blue.lighten(93%),
      stroke: (left: 2pt + uniud-blue),
      text(size: 0.9em, fill: uniud-dark-gray, body),
    )
  }
}
