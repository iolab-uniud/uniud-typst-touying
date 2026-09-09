#!/usr/bin/env bash
#
# Avanzamento di versione e pubblicazione di una release.
#
#   ./scripts/release.sh patch
#   ./scripts/release.sh minor
#   ./scripts/release.sh major
#   ./scripts/release.sh X.Y.Z
#   ./scripts/release.sh vX.Y.Z
#
# `typst.toml` è l'unica fonte di verità per la versione: da lì viene letta e
# lì viene riscritta, insieme a tutti i punti che la citano (README, modello).
# Lo script ricompila i PDF di esempio, li aggiorna nel repo, crea il commit e
# il tag `vX.Y.Z` e lo pubblica: da quel momento è il workflow `release.yml` a
# costruire gli allegati e a creare la release su GitHub.
#
# Opzione `--yes` per non chiedere conferma (uso non interattivo).

set -euo pipefail

die() {
    echo "ERRORE: $*" >&2
    exit 1
}

usage() {
    cat <<'USAGE'
Uso:
  ./scripts/release.sh patch
  ./scripts/release.sh minor
  ./scripts/release.sh major
  ./scripts/release.sh X.Y.Z
  ./scripts/release.sh vX.Y.Z

Opzioni:
  --yes    non chiede conferma prima di committare e pubblicare
USAGE
    exit 1
}

BUMP=""
ASSUME_YES=0
for arg in "$@"; do
    case "$arg" in
        --yes|-y) ASSUME_YES=1 ;;
        -h|--help) usage ;;
        *)
            [[ -z "$BUMP" ]] || usage
            BUMP="$arg"
            ;;
    esac
done
[[ -n "$BUMP" ]] || usage

cd "$(dirname "$0")/.."
[[ -d .git ]] || die "questo script va eseguito dentro il repository"
[[ -f typst.toml ]] || die "typst.toml non trovato"

OLD_VERSION="$(grep -m1 '^version' typst.toml | cut -d'"' -f2)"
[[ "$OLD_VERSION" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]] \
    || die "versione non valida in typst.toml: '$OLD_VERSION'"

MAJOR="${BASH_REMATCH[1]}"
MINOR="${BASH_REMATCH[2]}"
PATCH="${BASH_REMATCH[3]}"

