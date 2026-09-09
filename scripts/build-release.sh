#!/usr/bin/env bash
#
# Compila i PDF di esempio e impacchetta il tema.
# Lo usano sia la CI sia chi vuole provare una release in locale:
#
#   ./scripts/build-release.sh            # versione presa da typst.toml
#   ./scripts/build-release.sh 0.2.0      # versione esplicita
#
# Risultato in dist/:
#   - i PDF di tutti gli esempi, in tutte le varianti
#   - uniud-touying-<v>-pacchetto-locale.zip  da scompattare in packages/local
#   - uniud-touying-<v>-progetto.zip          progetto pronto, font inclusi
#   - thumbnail.png                           anteprima del template
#   - NOTE-RELEASE.md                         testo della release

set -euo pipefail
cd "$(dirname "$0")/.."

TYPST="${TYPST:-typst}"
NAME="uniud-touying"
VERSION="${1:-$(grep -m1 '^version' typst.toml | cut -d'"' -f2)}"
OUT="dist"

echo "==> $NAME $VERSION con $($TYPST --version)"
rm -rf "$OUT"
mkdir -p "$OUT/pdf"

# --- PDF di esempio ---------------------------------------------------------
# Sempre con --font-path fonts: i font del progetto, non quelli di sistema,
# così il PDF della release è identico ovunque venga costruito.
# `--root .`: gli esempi stanno in examples/ e importano ../uniud-theme.typ,
# quindi la radice del progetto è il repository, non la loro cartella.
compile() {
  local out="$1"; shift
  echo "    $out"
  $TYPST compile --root . --font-path fonts "$@" "$OUT/pdf/$out"
}

compile corporate.pdf         examples/corporate.typ
compile corporate-01.pdf      --input style=01    examples/corporate.typ
compile corporate-4-3.pdf     --input ratio=4-3   examples/corporate.typ
compile corporate-16-10.pdf   --input ratio=16-10 examples/corporate.typ
compile sections.pdf          examples/sections.typ
compile lecture.pdf           examples/lecture.typ
compile lecture-01.pdf        --input style=01    examples/lecture.typ
compile lecture-wide.pdf      --input wide=true   examples/lecture.typ
compile lecture-handout.pdf   --input handout=true examples/lecture.typ

# --- pacchetto locale -------------------------------------------------------
# Struttura richiesta da Typst: {namespace}/{nome}/{versione}/typst.toml
PKG="$OUT/pacchetto/$NAME/$VERSION"
./scripts/assemble-package.sh "$PKG"

# --- progetto pronto all'uso ------------------------------------------------
# Import relativo invece del pacchetto: funziona scompattandolo e basta, e
# funziona caricando i file nell'editor web di typst.app.
PRJ="$OUT/progetto/$NAME-$VERSION"
mkdir -p "$PRJ"
cp uniud-theme.typ GUIDA.md LICENSE "$PRJ/"
cp -R assets fonts "$PRJ/"
sed -e 's|#import "@local/uniud-touying:[0-9.]*": \*|#import "uniud-theme.typ": *|' \
    -e 's|`template`|questa cartella|' \
    template/main.typ > "$PRJ/main.typ"
cp template/LICENSE "$PRJ/LICENSE-template"

# thumbnail: la prima pagina del template come viene inizializzato, a 250 ppi,
# come richiesto da Typst Universe. Si rende dal progetto, che è lo stesso
# `main.typ` con l'import relativo, così non serve installare il pacchetto.
$TYPST compile -f png --pages 1 --ppi 250 --font-path fonts \
  "$PRJ/main.typ" "$OUT/thumbnail.png"
cp "$OUT/thumbnail.png" "$PKG/thumbnail.png"

(cd "$OUT/progetto" && zip -qr "../$NAME-$VERSION-progetto.zip" .)
(cd "$OUT/pacchetto" && zip -qr "../$NAME-$VERSION-pacchetto-locale.zip" .)

# --- note di release --------------------------------------------------------
cat > "$OUT/NOTE-RELEASE.md" <<EOF
Tema Touying per le presentazioni dell'Università degli Studi di Udine.

## Come si installa

**Come pacchetto locale** — da usare con \`#import "@local/$NAME:$VERSION": *\`
in qualsiasi documento, e con \`typst init\` per partire da un modello:

\`\`\`sh
# macOS
unzip $NAME-$VERSION-pacchetto-locale.zip -d "\$HOME/Library/Application Support/typst/packages/local"
# Linux
unzip $NAME-$VERSION-pacchetto-locale.zip -d "\${XDG_DATA_HOME:-\$HOME/.local/share}/typst/packages/local"
# Windows (PowerShell)
# Expand-Archive $NAME-$VERSION-pacchetto-locale.zip -DestinationPath "\$env:APPDATA\\typst\\packages\\local"

typst init @local/$NAME:$VERSION mia-lezione
cd mia-lezione && typst watch --font-path fonts main.typ
\`\`\`

\`typst init\` crea un progetto già completo di font, così la compilazione non
dipende da cosa hai installato nel sistema.

**Come progetto pronto** — non installa niente, ed è la via da usare
sull'editor web di typst.app: scompatta
\`$NAME-$VERSION-progetto.zip\`, apri un progetto vuoto su typst.app e
trascina dentro tutti i file (i font nella cartella del progetto vengono
riconosciuti da soli). In locale:

\`\`\`sh
unzip $NAME-$VERSION-progetto.zip && cd $NAME-$VERSION
typst watch --font-path fonts main.typ
\`\`\`

## PDF di esempio

Allegati: gli esempi nei due stili corporate, nei tre formati e nella variante
a tutta larghezza. \`corporate.pdf\` è la suite di test visivi degli archetipi
del PowerPoint d'Ateneo, \`lecture.pdf\` una lezione che usa gli elementi
didattici, \`sections.pdf\` la numerazione e il cromatismo delle sezioni.

## Licenze

Codice e documentazione: CC BY 4.0. La cartella \`template\` è MIT-0, così le
presentazioni che ci scrivi sopra non hanno obblighi di attribuzione. I marchi
UniUD in \`assets/\` restano di proprietà dell'Ateneo. Fira Math e Work Sans in
\`fonts/\` sono sotto SIL Open Font License 1.1.
EOF

mv "$OUT"/pdf/*.pdf "$OUT/"
rmdir "$OUT/pdf"
rm -rf "$OUT/pacchetto" "$OUT/progetto"

echo "==> fatto:"
ls -lh "$OUT" | tail -n +2 | awk '{printf "    %-46s %s\n", $9, $5}'
