#!/usr/bin/env bash
#
# Compila una lezione come dispensa A4 su carta intestata invece che come slide.
#
#   ./scripts/make-handout.sh lezione.typ              # → lezione-handout.pdf
#   ./scripts/make-handout.sh lezione.typ dispensa.pdf
#
# Prende la *sorgente*, non il PDF delle slide: la dispensa non e' un
# fotomontaggio delle diapositive, e' lo stesso contenuto ricomposto come
# documento, quindi serve il testo, non la pagina gia' stampata.
#
# Opzioni: --font-path DIR (default: fonts/ del repo), --root DIR, e tutto
# quello che segue `--` viene passato a typst.

set -euo pipefail

die() {
    echo "ERRORE: $*" >&2
    exit 1
}

usage() {
    cat <<'USAGE'
Uso:
  ./scripts/make-handout.sh <lezione.typ> [uscita.pdf] [opzioni] [-- opzioni di typst]

Opzioni:
  --font-path DIR   cartella dei font (default: fonts/ del repo)
  --root DIR        radice dei percorsi per typst (default: cartella del sorgente)
  --no-notes        lascia fuori le note del relatore
  --interactive     tiene le attività interattive invece del segnaposto
USAGE
    exit 1
}

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SRC=""
OUT=""
FONT_PATH=""
ROOT=""
NOTES=1
INTERACTIVE=0
PASSTHROUGH=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --font-path) [[ $# -ge 2 ]] || usage; FONT_PATH="$2"; shift 2 ;;
        --root) [[ $# -ge 2 ]] || usage; ROOT="$2"; shift 2 ;;
        --no-notes) NOTES=0; shift ;;
        --interactive) INTERACTIVE=1; shift ;;
        -h|--help) usage ;;
        --) shift; PASSTHROUGH+=("$@"); break ;;
        -*) usage ;;
        *)
            if [[ -z "$SRC" ]]; then SRC="$1"
            elif [[ -z "$OUT" ]]; then OUT="$1"
            else usage
            fi
            shift
            ;;
    esac
done

[[ -n "$SRC" ]] || usage
[[ -f "$SRC" ]] || die "sorgente non trovato: $SRC"
[[ "$SRC" == *.typ ]] || die "serve il sorgente .typ della lezione, non '$SRC'"

command -v typst >/dev/null 2>&1 || die "typst non trovato nel PATH"

[[ -n "$OUT" ]] || OUT="${SRC%.typ}-handout.pdf"
[[ -n "$ROOT" ]] || ROOT="$(cd "$(dirname "$SRC")" && pwd)"
if [[ -z "$FONT_PATH" && -d "$REPO/fonts" ]]; then FONT_PATH="$REPO/fonts"; fi

ARGS=(compile --root "$ROOT" --input uniud-handout=a4)
[[ -n "$FONT_PATH" ]] && ARGS+=(--font-path "$FONT_PATH")
[[ "$NOTES" -eq 0 ]] && ARGS+=(--input uniud-handout-notes=no)
[[ "$INTERACTIVE" -eq 1 ]] && ARGS+=(--input uniud-handout-interactive=yes)

typst "${ARGS[@]}" "${PASSTHROUGH[@]}" "$SRC" "$OUT"
echo "Dispensa in $OUT"
