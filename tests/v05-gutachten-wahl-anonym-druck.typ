// gutachten 0.5.0: `selected-tasks` als Array und als Dictionary, `anonymous` und `print`.
// erwartet: Schüler wählt Aufgabe 2: Elektrisches Feld und Aufgabe 3\.
// erwartet: Schüler wählt im Pflichtteil Aufgabe 1 und im Wahlteil Aufgabe 2: Elektrisches Feld und Aufgabe 3\.
// erwartet: In Aufgabe 3 erreicht Schüler insgesamt 15 von 30 Bewertungseinheiten
// erwartet: Schüler rechnet richtig
// erwartet: \(\) -
// nicht: Anna
// nicht: Bauer
// nicht: Mit Korrektur und Bewertung einverstanden
#import "@schule/gutachten:0.5.0": set-options, set-tasks, gutachten, aufgabe, name

#set-options(anonymous: true, print: true, max-points: 100)

#set-tasks((
  "Aufgabe 1": (max-points: 30),
  "Aufgabe 2": (max-points: 40, title: "Elektrisches Feld"),
  "Aufgabe 3": (max-points: 30),
))

#gutachten(first-name: "Anna", last-name: "Bauer", selected-tasks: ("Aufgabe 2", "Aufgabe 3"))[
  #aufgabe("Aufgabe 3", points: 15)[#name rechnet richtig.]
]

#gutachten(
  first-name: "Anna",
  last-name: "Bauer-Zwei",
  selected-tasks: ("Pflichtteil": ("Aufgabe 1",), "Wahlteil": ("Aufgabe 2", "Aufgabe 3")),
)[
  #aufgabe("Aufgabe 1", points: 12)[Teilweise richtig.]
]
