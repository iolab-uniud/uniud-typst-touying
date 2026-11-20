# Changelog

## 0.6.0 - 2026-11-20

- I callout hanno ora un fondo tenue che li fa risaltare, con filetto ed etichetta come prima: è il nuovo stile predefinito `"panel"`, che non ruba spazio alla slide perché riusa la spaziatura già presente intorno al blocco. Con `style: "header"` l'etichetta va in bianco su una testata piena; lo stile precedente resta disponibile come `"rule"` — per il singolo blocco (`style:`) o per tutta la lezione (`callout-style:` nel tema) — e riproduce le slide di prima identiche. `fill: none` toglie il fondo.
- Nuovi elementi `flow` e `roadmap` per disegnare catene di passi e la mappa del corso, con i mattoni `flow-node`, `flow-arrow` e `flow-arrow-labelled` per le composizioni a mano.
- Nuovo `credited-figure` per inserire un'immagine con la riga di credito alla fonte.
- Nuove etichette nei colori del manuale: `badge` e `slide-tag`, che sulle slide compaiono in alto a destra all'altezza del titolo e nella dispensa seguono il flusso del testo.
- Aggiunti `underline-at`, per sottolineare una porzione di testo, e `uniud-is-handout`, per differenziare il contenuto tra slide e dispensa.
- Nuova opzione per togliere l'indice dalla dispensa A4: `outline: false` nel tema oppure `./scripts/make-handout.sh --no-outline`. Sulle slide l'indice resta.
- `#wooclap()` senza codice usa ora quello della lezione in cui si trova: in una dispensa che concatena più lezioni prendeva per tutte il codice dell'ultima.

## 0.5.0 - 2026-11-19

Le colonne con passi cambiano comportamento, e si vede nei mazzi già scritti: si svolgono una dopo l'altra invece che in parallelo. `parallel: true` ripristina il comportamento precedente.

- Le colonne con passi si svolgono in fila: prima tutta la colonna di sinistra, dall'alto in basso, poi quella di destra. Prima avanzavano in parallelo: due `focus-list` affiancate mettevano a fuoco insieme il primo elemento di entrambe, e con i `#pause` la prima voce della colonna destra compariva insieme all'ultima della sinistra. Vale per `side-by-side` e per le slide a più corpi (`#slide[...][...]`). Le colonne senza passi non cambiano; `parallel: true` ripristina l'avanzamento in parallelo, utile per i confronti voce per voce.
- Il contenuto che sforava di pochissimo (bastava ridurlo meno del 3%) non veniva ridotto né segnalato e Typst ne mandava l'ultima riga — tipicamente una nota in fondo — su una pagina a sé, facendo avanzare anche il numero di slide. La soglia sotto cui la riduzione era considerata rumore saltava anche la riduzione stessa: ora il corpo viene ridotto comunque, in silenzio, e la pagina orfana non compare più.
- Le slide con una spaziatura frazionaria — `#v(1fr)` per spingere una nota in fondo — non risultano più sempre in overflow: la spaziatura si allargava fino a riempire l'area e il controllo mostrava un badge OVERFLOW e l'avviso «non entra nemmeno al 70%» anche quando tutto stava. Durante la misura le spaziature frazionarie vengono azzerate, mentre nel layout reale continuano a occupare lo spazio libero; se il contenuto sfora davvero, la slide viene ridotta come le altre.

## 0.4.0 - 2026-09-22

- Aggiunta una soglia minima di overflow (`marker-threshold`) sotto la quale il badge di avviso non viene mostrato, utile per silenziare gli sforamenti trascurabili.

## 0.3.5 - 2026-09-21

- Corretto `#alert[..]` affinché funzioni anche fuori dalle slide (es. nelle celle di tabella) e negli handout, dove il testo prima spariva
- Risolto un problema nello script di rilascio che poteva generare pacchetti non corretti

## 0.3.4 - 2026-09-13

- Rivisti e corretti gli handout, ora coerenti anche con le slide interattive (gli elementi interattivi non compaiono più negli handout).

## 0.3.3 - 2026-09-11

- Migliorato lo stile dello handout, con layout e formattazione più curati e coerenti con il tema

## 0.3.2 - 2026-09-10

- Il wordmark UNI/UD del «segue foglio» ora usa lo stesso peso Gotham Bold (o Work Sans SemiBold) dell'acronimo di dipartimento, anziché un peso diverso non conforme al manuale
- Aggiunto il parametro `display-weight` al tema handout per impostare esplicitamente il peso dei marchi composti quando si usa Gotham

## Non rilasciato

