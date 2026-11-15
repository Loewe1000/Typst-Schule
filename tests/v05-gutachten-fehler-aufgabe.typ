// gutachten 0.5.0: eine Aufgabe, die nicht in `set-tasks` steht, bricht deutsch ab.
// fehler: gutachten.aufgabe: unbekannte Aufgabe `Aufgabe 9` – in `set-tasks` eintragen; bekannt: `Aufgabe 1`
#import "@schule/gutachten:0.5.0": *

#set-options(subject: "Physik", level: "E", teacher: "MS", max-points: 100, year: 2027)
#set-tasks(("Aufgabe 1": (max-points: 30)))

#gutachten(first-name: "Anna", last-name: "Bauer")[
  #aufgabe("Aufgabe 9", points: 24)[Text]
]
