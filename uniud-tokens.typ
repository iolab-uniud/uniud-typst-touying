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

// -----------------------------------------------------------------------------
// Adattamento in larghezza
// -----------------------------------------------------------------------------

/// Riduce `body` quando, alla sua larghezza naturale, non entra nella regione
/// che lo ospita. Serve per i blocchi rigidi — diagrammi, tabelle, immagini,
/// codice — che Typst non manda a capo e che quindi escono dai margini invece
/// di adattarsi. Il controllo di overflow del tema misura solo l'altezza: la
/// slide "piena" la vede, la figura troppo larga no.
///
/// - limit: larghezza di riferimento per il pre-filtro, lunghezza o frazione
///   della pagina. Serve solo a non misurare ogni scatola in linea del
///   documento: la decisione vera la prende `layout`, sulla larghezza
///   effettiva della regione.
#let uniud-fit-width(body, limit: none) = context {
  let limit = if limit == none {
    page.width
  } else if type(limit) == ratio {
    limit * page.width
  } else { limit }
  let natural = measure(body)
  // Il pre-filtro resta fuori da `layout`: una `context` non spezza la riga,
  // `layout` si', e passarci ogni `box` in linea riscriverebbe i paragrafi.
  if natural.width <= limit + 0.25pt {
    body
  } else {
    layout(size => {
      let fitted = measure(width: size.width, body)
      // Se restringendo la regione il contenuto si allunga, va a capo da solo:
      // non c'e' niente da scalare, sta gia' facendo la cosa giusta.
      if (
        natural.width <= size.width + 0.25pt
          or fitted.height > natural.height + 0.25pt
          or natural.width == 0pt
      ) {
        body
      } else {
        let factor = size.width / natural.width
        std.scale(
          x: factor * 100%,
          y: factor * 100%,
          origin: top + left,
          reflow: true,
          body,
        )
      }
    })
  }
}

// -----------------------------------------------------------------------------
// Lingua
// -----------------------------------------------------------------------------
//
// Le poche diciture che il tema compone da se' — la numerazione della dispensa,
// il segnaposto delle attivita' interattive — seguono la lingua del documento.
// Senza `lang:` esplicito si segue `text.lang`, cioe' quello che il documento
// ha gia' impostato (l'inglese, se non lo cambia nessuno): il tema non deve
// imporre l'italiano a un mazzo scritto in inglese.

/// Diciture del tema, per lingua. Il tema le unisce a quelle passate da chi
/// scrive, quindi `strings: (en: (page-of: "of"))` ne cambia una sola.
#let uniud-strings = (
  it: (
    page-of: "di",
    interactive: [Attività interattiva — svolta in aula],
    wooclap-title: [Vota su Wooclap],
    wooclap-or-code: [o codice],
    wooclap-interactive: [Domanda Wooclap — si risponde in aula],
  ),
  en: (
    page-of: "of",
    interactive: [Interactive activity — run live in class],
    wooclap-title: [Vote on Wooclap],
    wooclap-or-code: [or code],
    wooclap-interactive: [Wooclap question — answered live in class],
  ),
)

#let _strings-state = state("uniud-strings", (:))
#let _lang-state = state("uniud-lang", auto)

/// Registra lingua e diciture del documento. La chiamano i due temi.
#let uniud-set-strings(lang: auto, strings: (:)) = {
  _lang-state.update(lang)
  _strings-state.update(strings)
}

/// La dicitura `key` nella lingua del documento, con ripiego sull'inglese per
/// le lingue che il tema non conosce.
#let uniud-str(key) = context {
  let lang = _lang-state.final()
  let lang = if lang == auto { text.lang } else { lang }
  let custom = _strings-state.final()
  let table = (
    uniud-strings.at("en")
      + uniud-strings.at(lang, default: (:))
      + custom.at("all", default: (:))
      + custom.at(lang, default: (:))
  )
  table.at(key, default: [])
}

// -----------------------------------------------------------------------------
// Wooclap
// -----------------------------------------------------------------------------

/// Il codice dell'evento Wooclap del corso, dichiarato una volta nel tema:
/// `#wooclap()` sulle slide non deve ripeterlo.
#let _wooclap-code = state("uniud-wooclap-code", none)

#let uniud-set-wooclap(code) = _wooclap-code.update(code)

/// L'indirizzo di partecipazione a un evento Wooclap.
#let wooclap-url(code) = "https://app.wooclap.com/" + code
