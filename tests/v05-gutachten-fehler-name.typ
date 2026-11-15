// gutachten 0.5.0: `name` gilt nur innerhalb eines Gutachtens.
// fehler: gutachten.name: steht außerhalb eines Gutachtens – nur innerhalb von `gutachten(...)[...]` verwenden
#import "@schule/gutachten:0.5.0": *

#set-options(subject: "Physik", level: "E", teacher: "MS", max-points: 100, year: 2027)
#set-tasks(("Aufgabe 1": (max-points: 30)))

#name
