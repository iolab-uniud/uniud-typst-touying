// =============================================================================
// UniUD design tokens
// =============================================================================
//
// Colori, loghi e temi di colorazione del codice: tutto cio' che l'identita'
// visiva fissa una volta e che vale per qualunque supporto. Le slide
// (`uniud-theme.typ`) e la dispensa A4 (`uniud-handout.typ`) partono da qui,
// cosi' i due formati non possono divergere.
//
// Riferimenti: "Manuale di identita' visiva UniUD", p. 037 (palette di stampa)
// e p. 148 (palette web).

// -----------------------------------------------------------------------------
// Palette corporate
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

// -----------------------------------------------------------------------------
// Artwork
// -----------------------------------------------------------------------------

#let _full-logo-blue = "assets/uniud-full-blue.svg"
#let _full-logo-white = "assets/uniud-full-white.svg"
#let _compact-logo-blue = "assets/uniud-compact-blue.png"
#let _compact-logo-white = "assets/uniud-compact-white.png"

// Il solo sigillo, ritagliato dal logotipo esteso. Serve al marchio di
// dipartimento della carta intestata, che il manuale compone come sigillo piu'
// acronimo invece che come artwork a se' stante.
#let _seal-blue = "assets/uniud-sigillo-blu.svg"
#let _seal-white = "assets/uniud-sigillo-bianco.svg"

// Carattere dei marchi composti tipograficamente (acronimo di dipartimento,
// wordmark del 'segue foglio'). Il manuale vuole Gotham, ma prescrive esso
// stesso Work Sans come sostituto d'ufficio (p. 045); chi ha Gotham installato
// passa `display-font: ("Gotham", "Work Sans")` al tema. Elencare qui Gotham
// per default farebbe emettere a Typst un avviso di font mancante a chiunque.
#let uniud-display-font = ("Work Sans",)

// Peso dei marchi composti. Il manuale vuole Gotham Bold sia per l'acronimo di
// dipartimento sia per il wordmark contratto UNI/UD; con Work Sans al posto di
// Gotham il peso corrispondente e' il SemiBold (manuale p. 045, dove Circular
// Bold diventa Work Sans SemiBold). Con Gotham installato si passa
// `display-font: ("Gotham", "Work Sans")` e `display-weight: "bold"`.
#let uniud-display-weight = "semibold"

// Syntax highlighting restricted to the corporate palette: blue for keywords,
// types and literals, 70 % black for strings, grey italic for comments.
#let _code-theme = "assets/uniud-code.tmTheme"
