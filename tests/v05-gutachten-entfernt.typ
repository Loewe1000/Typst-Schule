// gutachten 0.5.0: ein Parameter aus 0.0.1 nennt, wo die Angabe jetzt steht.
// fehler: gutachten.gutachten: `geschlecht` gibt es nicht mehr – seit 0.0.2 nennt das Gutachten den Vornamen ohne Anrede; Angabe streichen
#import "@schule/gutachten:0.5.0": *

#set-options(subject: "Physik", level: "E", teacher: "MS", max-points: 100, year: 2027)
#set-tasks(("Aufgabe 1": (max-points: 30)))

#gutachten(first-name: "Thomas", geschlecht: "m")[Text]
