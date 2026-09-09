// Visual test suite for the UniUD Touying theme.
// One slide per archetype of the corporate PowerPoint master, plus the
// multiline / stress cases the theme has to survive.
//
//   typst compile --root .. corporate.typ
//   typst compile --root .. --input ratio=4-3 corporate.typ corporate-4-3.pdf
//   typst compile --root .. --input style=01 corporate.typ corporate-01.pdf

#import "@preview/touying:0.7.4": *
#import "../uniud-theme.typ": *

// Change to "16-10" or "4-3" to test the same normalized layouts
// at a different slide aspect ratio.
#let demo-aspect-ratio = sys.inputs.at("ratio", default: "16-9")

// Corporate master: "02" (blue band) or "01" (recurring items at the bottom).
#let demo-style = sys.inputs.at("style", default: "02")

#show: uniud-theme.with(
  style: demo-style,
  aspect-ratio: demo-aspect-ratio,
  font: "Work Sans",
  config-info(
    title: [Titolo presentazione da scrivere su più righe massimo tre righe],
    subtitle: [Eventuale sottotitolo dalla lunghezza variabile, che può comporsi su più righe],
    author: [Prof. Mario Rossi],
    date: [Udine, 22 settembre 2023],
    institution: [Dipartimento di Lingue e Letterature, Comunicazione, Formazione e Società],
  ),
)

// 1. Corporate blue cover.
#title-slide(variant: "blue")

// 2. Corporate white cover.
#title-slide(variant: "white")

// 3. Cover with a single-line title: the subtitle has to follow the title,
//    not sit at a fixed height.
#title-slide(
  variant: "blue",
  title: [Titolo breve],
  subtitle: [Sottotitolo su una riga],
)

// 4. Text-only corporate layout (Work Sans Medium 85/88).
#text-slide[
  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
  tempor incididunt ut labore et dolore magna aliqua.
]

// 5. Text plus two images.
#text-two-media-slide[
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat
  a ante venenatis dapibus posuere velit aliquet.
][
  #media-box[
    #align(center + horizon)[#text(fill: uniud-gray, size: .75em)[image / diagram]]
  ]
][
  #media-box[
    #align(center + horizon)[#text(fill: uniud-gray, size: .75em)[image / diagram]]
  ]
]

// 6. Explanatory text on the left, one large image on the right.
#caption-media-slide[
  Spazio dedicato a un breve testo esplicativo dell'immagine oppure per uno
  schema o un elenco di voci.
][
  #media-box[
    #align(center + horizon)[#text(fill: uniud-gray, size: .75em)[large image]]
  ]
]

// 7. Explanatory text on the left, four-image grid on the right.
#caption-grid-slide[
  Spazio dedicato a un breve testo esplicativo dell'immagine oppure per uno
  schema o un elenco di voci.
][#media-box[]][#media-box[]][#media-box[]][#media-box[]]

// 8. Corporate image mosaic.
#mosaic-slide(
  media-box[], media-box[], media-box[],
  media-box[], media-box[], media-box[],
)

// 9. Full-media slide: under the band in style "02", without the recurring
//    items in style "01". The placeholder is light, so the logo is the blue one.
#full-media-slide(logo: "blue")[
  #media-box(fill: uniud-gray-web)[
    #align(center + horizon)[#text(fill: uniud-gray, size: 1em)[full-bleed image / visual]]
  ]
]

// 10-13. The four corporate section variants, with a two-line title.
#section-slide(
  number: 1,
  variant: "blue",
  title: [Titolo sezione anche su più righe],
  subtitle: [Eventuale sottotitolo dalla lunghezza variabile, che può comporsi su più di due righe],
)

#section-slide(
  number: 2,
  variant: "black",
  title: [Titolo sezione anche su più righe],
  subtitle: [Eventuale sottotitolo dalla lunghezza variabile, che può comporsi su più di due righe],
)

#section-slide(
  number: 3,
  variant: "gray",
  title: [Titolo sezione anche su più righe],
  subtitle: [Eventuale sottotitolo dalla lunghezza variabile, che può comporsi su più di due righe],
)

#section-slide(
  number: 4,
  variant: "white",
  title: [Titolo sezione anche su più righe],
  subtitle: [Eventuale sottotitolo dalla lunghezza variabile, che può comporsi su più di due righe],
)

// 14. Section slide stress test: short title, two-digit number, no subtitle.
#section-slide(
  number: 12,
  variant: "blue",
  title: [Conclusioni],
)

// 15. Emphasis slide.
#focus-slide[Hic sunt futura]

// 16-17. Ordinary content slides driven by headings.
= Struttura della lezione

Questa riga diventa il sottotitolo della slide di sezione.

== Slide con titolo e testo

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a
ante venenatis dapibus posuere velit aliquet.

- Primo punto dell'elenco
- Secondo punto dell'elenco
- Terzo punto dell'elenco

== Slide con titolo su due righe che manda a capo naturalmente

Sed posuere consectetur est at lobortis. Donec ullamcorper nulla non metus
auctor fringilla.
