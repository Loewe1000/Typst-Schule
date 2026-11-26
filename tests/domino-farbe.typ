// Ein Ton je Satz (riso), feste Farbe mit `color`, jedes Kärtchen anders mit fill: "tint".
#import "@schule/trimino:0.5.0": trimino, domino
#set page(paper: "a4", margin: 1.5cm)
#let paare = range(6).map(i => ([#(i + 2) · 4], [#((i + 2) * 4)]))
#domino(pairs: paare, seed: 3)
#domino(pairs: paare, color: rgb("#dfe7fd"), layout: "stack")
#trimino(pairs: paare, color: rgb("#fff1c1"), theme: "skizze")
#trimino(pairs: paare, theme: (fill: "tint"))
