// klausurboegen 0.5.0: Arbeit direkt auf dem Bogen (Ast 0.0.4, jetzt intern;
// Dokumente erreichen sie über klassenarbeit). Kopf, Platzhalter für die
// Tabelle, Rückseite, Seitenzahlen; Rückgabe-Schlüssel page, gutter, preamble.
// erwartet: Klassenarbeit 1
// erwartet: Brüche
// erwartet: Name:
// erwartet: Bitte frei lassen
// erwartet: Platz für Nebenrechnungen
// erwartet: Erste Aufgabe
// erwartet: Schlüssel: gutter, page, preamble
// erwartet: Abstand 28 mm: true
// nicht: passt nicht auf einen Klausurbogen
#import "@schule/klausurboegen:0.5.0": internal

#let pages = internal.answer-sheet-pages(margin: 14mm)
#show: internal.exam-on-sheet.with(
  title: "Klassenarbeit 1",
  subtitle: "Brüche",
  class: "5a",
  date: "01.10.2026",
  teacher: "SLZ",
  stage: "sek-1",
  task-points: (("A1", (3, 4)), ("A2", 5)),
  margin: (top: 14mm),
  header-spacing: 6mm,
)

Erste Aufgabe

Schlüssel: #pages.keys().sorted().join(", ")

Abstand 28 mm: #(pages.gutter == 28mm)