- Nuovi elementi, raccolti dai preamboli dei corsi che li ridefinivano ciascuno per conto proprio: `credited-figure` (immagine con riga di credito), `flow` e `roadmap` (catene di passi e mappa del corso, con i mattoni `flow-node`, `flow-arrow`, `flow-arrow-labelled` per le composizioni a mano), `badge` e `slide-tag` (etichette nei colori del manuale, in alto a destra all'altezza del titolo e nel flusso nella dispensa), `underline-at` e `uniud-is-handout`.
- `#wooclap()` senza codice usa quello della lezione in cui si trova: in una dispensa che concatena più lezioni prendeva per tutte il codice dell'ultima.
- I callout in stile `"panel"` non costano spazio: il fondo occupa la spaziatura che c'era già intorno al blocco e i margini interni sono stretti. Sulle lezioni di due corsi reali gli overflow restano quelli della 0.5.
- I callout hanno un fondo tenue che li fa risaltare: filetto in testa ed etichetta come prima, più una tinta chiara dell'accento (grigio UNIUD al 30% per gli accenti neri e grigi, un retino al 7% dell'accento per gli altri). È il nuovo stile predefinito, `"panel"`; con `style: "header"` l'etichetta sta in bianco su una testata piena. Lo stile precedente resta disponibile come `"rule"`, per il singolo blocco (`style:`) o per tutta la lezione (`callout-style:` nel tema), e riproduce le slide di prima identiche. `fill: none` toglie il fondo.
- Nuova opzione per togliere l'indice dalla dispensa A4: `outline: false` nel tema, oppure `./scripts/make-handout.sh --no-outline` (`--input uniud-handout-outline=no`). Sparisce tutta la `outline-slide`, titolo compreso; sulle slide l'indice resta.
- Nuovo `overflow-marker-threshold` (e argomento omonimo di `overflow-mode`): soglia minima di overflow, in percentuale, sotto la quale il badge non compare anche con `overflow-marker: true`, cosi' i mazzi non si riempiono di marker per sforamenti di una manciata di punti che nessuno noterebbe. Default `0%`, comportamento invariato: il marker compare per qualunque overflow, come prima.
- Nella dispensa A4 `#alert[..]` non fa più sparire il testo: dentro una cella di tabella (o comunque fuori dal corpo di una slide) il marcatore di Touying non veniva risolto e il contenuto andava perso. Ora `alert` viene rilegato alla versione documento, che lo stampa in blu corporate.
- `#small-note[..]` per la riga sottovoce — piu' piccola e in grigio — che accompagna un'affermazione senza rubarle il posto.
- `#wooclap()` compone il riquadro di partecipazione a un evento Wooclap — indirizzo, codice e QR — nello stile corporate, già marcato `interactive`. Il **QR si genera dal codice** con zebra (curve native di Typst, nessun plugin WASM): niente immagini da rifare a ogni cambio di evento. Il codice si dichiara una volta con `wooclap-code:` nel tema; `arrange` ("below", "side", "qr"), `qr`, `qr-fill`, `note`, `title` e `code` governano il resto. Aggiunge zebra 0.1.0 alle dipendenze del pacchetto.
- `interactive` marca i blocchi che esistono solo dal vivo — un voto in aula, una lavagna condivisa, un QR da inquadrare. Sulle slide non fa niente; nella dispensa A4 lascia al loro posto un segnaposto tratteggiato, perché la domanda e il debrief intorno restino leggibili. Si riaccendono con `interactive: true` nel tema o `make-handout.sh --interactive`.
- Nuova opzione `lang` (con `strings` per le personalizzazioni): le diciture composte dal tema — la numerazione della dispensa, il segnaposto delle attività interattive — seguono la lingua del documento, italiano e inglese inclusi. `lang: auto`, il default, segue `text.lang` e non impone niente ai mazzi esistenti; passare `lang:` imposta anche `text.lang`, quindi sillabazione e titoli generati da Typst. La numerazione della dispensa diceva «di» anche in un mazzo inglese.
- I blocchi rigidi più larghi della colonna — diagrammi fletcher e cetz, tabelle, blocchi di codice — vengono ridotti automaticamente perché rientrino nei margini, sulle slide come nella dispensa. Il controllo di overflow misurava solo l'altezza, quindi il contenuto troppo largo usciva dalla pagina senza nemmeno un avviso. Il contenuto che sa andare a capo da solo non viene toccato; `uniud-fit-width` è pubblica per i casi che il tema non intercetta.
- Nella dispensa A4 la rivelazione progressiva non fa più sparire il contenuto: `uncover`, `only`, `alternatives`, `item-by-item`, `effect`, `handout-only` e i riduttori (`touying-reduce`, `touying-reducer`, quindi i diagrammi fletcher/cetz) vengono rilegati alle versioni documento, che stampano lo stato finale. Prima solo `#pause` era coperto, e tutto ciò che stava dentro un `uncover("2-")[...]` veniva perso.
- I due blocchi con filetto sulla prima pagina della dispensa A4 portano i dati del contenuto — corso e corso di studi a sinistra, anno accademico e docente a destra — con ripiego su `institution` e `date` quando `course` e `academic-year` non ci sono. L'indirizzo della carta intestata scende nel piè di pagina e il blocco del titolo non ripete più autore, struttura e data.
- Nella dispensa A4 le sezioni continuano nel flusso senza salto pagina; il salto viene inserito soltanto tra deck distinti inclusi nello stesso documento.
- Nella dispensa A4 le figure e i diagrammi sovradimensionati vengono ridotti proporzionalmente entro l'area utile della pagina; il titolo della prima pagina parte subito sotto la testata, senza il posizionamento a un terzo previsto per le lettere.
- Il wordmark UNI/UD del «segue foglio» della dispensa usa lo stesso peso dell'acronimo di dipartimento: il manuale li vuole entrambi in Gotham Bold, reso in Work Sans SemiBold quando Gotham non c'è. Prima era in Black, e accanto all'acronimo risultava troppo pesante. Il peso è configurabile con `display-weight`, accanto a `display-font`.
- `release.sh` apre nell'editor anche una voce di changelog già presente nel file, invece di lasciarla passare senza mostrarla.

