// mathematik 0.5.0: der Radius ohne Einheit wird die Breite als Länge.
// fehler: mathematik.kreisdiagramm: `radius: 3.5` heißt jetzt `width: 7cm`
#import "@schule/mathematik:0.5.0": *

#kreisdiagramm((("A", 1), ("B", 2)), radius: 3.5)
