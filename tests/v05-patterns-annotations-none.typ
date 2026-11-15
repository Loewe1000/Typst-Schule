// patterns 0.5.0: ein Zeichenblock ohne Elemente (none) und stroke: auto
// laufen wie in 0.0.2 und zeichnen das Feld unverändert.
// erwartet: Leer A
// erwartet: Bedingt B
// erwartet: Ende
#import "@schule/patterns:0.5.0": kariert, liniert
#import "@preview/cetz:0.4.2": draw
#kariert(3, annotations: none, items: ("Leer A",))
#kariert(3, annotations: {})
#kariert(3, items: ("Bedingt B",), annotations: {
  if false { draw.circle((1, 1)) }
})
#kariert(2, stroke: auto)
#liniert(2, stroke: auto)
#liniert(1fr, stroke: auto)
Ende
