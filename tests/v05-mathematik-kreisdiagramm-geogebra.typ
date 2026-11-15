// mathematik 0.5.0: kreisdiagramm und die GeoGebra-Funktionen.
// erwartet: 35%
// erwartet: Kirschen
// erwartet: ohne Legende gesetzt
// erwartet: P = \(3, 1, −3\)
#import "@schule/mathematik:0.5.0": kreisdiagramm, geogebra-algebra, geogebra-cell, geogebra-style

#let items = (("Äpfel", 35), ("Birnen", 45), ("Kirschen", 20))
#kreisdiagramm(items)
#kreisdiagramm(items, legend-position: "bottom", text-fill: white, percent: false, width: 7cm)
#kreisdiagramm(items, legend-position: "left", labeled: false, accents: (red, green, blue), stroke: white + 2pt)
#kreisdiagramm(items, legend: false)
ohne Legende gesetzt

#geogebra-algebra($v = vec(2, 1, 5)$, $u = vec(1, -1, 3)$, $P = (3, 1, -3)$)
#geogebra-algebra($a = 2$, $b = 3$, approximate-last: true, columns: 2, stroke: blue + 1pt, inset: 1em)
#geogebra-style[$g(t) = v + t u$]
#geogebra-cell(approximate: true)[$f(x) = x^2$]
#geogebra-cell($f(x) = x^2$, menu: false)
