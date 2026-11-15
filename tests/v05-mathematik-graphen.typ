// mathematik 0.5.0: graphen mit Termen, Funktionen, Flächen, Punkten und Beschriftungen.
// erwartet: Graphen gesetzt
// erwartet: Scheitel
// erwartet: in m/s
// erwartet: 2,5
#import "@schule/mathematik:0.5.0": graphen
#import "@preview/cetz:0.4.2": draw

#graphen($f(x)=0,5 x^2 - 2$)
#graphen($x(x-2)$, $(x-1)(x+2)$, $|x| - 1$, $x sin(x)$)
#graphen($1/x$, $tan(x)$, domain: (-3, 3))
#graphen($x$, step: none, grid-lines: none)
#graphen(
  (term: x => x * x, accent: blue, domain: (0, 3), labels: ((x: 2, body: $f(x) = x^2$, position: "bottom-right"),)),
  (term: $0,5 x + 1$, stroke: (thickness: 2pt, dash: "dashed"), accent: red),
  domain: (x: (-1, 4), y: (-1, 10)),
  step: (x: (1, 0.5), y: 2),
  grid-lines: (x: "major"),
  labels: ([$t$ in s], [$v$ in m/s]),
  width: 10cm,
  height: 6cm,
  stroke: 2pt,
  sample-count: 100,
)
#graphen(
  $x^2 - 1$,
  $x$,
  domain: (x: (-3, 3), y: (-2, 6)),
  areas: (
    (term: $x^2 - 1$, domain: "intersections"),
    (between: ($x^2 - 1$, $x$), domain: (0, 1), fill: green.transparentize(60%)),
  ),
  marks: (
    (at: (0, -1), body: [Scheitel], position: "bottom-right"),
    (at: (1, 0)),
    (at: (-1, 0), body: [$N$], position: "top-left", distance: 3mm, symbol: "o", accent: red),
  ),
  annotations: { draw.line((0, 0), (2, 3), stroke: red) },
)
#graphen($x$, domain: (x: (0, 5), y: (0, 5)), step: 2.5)

Graphen gesetzt
