# UniUD Touying theme

[![Release](https://github.com/iolab-uniud/uniud-typst-touying/actions/workflows/release.yml/badge.svg)](https://github.com/iolab-uniud/uniud-typst-touying/actions/workflows/release.yml)

Corporate Touying theme for UniUD teaching slides. Geometry and type are
measured out of the two official UniUD PowerPoint masters and cross-checked
against the *Manuale di identità visiva*, sections 3.1 and 3.2.

**Per scrivere una presentazione: [GUIDA.md](GUIDA.md)** — guida operativa in
italiano a tutte le funzionalità. Questo README è il riferimento tecnico: misure
corporate, scostamenti dal manuale, scelte di design.

## Requirements

Typst 0.13.1+ and Touying 0.7.4, which Typst downloads on its own. Both fonts
the theme needs ship in `fonts/`, under the SIL Open Font License:

- **Work Sans** — the corporate typeface (the manual's substitute for Gotham and
  LL Circular, p. 045);
- **Fira Math** — for equations, because Typst's built-in math font is a serif
  and clashes with Work Sans. `math-font: "New Computer Modern Math"` goes back
  to the built-in one.

So nothing has to be installed system-wide: compile passing the folder and the
result is identical on any machine.

```
typst compile --font-path fonts lezione.typ
```

## Installing

Three routes, depending on how you work.

**As a local package** — makes the theme importable from any document and
usable as a `typst init` template. Download
`uniud-touying-<version>-pacchetto-locale.zip` from the
[releases](https://github.com/iolab-uniud/uniud-typst-touying/releases) and
unzip it into Typst's package directory (`typst info` prints yours):

```sh
# macOS
unzip uniud-touying-0.3.1-pacchetto-locale.zip \
  -d "$HOME/Library/Application Support/typst/packages/local"

typst init @local/uniud-touying:0.3.1 mia-lezione
cd mia-lezione && typst watch --font-path fonts main.typ
```

`typst init` scaffolds a project that already carries the fonts, so it compiles
the same everywhere. In any other document: `#import "@local/uniud-touying:0.3.1": *`.

**As a ready-made project** — installs nothing, and it is the way to work on
typst.app, which supports neither local packages nor system fonts: unzip
`uniud-touying-<version>-progetto.zip`, open an empty project on typst.app and
drop every file into it (fonts in a project folder are picked up automatically).

**From a clone** — for working on the theme itself. `./scripts/install-local.sh`
installs the working tree as `@local/uniud-touying:<version>`, so a document can
import it without going through a release; `--link` symlinks it instead of
copying, and every edit to the theme is immediately live in the documents that
import it. `--prune` clears the older versions left in the namespace once the
new one is in place, and `--uninstall --all` removes every installed version.
`./scripts/build-release.sh` compiles every example in every variant and
assembles both zips into `dist/`, which is exactly what CI does.

## Basic use

```typst
#import "@preview/touying:0.7.4": *
#import "uniud-theme.typ": *

#show: uniud-theme.with(
  style: "02",          // corporate master: "02" (default) or "01"
  aspect-ratio: "16-9",
  font: "Work Sans",
  config-info(
    title: [Presentation title],
    subtitle: [Optional subtitle],
    author: [Name],
    date: [Udine, date],
    institution: [Department],
  ),
)

#title-slide()

= Section title

This paragraph becomes the section subtitle.

== Slide title

Lorem ipsum dolor sit amet.
```

Content placed directly after a `=` heading is consumed as the *subtitle of the
section slide* (Touying's `receive-body-for-new-section-slide-fn`). Ordinary
slide content therefore has to live under a `==` heading.

## Corporate styles

Both official masters are available. What separates them is where the *elementi
ricorrenti* — place and date, speaker, department — sit, so `style` accepts
either the corporate number or that position as a name:

| | `"01"` = `"bottom"` | `"02"` = `"top"` (default) |
| ---------------------- | ----------------------------- | --------------------------- |
| recurring items        | along the bottom, 90.7 %      | in the blue band, 5.2 %     |
| recurring items grid   | columns 1, 5 and 7            | columns 7, 9 and 11         |
| recurring items type   | Work Sans Bold 16/19, black   | Work Sans Bold 16/16, white |
| colour band            | none                          | 18.8 % of the height        |
| title / text anchor    | 19.2 %                        | 27.2 %                      |
| bottom margin          | 12.5 % (4,8 cm)               | 5 % (1,9 cm)                |
| image zones start at   | the top margin                | the text anchor             |
| full-screen image      | no recurring items, logo only | band kept                   |

Grid, type scale, colours, logos, section slides and every layout helper are
shared, so switching a deck from one master to the other is a one-word change:

```typst
#show: uniud-theme.with(style: "bottom", ...)   // or "01"
```

The manual calls the block "elementi ricorrenti" and uses *intestazione* only
for their type style (Work Sans Bold 16, uppercase), which is why the theme
talks about recurring items rather than headers or footers.

**What goes in them.** The masters carry place and date, the speaker and the
structure. In a lecture the speaker is the least useful of the three — the room
knows who is talking, and what it does not always remember is which lecture this
is — so a `short-title` takes that slot as soon as it is given:

```typst
config-info(
  title: [Strutture dati e algoritmi],
  short-title: [Ordinamento per fusione],   // goes in the recurring items
  author: [Prof. Mario Rossi],              // stays on the cover
  ...
)
```

The long title still heads the cover and the PDF metadata; the short one is the
running head. `meta:` overrides the three slots outright, each entry a keyword
(`"date"`, `"author"`, `"institution"`, `"title"`, `"short-title"`, `"subtitle"`,
`"short-subtitle"`, or `""` for an empty slot) or explicit content:

```typst
#show: uniud-theme.with(meta: ([Analisi matematica], "short-title", ""), ...)
```

## Design system

Both masters are 24384000 x 13716000 EMU, exactly the 1920 x 1080 pt canvas
(67,73 x 38,10 cm) the manual draws on, so every corporate measure converts into
a percentage of the slide:

| corporate measure    | value      | normalized                  |
| -------------------- | ---------- | --------------------------- |
| margins              | 1,9 cm     | 2.805 % w / 5.0 % h         |
| column gutter        | 0,6 cm     | 0.886 % w / 1.575 % h       |
| grid                 | 12 columns | column 7.054 %, step 7.94 % |
| titles and body text | 23,4 cm    | column 5                    |
| recurring items      | 34/45/55 cm| columns 7, 9, 11 in "02"    |
| section number       | 17,5-18 cm | columns 3-4, flush right    |
| extended logo        | 15,6 cm    | 23.08 % w                   |
| compact logo         | 8,5 cm     | 12.61 % w                   |

Type follows the manual (pp. 048-049, 111-127) and matches the masters. Sizes
are multiples of `base-size`, never nested `em`, so a size can never be rescaled
by its context:

| role              | corporate spec              | multiple of `base-size` |
| ----------------- | --------------------------- | ----------------------- |
| title             | Work Sans Bold 85/88        | 1.932                   |
| subtitle          | Work Sans Medium 51/54      | 1.159                   |
| text-only slide   | Work Sans Medium 85/88      | 1.932                   |
| text + images     | Work Sans Medium 54/60      | 1.227                   |
| section number    | Work Sans Bold 221          | 5.023                   |
| recurring items   | Work Sans Bold 16/16, CAPS  | 0.364                   |

`base-size` is 44 pt on the corporate canvas, i.e. 4.074 % of the slide height.
It defaults to `auto`, which derives it from the actual page height: Touying's
presentation papers are 473.56 pt high at 16:9 but 595.28 pt at 4:3, so a fixed
pt value would make the corporate proportions drift between aspect ratios.

Line spacing is computed from the cap height of the font, so the first line of
every block sits exactly on the anchor and the baseline grid reproduces
the "85/88" specifications. If you change `font`, set `cap-height` accordingly
(0.66 for Work Sans).

Colours are the corporate palette (manual p. 037): `uniud-blue` (#0000ff),
`uniud-gray` (#b3b6b7, Pantone 877 U), `uniud-gray-web` (#cdcdce),
`uniud-black`, `uniud-white` and `uniud-dark-gray` (70 % black, used for
secondary text on light backgrounds). The shipped PowerPoint master actually
uses #0433ff; pass `primary: uniud-blue-ppt` to match the deck instead of the
manual.

## Adaptive blocks

Title, subtitle and body blocks flow — they are never pinned to a fixed height.
A one-line title leaves the subtitle high on the slide, a three-line title
pushes it down, and the two can never collide. The only fixed vertical
reference is the anchor at the top of the block.

## A4 handout

The same source also composes as an A4 document on department letterhead
instead of as slides:

It is switched on with a compiler `--input`, not a theme parameter — by the
time `uniud-theme.with(...)` runs, `#text-slide` has already been resolved, so
the choice has to be made when the module is imported:

```
typst compile --input uniud-handout=a4 --font-path fonts lecture.typ lecture-handout.pdf
typst watch   --input uniud-handout=a4 --font-path fonts lecture.typ
```

The script is a shortcut for that same line. A project scaffolded with
`typst init` already carries a `.vscode/` with tasks for slides, the A4 handout,
slides without progressive reveal and adding a new lecture, plus the Tinymist
settings that point the preview at the project's own `fonts/`. For a course,
run `typst init` once at the course root and keep the lectures in subfolders:
the tasks compile the open file and look for fonts in `${workspaceFolder}/fonts`,
so they work at any depth. With the fonts installed system-wide the `fonts/`
folder can simply be deleted — a `--font-path` pointing nowhere is not an error
— and it is only worth keeping to make the project portable, typst.app
included.

```
./scripts/make-handout.sh lecture.typ             # → lecture-handout.pdf
./scripts/make-handout.sh lecture.typ --no-notes
```

The script takes the *source*, not the slide PDF: the handout is not a montage
of the slides, it is the same content recomposed as a document. Underneath it
is `typst compile --input uniud-handout=a4`; the lecture file does not change,
because `uniud-theme.typ` rebinds its public names to the `uniud-handout.typ`
versions when that flag is set.

The cover becomes the document masthead, `= Section` a chapter opening, `==
Title` a paragraph heading, progressive reveal collapses, `focus-slide` becomes
a blue callout, and `#speaker-note` — invisible on stage — becomes a
highlighted block, which is where half the value of a handout is.

Letterhead data goes to the theme through `letterhead`, ignored in slide mode:

```typst
#show: uniud-theme.with(
  letterhead: (
    acronym: [DPIA],
    department: [Dipartimento Politecnico di\ ingegneria e architettura],
    site: [uniud.it],
    address: ([via delle Scienze 206], [33100 Udine, Italia]),
    institution-line: [Università degli Studi di Udine],
  ),
)
```

The department mark is not an artwork file: it is the seal plus the acronym set
in type, the way the official model and the `uniudletter` LaTeX package build
it. The manual asks for Gotham; the default is Work Sans, which the manual
itself prescribes as the office substitute, and which raises no missing-font
warning. With Gotham installed, pass `display-font: ("Gotham", "Work Sans")`.

Sheet geometry lives in `uniud-paper()` and the type scale in
`uniud-paper-type()`, the document counterparts of `uniud-layout()` and
`uniud-type()`.

## Slides without progressive reveal

`incremental: false` turns the steps off: one page per slide, everything shown.

```typst
#show: uniud-theme.with(incremental: false, ...)
```

It can also be switched off from the command line, leaving the document alone:

```
typst compile --input uniud-incremental=false --font-path fonts lecture.typ
```

It is more than `handout: true`, which flattens the subslides but keeps the
last step as it was — the final item of a focus list in the foreground and the
rest pushed back, the last code highlight still on. With `incremental: false`
those decay too: `focus-list` becomes a plain list, `code-box(steps: ...)` shows
the code with no highlighting, `dim-at` dims nothing. `alert-at`, `mark-at` and
`strike-at` stay: they are emphasis, not steps.

## Slide numbers

Off by default. `slide-numbering` puts the number bottom right, in the style of
the recurring items.

```typst
#show: uniud-theme.with(slide-numbering: "1")     // 12
#show: uniud-theme.with(slide-numbering: "1/1")   // 12/48
#show: uniud-theme.with(slide-numbering: (n, tot) => [#n of #tot])
```

A string is a `numbering` pattern: with two counting symbols it gets the number
and the total, otherwise just the number; a function always gets both.

It counts logical slides, so every subslide of one slide carries the same
number. The cover, section slides, `focus-slide` and `quote-slide` neither show
it nor consume one, so the sequence runs unbroken over the content slides and
the total is how many of those there are. Style `"02"` puts it in the bottom
margin the band leaves free, style `"01"` on the row of the recurring items;
`uniud-layout(slide-number-top: ...)` moves it.

## Overflow

Every slide body is measured before it is laid out. When it does not fit the
text area the theme shrinks it just enough — never below `overflow-min` — and
says so twice: a compiler warning naming the page and the factor, and a red
badge on the slide itself.

```
warning: [uniud-touying] contenuto in overflow a pagina 12, ridotto all'82%
```

```typst
#show: uniud-theme.with(
  overflow: "shrink",      // "shrink" (default), "mark", "error", "ignore"
  overflow-min: 70%,       // how far down the shrink may go
  overflow-marker: true,   // the red badge
  overflow-warn: true,     // the compiler warning
)

#content-slide(title: [Dense], overflow: "ignore")[...]
#text-slide(scale: 85%)[...]        // fixed manual shrink, no measuring

#show: overflow-mode("ignore")      // for `== Heading` slides, like wide-mode
#show: overflow-mode(marker: false) // shrink quietly
#show: overflow-mode(auto)          // back to the theme settings
```

When even `overflow-min` is not enough the theme shrinks nothing and only
warns: a scaled block cannot break, so shrinking would drop the excess text
instead of carrying it over. A flagged extra slide beats a lost paragraph.

Shipping a deck usually means `overflow-marker: false` with the warning left
on: the PDF stays clean, the crowded slides still show up in the build log.

## Captions

Captions sit under the image, in the same style as `#figure` captions, and
their height is taken out of the box so the picture shrinks instead of the
block growing.

```typst
#media-box(caption: [Pipeline overview.])[#image("pipeline.svg")]
```

The caption archetypes follow the same rule: the text goes under the picture
rather than in the side column of the PowerPoint master. `caption-at: "side"`
restores the corporate geometry, per slide or deck-wide.

```typst
#caption-media-slide(caption-at: "side")[Text][#media-box[]]
#show: uniud-theme.with(caption-at: "side", ...)
```

## Aspect ratios

```typst
#show: uniud-theme.with(aspect-ratio: "16-9",  ...)
#show: uniud-theme.with(aspect-ratio: "16-10", ...)
#show: uniud-theme.with(aspect-ratio: "4-3",   ...)
```

16:9 is the canonical reference. The grid is expressed in percentages and
`base-size` is derived from the page height, so both the layout and the
corporate type proportions hold at any ratio; only the measure changes, and a
4:3 slide fits fewer words per line.

## Customization

```typst
#show: uniud-theme.with(
  aspect-ratio: "16-10",
  style: "bottom",             // corporate master, "01"/"bottom" or "02"/"top"
  base-size: 20pt,             // overrides the height-derived default
  cap-height: 0.66,            // cap height of the chosen font
  primary: uniud-blue-ppt,     // match the PowerPoint master
  section-variant: "white",    // or "cycle", "blue", "black", "gray"
  section-numbering: false,    // hide the big section number
  layout: uniud-layout(
    style: "bottom",           // must match, it selects the geometry defaults
    content-column: 4,         // start titles and text one column earlier
    title-gap: 5.0,            // gap between title and subtitle, % of height
    logo-align: right,         // the manual puts the logo top right
    meta-blocks: ((1, 3), (5, 3), (9, 4)),  // grid slots of the recurring items
  ),
)
```

`uniud-layout()` exposes the whole grid (margins, gutter, number of columns,
band height, anchor, logo widths, media positions); `uniud-type()` exposes the
whole type scale.

## Section slides

Automatic level-1 section slides use a dedicated counter, so content slides
never disturb the numbering. The big number is flush right against the title
column, which keeps two-digit numbers clear of the title (the manual specifies
a left-aligned number, which only works up to 9).

**Global policy.** The colours of the section slides are chosen once, for the
whole deck:

```typst
// cycle through the four corporate backgrounds (default)
#show: uniud-theme.with(section-variant: "cycle", ...)

// or a shorter cycle
#show: uniud-theme.with(section-variant: "cycle", section-variants: ("blue", "white"), ...)

// or one fixed colour for every section
#show: uniud-theme.with(section-variant: "white", ...)

// or an arbitrary rule: the function receives the section number
#show: uniud-theme.with(section-variant: n => if calc.odd(n) { "blue" } else { "gray" }, ...)
```

**Per-section override.** A single section can opt out of the global policy
with `#next-section(...)`, placed immediately before its heading. Anything left
out falls back to the global setting, and the cycle is *not* shifted, so the
sections that follow keep the colours they would have had anyway:

```typst
= Prima sezione        // global policy: blue

#next-section(variant: "white")
= Seconda sezione      // white instead of the black the cycle would pick

= Terza sezione        // global policy again: gray, not black

#next-section(variant: "black", show-number: false)
= Conclusioni          // black background, no section number
```

**Manual section slides.** Outside the heading flow, `#section-slide()` takes
the number and the appearance directly:

```typst
#section-slide(
  number: 7,
  variant: "black",
  show-number: true,
  title: [A custom section],
  subtitle: [Optional subtitle],
)
```

`examples/sections.typ` exercises all three levels at once.

## Corporate layout helpers

| function                                             | corporate layout                     |
| ---------------------------------------------------- | ------------------------------------ |
| `#title-slide(variant: "blue" \| "white")`            | copertina                            |
| `#text-slide[...]`                                    | slide di solo testo                  |
| `#text-two-media-slide[...][...][...]`                | testo + due immagini                 |
| `#caption-media-slide[...][...]`                      | testo laterale + immagine grande     |
| `#caption-grid-slide[...][...][...][...][...]`        | testo laterale + griglia 2x2         |
| `#mosaic-slide(...)`                                  | mosaico di immagini                  |
| `#full-media-slide[...]`                              | immagine a tutto schermo             |
| `#section-slide(...)`                                 | slide di sezione                     |
| `#focus-slide[...]`                                   | slide di enfasi (non corporate)      |
| `#media-box[...]`                                     | segnaposto immagine                  |

`text-slide` uses the corporate 85/88 size; pass `role: "body"` for the 54/60
size when the slide carries more text than the corporate archetype expects.
`full-media-slide(chrome: false, logo: "blue")` drops the recurring items and
keeps only the logo, as the manual prescribes for full-screen images; style
`"01"` does that by default.

## Teaching helpers

The corporate masters only cover institutional presentations, so the theme adds
the shapes a lecture needs. They are built out of the same design system — the
3 pt rule above a text block, the corporate palette, the corporate type scale —
so a lecture still looks like a UniUD deck.

Most of them are **elements**: they go inside an ordinary slide, under a
`== Heading`, so slide titles keep working the usual way.

| element | what it is |
| ------------------------------------------- | ----------------------------------- |
| `#callout(title: [Teorema])[...]`            | titled block: definitions, theorems, examples, warnings |
| `#side-by-side[...][...]`                    | two or more blocks abreast, on the column gutter |
| `#code-box(caption:, numbered:, highlight:)` | code frame with line numbers and emphasised lines |
| `#focus-list[...]`                           | list walked one item at a time, the current one in full ink |
| `#alert-at("2")[...]`                        | emphasise a fragment on those steps only |
| `#output-box(caption:)[...]`                 | the same frame in negative, for a result or a terminal |
| `#uniud-table(columns: .., ..)`              | table with no vertical rules and a blue header rule |
| `#media-box[...]`                            | image placeholder |

`code-box` is filled with a light grey by default; `fill: none, stroke: .06em +
uniud-gray` gives the outlined variant on white, and any other `fill`/`ink` pair
works — `output-box` is just the inverted one.

````typst
== Stabilità

#side-by-side[
  #callout(title: [Definizione])[
    Un algoritmo di ordinamento è _stabile_ se preserva l'ordine relativo
    di elementi con chiave uguale.
  ]
][
  #callout(title: [Attenzione], accent: uniud-black)[
    Quicksort in place non è stabile.
  ]
]

== Implementazione

#code-box(caption: [merge_sort.py], numbered: true, highlight: (6,))[
```python
def merge_sort(a):
    ...
```
]
````

Text that has to *flow* from one column into the next is Typst's own
`#columns(2)[...]`; `side-by-side` is for independent blocks.

Four more are whole slides, called explicitly:

| slide | what it is |
| ----------------------------------- | ------------------------------------------- |
| `#outline-slide(title: [Indice])`   | agenda listing the level-1 sections, numbered like the section slides |
| `#quote-slide(attribution: ..)[..]` | quotation, in white or blue |
| `#references-slide(title: .., "refs.bib", style: "ieee")` | bibliography; extra arguments go straight to Typst's `bibliography`, `cols: 2` splits a long list |
| `#wide-slide(title: ..)[..]`        | content area from the first to the last column, for code, tables and wide diagrams |

These four take their own `title`, because they are called explicitly rather
than produced by a `== Heading`. The agenda and the bibliography sit where the
rest of the text sits — the corporate measure, or the whole width in a `wide`
deck; `column` and `span` override that per slide.

**Whole deck wide.** For a lecture where the corporate measure on columns 5-12
is too narrow, `wide: true` moves the body to the first column:

```typst
#show: uniud-theme.with(wide: true, ...)
```

It applies to every text slide — `== Heading` slides, `text-slide`,
`outline-slide`, `references-slide`, `quote-slide` — so the deck stays
internally consistent. Covers, section slides and the corporate image layouts
keep their placement either way.

**Single slides, either way.** Slides called explicitly take a `wide:` argument
that overrides the deck for that slide alone, in both directions:

```typst
#content-slide(title: [Codice], wide: true)[...]   // wide in a narrow deck
#content-slide(title: [Citazione], wide: false)[...]  // narrow in a wide deck
#outline-slide(title: [Indice], wide: true)
```

`wide-slide(title: ..)[..]` is simply `content-slide(wide: true)`.

Slides that Touying builds from a `== Heading` take no arguments, so there the
switch is a show rule that applies from that point on:

```typst
#show: wide-mode(true)
== Una slide larga
#show: wide-mode(false)
== Di nuovo nella misura corporate
```

Code is highlighted with a syntax theme restricted to the corporate palette
(`assets/uniud-code.tmTheme`): blue for keywords, types and literals, 70 % black
for strings, grey italic for comments. The monospaced family is `code-font`,
which defaults to a face bundled with Typst, so it always resolves.

Citations are corporate blue and equations use `math-font`. Touying's own
machinery keeps working: `#pause` for progressive reveals,
`#alert[...]` for corporate-blue emphasis, `#figure(..., caption: ...)` with
captions styled and unnumbered (`set figure(numbering: "1")` restores numbers).

## Progressive reveal

`#pause` reveals. These change something already on the slide, for the steps
given (`2`, `(1, 3)`, `"2-4"`, `"3-"`, Touying's own syntax) and then let it go
back to normal: `#alert-at` colours a fragment corporate blue, `#mark-at` runs a
highlighter over it, `#strike-at` strikes it through, `#dim-at` pushes it into
the background.

`#focus-list` walks a list one item at a time with everything still on the
slide: the current item keeps its ink, the others recede, so the shape and the
length of the list are visible from the first step and the page never reflows.
`mode: "cumulative"` keeps what has already been walked through in the
foreground as well, `alpha` sets how much ink the backgrounded items keep, and
`weight` the weight of the current one.

The receding is a veil of the page colour laid over the content, not a change of
text colour, so bold lead-ins, blue keywords and code frames fade at the same
rate as plain text, and a black and white print comes out grey. `blur: true`
defocuses instead — Typst has no blur filter, so it is approximated by drawing
the content sixteen times, each copy offset by a fraction of an em with nothing
sharp underneath. It reads as out of focus, but the text really is in the PDF
sixteen times, so selection, copy-paste and search see every copy: it is opt-in
for that reason.

`code-box` takes `steps:`, the equivalent of reveal.js's
`data-line-numbers="1|2-3|4"` — a list of line groups, one per step, where each
group is a number, an array, `"2-4"`, `"5-"` or `"1, 4-6"`:

```typst
#code-box(caption: [merge_sort.py], numbered: true, steps: (none, "1", "2-3", "4-5"))[...]
```

`handout: true` on the theme (or `--input handout=true`, the way the examples
read it) flattens every slide to its last step: one page per slide, for the PDF
that gets handed out. `#speaker-note[...]` adds a presenter note; the notes come
out of the document with

```sh
typst query --root . --field value lezione.typ "<pdfpc-file>" --one > lezione.pdfpc
```

for a reader that shows them, pdfpc being the usual one.

## Examples

`examples/` holds the decks the theme is developed against — they are the visual
test suite, and every change is checked by rendering them. The repository keeps
only the sources: the rendered PDFs live at
**[iolab-uniud.github.io/uniud-typst-touying](https://iolab-uniud.github.io/uniud-typst-touying/)**,
where they open in the browser next to the guide and this reference, and are
attached to every
[release](https://github.com/iolab-uniud/uniud-typst-touying/releases).

- `examples/corporate.typ` — one slide per corporate archetype, plus the
  multiline and two-digit-number stress cases. The same suite renders in either
  master and at any aspect ratio.
- `examples/sections.typ` — automatic section numbering and the colour cycle.
- `examples/lecture.typ` — a lecture using the teaching helpers: agenda, columns,
  callouts, code and output, equations, table, figure, quotation, bibliography,
  progressive reveal. `--input wide=true` renders it in the wide variant.

They import the theme as `../uniud-theme.typ`, so Typst needs the repository as
its root. From the repository root:

```sh
typst compile --root . --font-path fonts examples/corporate.typ
typst compile --root . --font-path fonts --input style=01 examples/corporate.typ corporate-01.pdf
typst compile --root . --font-path fonts --input ratio=4-3 examples/corporate.typ corporate-4-3.pdf
typst compile --root . --font-path fonts --input wide=true examples/lecture.typ lecture-wide.pdf
```

`./scripts/build-release.sh` renders all eight variants into `dist/` in one go.

## Licences and marks

| what | licence |
| --- | --- |
| theme, examples, documentation | CC BY 4.0 (`LICENSE`) |
| `template/` | MIT-0 (`template/LICENSE`) |
| `assets/` — UniUD seal and wordmark | property of the Università degli Studi di Udine, not covered by the above |
| `fonts/` — Work Sans, Fira Math | SIL Open Font License 1.1 |

The template directory is MIT-0 on purpose: a lecture written on top of the
starter file is the author's own, with no attribution or licence-notice
obligation attached to it. Everything else asks for attribution.

The marks are a separate matter from the code licence. The seal, the wordmark
and the visual identity are property of the Università degli Studi di Udine,
whose *Manuale di identità visiva* (§ 0.1) reserves their use to the University
and to its administrative, teaching and research structures. Anyone reusing this
theme outside UniUD has to replace the artwork in `assets/`.

## Releasing

`typst.toml` is the single source of truth for the version. `./scripts/release.sh`
takes it from there:

```sh
./scripts/release.sh patch     # or minor, major, or an explicit X.Y.Z
```

It refuses to run on a dirty tree or on a tag that already exists, rewrites the
version in `typst.toml`, in the README and in `template/main.typ`, and checks that
no occurrence of the old one is left behind. Then it writes the `CHANGELOG.md`
entry: the commits since the last tag go to a command-line LLM — `claude -p`, or
whatever `RELEASE_CHANGELOG_CMD` names — and the draft opens in `$EDITOR` for
review, the way a commit message does; lines starting with `#` are dropped, and an
empty file cancels the release. `--no-llm` skips the draft (the raw commit list is
used instead), `--no-edit` skips the editor, `--yes` skips both. Finally it runs
the full build as a check — a broken layout stops the release right there — then
shows the diff and asks before committing, tagging `vX.Y.Z` and pushing.

No PDF is committed: the rendered examples are build output, and the copies that
count are the ones CI rebuilds from the tag, so they always match the tagged
source. `dist/` is ignored, and so is every `.pdf`. Each release attaches them as
assets and also publishes them to GitHub Pages, replacing the site, so
[the examples page](https://iolab-uniud.github.io/uniud-typst-touying/) always
shows the current version.

`release.yml` is the only workflow and it runs on `vX.Y.Z` tags only — nothing is
built on an ordinary push. It compiles the examples with Typst 0.13.1 first, the
minimum `typst.toml` declares, then builds and publishes the release with 0.15.1:
example PDFs, both zips, thumbnail — then builds the site with
`scripts/build-site.py` (index, guide, technical reference, PDFs) and deploys it
to Pages. That script declares its own dependencies inline (PEP 723), so `uv run
scripts/build-site.py` — or just `./scripts/build-site.py` — prepares the
environment on the fly and installs nothing system-wide.
`workflow_dispatch` runs the same build by hand without publishing anything,
which is the way to check CI without cutting a release. Pages has to be enabled
once in the repository settings, with **Source: GitHub Actions**.

## Publishing to Typst Universe

Not done yet. The manifest is already shaped for it — `[template]` section,
`categories`, a `thumbnail.png` built at 250 ppi by `scripts/build-release.sh` —
and CC BY is one of the licences Universe accepts. What is left is the
submission itself: fork [typst/packages](https://github.com/typst/packages), copy
the package into `packages/preview/uniud-touying/<version>/`, change the import
in `template/main.typ` from `@local` to `@preview`, and open a pull request.

Two things to sort out first. Universe packages cannot carry fonts — Typst does
not load fonts from a package — so a Universe user would depend on Work Sans and
Fira Math being available in their environment. And the UniUD marks in `assets/`
need the copyright holder's policy to clear their distribution, which Universe
asks authors to state explicitly in the README.
