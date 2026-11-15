// gutachten 0.5.0: Ganz ohne Fach, Niveau und Kürzel steht im Kopf „() -“ wie in 0.0.2.
// erwartet: Abitur 2027
// erwartet: Max Mustermann \(\) -$
// nicht: none
#import "@schule/gutachten:0.5.0": *

#set-options(max-points: 10, year: 2027)
#set-tasks(("A": (max-points: 10)))

#gutachten[#aufgabe("A", points: 5)[x]]
