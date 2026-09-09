// Presentazione UniUD — punto di partenza.
//
// Questo file e il resto della cartella `template` sono sotto licenza MIT-0
// (vedi LICENSE qui accanto): la presentazione che ci scrivi sopra è tua, senza
// obblighi di attribuzione.
//
// I font stanno in `fonts/`: compila con
//   typst watch --font-path fonts main.typ
// oppure installali una volta sola nel sistema.

#import "@preview/touying:0.7.4": *
#import "@local/uniud-touying:0.3.1": *

#show: uniud-theme.with(
  style: "02", // "02"/"top" con la fascia blu, "01"/"bottom" con i ricorrenti in basso
  aspect-ratio: "16-9",
  wide: false, // true per usare tutta la larghezza della slide
  config-info(
    title: [Titolo della lezione],
    subtitle: [Eventuale sottotitolo],
    author: [Nome Cognome],
    date: [Udine, 1 gennaio 2026],
    institution: [Dipartimento Politecnico di Ingegneria e Architettura],
  ),
)

#title-slide()

#outline-slide(title: [Indice])

= Prima sezione

Questa riga diventa il sottotitolo della slide di sezione.

== Una slide con elenco

Testo introduttivo.

- Primo punto
- Secondo punto
- Terzo punto

== Una slide con un blocco e del codice

#callout(title: [Definizione])[
  Il testo della definizione.
]

#code-box(caption: [esempio.py], numbered: true)[
```python
def saluta(nome):
    print(f"Buongiorno, {nome}")
```
]

= Conclusioni

== Riepilogo

- Primo punto da ricordare
- Secondo punto da ricordare

#focus-slide[Domande?]