case "$BUMP" in
    patch) NEW_VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))" ;;
    minor) NEW_VERSION="${MAJOR}.$((MINOR + 1)).0" ;;
    major) NEW_VERSION="$((MAJOR + 1)).0.0" ;;
    *)
        NEW_VERSION="${BUMP#v}"
        [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || usage
        ;;
esac

NEW_TAG="v${NEW_VERSION}"

echo
echo "uniud-touying release"
echo "---------------------"
echo "Versione corrente : $OLD_VERSION"
echo "Nuova versione    : $NEW_VERSION"
echo "Tag               : $NEW_TAG"
[[ "$NEW_VERSION" == "$OLD_VERSION" ]] \
    && echo "(stessa versione: si tagga lo stato corrente)"
echo

# --- controlli preliminari --------------------------------------------------

command -v typst >/dev/null 2>&1 || die "typst non trovato nel PATH"
command -v zip   >/dev/null 2>&1 || die "zip non trovato nel PATH"

if [[ -n "$(git status --porcelain)" ]]; then
    git status --short
    die "l'albero di lavoro non è pulito"
fi

git fetch --tags --prune origin

if git rev-parse -q --verify "refs/tags/$NEW_TAG" >/dev/null; then
    die "il tag locale '$NEW_TAG' esiste già"
fi

if git ls-remote --exit-code --tags origin "refs/tags/$NEW_TAG" >/dev/null 2>&1; then
    die "il tag remoto '$NEW_TAG' esiste già"
fi

# --- riscrittura della versione ---------------------------------------------
# typst.toml è la fonte di verità; gli altri file la citano e vengono derivati.

if [[ "$NEW_VERSION" != "$OLD_VERSION" ]]; then
    OLD="$OLD_VERSION" NEW="$NEW_VERSION" perl -0pi -e '
      s/^version = "\Q$ENV{OLD}\E"/version = "$ENV{NEW}"/m;
    ' typst.toml

    # `@local/uniud-touying:X.Y.Z` nel modello e nella documentazione, i nomi
    # degli zip di release e i tag citati negli esempi.
    for f in README.md GUIDA.md template/main.typ; do
        [[ -f "$f" ]] || continue
        OLD="$OLD_VERSION" NEW="$NEW_VERSION" perl -0pi -e '
          s/uniud-touying:\Q$ENV{OLD}\E/uniud-touying:$ENV{NEW}/g;
          s/uniud-touying-\Q$ENV{OLD}\E/uniud-touying-$ENV{NEW}/g;
          s/\bv\Q$ENV{OLD}\E\b/v$ENV{NEW}/g;
        ' "$f"
    done

    # Nessun residuo della versione precedente fuori dal changelog: se ne resta
    # uno è un punto da aggiungere alla sostituzione qui sopra.
    STALE="$(git grep -n -F "$OLD_VERSION" -- . \
             ':(exclude)CHANGELOG.md' ':(exclude)dist' || true)"
    if [[ -n "$STALE" ]]; then
        echo "$STALE" >&2
        die "versione precedente ancora citata nei file qui sopra"
    fi
fi

# --- changelog --------------------------------------------------------------

[[ -f CHANGELOG.md ]] || printf '# Changelog\n' > CHANGELOG.md

TODAY="$(date +%Y-%m-%d)"
if ! grep -Eq "^## ${NEW_VERSION}([[:space:]]|$)" CHANGELOG.md; then
    TMPFILE="$(mktemp)"
    {
        IFS= read -r first_line || true
        printf '%s\n' "$first_line"
        printf '\n## %s - %s\n\n' "$NEW_VERSION" "$TODAY"
        printf '%s\n' "- Release ${NEW_VERSION}."
        cat
    } < CHANGELOG.md > "$TMPFILE"
    mv "$TMPFILE" CHANGELOG.md
fi

# --- build ------------------------------------------------------------------

echo
echo "Compilazione dei demo e dei pacchetti..."
./scripts/build-release.sh "$NEW_VERSION"

for f in \
    "dist/uniud-touying-${NEW_VERSION}-pacchetto-locale.zip" \
    "dist/uniud-touying-${NEW_VERSION}-progetto.zip" \
    dist/thumbnail.png
do
    [[ -s "$f" ]] || die "la build non ha prodotto $f"
done

# I demo versionati sono il riferimento visivo del tema: si aggiornano a ogni
# release, gli altri PDF restano solo fra gli allegati.
DEMO_PDF=(demo.pdf demo-01.pdf demo-auto-sections.pdf demo-teaching.pdf demo-teaching-wide.pdf)
for pdf in "${DEMO_PDF[@]}"; do
    [[ -s "dist/$pdf" ]] || die "la build non ha prodotto dist/$pdf"
    cp "dist/$pdf" "$pdf"
done

# --- conferma ---------------------------------------------------------------

echo
echo "Modifiche:"
git status --short
echo
git --no-pager diff -- typst.toml README.md GUIDA.md template/main.typ CHANGELOG.md || true

if [[ "$ASSUME_YES" -eq 0 ]]; then
    echo
    echo "Prima di confermare puoi completare la voce di CHANGELOG.md."
    read -r -p "Creare e pubblicare la release $NEW_TAG? [y/N] " answer
    case "$answer" in
        y|Y|yes|YES|s|S|si|SI|sì) ;;
        *)
            echo "Release annullata. Le modifiche restano nell'albero di lavoro."
            exit 0
            ;;
    esac
fi

# --- commit, tag, push ------------------------------------------------------

git add typst.toml CHANGELOG.md "${DEMO_PDF[@]}"
for f in README.md GUIDA.md template/main.typ; do
    [[ -f "$f" ]] && git add "$f"
done

if git diff --cached --quiet; then
    echo "Nessuna modifica da committare: si tagga lo stato corrente."
else
    git commit -m "Release $NEW_TAG"
fi

git tag -a "$NEW_TAG" -m "uniud-touying $NEW_VERSION"

CURRENT_BRANCH="$(git branch --show-current)"
[[ -n "$CURRENT_BRANCH" ]] || die "impossibile determinare il branch corrente"

git push origin "$CURRENT_BRANCH"
git push origin "$NEW_TAG"

echo
echo "Tag $NEW_TAG pubblicato. La release su GitHub la costruisce il workflow"
echo "release.yml: PDF di esempio, zip installabili e thumbnail."
