#!/usr/bin/env python3
"""Costruisce il sito degli esempi pubblicato su GitHub Pages.

    ./scripts/build-site.py [--version X.Y.Z] [--out site] [--dist dist]

Mette insieme tre cose:

  index.html   indice: la guida sezione per sezione, i PDF, i download
  guida.html   GUIDA.md
  readme.html  README.md, il riferimento tecnico

I PDF li prende da `dist/`, quindi va lanciato dopo `scripts/build-release.sh`.
Serve il modulo `markdown` (pip install markdown).
"""

import argparse
import os
import pathlib
import re
import shutil
import sys

try:
    import markdown
except ImportError:  # pragma: no cover
    sys.exit("serve il modulo python 'markdown': pip install markdown")

ROOT = pathlib.Path(__file__).resolve().parent.parent

# I PDF pubblicati, nell'ordine in cui compaiono nell'indice.
ESEMPI = [
    ("Archetipi corporate", [
        ("corporate.pdf", "un esemplare di ogni archetipo del master, stile 02, 16:9"),
        ("corporate-01.pdf", "gli stessi archetipi nello stile 01"),
        ("corporate-4-3.pdf", "formato 4:3"),
        ("corporate-16-10.pdf", "formato 16:10"),
        ("sections.pdf", "numerazione automatica e cromatismo delle sezioni"),
    ]),
    ("Lezione", [
        ("lecture.pdf", "elementi didattici: indice, colonne, callout, codice, formule, tabelle, bibliografia"),
        ("lecture-01.pdf", "la stessa lezione nello stile 01"),
        ("lecture-wide.pdf", "misura del testo a tutta larghezza"),
    ]),
]

CSS = """
:root {
  color-scheme: light dark;
  --blu: #0000ff;
  --testo: #111;
  --tenue: #666;
  --riga: #d8d8d9;
  --fondo: #fff;
  --codice: #f4f4f5;
}
@media (prefers-color-scheme: dark) {
  :root {
    --blu: #7d8cff; --testo: #e9e9ea; --tenue: #a0a0a3;
    --riga: #3a3a3d; --fondo: #131316; --codice: #1d1d21;
  }
}
* { box-sizing: border-box; }
body {
  margin: 0; background: var(--fondo); color: var(--testo);
  font: 16px/1.65 "Work Sans", system-ui, -apple-system, "Segoe UI", sans-serif;
  -webkit-font-smoothing: antialiased;
}
.wrap { max-width: 46rem; margin: 0 auto; padding: 0 1.25rem 5rem; }
header.sito { border-bottom: 3px solid var(--blu); margin-bottom: 2.5rem; }
header.sito .wrap { padding-top: 2rem; padding-bottom: 1rem; }
header.sito a { color: inherit; text-decoration: none; }
.marchio { font-weight: 700; letter-spacing: .01em; }
.versione {
  font-size: .75rem; text-transform: uppercase; letter-spacing: .08em;
  color: var(--tenue); margin-left: .5rem;
}
nav.sito { margin-top: .75rem; font-size: .875rem; }
nav.sito a { margin-right: 1.25rem; color: var(--tenue); }
nav.sito a.attivo { color: var(--blu); font-weight: 600; }
h1 { font-size: 1.85rem; line-height: 1.2; margin: 0 0 .5rem; }
h2 {
  font-size: 1.25rem; margin: 2.75rem 0 .75rem;
  padding-top: .6rem; border-top: 3px solid var(--blu);
}
h3 { font-size: 1.05rem; margin: 2rem 0 .5rem; }
a { color: var(--blu); }
p.occhiello { color: var(--tenue); margin-top: 0; }
ul.indice, ul.esempi { list-style: none; padding: 0; }
ul.indice li, ul.esempi li { margin: .35rem 0; }
ul.esempi .nota { color: var(--tenue); }
code {
  font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: .875em; background: var(--codice);
  padding: .1em .3em; border-radius: 3px;
}
pre {
  background: var(--codice); padding: .9rem 1rem; border-radius: 4px;
  overflow-x: auto; line-height: 1.5;
}
pre code { background: none; padding: 0; font-size: .8125rem; }
table { border-collapse: collapse; width: 100%; margin: 1.25rem 0; display: block; overflow-x: auto; }
th, td { text-align: left; padding: .45rem .75rem .45rem 0; vertical-align: top; }
th { border-bottom: 2px solid var(--blu); font-size: .8125rem;
     text-transform: uppercase; letter-spacing: .04em; }
td { border-bottom: 1px solid var(--riga); font-size: .9375rem; }
blockquote { margin: 1.25rem 0; padding-left: 1rem; border-left: 3px solid var(--riga); color: var(--tenue); }
img { max-width: 100%; height: auto; border: 1px solid var(--riga); }
footer.sito { border-top: 1px solid var(--riga); margin-top: 4rem; padding-top: 1rem;
              font-size: .8125rem; color: var(--tenue); }
"""

