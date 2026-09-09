// Teaching extensions: the slide shapes a lecture needs and the corporate
// masters do not cover — agenda, columns, callouts, code, output, tables,
// quotations, progressive reveals.
//
//   typst compile --root .. lecture.typ
//   typst compile --root .. --input style=01 lecture.typ lecture-01.pdf
//   typst compile --root .. --input wide=true lecture.typ lecture-wide.pdf
//   typst compile --root .. --input handout=true lecture.typ lecture-handout.pdf

#import "@preview/touying:0.7.4": *
#import "../uniud-theme.typ": *

#show: uniud-theme.with(
  style: sys.inputs.at("style", default: "02"),
  aspect-ratio: sys.inputs.at("ratio", default: "16-9"),
  // `wide: true` lets ordinary `== Titolo` slides use the whole width.
  wide: sys.inputs.at("wide", default: "false") == "true",
  // One page per slide instead of one per step, for the handout.
  handout: sys.inputs.at("handout", default: "false") == "true",
  font: "Work Sans",
  // Carta intestata della dispensa A4: sulle slide non ha effetto.
  letterhead: (
    acronym: [DPIA],
    department: [Dipartimento Politecnico di\ ingegneria e architettura],
    site: [uniud.it],
    address: ([via delle Scienze 206], [33100 Udine, Italia]),
    institution-line: [Università degli Studi di Udine],
  ),
  config-info(
    title: [Strutture dati e algoritmi],
    subtitle: [Lezione 7 — Ordinamento per fusione],
    // Nei ricorrenti prende il posto del relatore: in aula serve sapere che
    // lezione è, non chi parla.
    short-title: [Ordinamento per fusione],
    author: [Prof. Mario Rossi],
    date: [Udine, 22 settembre 2023],
    institution: [Dipartimento Politecnico di Ingegneria e Architettura],
  ),
)

#title-slide()

// Agenda: numbered like the section slides, filled in automatically.
#outline-slide(title: [Indice della lezione])

= Divide et impera

L'idea generale e il caso dell'ordinamento.

== Elenco con rivelazione progressiva

Il paradigma si articola in tre passi.

#pause
- *Divide*: si spezza il problema in sottoproblemi dello stesso tipo.
#pause
- *Impera*: si risolvono i sottoproblemi ricorsivamente.
#pause
- *Combina*: si ricompongono le soluzioni parziali.

== Elenco a fuoco

L'elenco resta tutto sulla slide: cambia dove va l'occhio.

#focus-list[
  - *Divide*: il problema si spezza in due metà.
  - *Impera*: ogni metà si ordina ricorsivamente.
  - *Combina*: la fusione ricompone il vettore ordinato.
]

== Elenco a fuoco, cumulativo e sfocato

#focus-list(mode: "cumulative", blur: true)[
  - Il caso base è il vettore di un solo elemento.
  - La ricorsione dimezza a ogni livello: $log_2 n$ livelli.
  - Ogni livello costa $Theta(n)$ confronti, da cui $Theta(n log n)$.
]

== Enfasi su un frammento

Il costo di merge sort è #alert-at("2")[$Theta(n log n)$] nel caso peggiore,
al prezzo di #mark-at("3")[$Theta(n)$] di memoria ausiliaria.

Quicksort in place #strike-at("4")[è stabile]: non lo è.

#dim-at("4-")[Questo dettaglio esce di scena quando arriviamo al confronto.]

== Testo su due colonne

#columns(2)[
  Il testo che deve scorrere da una colonna all'altra usa il `columns` di Typst,
  che bilancia automaticamente le due colonne.

  È la soluzione giusta per un paragrafo lungo o per un elenco che non entra in
  una colonna sola.

  Per blocchi indipendenti — un testo e uno schema, del codice e il suo output —
  conviene invece `side-by-side`, che li affianca senza farli scorrere.
]

== Blocchi affiancati

#side-by-side[
  #callout(title: [Definizione])[
    Un algoritmo di ordinamento è _stabile_ se preserva l'ordine relativo di
    elementi con chiave uguale.
  ]
][
  #callout(title: [Attenzione], accent: uniud-black)[
    La stabilità non è gratuita: quicksort in place non è stabile, merge sort
    lo è al prezzo di memoria ausiliaria.
  ]
]

== Definizione, teorema, esempio

#callout(title: [Teorema])[
  Ogni algoritmo di ordinamento basato su confronti esegue
  $Omega(n log n)$ confronti nel caso peggiore.
]

#v(.6em)