## 0.3.1 - 2026-09-09

- release.sh: garantita la possibilità di rivedere/modificare nell'editor anche una voce di changelog già preparata prima di confermare la release
- fixed pubblicazione di pages

## 0.3.0 - 2026-09-09

Due comportamenti di default cambiano, e si vedono nei mazzi già scritti: il
contenuto che sfora viene ridotto e segnalato invece di traboccare, e le
didascalie degli archetipi con immagini passano dalla colonna laterale a sotto
la figura. L'API non rompe niente — `overflow: "ignore"` e `caption-at: "side"`
ripristinano il comportamento precedente — ma i PDF cambiano.

- Aggiunto il controllo dell'overflow: il tema misura il corpo di ogni slide, lo riduce quanto basta per farlo stare nell'area di testo e lo segnala con un warning del compilatore e un badge sulla slide (`overflow`, `overflow-min`, `overflow-marker`, `overflow-warn`, `overflow-mode`, e gli argomenti `overflow:`/`scale:` sulle singole slide).
- Il template porta con sé la configurazione dell'editor: un progetto creato con `typst init` ha già le attività VS Code per slide, dispensa A4, slide senza passi e nuova lezione, e le impostazioni di Tinymist per i font del progetto. Le attività compilano il file aperto e cercano i font nella radice del progetto, quindi un corso si inizializza una volta sola e tiene le lezioni in sottocartelle.
- Aggiunta l'opzione `incremental: false`: slide senza rivelazione progressiva, una pagina per slide e tutto in chiaro, con le liste a fuoco, i passi del codice e `dim-at` che decadono invece di restare all'ultimo passo.
- Estratto dal logotipo esteso il solo sigillo (`assets/uniud-sigillo-blu.svg`, `-bianco.svg`), che serve al marchio di dipartimento della carta intestata.
- Aggiunta la dispensa A4: `scripts/make-handout.sh lezione.typ` ricompone la stessa sorgente come documento su carta intestata di dipartimento (manuale d'identità, 2.2), con le note del relatore evidenziate. Nuovi moduli `uniud-handout.typ` e `uniud-tokens.typ`, quest'ultimo condiviso fra slide e dispensa.
- Aggiunta la numerazione delle slide, spenta di default: `slide-numbering` accetta un modello di `numbering` (`"1"`, `"1/1"`, `"I"`) o una funzione `(numero, totale)`. Conta le slide logiche e salta copertina, sezioni, focus e citazioni.
- Le didascalie delle immagini vanno sotto la figura: `media-box(caption: ...)` e gli archetipi con immagini, che ora usano `caption-at` (`"bottom"` di default, `"side"` per la disposizione del master PowerPoint). Lo stile è lo stesso delle didascalie di `#figure`.
- Aggiunte a `install-local.sh` le opzioni `--prune` (toglie le versioni precedenti dopo l'installazione) e `--uninstall --all` (toglie tutte le versioni installate).

## 0.2.0 - 2026-09-09

- Aggiunta l'enfasi incrementale per evidenziare progressivamente il contenuto delle diapositive.
- Aggiunte le liste a fuoco, che rivelano e mettono in risalto un elemento alla volta.
- Aggiunto il supporto per la presentazione di codice passo per passo.
- Aggiunta la generazione della modalità handout per la stampa/distribuzione delle slide.
- Aggiunto il titolo breve nelle diapositive ricorrenti (es. intestazioni/piè di pagina) per un riferimento più leggibile.

## 0.1.3 - 2026-09-09

- Aggiunto supporto per la creazione di pagine dedicate nelle presentazioni.
- Riorganizzati i file demo in una cartella `examples/` con esempi rinominati e più chiari.
- Pubblicati i PDF di esempio su GitHub Pages e allegati automaticamente alle release.

## 0.1.2 - 2026-09-09

- Rimossi i PDF di esempio dal repository, ora generati come artifact della CI invece che versionati.
- Aggiornati script di rilascio e installazione locale.

## 0.1.1 - 2026-09-09

- Consolidato il workflow CI in un unico processo di rilascio, attivato solo alla pubblicazione dei tag di versione
- Aggiornati gli script di rilascio per supportare l'installazione locale del tema
- Aggiornata la documentazione con le istruzioni per l'installazione locale

## 0.1.0 - 2026-09-09

- Release 0.1.0.
