// Die Fassung "answer-sheets": nur die Bögen, Kopf aus der Klassenarbeit.
// erwartet: Physik
// erwartet: Q1 - MÜ
// erwartet: Ergebnis:
// nicht: Aufgabe 1
#import "@schule/klassenarbeit:0.5.0": *
#show: klassenarbeit.with(
  title: [Physik], subtitle: [Wellen], class: [Q1], teacher: [MÜ], date: [1.2.2026],
  answer-sheets: (pattern: "lines", correction-margin-side: "inside", stage: "sek-1"),
  preview-variant: "answer-sheets",
)
#aufgabe[Nicht auf dem Bogen]
