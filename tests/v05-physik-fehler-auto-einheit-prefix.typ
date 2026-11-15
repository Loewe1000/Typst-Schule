// physik 0.5.0: neben einem gesetzten `prefix` wird `auto-einheit` nur gelöscht.
// fehler: physik.datensatz: `auto-einheit: true` gibt es nicht mehr – Argument löschen, das gesetzte `prefix` gilt
#import "@schule/physik:0.5.0": datensatz

#datensatz((1, 2), name: "Weg", unit: "m", auto-einheit: true, prefix: "k")
