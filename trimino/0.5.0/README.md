# trimino

Trimino- und Domino-Legespiele.

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
| `trimino(pairs: (), shape: auto, shape-size: auto, distractors: (), seed: 1, side: 6cm, title: none, solution: true, cards: true, number: true, theme: auto, corners: true, label-size: auto, back: false, copies: 1, first-copy: 1, cut-marks: false)` | setzt Lösungsbild und Schnittbogen |
| `domino(pairs: (), layout: "chain", word: auto, loop: false, start: [Start], end: [Ende], tags: none, seed: 1, side: 3.5cm, title: none, solution: true, cards: true, theme: auto, label-size: auto, back: false, copies: 1, first-copy: 1, cut-marks: false)` | setzt ein Domino als Kette (zufällige Treppe, Anlegerahmen) oder Stapel (Lösungswort auf der Rückseite) |
| `trimino-cut-file(path)` | legt die Schnittvorlage als `.json` oder `.svg` in ein Bündel |
| `trimino-shapes(count)` | listet die Formen für eine Zahl von Paaren |

Beispiele liegen in `examples/brueche-prozente.typ`, `examples/summenregel-domino.typ`
und `examples/graphen-domino.typ`.

## Gestaltung

Sieben Themes: drei klassische und vier, die zu den Themes von
`@schule/arbeitsblatt` passen (gleiche Schriften und Motive, Akzent in der
Fachfarbe Mathematik). Jedes gestaltet Kärtchen, Kopf, Dominos und Rückseite.
Die Funktionscodes bleiben in allen gleich: Eckspitzen zur Selbstkontrolle
(`corners: "wheel"`: sechs Farben plus 1–6 Würfelaugen), Anlegerahmen der
Dominos (Lösung dünn und rund, Aufgabe kräftig und eckig, deutlicher
Helligkeitsabstand). Farbe gehört zum Rahmen, nicht zum Inhalt: Graphen in
Tinte zeichnen.

| `theme` | Zweck |
|---|---|
| `"riso"` (Standard) | Pastell je Kärtchen, weiße Felder mit Haarlinie, zweifarbige Drachen in den Ecken; Rückseite creme mit Pastellkonfetti und buntem Schriftzug |
| `"klar"` | schwarz-weiß, kopierfest, ab Klasse 9; Grauleiter mit Augen |
| `"leiste"` | violette Leiste an jeder Kante, Beschriftungen darin |
| `"atlas"` | wie ein modernes Schulbuch: Kärtchen in der Fachfarbe getönt, weiße runde Felder, Titelband mit Kreisen (Myriad Pro) |
| `"skizze"` | verspielt für die Unterstufe: Kreidetöne, gestrichelte Felder, Titel auf Klebeband (Playpen Sans) |
| `"labor"` | technisch für MINT: Haarlinien, Messskalen, Fira Code für Nummern, Millimeterpapier auf der Rückseite |
| `"kontur"` | plakativ: dicke schwarze Umrisse, harte Schatten in der Akzentfarbe, Futura-Versalien |

`"bauhaus"` gibt es nicht mehr. Ein Dictionary ändert einzelne Schlüssel,
mit `base` auch eines anderen Themes als `"riso"`; Werte dürfen Funktionen
der Akzentfarbe sein: `theme: (base: "atlas", accent: rgb("#d4572a"))`.

Theme-Schlüssel (Auswahl): `font` (`"serifenlos"`, `"klassisch"`,
`"libertinus"`, `"stix"`, ein Name oder `auto`), `math` (Matheschrift des
Dokuments – Typst kann sie nicht abfragen), `fill`, `field`, `field-stroke`,
`answer`, `task`, `accent`, `corner-mark` (`"arc"`, `"kite"`, `"triangle"`,
`"dot"`, `"ticks"`, `none`), `label` (`"field"`, `"plain"`, `"pill"`,
`"outline"`, `"tab"`), `tip`, `pips`, `wheel` (`auto`, `none` oder sechs
Farben), `head`, `back-style`, `wordmark`, `divider`, `shadow`, `chrome`,
`display`, `code`. Alle Schlüssel erklärt die Dokumentation.

Beschriftungen stehen standardmäßig in Fira Sans mit Fira Math (New Computer
Modern nur mit `font: "klassisch"` oder wenn das Dokument sie setzt). Die
Themes zu `@schule/arbeitsblatt` bringen ihre Schriften mit (Myriad Pro,
SF Pro Rounded und Playpen Sans, Fira Code, Helvetica Neue und Futura), Mathe
immer in Fira Math; fehlt eine, steht Fira Sans.

Drucken: 120–160 g/m², im Treiber „dickes Papier“ für Duplex, matt
laminieren (80–125 µm).

```typ
#import "@schule/trimino:0.5.0": domino

#domino(title: [Summenregel], tags: ([$f'(x)$], [$f(x)$]), pairs: (
  ([$x^5 + x^(-3)$], [$5x^4 - 3/x^4$]),
  ([$x^7 - x^3$], [$7x^6 - 3x^2$]),
  ([$x^2 + x^(-5)$], [$2x - 5/x^6$]),
))
```
