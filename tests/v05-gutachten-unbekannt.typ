// gutachten 0.5.0: ein unbekannter Parameter bekommt einen Vorschlag.
// fehler: gutachten.gutachten: unbekannter Parameter `vornam` – meintest du `first-name`?
#import "@schule/gutachten:0.5.0": *

#set-options(subject: "Physik", level: "E", teacher: "MS", max-points: 100, year: 2027)
#set-tasks(("Aufgabe 1": (max-points: 30)))

#gutachten(vornam: "Anna")[Text]
