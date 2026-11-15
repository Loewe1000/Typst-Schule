// physik 0.5.0: datensatz, messdaten, berechnung und messwerttabelle mit den
// neuen Namen; Vorsätze, Stellenzahl, Teilung und Kopfzeile.
// erwartet: Zeit in s 0 1 2 3
// erwartet: Weg in m 0,0 1,2 4,8 10,8
// erwartet: I in mA 1,2 4,7
// erwartet: U in kV 1,5 3,0
// erwartet: f in 1014 Hz 5,2 6,1
// erwartet: R in Ω 100 220
// erwartet: Zeit² in s² 0 1
// erwartet: Zeit² in s² 4 9
// erwartet: P in W 1,80 14,10
// erwartet: A B
// erwartet: Druck in hPa
#import "@schule/physik:0.5.0": berechnung, datensatz, messdaten, messwerttabelle

#let t = datensatz((0, 1, 2, 3), name: "Zeit", unit: "s")
#let s = datensatz((0, 1.2, 4.8, 10.8), name: "Weg", unit: "m", digits: 1)
#messwerttabelle(t, s)

#let i = datensatz((0.0012, 0.0047), name: "I", unit: "A", prefix: auto)
#let u = datensatz((1.5, 3.0), name: "U", unit: "V", prefix: "k")
#let f = datensatz((5.2, 6.1), name: "f", unit: "Hz", prefix: "e14")
#let r = datensatz((100, 220), name: "R", unit: "ohm")
#messwerttabelle(i, u, f, r, digits: 1, header: ([A], [B]))

#let t2 = berechnung(t => t * t, datasets: (t,), name: "Zeit²", unit: "s²")
#let p = berechnung((u, i) => u * i, datasets: (u, i), name: "P", unit: "W", prefix: none)
#messwerttabelle(t, t2, count: 2)
#messwerttabelle(p)

// leere Messreihen, auch als Eingabe einer Berechnung
#let leer = messdaten(3, name: "Druck", unit: "hPa")
#messwerttabelle(leer, berechnung(x => 2 * x, datasets: (leer,), name: "doppelt", unit: [Pa]), row-height: 8mm)
