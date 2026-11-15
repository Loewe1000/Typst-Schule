// gutachten 0.5.0: Kopf, Aufgaben mit Punkten, Summe, Note und Seitenzahl je Gutachten.
// erwartet: Gutachten über die schriftliche Prüfung von
// erwartet: Anna Bauer
// erwartet: Abitur 2027
// erwartet: Physik \(E\) - MS
// erwartet: Anna beschreibt die Bewegung
// erwartet: In Aufgabe 1 erreicht Anna insgesamt 25 von 30 Bewertungseinheiten
// erwartet: In der zweiten Aufgabe erreicht Anna insgesamt 35,5 von 40 Bewertungseinheiten
// erwartet: In Aufgabe 3 erreicht Anna insgesamt 08 von 30 Bewertungseinheiten
// erwartet: Insgesamt erreicht der Prüfling 68,5 von 100 Bewertungseinheiten \(68,5%\)
// erwartet: befriedigend \(09 Punkte\)
// erwartet: Mit Korrektur und Bewertung einverstanden
// erwartet: Ort, Datum, Unterschrift
// erwartet: 1 von 1
// erwartet: Lena Braun
// erwartet: Insgesamt erreicht der Prüfling 30 von 100 Bewertungseinheiten \(30%\)
// erwartet: mangelhaft \(02 Punkte\)
// erwartet: Skala: sehr gut \(15 Punkte\), gut \(10 Punkte\), ausreichend \(06 Punkte\), ungenügend \(00 Punkte\)
#import "@schule/gutachten:0.5.0": set-options, set-tasks, gutachten, aufgabe, name, format-grade

#set-options(subject: "Physik", level: "E", teacher: "MS", max-points: 100, year: 2027)

#set-tasks((
  "Aufgabe 1": (max-points: 30),
  "Aufgabe 2": (max-points: 40, dative: "der zweiten Aufgabe"),
  "Aufgabe 3": (max-points: 30),
))

#gutachten(first-name: "Anna", last-name: "Bauer")[
  #aufgabe("Aufgabe 1", points: 25)[#name beschreibt die Bewegung korrekt.]
  #aufgabe("Aufgabe 2", points: 35.5)[Kleiner Rechenfehler in b).]
  #aufgabe("Aufgabe 3", points: 8)[Die Deutung fehlt.]
]

#gutachten(first-name: "Lena", last-name: "Braun")[
  #aufgabe("Aufgabe 1", points: 30)[Volle Punktzahl.]

  Skala: #format-grade(0.95), #format-grade(0.72), #format-grade(0.5), #format-grade(0)
]