PAGINE = [("index.html", "Indice"), ("guida.html", "Guida"), ("readme.html", "Riferimento tecnico")]


def guscio(titolo, versione, corpo, attiva, repo_url):
    def voce(href, etichetta):
        classe = ' class="attivo"' if href == attiva else ""
        return f'      <a href="{href}"{classe}>{etichetta}</a>'

    nav = "\n".join(voce(href, etichetta) for href, etichetta in PAGINE)
    return f"""<!doctype html>
<html lang="it">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{titolo}</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Work+Sans:ital,wght@0,400;0,500;0,700;1,400&display=swap">
<link rel="stylesheet" href="stile.css">
</head>
<body>
<header class="sito">
  <div class="wrap">
    <a href="index.html"><span class="marchio">uniud-touying</span></a><span class="versione">{versione}</span>
    <nav class="sito">
{nav}
      <a href="{repo_url}">GitHub</a>
    </nav>
  </div>
</header>
<main class="wrap">
{corpo}
</main>
<footer class="sito">
  <div class="wrap">
    Tema Touying per le presentazioni dell&rsquo;Universit&agrave; degli Studi di
    Udine. Codice e documentazione CC BY 4.0; i marchi UniUD restano di
    propriet&agrave; dell&rsquo;Ateneo.
  </div>
</footer>
</body>
</html>
"""


def converti(sorgente, link_interni):
    """Markdown -> (html, elenco delle sezioni di primo livello)."""
    md = markdown.Markdown(extensions=["extra", "toc", "sane_lists"])
    corpo = md.convert(sorgente.read_text(encoding="utf-8"))
    for da, a in link_interni.items():
        corpo = corpo.replace(f'href="{da}"', f'href="{a}"')
    piatto = []

    def visita(tokens):
        for t in tokens:
            piatto.append(t)
            visita(t.get("children", []))

    visita(md.toc_tokens)
    sezioni = [(t["id"], t["name"]) for t in piatto if t["level"] == 2]
    if not sezioni:  # documenti che usano l'h1 come titolo di sezione
        sezioni = [(t["id"], t["name"]) for t in piatto if t["level"] == 1]
    return corpo, sezioni


