#!/usr/bin/env bash
#
# Installa l'albero di lavoro come pacchetto Typst locale, senza passare da una
# release: quello che c'è nel repo diventa subito `@local/uniud-touying:X.Y.Z`.
#
#   ./scripts/install-local.sh              # installa la versione di typst.toml
#   ./scripts/install-local.sh --link       # collegamento simbolico invece di copia
#   ./scripts/install-local.sh --prune      # installa e toglie le altre versioni
#   ./scripts/install-local.sh --uninstall  # rimuove la versione installata
#   ./scripts/install-local.sh --uninstall --all  # rimuove tutte le versioni
#   ./scripts/install-local.sh --list       # mostra cosa è installato
#
# Opzioni: --namespace NOME (default: local), --data-dir DIR per scegliere a
# mano la cartella dati di Typst.
#
# Con --link il pacchetto punta al repo: ogni modifica al tema è immediatamente
# visibile nei documenti che lo importano — comodo mentre si lavora, da evitare
# quando si vuole provare il pacchetto com'è distribuito.

set -euo pipefail

die() {
    echo "ERRORE: $*" >&2
    exit 1
}

usage() {
    cat <<'USAGE'
Uso:
  ./scripts/install-local.sh [opzioni]
  ./scripts/install-local.sh --uninstall [--all] [opzioni]
  ./scripts/install-local.sh --list [opzioni]

Opzioni:
  --link             installa un collegamento simbolico al repo invece di una copia
  --prune            dopo l'installazione rimuove le altre versioni nel namespace
  --namespace NOME   namespace del pacchetto (default: local)
  --data-dir DIR     cartella dati di Typst (default: quella del sistema)
  --uninstall        rimuove la versione installata
  --all              con --uninstall: rimuove tutte le versioni, non solo questa
  --list             elenca le versioni installate nel namespace
USAGE
    exit 1
}

cd "$(dirname "$0")/.."

NAME="uniud-touying"
NAMESPACE="local"
DATA_DIR=""
MODE="install"
LINK=0
PRUNE=0
ALL=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --link) LINK=1; shift ;;
        --prune) PRUNE=1; shift ;;
        --all) ALL=1; shift ;;
        --uninstall) MODE="uninstall"; shift ;;
        --list) MODE="list"; shift ;;
        --namespace) [[ $# -ge 2 ]] || usage; NAMESPACE="$2"; shift 2 ;;
        --data-dir) [[ $# -ge 2 ]] || usage; DATA_DIR="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) usage ;;
    esac
done

[[ -f typst.toml ]] || die "typst.toml non trovato"
VERSION="$(grep -m1 '^version' typst.toml | cut -d'"' -f2)"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] \
    || die "versione non valida in typst.toml: '$VERSION'"

# Cartella dati di Typst, come documentato nel manuale dei pacchetti.
if [[ -z "$DATA_DIR" ]]; then
    case "$(uname -s)" in
        Darwin) DATA_DIR="$HOME/Library/Application Support/typst" ;;
        MINGW*|MSYS*|CYGWIN*) DATA_DIR="${APPDATA:-$HOME/AppData/Roaming}/typst" ;;
        *) DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/typst" ;;
    esac
fi

PKG_ROOT="$DATA_DIR/packages/$NAMESPACE/$NAME"
DEST="$PKG_ROOT/$VERSION"

case "$MODE" in
    list)
        if [[ -d "$PKG_ROOT" ]]; then
            echo "In $PKG_ROOT:"
            for d in "$PKG_ROOT"/*; do
                [[ -e "$d" ]] || continue
                if [[ -L "$d" ]]; then
                    echo "  $(basename "$d")  ->  $(readlink "$d")"
                else
                    echo "  $(basename "$d")"
                fi
            done
        else
            echo "Nessuna versione installata in $PKG_ROOT"
        fi
        exit 0
        ;;
    uninstall)
        if [[ "$ALL" -eq 1 ]]; then
            [[ -d "$PKG_ROOT" ]] || die "niente da rimuovere in $PKG_ROOT"
            for d in "$PKG_ROOT"/*; do
                [[ -e "$d" || -L "$d" ]] || continue
                rm -rf "$d"
                echo "Rimosso $d"
            done
            rmdir "$PKG_ROOT" 2>/dev/null || true
            exit 0
        fi
        [[ -e "$DEST" || -L "$DEST" ]] || die "non installato: $DEST"
        rm -rf "$DEST"
        rmdir "$PKG_ROOT" 2>/dev/null || true
        echo "Rimosso $DEST"
        exit 0
        ;;
esac

# Un'installazione precedente della stessa versione viene sostituita: durante
# lo sviluppo la versione non cambia a ogni modifica.
if [[ -e "$DEST" || -L "$DEST" ]]; then
    echo "Sostituisco l'installazione esistente in $DEST"
    rm -rf "$DEST"
fi
mkdir -p "$PKG_ROOT"

if [[ "$LINK" -eq 1 ]]; then
    ln -s "$PWD" "$DEST"
    echo "Collegato $DEST -> $PWD"
    # Con il collegamento i font restano in fonts/ e non in template/fonts:
    # `typst init` funziona lo stesso, ma il progetto creato non li avrebbe.
    echo "Nota: in modalità --link i progetti creati con \`typst init\` non"
    echo "      includono i font; usali con --font-path della cartella fonts/."
else
    ./scripts/assemble-package.sh "$DEST"
    echo "Installato $DEST"
fi

# Le altre versioni si tolgono solo a installazione riuscita: un errore non
# deve lasciare il namespace vuoto.
if [[ "$PRUNE" -eq 1 ]]; then
    for d in "$PKG_ROOT"/*; do
        [[ -e "$d" || -L "$d" ]] || continue
        [[ "$(basename "$d")" != "$VERSION" ]] || continue
        rm -rf "$d"
        echo "Rimossa versione precedente $(basename "$d")"
    done
fi

cat <<EOF

Da qualunque documento:
  #import "@$NAMESPACE/$NAME:$VERSION": *

Nuovo progetto dal modello:
  typst init @$NAMESPACE/$NAME:$VERSION mia-lezione
  cd mia-lezione && typst watch --font-path fonts main.typ
EOF
