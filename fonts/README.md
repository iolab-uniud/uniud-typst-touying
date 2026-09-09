# Fonts

Entrambi i font che servono al tema, sotto SIL Open Font License 1.1. Non serve
installarli: basta compilare con `--font-path fonts`, e nell'editor web di
typst.app basta caricarli nella cartella del progetto.

- `WorkSans[wght].ttf`, `WorkSans-Italic[wght].ttf` — [Work Sans](https://github.com/google/fonts/tree/main/ofl/worksans)
  di Wei Huang, licenza in `LICENSE-WorkSans.txt`. È il carattere corporate:
  il manuale d'Ateneo (p. 045) lo indica come sostituto di Gotham e LL Circular
  per tutte le applicazioni d'ufficio. Sono i file variabili originali di Google
  Fonts: Typst applica correttamente l'asse dei pesi, verificato confrontando le
  metriche con le istanze statiche.
- `FiraMath-Regular.otf` — [Fira Math](https://github.com/firamath/firamath) 0.3.4
  di Xiangdong Zeng, licenza in `LICENSE-FiraMath.txt`. Font matematico senza
  grazie, usato come `math-font` predefinito perché si accorda a Work Sans per
  peso e proporzioni, mentre il New Computer Modern Math incluso in Typst è un
  graziato e stona.

Alternativa con un peso bold nelle formule: [Lete Sans Math](https://github.com/abccsss/LeteSansMath).
Per tornare al matematico di Typst: `math-font: "New Computer Modern Math"`.
