// operatoren 0.5.0: Operatoren markieren, Operatorenliste mit Definitionen,
// sortiert und ohne Dopplung; der Link führt zur Zeile des Operators.
// erwartet: Berechne die Geschwindigkeit
// erwartet: Schätzen Sie ab
// erwartet: Operatorenliste
// erwartet: abschätzen +durch begründete Überlegungen
// erwartet: berechnen +die Berechnung ist ausgehend
// erwartet: Links: 3, Ziel Liste: 1, Ziel abschaetzen: 1
// nicht: zeichnen
#import "@schule/operatoren:0.5.0": operator, operatoren-liste

#operator("berechnen", caption: [Berechne]) die Geschwindigkeit.
#operator("abschätzen", caption: "Schätzen Sie ab"), wie lange es dauert.
Noch einmal #operator("Berechnen", bold: true).

#operatoren-liste(subject: "Physik", bold: true)

#context [Links: #query(link).len(), Ziel Liste: #query(<schule-operatoren-overview>).len(),
  Ziel abschaetzen: #query(<schule-operatoren-abschaetzen>).len()]
