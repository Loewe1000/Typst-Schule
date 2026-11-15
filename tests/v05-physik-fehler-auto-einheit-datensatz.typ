// physik 0.5.0: die Abhilfe für `auto-einheit` hängt vom Wert ab (false war die Vorgabe von datensatz).
// fehler: physik.datensatz: `auto-einheit: false` gibt es nicht mehr – Argument löschen, `prefix: none` ist die Vorgabe
#import "@schule/physik:0.5.0": datensatz

#datensatz((1, 2), name: "Zeit", unit: "s", auto-einheit: false)
