// Kopf, Namensfeld, Info-Tabelle, Punkte, Seitenzahl und Erwartungshorizont.
// erwartet: Klassenarbeit Nr\. 2
// erwartet: Quadratische Funktionen
// erwartet: 9a - MÜ
// erwartet: Name: Mia Schneider
// erwartet: Hilfsmittel: Taschenrechner
// erwartet: Aufgabe 1 − Nullstellen 6 BE
// erwartet: \[3 BE\]
// erwartet: Seite 1 von 1
// erwartet: Erwartungshorizont
// erwartet: Summe / ?6
// nicht: x_1 = 2
#import "@schule/klassenarbeit:0.5.0": *

#show: klassenarbeit.with(
  title: [Klassenarbeit Nr. 2],
  subtitle: [Quadratische Funktionen],
  class: [9a],
  date: [15.03.2026],
  teacher: [MÜ],
  student: "Mia Schneider",
  info-table: (([Hilfsmittel], [Taschenrechner]), ([Zeit], [45 Minuten])),
  points: "all",
  expectations: (achieved: true),
)

#aufgabe(title: [Nullstellen])[
  Gegeben ist $f(x) = x^2 - 5x + 6$.
  #teilaufgabe[
    Bestimme die Nullstellen.
    #erwartung(3)[beide Nullstellen berechnet]
    #loesung[x_1 = 2]
  ]
  #teilaufgabe[
    Skizziere den Graphen.
    #erwartung(3)[Parabel]
  ]
]
