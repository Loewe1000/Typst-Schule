// gutachten 0.5.0: `vorname` heißt jetzt `first-name`.
// fehler: gutachten.gutachten: `vorname` heißt jetzt `first-name`
#import "@schule/gutachten:0.5.0": *

#set-options(subject: "Physik", level: "E", teacher: "MS", max-points: 100, year: 2027)
#set-tasks(("Aufgabe 1": (max-points: 30)))

#gutachten(vorname: "Anna", nachname: "Bauer")[Text]
