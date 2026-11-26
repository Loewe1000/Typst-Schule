// Zeichen für das Handbuch: ein Trimino-Dreieck neben einem Dominostein.
#set page(width: auto, height: auto, margin: 0pt, fill: none)
#import "@preview/cetz:0.4.2"
#cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let h = calc.sqrt(3) / 2
  line((0, 0), (1, 0), (0.5, h), close: true, fill: rgb("#fde2e4"), stroke: 1.4pt + luma(25%))
  for (p, c) in (((0, 0), rgb("#d62839")), ((1, 0), rgb("#1d5fa8")), ((0.5, h), rgb("#c99a06"))) {
    circle(p, radius: 0.16, fill: c, stroke: none)
  }
  line((0, 0), (1, 0), (0.5, h), close: true, fill: none, stroke: 1.4pt + luma(25%))
  rect((1.35, 0), (2.95, 0.8), radius: 0.08, fill: rgb("#dfe7fd"), stroke: 1.4pt + luma(25%))
  line((2.15, 0.12), (2.15, 0.68), stroke: (paint: luma(25%), thickness: 1pt, dash: "dotted"))
  rect((1.48, 0.13), (2.02, 0.67), radius: 0.06, stroke: 1.2pt + rgb("#d62839"))
  rect((2.28, 0.13), (2.82, 0.67), stroke: 1.8pt + rgb("#1d5fa8"))
})
