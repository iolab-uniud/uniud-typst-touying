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
# La voce di CHANGELOG.md viene abbozzata a partire dai commit dall'ultimo tag
# in poi — se c'è un LLM da riga di comando (`claude -p`, o quello indicato in
# RELEASE_CHANGELOG_CMD) è lui a scriverla — e poi aperta nell'editor per la
# revisione, come il messaggio di un commit.
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
  --yes       non chiede conferma e non apre l'editor (uso non interattivo)
  --no-llm    non fa scrivere la bozza del changelog a un LLM
  --no-edit   non apre l'editor sulla voce di changelog

Variabili d'ambiente:
  RELEASE_CHANGELOG_CMD  comando che scrive la bozza (default: claude -p)
  EDITOR / VISUAL        editor per la voce di changelog (default: vi)
USAGE
    exit 1
}

BUMP=""
ASSUME_YES=0
USE_LLM=1
EDIT_CHANGELOG=1
for arg in "$@"; do
    case "$arg" in
        --yes|-y) ASSUME_YES=1 ;;
        --no-llm) USE_LLM=0 ;;
        --no-edit) EDIT_CHANGELOG=0 ;;
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

if grep -Eq "^## ${NEW_VERSION}([[:space:]]|$)" CHANGELOG.md; then
    echo "CHANGELOG.md ha già una voce per $NEW_VERSION: la lascio com'è."
else
    ENTRY="$(mktemp)"
    trap 'rm -f "$ENTRY"' EXIT

    # Materiale grezzo: i commit dall'ultimo tag in poi.
    LAST_TAG="$(git describe --tags --abbrev=0 2>/dev/null || true)"
    if [[ -n "$LAST_TAG" ]]; then
        RANGE="${LAST_TAG}..HEAD"
        echo "Voce di changelog da $LAST_TAG a HEAD."
    else
        RANGE="HEAD"
        echo "Nessun tag precedente: si parte dall'inizio della storia."
    fi
    COMMITS="$(git log --no-merges --pretty=format:'- %s' "$RANGE" || true)"
    DIFFSTAT="$(git diff --stat "$RANGE" 2>/dev/null | tail -n 30 || true)"

    # Bozza scritta da un LLM da riga di comando, se ce n'è uno. `claude -p`
    # è la modalità non interattiva di Claude Code; con RELEASE_CHANGELOG_CMD
    # se ne può usare un altro (deve leggere il prompt da stdin e scrivere la
    # bozza su stdout). `--no-llm` salta il passaggio.
    DRAFT=""
    if [[ "$USE_LLM" -eq 1 && -n "$COMMITS" ]]; then
        LLM_CMD="${RELEASE_CHANGELOG_CMD:-}"
        if [[ -z "$LLM_CMD" ]] && command -v claude >/dev/null 2>&1; then
            LLM_CMD="claude -p"
        fi
        if [[ -n "$LLM_CMD" ]]; then
            echo "Bozza della voce di changelog con: $LLM_CMD"
            PROMPT="Scrivi la voce di CHANGELOG per la versione $NEW_VERSION di
uniud-touying, un tema Touying/Typst per le presentazioni dell'Università di
Udine.

Regole:
- rispondi SOLO con un elenco puntato markdown, niente titoli, niente premesse;
- una riga per cambiamento, in italiano, al passato o all'infinito, concisa;
- descrivi l'effetto per chi usa il tema, non il dettaglio implementativo;
- accorpa i commit che fanno parte dello stesso cambiamento;
- ometti refactoring interni e correzioni di refusi senza effetti visibili.

Commit dall'ultima release:
$COMMITS

File toccati:
$DIFFSTAT"
            # Un LLM che non risponde o fallisce non deve bloccare la release.
            DRAFT="$(printf '%s' "$PROMPT" | $LLM_CMD 2>/dev/null || true)"
            [[ -n "$DRAFT" ]] || echo "  (nessuna bozza: si usa l'elenco dei commit)"
        fi
    fi

    if [[ -n "$DRAFT" ]]; then
        printf '%s\n' "$DRAFT" > "$ENTRY"
    elif [[ -n "$COMMITS" ]]; then
        printf '%s\n' "$COMMITS" > "$ENTRY"
    else
        printf -- '- Release %s.\n' "$NEW_VERSION" > "$ENTRY"
    fi

    # Revisione a mano, come per un messaggio di commit.
    if [[ "$ASSUME_YES" -eq 0 && "$EDIT_CHANGELOG" -eq 1 && -t 1 ]]; then
        {
            printf '# Voce di CHANGELOG.md per la versione %s (%s).\n' "$NEW_VERSION" "$TODAY"
            printf '# Le righe che iniziano con # vengono ignorate.\n'
            printf '# Salva ed esci per continuare; svuota il file per annullare.\n'
        } >> "$ENTRY"

        EDITOR_CMD="${GIT_EDITOR:-${VISUAL:-${EDITOR:-vi}}}"
        $EDITOR_CMD "$ENTRY" </dev/tty >/dev/tty 2>&1 \
            || die "l'editor è uscito con errore"

        # Via i commenti e le righe vuote in testa e in coda.
        CLEANED="$(grep -v '^#' "$ENTRY" | perl -0pe 's/\A\s*\n//; s/\s*\z/\n/' || true)"
        CLEANED="${CLEANED%$'\n'}"
        [[ -n "$CLEANED" ]] || die "voce di changelog vuota: release annullata"
        printf '%s\n' "$CLEANED" > "$ENTRY"
    fi

    TMPFILE="$(mktemp)"
    {
        IFS= read -r first_line || true
        printf '%s\n' "$first_line"
        printf '\n## %s - %s\n\n' "$NEW_VERSION" "$TODAY"
        cat "$ENTRY"
        cat
    } < CHANGELOG.md > "$TMPFILE"
    mv "$TMPFILE" CHANGELOG.md
fi

# --- build ------------------------------------------------------------------

echo
echo "Compilazione dei demo e dei pacchetti..."
./scripts/build-release.sh "$NEW_VERSION"

# La build qui serve come verifica: se un layout si rompe la release non parte.
# I PDF pubblicati sono però quelli che ricostruisce la CI dal tag, non questi.
for f in \
    "dist/uniud-touying-${NEW_VERSION}-pacchetto-locale.zip" \
    "dist/uniud-touying-${NEW_VERSION}-progetto.zip" \
    dist/thumbnail.png \
    dist/demo.pdf dist/demo-01.pdf dist/demo-auto-sections.pdf \
    dist/demo-teaching.pdf dist/demo-teaching-wide.pdf
do
    [[ -s "$f" ]] || die "la build non ha prodotto $f"
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

git add typst.toml CHANGELOG.md
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
