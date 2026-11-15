// patterns 0.5.0: kariert und liniert mit den neuen Namen (Zeilenzahl vorn,
// columns/width, height, item-rows, overlay, stroke, fill).
// erwartet: Messung 1
// erwartet: Messung 3
// erwartet: Rechne hier
// erwartet: Name:
// erwartet: Datum:
// erwartet: Ende
#import "@schule/patterns:0.5.0": kariert, liniert
#import "@preview/cetz:0.4.2": draw
#kariert()
#kariert(5)
#kariert(height: 3cm)
#kariert(2, width: 5cm)
#kariert(4, columns: 12, grid-size: 1cm, fill: none, stroke: (paint: blue, thickness: 1pt))
#kariert(items: ("Messung 1", "Messung 2", "Messung 3"), item-rows: 3)
#kariert(6, overlay: [Rechne hier], width: 8cm)
#kariert(4, annotations: draw.circle((3, 2), radius: 1))
#liniert()
#liniert(4)
#liniert(3, line-height: 1.5cm, width: 6cm, stroke: red)
#liniert(items: ("Name:", "Klasse:", "Datum:"), item-rows: 2)
Ende
