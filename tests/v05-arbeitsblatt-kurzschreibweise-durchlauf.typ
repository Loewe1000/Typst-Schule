// Kurzschreibweise `shortcodes: "all"` mit Material (Messwerttabelle) und flexibler
// Fläche: die Überschrift wird schon im ersten Durchlauf zur Aufgabe
// (Wert aus dem Vorlagenaufruf), `set-options(shortcodes: …)` wirkt danach.
// erwartet: Aufgabe 1 − Kurzschreibweise
// erwartet: Aufgabe 2 − Steigung 3 BE
// erwartet: M2-A
// erwartet: Später
// nicht: Aufgabe 3
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(title: [Q], class: "MA-08", points: "all", shortcodes: "all")
= Kurzschreibweise
#aufgabe(title: [Steigung])[
  Gegeben.
  #material(caption: [Wertetabelle])[MATERIALTEXT #messwerttabelle(
    datensatz((0, 1, 2, 3), name: "Zeit", unit: "s"),
  )]
  #teilaufgabe(workspace: kariert(1fr))[Skizziere. #erwartung(3)[Skizze]]
]
#set-options(shortcodes: none)
= Später
