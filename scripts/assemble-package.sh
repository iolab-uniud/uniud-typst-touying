#!/usr/bin/env bash
#
# Assembla il pacchetto Typst in una directory.
#
#   ./scripts/assemble-package.sh DESTDIR
#
# DESTDIR è la cartella finale del pacchetto, cioè quella che nella gerarchia
# di Typst si chiama {namespace}/{nome}/{versione}. Lo usano sia
# `build-release.sh` (per costruire lo zip) sia `install-local.sh` (per
# installare direttamente l'albero di lavoro): l'elenco dei file che fanno
# parte del pacchetto sta qui e solo qui.

set -euo pipefail
cd "$(dirname "$0")/.."

[[ $# -eq 1 ]] || { echo "uso: $0 DESTDIR" >&2; exit 2; }
DEST="$1"

mkdir -p "$DEST"
# I tre moduli sono un pacchetto solo: il tema importa i token, e in modalita'
# dispensa rilega i propri nomi a quelli di uniud-handout.
cp typst.toml uniud-theme.typ uniud-tokens.typ uniud-handout.typ "$DEST/"
cp README.md GUIDA.md LICENSE "$DEST/"
if [[ -f CHANGELOG.md ]]; then
    cp CHANGELOG.md "$DEST/"
fi

rm -rf "$DEST/assets" "$DEST/template"
cp -R assets template "$DEST/"

# Typst non carica font dai pacchetti, ma li carica dalla cartella di un
# progetto: mettendoli dentro `template` finiscono nei progetti creati con
# `typst init`.
cp -R fonts "$DEST/template/"
