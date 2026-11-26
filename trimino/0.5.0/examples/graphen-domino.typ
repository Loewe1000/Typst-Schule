// Graphen-Domino: Funktion f ↔ Ableitung f′ als Kette. Die Kurven stehen in
// Tinte – Farbe gehört zum Rahmen (Lösung rot und rund, Aufgabe blau und
// eckig), nicht zum Inhalt. Für Graphen mindestens `side: 4cm`.
#import "@schule/trimino:0.5.0": domino
#import "@preview/cetz:0.4.2"

#set page(paper: "a4", margin: 1.5cm)
#set text(lang: "de")

#let graph(f) = cetz.canvas(length: 0.28cm, {
  import cetz.draw: *
  grid((0, -4), (10, 4), step: 1, stroke: 0.4pt + luma(72%))
  line((0, 0), (10.4, 0), mark: (end: ">", fill: black, scale: 1.4), stroke: 0.8pt)
  line((0, -4), (0, 4.4), mark: (end: ">", fill: black, scale: 1.4), stroke: 0.8pt)
  line(..range(101).map(i => (i / 10, calc.max(-4, calc.min(4, f(i / 10))))), stroke: 1.6pt + rgb("#1a1a1a"))
})

#let fs = (
  (x => 0.1 * calc.pow(x - 5, 2) - 2, x => 0.2 * (x - 5)),
  (x => 2 * calc.sin(x / 1.6), x => 1.25 * calc.cos(x / 1.6)),
  (x => -0.3 * x + 2, x => -0.3),
  (x => 0.02 * calc.pow(x - 5, 3), x => 0.06 * calc.pow(x - 5, 2)),
  (x => 3 - 0.1 * calc.pow(x - 4, 2), x => -0.2 * (x - 4)),
  (x => calc.exp(0.3 * x) / 6 - 2, x => 0.05 * calc.exp(0.3 * x)),
)

#domino(
  title: [Änderungsgraphen zuordnen],
  side: 4cm,
  tags: ([$f'$], [$f$]),
  back: [*Graphisches Ableiten*],
  pairs: fs.map(((f, d)) => (graph(f), graph(d))),
)
