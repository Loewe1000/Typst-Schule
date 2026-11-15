// page-counter: none – keine Seitenzahlen; name-field: none – kein Namensfeld.
// erwartet: Aufgabe 1
// nicht: Seite 1
// nicht: Name:
#import "@schule/klassenarbeit:0.5.0": *
#show: klassenarbeit.with(title: [K], page-counter: none, name-field: none, logo: none, expectations: false)
#aufgabe[A]
