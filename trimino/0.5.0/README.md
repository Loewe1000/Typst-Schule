# trimino

Trimino-Legespiele: Aufgaben und Lösungen stehen auf dreieckigen Kärtchen,
die zu einer Figur zusammengelegt werden. Die Form (Dreieck, Sechseck, Stern,
Raute, Trapez, Streifen) wählt das Paket nach der Zahl der Paare. Gesetzt
werden ein Lösungsbild und ein Schnittbogen mit gemischten, gedrehten
Kärtchen.

```typ
#import "@schule/trimino:0.5.0": trimino

#set page(paper: "a4", margin: 1.5cm)

#trimino(title: [Einmaleins], pairs: (
  ([3 · 4], [12]), ([6 · 7], [42]), ([8 · 8], [64]),
  ([9 · 3], [27]), ([7 · 5], [35]), ([4 · 9], [36]),
))
```

| Funktion | Zweck |
|---|---|
| `trimino(pairs: (), shape: auto, shape-size: auto, distractors: (), seed: 1, side: 6cm, title: none, solution: true, cards: true, number: true, theme: auto, corners: true, back: false, copies: 1, cut-marks: false)` | setzt Lösungsbild und Schnittbogen |
| `trimino-cut-file(path)` | legt die Schnittvorlage als `.json` oder `.svg` in ein Bündel |
| `trimino-shapes(count)` | listet die Formen für eine Zahl von Paaren |

Ein Beispiel liegt in `examples/brueche-prozente.typ`.
