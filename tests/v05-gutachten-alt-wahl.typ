// gutachten 0.5.0: `wahl` heißt jetzt `selected-tasks`, auch über `.with`.
// fehler: gutachten.gutachten: `wahl` heißt jetzt `selected-tasks`
#import "@schule/gutachten:0.5.0": *

#set-options(subject: "Physik", level: "E", teacher: "MS", max-points: 100, year: 2027)
#set-tasks(("Aufgabe 1": (max-points: 30)))

#show: gutachten.with(wahl: ("Aufgabe 1",))

Text
