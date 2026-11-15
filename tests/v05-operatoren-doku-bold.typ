// operatoren 0.5.0: Handbuch-Beispiel „Fettdruck im ganzen Dokument" (dort
// nur als Code).
// erwartet: Berechne die Masse
// erwartet: berechnen +die Berechnung ist ausgehend
// erwartet: fett: 2
#import "@schule/operatoren:0.5.0": operator, operatoren-liste

#operator("berechnen", caption: [Berechne]) die Masse.

#operatoren-liste(subject: "Physik", bold: true)

#context [fett: #query(strong).len()]
