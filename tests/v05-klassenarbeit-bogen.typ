// Arbeit direkt auf dem Klausurbogen; die Aufgabe der Rückseite ist die letzte.
// erwartet: Aufgabe 3 − Rückseite 7 BE
// erwartet: Aufgabe 1 − Eins 5 BE
// erwartet: Ergebnis:
// erwartet: Bitte frei lassen
// nicht: Erwartungshorizont
// nicht: Seite 1 von
#import "@schule/klassenarbeit:0.5.0": *
#show: klassenarbeit.with(
  title: [Auf dem Bogen], class: [9a], date: [1.2.2026], teacher: [MÜ],
  points: "all",
  answer-sheet-pages: (stage: "sek-1", back-page-tasks: [
    #aufgabe(title: [Rückseite])[Letzte Aufgabe #erwartung(7)[r]]
  ]),
)
#aufgabe(title: [Eins])[
  #teilaufgabe[a #erwartung(1)[x]]
  #teilaufgabe[b #erwartung(4)[y]]
]
#aufgabe(title: [Zwei])[Text #erwartung(2)[z]]
