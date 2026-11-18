#import "@schule/schuldocs:0.3.1": info, show-code, show-module, tip, warning

= Über dieses Paket

Ein *Trimino* ist ein Legespiel aus dreieckigen Kärtchen. An jeder inneren
Kante der fertigen Figur treffen eine Aufgabe und ihre Lösung aufeinander:
die Aufgabe auf dem einen Kärtchen, die Lösung auf dem Nachbarkärtchen.
Liegt alles richtig, entsteht die Figur. Das Spiel kontrolliert sich so
selbst.

`trimino` setzt zwei Teile:

- das *Lösungsbild*: die fertige Figur mit allen Beschriftungen, für die Lehrkraft
- den *Schnittbogen*: dieselben Kärtchen gemischt und gedreht, zum Ausschneiden

Jede Beschriftung steht vom Inneren ihres Kärtchens aus gesehen aufrecht.
Auf dem Schnittbogen ist darum keine Kante bevorzugt.

= Schnellstart

#show-code(```typ
#import "@schule/trimino:0.5.0": trimino

#set page(paper: "a4", margin: 1.5cm)

#trimino(title: [Einmaleins], pairs: (
  ([3 · 4], [12]), ([6 · 7], [42]), ([8 · 8], [64]),
  ([9 · 3], [27]), ([7 · 5], [35]), ([4 · 9], [36]),
))
```)

Sechs Paare ergeben ein Sechseck aus sechs Kärtchen. Auf der ersten Seite
steht das Lösungsbild, danach der Schnittbogen.

= Formen

Jede innere Kante trägt genau ein Paar. Eine Form passt deshalb nur, wenn sie
so viele innere Kanten hat, wie es Paare gibt. Mit `shape: auto` probiert das
Paket die Formen in dieser Reihenfolge und nimmt die erste, die passt:

#table(columns: 4, inset: 6pt, stroke: 0.5pt + luma(70%),
  [*Form*], [*`shape`*], [*`shape-size`*], [*Paare (Kärtchen)*],
  [Dreieck], [`"triangle"`], [Kärtchen je Seite: 2, 3, 4, 5], [3 (4), 9 (9), 18 (16), 30 (25)],
  [Sechseck], [`"hexagon"`], [Kärtchen je Seite: 1, 2], [6 (6), 30 (24)],
  [Stern], [`"star"`], [1, 2], [12 (12), 60 (48)],
  [Raute], [`"rhombus"`], [`(Breite, Höhe)`], [8 (8), 13 (12), 18 (16), 21 (18), …],
  [Trapez], [`"trapezoid"`], [`(Seite, abgeschnittene Spitze)`], [8 (8), 13 (12), 17 (15), 18 (16), …],
  [Streifen], [`"strip"`], [Zahl der Kärtchen], [jede Zahl: $n - 1$ Paare bei $n$ Kärtchen],
)

Der Streifen passt immer und ist deshalb die letzte Möglichkeit. Welche
Formen es für eine Paarzahl gibt, liefert `trimino-shapes`:

#show-code(```typ
#import "@schule/trimino:0.5.0": trimino-shapes
#for e in trimino-shapes(13) [
  #e.shape #repr(e.shape-size): #e.cards Kärtchen \
]
```)

#tip[Für die Klasse eignen sich 9 Paare (Dreieck), 12 Paare (Stern) oder
18 Paare (großes Dreieck). Wer eine andere Zahl hat, ergänzt ein Paar oder
streicht eines, statt beim Streifen zu landen.]

= Ablenker

Die Außenkanten bleiben leer. Dadurch erkennt man Randkärtchen leicht. Mit
`distractors` stehen dort falsche Ergebnisse, die nirgends passen:

```typ
#trimino(pairs: paare, distractors: ([48], [0,5], [120 %]))
```

= Mischen

`seed` legt fest, wie Paare auf Kanten verteilt und Kärtchen gemischt
werden. Dieselbe Zahl liefert dasselbe Spiel; eine andere Zahl ein neues mit
denselben Paaren, etwa für eine zweite Gruppe.

#info[Die kleine graue Zahl in der Mitte ist die Kärtchennummer. Sie steht
auf Lösungsbild und Schnittbogen gleich und hilft beim Kontrollieren. Mit
`number: false` verschwindet sie.]

= API-Referenz

#show-module(read("../src/trimino.typ"), name: "trimino")
