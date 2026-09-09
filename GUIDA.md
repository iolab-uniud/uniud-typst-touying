# Guida all'uso del tema UniUD per Typst

Guida operativa: come si scrive una presentazione con questo tema. Per le
misure corporate, gli scostamenti dal manuale d'Ateneo e le scelte di design
c'è il [README](README.md).

- [1. Preparazione](#1-preparazione)
- [2. Struttura di una presentazione](#2-struttura-di-una-presentazione)
- [3. Le due varianti corporate](#3-le-due-varianti-corporate)
- [4. Formato della slide](#4-formato-della-slide)
- [5. Sezioni, numerazione e colori](#5-sezioni-numerazione-e-colori)
- [6. Larghezza del testo](#6-larghezza-del-testo)
- [7. I layout del PowerPoint corporate](#7-i-layout-del-powerpoint-corporate)
- [8. Elementi per le lezioni](#8-elementi-per-le-lezioni)
- [9. Formule, citazioni, bibliografia](#9-formule-citazioni-bibliografia)
- [10. Rivelazione progressiva ed enfasi](#10-rivelazione-progressiva-ed-enfasi)
- [11. Personalizzazione](#11-personalizzazione)
- [12. Riferimento delle funzioni](#12-riferimento-delle-funzioni)
- [13. Problemi frequenti](#13-problemi-frequenti)

---

## 1. Preparazione

Servono Typst 0.13 o successivo e due font:

- **Work Sans** — è il carattere corporate (il manuale lo indica come
  sostituto di Gotham e LL Circular). Va installato: si scarica da Google
  Fonts.
- **Fira Math** — per le formule. È già nella cartella `fonts/` del progetto:
  o lo installi con doppio clic, oppure compili passando la cartella.

```
typst compile --font-path fonts lezione.typ
typst watch   --font-path fonts lezione.typ      # anteprima continua
```

Se usi Tinymist in VS Code, aggiungi la cartella a `tinymist.fontPaths` e ti
dimentichi dell'opzione. Touying viene scaricato da Typst al primo utilizzo.

Il file più corto che compila:

```typst
#import "@preview/touying:0.7.4": *
#import "uniud-theme.typ": *

#show: uniud-theme.with(
  config-info(
    title: [Titolo della lezione],
    subtitle: [Eventuale sottotitolo],
    author: [Prof. Mario Rossi],
    date: [Udine, 22 settembre 2023],
    institution: [Dipartimento Politecnico di Ingegneria e Architettura],
  ),
)

#title-slide()

== Prima slide

Buongiorno.
```

I quattro campi di `config-info` alimentano la copertina e gli **elementi
ricorrenti** (luogo e data, docente, dipartimento) che compaiono su ogni slide.
Se lasci fuori `institution`, quel blocco semplicemente non viene disegnato.

---

## 2. Struttura di una presentazione

Il corpo del documento è markup Typst normale. Le intestazioni scandiscono la
presentazione:

```typst
#title-slide()                    // copertina

#outline-slide(title: [Indice])   // indice, generato dalle sezioni

= Prima sezione                   // slide di sezione, con il numerone

Questa riga diventa il sottotitolo della slide di sezione.

== Una slide                      // slide di contenuto, con titolo

Testo della slide.

== Un'altra slide

Altro testo.
```

Due cose da tenere a mente:

- il testo che segue subito una `=` **diventa il sottotitolo della slide di
  sezione**, non una slide a sé. È il comportamento di Touying
  (`receive-body-for-new-section-slide-fn`). Il contenuto vero va sotto una
  `==`;
- ogni `==` apre una slide nuova. Non serve chiuderla.

`#outline-slide()` interroga il documento e numera le sezioni con la stessa
numerazione delle slide di sezione, quindi puoi metterlo in cima anche se le
sezioni sono definite più avanti.

---

## 3. Le due varianti corporate

L'Ateneo ha due master PowerPoint. Si scelgono con `style`, che accetta sia il
numero corporate sia la posizione degli elementi ricorrenti:

```typst
#show: uniud-theme.with(style: "02", ...)   // oppure "top"  — default
#show: uniud-theme.with(style: "01", ...)   // oppure "bottom"
```

| | `"01"` / `"bottom"` | `"02"` / `"top"` |
| --- | --- | --- |
| ricorrenti | in basso, lungo tutta la slide | in alto, dentro una fascia blu |
| fascia blu | assente | 7 cm |
| testi | ancorati più in alto (7 cm) | ancorati a 9,5 cm, sotto la fascia |
| immagini | partono dal margine superiore | partono dall'ancoraggio del testo |
| immagine a tutto schermo | ricorrenti eliminati, resta il logo | fascia mantenuta |

Cambia solo questo: griglia, tipografia, colori, loghi, slide di sezione e
tutti i layout sono gli stessi, quindi convertire un deck da un master
all'altro è una parola sola.

---

## 4. Formato della slide

```typst
#show: uniud-theme.with(aspect-ratio: "16-9",  ...)   // default
#show: uniud-theme.with(aspect-ratio: "16-10", ...)
#show: uniud-theme.with(aspect-ratio: "4-3",   ...)
```

La griglia è espressa in percentuali e il corpo del testo è derivato
dall'altezza della pagina, quindi le proporzioni corporate restano identiche a
ogni formato: cambia solo la giustezza, e una 4:3 sta su meno parole per riga.

Per ingrandire o rimpicciolire *tutto* il sistema tipografico in blocco:

```typst
#show: uniud-theme.with(base-size: 20pt, ...)
```

---

## 5. Sezioni, numerazione e colori

### Cromatismo globale

Le slide di sezione hanno quattro fondi istituzionali: blu, nero, grigio,
bianco. La politica si decide una volta per tutto il deck:

```typst
// ciclo sui quattro fondi (default)
#show: uniud-theme.with(section-variant: "cycle", ...)

// ciclo più corto
#show: uniud-theme.with(section-variant: "cycle", section-variants: ("blue", "white"), ...)

// un colore fisso per tutte
#show: uniud-theme.with(section-variant: "white", ...)

// una regola qualsiasi: la funzione riceve il numero di sezione
#show: uniud-theme.with(section-variant: n => if calc.odd(n) { "blue" } else { "gray" }, ...)
```

### Eccezioni per una singola sezione

`#next-section(...)` si mette subito prima dell'intestazione a cui si
riferisce. Quello che non specifichi resta come da impostazione globale, e il
ciclo **non si sfasa**: le sezioni successive mantengono il colore che
avrebbero avuto comunque.

```typst
= Prima sezione            // dal ciclo: blu

#next-section(variant: "white")
= Seconda sezione          // bianca invece che nera

= Terza sezione            // di nuovo dal ciclo: grigia

#next-section(variant: "black", show-number: false)
= Conclusioni              // nera e senza numero
```

### Slide di sezione fuori dal flusso

Se ti serve una slide di sezione dove vuoi, con numero e colore decisi a mano:

```typst
#section-slide(
  number: 7,
  variant: "black",
  show-number: true,
  title: [Una sezione a parte],
  subtitle: [Sottotitolo facoltativo],
)
```

Per togliere il numerone da tutte le sezioni: `section-numbering: false` nel
tema.

---

## 6. Larghezza del testo

Nei master corporate il testo occupa solo le colonne 5–12, cioè i due terzi di
destra. Per una lezione può essere stretto, quindi la giustezza si può
allargare a tutta la slide.

**Per tutto il deck**:

```typst
#show: uniud-theme.with(wide: true, ...)
```

Vale per tutte le slide di testo: quelle da `== Titolo`, `text-slide`,
`outline-slide`, `references-slide`, `quote-slide`. Copertine, slide di sezione
e layout con le immagini restano dove li mette il corporate.

**Per una singola slide chiamata esplicitamente**, l'argomento `wide:` vince
sul default, in tutte e due le direzioni:

```typst
#content-slide(title: [Codice], wide: true)[...]       // larga in un deck stretto
#content-slide(title: [Citazione], wide: false)[...]   // stretta in un deck largo
#outline-slide(title: [Indice], wide: true)
```

`#wide-slide(title: ..)[..]` è la scorciatoia per `content-slide(wide: true)`.

**Per una slide da `== Titolo`** non c'è un argomento — quelle le costruisce
Touying — quindi si usa una regola che cambia la larghezza da lì in avanti, e
la si spegne dopo:

```typst
#show: wide-mode(true)
== Una slide larga
#show: wide-mode(false)
== Di nuovo nella misura corporate
```

---

## 7. I layout del PowerPoint corporate

Riproducono uno per uno gli archetipi del master. Prendono il contenuto come
blocchi posizionali, nell'ordine in cui compaiono sulla slide.

```typst
// copertina, blu o bianca
#title-slide(variant: "blue")
#title-slide(variant: "white", title: [Titolo alternativo], subtitle: [...])

// solo testo, nel corpo grande corporate (85/88)
#text-slide[Testo breve ed efficace.]
#text-slide(role: "body")[Testo più lungo, nel corpo 54/60.]

// testo in alto, due immagini sotto
#text-two-media-slide[Testo][#media-box[]][#media-box[]]

// testo esplicativo a sinistra, immagine grande a destra
#caption-media-slide[Testo o elenco][#media-box[]]

// testo a sinistra, griglia 2×2 a destra
#caption-grid-slide[Testo][#media-box[]][#media-box[]][#media-box[]][#media-box[]]

// mosaico libero di sei immagini sulla griglia di base
#mosaic-slide(media-box[], media-box[], media-box[], media-box[], media-box[], media-box[])

// immagine a tutto schermo
#full-media-slide[#image("foto.jpg", width: 100%, height: 100%, fit: "cover")]
#full-media-slide(chrome: false, logo: "blue")[...]   // senza ricorrenti, logo blu

// slide di enfasi, fondo blu
#focus-slide[Hic sunt futura]
```

`#media-box[...]` è il segnaposto grigio per le immagini: comodo per
impaginare prima di avere le figure definitive. Accetta `width`, `height`,
`fill` e `inset`.

In `full-media-slide`, `chrome: false` toglie gli elementi ricorrenti e lascia
solo il logo — è quello che il manuale prescrive per le immagini a piena
pagina — e `logo:` sceglie `"white"` o `"blue"` a seconda del contrasto con la
foto. Nello stile `"01"` è già il comportamento di default.

---

## 8. Elementi per le lezioni

Non fanno parte dei master corporate, che coprono solo le presentazioni
istituzionali, ma sono costruiti con gli stessi stilemi: il filetto da 3 pt
sopra il blocco di testo, la palette, la scala tipografica.

Quasi tutti sono **elementi**, non slide: si mettono dentro una slide normale,
sotto un `== Titolo`, così i titoli continuano a funzionare come sempre.

### Blocchi con testata

```typst
== Stabilità

#callout(title: [Definizione])[
  Un algoritmo di ordinamento è _stabile_ se preserva l'ordine relativo di
  elementi con chiave uguale.
]

#callout(title: [Attenzione], accent: uniud-black)[
  Quicksort in place non è stabile.
]

#callout(title: [Dimostrazione], accent: uniud-black, fill: uniud-gray.lighten(85%))[
  Segue dall'albero di decisione.
]
```

`accent` colora filetto ed etichetta, `fill` aggiunge un fondo. Con
`title: none` resta il solo filetto.

### Colonne

Due cose diverse, che è bene non confondere:

```typst
// testo che SCORRE da una colonna all'altra: il columns nativo di Typst
#columns(2)[
  Un paragrafo lungo, o un elenco che non entra in una colonna sola.
]

// blocchi INDIPENDENTI affiancati: side-by-side
#side-by-side[
  #callout(title: [Pro])[...]
][
  #callout(title: [Contro])[...]
]

#side-by-side(gutter: 1em, align-items: horizon)[...][...][...]
```

`side-by-side` accetta un numero qualsiasi di blocchi e li distribuisce in
colonne uguali.

### Codice e output

````typst
#code-box(caption: [merge_sort.py], numbered: true, highlight: (5, 6))[
```python
def merge_sort(a):
    if len(a) <= 1:
        return a
    m = len(a) // 2
    left, right = merge_sort(a[:m]), merge_sort(a[m:])
    return merge(left, right)
```
]
````

- `caption` — etichetta sopra il frame, in stile corporate;
- `numbered` — numeri di riga;
- `highlight` — elenco di righe da evidenziare;
- `size` — corpo del testo, relativo al testo circostante (default `.8em`);
- `fill` / `stroke` / `ink` — aspetto del frame.

Il fondo di default è un grigio chiarissimo. Per la variante con bordo su
bianco:

```typst
#code-box(fill: none, stroke: .06em + uniud-gray)[...]
```

`#output-box(caption: [risultato])[...]` è lo stesso frame in negativo — fondo
nero, testo bianco — pensato per stare accanto al codice che lo ha prodotto:

```typst
#wide-slide(title: [Codice e risultato])[
  #side-by-side(gutter: 1em)[
    #code-box(caption: [sessione], numbered: true)[...]
  ][
    #output-box(caption: [output])[...]
  ]
]
```

L'evidenziazione della sintassi usa una palette ridotta ai colori d'Ateneo:
blu per parole chiave, tipi e letterali, grigio scuro per le stringhe, grigio
corsivo per i commenti. Sul frame in negativo non viene applicata, altrimenti
il testo resterebbe nero su nero. Il font monospaziato si cambia con
`code-font` nel tema.

### Tabelle

```typst
#uniud-table(
  columns: (auto, 1fr, 1fr, auto),
  table.header([Algoritmo], [Caso medio], [Caso peggiore], [Stabile]),
  [Merge sort], [$n log n$], [$n log n$], [sì],
  [Quicksort],  [$n log n$], [$n^2$],     [no],
)
```

Niente filetti verticali, filetto blu sotto la testata, righe separate da
capelli grigi. Tutti gli argomenti passano al `table` di Typst, quindi
`table.cell`, `colspan`, `align` e compagnia funzionano come sempre.

### Figure

`#figure` funziona normalmente; il tema ne imposta la didascalia (piccola,
grigio scuro) e toglie la numerazione, che sulle slide raramente serve.

```typst
#figure(
  image("albero.svg", height: 60%),
  caption: [Albero di ricorsione di merge sort.],
)
```

Per rimettere i numeri: `#set figure(numbering: "1")`.

### Slide intere

```typst
#outline-slide(title: [Indice della lezione], cols: 2)
#quote-slide(attribution: [Donald E. Knuth, 1974])[
  L'ottimizzazione prematura è la radice di ogni male.
]
#quote-slide(variant: "blue", attribution: [...])[...]
#content-slide(title: [Titolo], wide: true)[Contenuto qualsiasi.]
```

Queste prendono il `title` come argomento, perché non nascono da una `==`.

---

## 9. Formule, citazioni, bibliografia

Le formule sono quelle di Typst; il tema cambia solo il carattere, per
accordarle a Work Sans:

```typst
Il costo si ricava dalla ricorrenza

$ T(n) = 2 T(n/2) + Theta(n), quad T(1) = Theta(1), $

che vale $T(n) = Theta(n log n)$.
```

Per tornare al matematico graziato incluso in Typst:
`math-font: "New Computer Modern Math"`.

Citazioni e bibliografia:

```typst
Si vedano @clrs e @knuth1974.

#references-slide(title: [Riferimenti], "riferimenti.bib", style: "ieee")
```

Gli argomenti dopo il titolo vanno dritti al `bibliography` di Typst, quindi
vale qualsiasi stile CSL. `cols: 2` divide un elenco lungo su due colonne,
`size:` cambia il corpo. Le citazioni nel testo sono in blu corporate.

---

## 10. Rivelazione progressiva ed enfasi

`#pause` è di Touying e funziona dentro qualsiasi slide di contenuto: spezza la
slide in più passaggi, uno per clic.

```typst
== Il paradigma

Si articola in tre passi.

#pause
- *Divide*: si spezza il problema.
#pause
- *Impera*: si risolvono i sottoproblemi.
#pause
- *Combina*: si ricompongono le soluzioni.
```

`#alert[...]` evidenzia in blu corporate. Restano disponibili tutte le altre
funzioni di Touying (`#meanwhile`, `#only`, `#uncover`, i contatori di
sottoslide): il tema non le tocca.

---

## 11. Personalizzazione

### Parametri del tema

```typst
#show: uniud-theme.with(
  style: "02",                 // master corporate: "01"/"bottom" o "02"/"top"
  aspect-ratio: "16-9",        // "16-9", "16-10", "4-3", o "L-H"
  wide: false,                 // testo a tutta larghezza
  font: "Work Sans",           // none per ereditare il font del documento
  code-font: "DejaVu Sans Mono",
  math-font: "Fira Math",
  base-size: auto,             // auto = 4,074 % dell'altezza pagina
  cap-height: 0.66,            // cap height del font, serve per le interlinee
  primary: uniud-blue,         // uniud-blue-ppt per il blu del PowerPoint
  section-variant: "cycle",
  section-variants: ("blue", "black", "gray", "white"),
  section-numbering: true,
  layout: auto,                // vedi sotto
  type-scale: auto,            // vedi sotto
  config-info(...),
)
```

Se cambi `font`, aggiorna anche `cap-height`: da lì il tema ricava le
interlinee e l'allineamento della prima riga sull'ancoraggio (0.66 è il valore
di Work Sans).

### Colori

Sono esportati come variabili: `uniud-blue` (`#0000ff`), `uniud-blue-ppt`
(`#0433ff`, quello effettivamente usato nel PowerPoint), `uniud-gray`
(`#b3b6b7`, Pantone 877 U), `uniud-gray-web` (`#cdcdce`), `uniud-black`,
`uniud-white`, `uniud-dark-gray` (70 % di nero, per i testi secondari sui fondi
chiari).

### Geometria

`uniud-layout()` espone tutta la griglia. Si passa al tema con `layout:`, e va
costruito con lo stesso `style`:

```typst
#show: uniud-theme.with(
  style: "01",
  layout: uniud-layout(
    style: "01",                            // deve coincidere
    content-column: 4,                      // testi una colonna più a sinistra
    title-gap: 5.0,                         // stacco titolo/sottotitolo, % altezza
    logo-align: right,                      // il manuale lo vuole in alto a destra
    meta-blocks: ((1, 3), (5, 3), (9, 4)),  // posizioni dei ricorrenti (colonna, larghezza)
    meta-top: 88.0,                         // altezza dei ricorrenti, % altezza
  ),
  ...
)
```

Gli altri parametri disponibili: `columns`, `h-margin`, `v-margin`, `gutter`,
`row-gutter`, `band-height`, `anchor`, `content-bottom`, `media-anchor`,
`media-top`, `number-gap`, `number-offset`, `logo-width`, `logo-left`,
`logo-top`, `compact-logo-width`, `compact-logo-left`, `compact-logo-top`.
Tutti in percentuale di larghezza o di altezza della slide.

### Tipografia

`uniud-type()` espone la scala completa; si passa con `type-scale:`. Ogni ruolo
è una dimensione come multiplo di `base-size`, più interlinea, tracking,
spaziatura fra parole e peso:

```typst
#let mia-scala = uniud-type(base: 20pt, cap-height: 0.66)
#show: uniud-theme.with(type-scale: mia-scala, ...)
```

I ruoli sono `title`, `subtitle`, `number`, `body-large`, `body`, `meta`,
`heading`.

---

## 12. Riferimento delle funzioni

### Slide

| funzione | argomenti |
| --- | --- |
| `title-slide` | `variant` `"blue"`/`"white"`, `title`, `subtitle` |
| `section-slide` | `number`, `variant`, `show-number`, `title`, `subtitle` |
| `next-section` | `variant`, `show-number` — prima di una `=` |
| `content-slide` | `title`, `wide` |
| `wide-slide` | `title` — cioè `content-slide(wide: true)` |
| `text-slide` | `role` `"body-large"`/`"body"`, `wide` |
| `text-two-media-slide` | testo, media sinistro, media destro |
| `caption-media-slide` | testo, media |
| `caption-grid-slide` | testo, quattro media |
| `mosaic-slide` | sei media |
| `full-media-slide` | `chrome`, `logo` `"white"`/`"blue"`/`none` |
| `focus-slide` | `background`, `foreground` |
| `outline-slide` | `title`, `cols`, `wide`, `column`, `span` |
| `quote-slide` | `attribution`, `variant`, `wide` |
| `references-slide` | `title`, `cols`, `size`, `wide`, `column`, `span`, + argomenti di `bibliography` |

### Elementi

| funzione | argomenti |
| --- | --- |
| `callout` | `title`, `accent`, `fill` |
| `side-by-side` | `gutter`, `align-items`, + blocchi |
| `code-box` | `caption`, `numbered`, `highlight`, `fill`, `stroke`, `ink`, `size` |
| `output-box` | `caption`, `numbered`, `size` |
| `uniud-table` | argomenti di `table` |
| `media-box` | `width`, `height`, `fill`, `inset` |

### Configurazione

| funzione | a cosa serve |
| --- | --- |
| `uniud-theme` | il tema, con `#show:` |
| `uniud-layout` | griglia e ancoraggi |
| `uniud-type` | scala tipografica |
| `wide-mode` | cambia la larghezza da un punto in poi, con `#show:` |

---

## 13. Problemi frequenti

**«unknown font family: fira math»** — il font matematico non è installato.
Compila con `--font-path fonts`, oppure installa `fonts/FiraMath-Regular.otf`,
oppure passa `math-font: "New Computer Modern Math"`. Non è un errore: le
formule escono comunque, in graziato.

**Il testo che ho scritto dopo `= Sezione` non compare** — è diventato il
sottotitolo della slide di sezione. Spostalo sotto una `==`.

**Il testo sfora la slide** — i corpi corporate sono grandi per scelta (85 pt
sulla slide di solo testo). Usa `text-slide(role: "body")` per il corpo più
piccolo, spezza la slide, o allarga la giustezza con `wide: true`.

**La numerazione delle sezioni parte da zero o salta** — non dovrebbe: il tema
usa un contatore suo, indipendente da quello delle intestazioni, e le slide di
contenuto non lo toccano. Se succede, la causa è quasi sempre una `=` dentro un
blocco che non è al livello del documento.

**Ho cambiato font e le prime righe non sono più allineate** — passa la
`cap-height` del nuovo font: le interlinee e l'ancoraggio si calcolano da lì.

**`wide-mode` sembra agire sulla slide sbagliata** — deve stare *prima*
dell'intestazione a cui si riferisce, e resta attivo fino a quando non lo
cambi. Per una slide sola serve la coppia: `wide-mode(true)` prima,
`wide-mode(false)` dopo.

**Voglio il blu esatto del PowerPoint** — `primary: uniud-blue-ppt`. Il default
è `#0000ff`, che è quello prescritto dal manuale d'identità visiva; il master
PowerPoint usa `#0433ff`.

---

## Demo

Nella cartella ci sono tre file di esempio, che sono anche la suite di test
visivi del tema:

| file | cosa mostra |
| --- | --- |
| `demo.typ` | un esemplare di ogni archetipo del PowerPoint corporate, più i casi limite: titoli multiriga, numeri di sezione a due cifre |
| `demo-auto-sections.typ` | numerazione automatica delle sezioni, ciclo cromatico e override |
| `demo-teaching.typ` | una lezione che usa tutti gli elementi didattici |

```
typst compile --font-path fonts demo-teaching.typ
typst compile --font-path fonts --input style=01 demo.typ demo-01.pdf
typst compile --font-path fonts --input ratio=4-3 demo.typ demo-4-3.pdf
typst compile --font-path fonts --input wide=true demo-teaching.typ demo-wide.pdf
```
