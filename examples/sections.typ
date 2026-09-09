// Smoke test for automatic section numbering, the colour cycle and the
// per-section overrides.
//
// The text right after a `=` heading becomes the section subtitle; ordinary
// content lives under a `==` heading.

#import "@preview/touying:0.7.4": *
#import "../uniud-theme.typ": *

#show: uniud-theme.with(
  aspect-ratio: "16-9",
  font: "Work Sans",
  // Global policy: cycle through blue, black, gray, white.
  section-variant: "cycle",
  config-info(
    title: [Automatic section numbering smoke test],
    author: [Prof. Mario Rossi],
    date: [Udine, 22 settembre 2023],
    institution: [Università degli Studi di Udine],
  ),
)

#title-slide()

// 1. Follows the global cycle: blue.
= Prima sezione

Lorem ipsum dolor sit amet, consectetur adipiscing elit.

== Contenuto della prima sezione

Le slide di contenuto non devono alterare la numerazione delle sezioni.

// 2. Overridden: white instead of the black the cycle would pick.
#next-section(variant: "white")
= Seconda sezione

Sed posuere consectetur est at lobortis.

// 3-4. Back to the cycle, which is not shifted by the override: gray, white.
= Terza sezione

Donec ullamcorper nulla non metus auctor fringilla.

= Quarta sezione

Maecenas sed diam eget risus varius blandit sit amet non magna.

// 5. Overridden colour and numbering.
#next-section(variant: "black", show-number: false)
= Quinta sezione

Sezione senza numero, su fondo nero.
