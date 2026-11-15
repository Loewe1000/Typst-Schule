// Ein Theme gestaltet die Aufgaben; Kopf und Seitenzahl bleiben die der Klassenarbeit.
// erwartet: Teil A
// erwartet: MA-09 - SLZ
// erwartet: Seite 1 von 1
// erwartet: Rechnen
#import "@schule/klassenarbeit:0.5.0": *
#show: klassenarbeit.with(title: "Teil A", class: "MA-09", teacher: "SLZ", theme: "klar", accent: red, expectations: false)
#aufgabe(title: [Rechnen])[Text #tip[Tipp]]