#callout(title: [Dimostrazione], accent: uniud-black, fill: uniud-gray.lighten(85%))[
  L'albero di decisione ha $n!$ foglie, quindi altezza almeno
  $log_2(n!) = Theta(n log n)$.
]

== Formule

Il costo di merge sort si ricava dalla ricorrenza

$ T(n) = 2 T(n/2) + Theta(n), quad T(1) = Theta(1), $

che per il teorema dell'esperto @clrs vale $T(n) = Theta(n log n)$. In generale,
per confronti, $sum_(i=1)^n log_2 i = log_2 (n!) = Theta(n log n)$.

= Implementazione

Dal pseudocodice al codice eseguibile.

== Frame di codice

#code-box(caption: [merge_sort.py], numbered: true, highlight: (6, 7))[
```python
def merge_sort(a):
    if len(a) <= 1:
        return a
    m = len(a) // 2
    left, right = merge_sort(a[:m]), merge_sort(a[m:])
    return merge(left, right)
```
]

== Codice commentato passo passo

#code-box(
  caption: [merge_sort.py],
  numbered: true,
  // Come il `data-line-numbers="1|2-3|4-5|6"` di reveal.js.
  steps: (none, "1", "2-3", "4-5", "6"),
)[
```python
def merge_sort(a):
    if len(a) <= 1:
        return a
    m = len(a) // 2
    left, right = merge_sort(a[:m]), merge_sort(a[m:])
    return merge(left, right)
```
]

#speaker-note[
  Sul passo 4 fermarsi: è lì che si paga la memoria ausiliaria.
]

== Due varianti del frame

#side-by-side(gutter: 1em)[
  #code-box(caption: [fondo pieno], size: .7em)[
```python
for i in range(n):
    print(i)
```
  ]
][
  #code-box(caption: [con bordo], size: .7em, fill: none, stroke: .06em + uniud-gray)[
```python
for i in range(n):
    print(i)
```
  ]
]

// Full width: code and its output side by side, which the corporate text
// measure would squeeze.
#wide-slide(title: [Codice e output affiancati])[
  #side-by-side(gutter: 1em)[
    #code-box(caption: [sessione], numbered: true)[
```python
a = [5, 2, 9, 1, 5, 6]
print(merge_sort(a))
print(sorted(a) == merge_sort(a))
```
    ]
  ][
    #output-box(caption: [risultato])[
```text
[1, 2, 5, 5, 6, 9]
True
```
    ]
  ]
]

#wide-slide(title: [Confronto fra algoritmi])[
  #uniud-table(
    columns: (auto, 1fr, 1fr, 1fr, auto),
    table.header([Algoritmo], [Caso migliore], [Caso medio], [Caso peggiore], [Stabile]),
    [Insertion sort], [$n$], [$n^2$], [$n^2$], [sì],
    [Merge sort], [$n log n$], [$n log n$], [$n log n$], [sì],
    [Quicksort], [$n log n$], [$n log n$], [$n^2$], [no],
    [Heapsort], [$n log n$], [$n log n$], [$n log n$], [no],
  )

  #v(.6em)
  Le complessità sono espresse in $Theta$ sul numero di confronti.
]

// `wide-mode` is the only way to change the width of the slides Touying builds
// from a `== Heading`: it switches from here on, so it comes in pairs.
#show: wide-mode(true)

== Una slide forzata a tutta larghezza

Questa slide segue `#show: wide-mode(true)`, quindi parte dalla prima colonna
anche se il deck è nella misura corporate.

#show: wide-mode(false)

== Figura con didascalia

#figure(
  media-box(height: 55%)[
    #align(center + horizon)[#text(fill: uniud-gray)[schema dell'albero di ricorsione]]
  ],
  caption: [Albero di ricorsione di merge sort su un vettore di 8 elementi.],
)

// Citazione a tutta pagina.
#quote-slide(attribution: [Donald E. Knuth, 1974])[
  L'ottimizzazione prematura è la radice di ogni male.
]

= Conclusioni

Cosa portarsi a casa.

== Riepilogo

- Merge sort ordina in $Theta(n log n)$ confronti, sempre.
- Il prezzo è $Theta(n)$ di memoria ausiliaria.
- La #alert[stabilità] è una proprietà dell'algoritmo, non dei dati.
- Per l'analisi completa si vedano @clrs e @knuth1974; su quicksort @sedgewick1978.

#references-slide(title: [Riferimenti], "lecture.bib", style: "ieee")

#focus-slide[Domande?]
