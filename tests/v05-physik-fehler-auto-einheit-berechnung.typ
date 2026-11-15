// physik 0.5.0: bei berechnung war `auto-einheit: true` die Vorgabe, `false` ist `prefix: none`.
// fehler: physik.berechnung: `auto-einheit: false` heißt jetzt `prefix: none`
#import "@schule/physik:0.5.0": datensatz, berechnung

#let t = datensatz((1, 2), name: "Zeit", unit: "s")
#berechnung(t => 2 * t, datasets: (t,), name: "Weg", unit: "m", auto-einheit: false)
