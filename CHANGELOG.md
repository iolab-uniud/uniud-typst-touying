# Changelog

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
