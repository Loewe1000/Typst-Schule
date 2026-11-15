// patterns 0.5.0: patterns.is-flex-area und aufgaben.internal.is-flex-area
// haben denselben Vertrag (zwei Fassungen, weil aufgaben kein @schule-Paket
// importiert): gleiche Antwort auf dieselben Eingaben.
// erwartet: Vertrag true
// erwartet: Antworten true false true false false false false true true
#import "@schule/patterns:0.5.0" as p
#import "@schule/aufgaben:0.5.0" as a
#let inputs = (
  p.kariert(1fr),
  p.kariert(4),
  p.liniert(2fr),
  p.liniert(1fr, items: ("a",)),
  [x],
  none,
  block(height: 2cm)[],
  block(height: 1fr)[],
  p.flex-area(1fr, height => []),
)
Vertrag #inputs.all(x => p.is-flex-area(x) == (a.internal.is-flex-area)(x))

Antworten #inputs.map(x => repr(p.is-flex-area(x))).join(" ")
