// mathematik 0.5.0: Messreihen aus physik 0.5.0 und als Zahlenreihen; der Vorsatz wird eingerechnet.
// erwartet: in s
// erwartet: in m
// erwartet: in A
// erwartet: 4000
// erwartet: 0,035
#import "@schule/mathematik:0.5.0": graphen
#import "@schule/physik:0.5.0": datensatz, messdaten

#let t = datensatz((0, 1, 2, 3, 4), name: $t$, unit: "s")
#let s = datensatz((0, 5, 20, 45, 80), name: $s$, unit: "m")
#let s2 = datensatz((0, 3, 12, none, 48), name: $s$, unit: "m")
#graphen(datasets: ((x: t, y: s),), width: 10cm, height: 6cm)
#graphen(
  x => 5 * x * x,
  datasets: (
    (x: t, y: s, symbol: "o", accent: blue),
    (x: t, y: s2, symbol: "square", fill: white, stroke: red + 1pt),
  ),
  width: 10cm,
  height: 6cm,
)
#graphen(datasets: ((x: (0, 1, 2, 3, 4), y: (0, 1, 4, 9, 16)),), width: 6cm, height: 6cm)

// Werte in kV, Achse in V: 4 kV erscheinen als 4000
#let u = datensatz((1, 2, 3, 4), name: $U$, unit: "V", prefix: "k")
#let i = datensatz((1, 2, 3, 4), name: $I$, unit: "A")
#graphen(datasets: ((x: i, y: u),), step: (x: 1, y: 1000), width: 6cm, height: 6cm)

// Werte in mA, Achse in A: kleine Zahlen bekommen genug Nachkommastellen (0,035 statt zweimal 0,04)
#let i-milli = datensatz((0, 10, 20, 30, 40), name: $I$, unit: "A", prefix: "m")
#let u-volt = datensatz((0, 1, 2, 3, 4), name: $U$, unit: "V")
#graphen(datasets: ((x: u-volt, y: i-milli),), width: 8cm, height: 5cm)

// Fläche ohne `domain` neben Messreihen und `accent` neben einer Farbe im Strich
#graphen(
  (term: $x$, stroke: (paint: red, thickness: 3pt), accent: blue),
  datasets: ((x: (0, 2, 4, 6, 8, 10), y: (0, 2, 4, 6, 8, 10)),),
  areas: ((term: $x$), (between: ($x$, $x^2 / 4$), domain: "intersections")),
  width: 8cm,
  height: 8cm,
)

// leere Zellen aus messdaten werden übersprungen
#graphen(datasets: ((x: t, y: messdaten(5, name: $s$, unit: "m")),))
