// Ohne Einheit wählt `prefix: auto` weiter einen Vorsatz, der dann allein im
// Kopf steht (wie in 0.0.2 mit `einheit: ""`): gleiches Dokument, gleiches PDF.
// erwartet: n in m 1 2 3
// erwartet: D in m 1 2
// nicht: 0,00
#import "@schule/physik:0.5.0": datensatz, berechnung, messwerttabelle
#let a = datensatz((1, 2, 3), name: "A", unit: "s")
#let n = berechnung(x => x * 0.001, datasets: (a,), name: "n")
#messwerttabelle(a, n)
#let d = datensatz((0.001, 0.002), name: "D", prefix: auto)
#messwerttabelle(d)