def indice(versione, sezioni_guida, repo_url, pdf_presenti):
    voci = "\n".join(
        f'    <li><a href="guida.html#{id_}">{nome}</a></li>' for id_, nome in sezioni_guida
    )
    blocchi = []
    for titolo, elenco in ESEMPI:
        righe = "\n".join(
            f'    <li><a href="{f}">{f}</a> <span class="nota">&mdash; {d}</span></li>'
            for f, d in elenco if f in pdf_presenti
        )
        if righe:
            blocchi.append(f"<h3>{titolo}</h3>\n  <ul class=\"esempi\">\n{righe}\n  </ul>")
    esempi = "\n  ".join(blocchi)
    anteprima = ('  <p><img src="thumbnail.png" alt="prima slide del modello"></p>\n'
                 if "thumbnail.png" in pdf_presenti else "")
    return f"""  <h1>uniud-touying</h1>
  <p class="occhiello">Tema Touying per le presentazioni didattiche
  dell&rsquo;Universit&agrave; degli Studi di Udine, ricavato dai due master
  PowerPoint d&rsquo;Ateneo. Questa pagina raccoglie la guida e gli esempi
  compilati della versione {versione}.</p>

  <h2>Guida</h2>
  <p>Come si scrive una presentazione, sezione per sezione
  (<a href="guida.html">tutta di seguito</a>):</p>
  <ul class="indice">
{voci}
  </ul>

  <h2>Esempi compilati</h2>
  <p>Gli stessi file di <code>examples/</code> resi in PDF: sono la suite di
  test visivi del tema.</p>
  {esempi}

  <h2>Il modello</h2>
  <p>Quello che si ottiene con <code>typst init</code>, prima slide:</p>
{anteprima}
  <h2>Download</h2>
  <ul class="indice">
    <li><a href="{repo_url}/releases/latest">Release</a> &mdash; pacchetto da
    installare in Typst, progetto pronto per typst.app, PDF di esempio</li>
    <li><a href="{repo_url}">Codice del tema</a> su GitHub</li>
    <li><a href="readme.html">Riferimento tecnico</a> &mdash; misure corporate,
    scostamenti dal manuale, scelte di design</li>
  </ul>
"""


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--version", default=None, help="versione da mostrare (default: quella di typst.toml)")
    ap.add_argument("--out", default="dist/site", help="cartella di destinazione")
    ap.add_argument("--dist", default="dist", help="cartella con i PDF compilati")
    ap.add_argument("--repo-url", default=None, help="URL del repository")
    args = ap.parse_args()

    versione = args.version
    if not versione:
        testo = (ROOT / "typst.toml").read_text(encoding="utf-8")
        versione = re.search(r'^version\s*=\s*"([^"]+)"', testo, re.M).group(1)

    repo_url = args.repo_url
    if not repo_url:
        server = os.environ.get("GITHUB_SERVER_URL", "https://github.com")
        nome = os.environ.get("GITHUB_REPOSITORY")
        repo_url = f"{server}/{nome}" if nome else "https://github.com/iolab-uniud/uniud-typst-touying"

    out = pathlib.Path(args.out)
    dist = pathlib.Path(args.dist)
    out.mkdir(parents=True, exist_ok=True)

    # PDF e anteprima
    presenti = set()
    for f in sorted(dist.glob("*.pdf")) + sorted(dist.glob("thumbnail.png")):
        shutil.copy2(f, out / f.name)
        presenti.add(f.name)
    if not presenti:
        print(f"attenzione: nessun PDF in {dist}/ (lanciare prima build-release.sh)", file=sys.stderr)

    (out / "stile.css").write_text(CSS.strip() + "\n", encoding="utf-8")

    guida, sezioni = converti(ROOT / "GUIDA.md", {"README.md": "readme.html"})
    readme, _ = converti(ROOT / "README.md", {"GUIDA.md": "guida.html"})

    pagine = {
        "index.html": ("uniud-touying — tema Touying per UniUD",
                       indice(versione, sezioni, repo_url, presenti)),
        "guida.html": ("Guida — uniud-touying", guida),
        "readme.html": ("Riferimento tecnico — uniud-touying", readme),
    }
    for nome, (titolo, corpo) in pagine.items():
        (out / nome).write_text(
            guscio(titolo, versione, corpo, nome, repo_url), encoding="utf-8")

    print(f"sito in {out}/ — {len(pagine)} pagine, {len(presenti)} file allegati, "
          f"{len(sezioni)} sezioni di guida nell'indice")


if __name__ == "__main__":
    main()
