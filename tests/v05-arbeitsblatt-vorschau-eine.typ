// `preview-variant: "solutions"` setzt genau die Lösungsfassung; ohne Angabe erscheint keine Lösung.
// erwartet: Lösung 1
// nicht: Aufgabe 1
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(title: [V], preview-variant: "solutions")
#aufgabe(title: [Erste])[Rechne. #loesung[42]]
