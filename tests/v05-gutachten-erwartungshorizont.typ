// gutachten 0.5.0: der reparierte Erwartungshorizont aus `bewertung.typ` liegt in `internal` und kompiliert unter Typst 0.15.
// erwartet: Erwartungshorizont
// erwartet: Die Schülerin / Der Schüler
// erwartet: 1 Kinematik 10
// erwartet: … berechnet die Geschwindigkeit
// erwartet: 1\.2 … zeichnet das Diagramm 5
// erwartet: b\) … zeichnet das Diagramm 5
// erwartet: Insgesamt: 20
// erwartet: Bewertung
// erwartet: Aufgabe 1 1\.1 1\.2 2 Insgesamt:
// erwartet: Schwelle 19 18 17 16 15 14 13 12 11 10 9 8 6 5 4 0
// erwartet: Schwelle 17 14 11 8 4 0
// erwartet: berechnet die Geschwindigkeit \(4\)
#import "@schule/gutachten:0.5.0": internal

#internal.expectation-tasks.update((
  (task-number: 1, subtask-count: 2, title: "Kinematik"),
  (task-number: 2, subtask-count: 0, title: "Felder"),
))
#internal.expectations.update((
  (task-number: 1, subtask-number: 1, text: [berechnet die Geschwindigkeit], points: 4),
  (task-number: 1, subtask-number: 1, text: [nennt die Einheit], points: 1),
  (task-number: 1, subtask-number: 2, text: [zeichnet das Diagramm], points: 5),
  (task-number: 2, subtask-number: 0, text: [beschreibt das Feld], points: 10),
))

#internal.points-table()
#internal.grade-table()
#internal.grade-table(boundaries: internal.grade-boundaries-plain, names: internal.grade-names-plain)
#internal.expectation-entries(1, subtask-number: 1)
#internal.expectations-sek-2()
#internal.expectations-sek-1()
