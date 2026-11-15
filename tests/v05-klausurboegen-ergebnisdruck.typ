// klausurboegen 0.5.0: Ergebnisdruck aus CSV-Zeilen. Sek II mit Teilaufgaben
// ("A1 a)" und "A3.1"), leere Zelle zählt 0, leere Zeile und leere Kopfspalte
// werden übersprungen; Sek I mit Notenwort und Ziffern-Muster (bleibt a/b);
// Vordruck: nur Werte sichtbar; Name zur Kontrolle.
// erwartet: 87,50 % ≙ 12 Punkte
// erwartet: 20,00 % ≙ 1 Punkt
// erwartet: Punktegrenze ≥
// erwartet: mögliche Punkte +3 +4 +5 +2 +6 +20
// erwartet: erreichte Punkte +3 +3,5 +4 +2 +5 +17,5
// erwartet: erreichte Punkte +1 +0 +2 +0 +1 +4
// erwartet: a\) +b\) +a\) +b\)
// erwartet: 87,50 % ≙ gut
// erwartet: Punktegrenzen +20 - 17,5
// erwartet: Kontrollname Cem
// erwartet: 75,00 % ≙ 9 Punkte
// erwartet: erreichte Punkte +3 +4,5 +7,5
// erwartet: Aufgabe +A1 +A2 +∑
// erwartet: 1 +2 +1 +2
// nicht: Name:
// nicht: Ergebnis:
#import "@schule/klausurboegen:0.5.0": klausurboegen

#let rows = (
  ("Name", "Note", "A1 a)", "A1 b)", "A2", "A3.1", "A3.2", ""),
  ("", "", "3", "4", "5", "2", "6", ""),
  ("Anna", "12", "3", "3.5", "4", "2", "5", ""),
  ("", "", "", "", "", "", "", ""),
  ("Ben", "1", "1", "", "2", "0", "1", ""),
)

#klausurboegen(title: "Physik", subtitle: "Wellen", class: "Q1", teacher: "MÜ", results: rows, overprint: true)

#klausurboegen(
  title: "Mathe",
  results: (rows.at(0), rows.at(1), ("Kontrollname Cem", "2", "3", "3.5", "4", "2", "5", "")),
  overprint: true,
  overprint-name: true,
  stage: "sek-1",
  subtask-numbering: "1.1",
  offset: (dx: 1mm, dy: -1mm),
)

// ohne Teilaufgaben
#klausurboegen(
  title: "Chemie",
  results: (("Name", "Note", "A1", "A2"), ("", "", "4", "6"), ("Eva", "9", "3", "4.5")),
  overprint: true,
)

// Ziffern für die Teilaufgaben; Vordruck: Tabellenrahmen bleibt unsichtbar
#klausurboegen(
  title: "Chemie",
  results: (("Name", "Note", "A1.1", "A1.2", "A2.1", "A2.2"), ("", "", "1", "1", "1", "1"), ("Eva", "9", "1", "0", "1", "1")),
  overprint: true,
  subtask-numbering: "1.1",
)
#klausurboegen(
  title: "Chemie",
  results: (("Name", "Note", "A1", "A2"), ("", "", "4", "6"), ("Eva", "9", "3", "4.5")),
  overprint: true,
  points-table-preprinted: true,
  continuation: true,
)
