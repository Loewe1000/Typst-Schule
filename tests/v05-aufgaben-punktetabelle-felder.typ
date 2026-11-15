// possible: "fields" lässt die Zeile leer, none lässt sie weg; subtotals zeigt die Zwischensumme.
// erwartet: mögliche Punkte *$
// nicht: mögl\. *\n?Punkte +[0-9]
// erwartet: erreichte Punkte
#import "@schule/aufgaben:0.5.0": *
#aufgabe(title: [A])[#teilaufgabe[a #erwartung(3)[aa]] #teilaufgabe[b #erwartung(4)[bb]]]
#show-points-table(possible: "fields")
#show-points-table(possible: none, subtotals: true)
