// gutachten 0.5.0: ohne `points` bricht `aufgabe` mit Abhilfe ab.
// fehler: gutachten.aufgabe: `points` fehlt – die erreichten Punkte angeben: `aufgabe("Aufgabe 1", points: 24)[...]`
#import "@schule/gutachten:0.5.0": *

#set-options(subject: "Physik", level: "E", teacher: "MS", max-points: 100, year: 2027)
#set-tasks(("Aufgabe 1": (max-points: 30)))

#gutachten(first-name: "Anna", last-name: "Bauer")[
  #aufgabe("Aufgabe 1")[Text]
]
