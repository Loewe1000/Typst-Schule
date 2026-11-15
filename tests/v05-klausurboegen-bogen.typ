// klausurboegen 0.5.0: leerer Bogen mit Kopf (kariert, Korrekturrand außen),
// Blankobogen ohne Titel, linierter Bogen mit Rand innen, Folgebogen.
// erwartet: Physik
// erwartet: Schwingungen und Wellen
// erwartet: 15\.05\.2026
// erwartet: Q1 - MÜ
// erwartet: Name:
// erwartet: Ergebnis:
// erwartet: Deutsch
// erwartet: Vorschlag A:
// nicht: Punktegrenze
// nicht: erreichte Punkte
#import "@schule/klausurboegen:0.5.0": klausurboegen

#klausurboegen()

#klausurboegen(
  title: "Physik",
  subtitle: "Schwingungen und Wellen",
  teacher: "MÜ",
  class: "Q1",
  date: "15.05.2026",
)

#klausurboegen(
  title: [Deutsch],
  class: "10a",
  pattern: "lines",
  line-height: 9mm,
  correction-margin: 4cm,
  correction-margin-side: "inside",
  correction-margin-blank: false,
  correction-margin-stroke: 1pt + blue,
  logo: none,
)

#klausurboegen(
  title: "Physik",
  continuation: true,
  points-table: false,
  proposal: "Vorschlag A",
  grid-size: 0.6cm,
)
