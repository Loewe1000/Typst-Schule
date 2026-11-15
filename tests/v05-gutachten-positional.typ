// gutachten 0.5.0: die erreichten Punkte stehen nur in `points:`; die alte Schreibweise bricht mit Abhilfe ab.
// fehler: gutachten.aufgabe: 2 Positionsargumente, erlaubt ist höchstens 1 – die erreichten Punkte benannt schreiben: `aufgabe("Aufgabe 1", points: 24)[...]`
#import "@schule/gutachten:0.5.0": *

#set-options(subject: "Physik", level: "E", teacher: "MS", max-points: 100, year: 2027)
#set-tasks(("Aufgabe 1": (max-points: 30)))

#gutachten(first-name: "Anna", last-name: "Bauer")[
  #aufgabe("Aufgabe 1", 24)[Text]
]
