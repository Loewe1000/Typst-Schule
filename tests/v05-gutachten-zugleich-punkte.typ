// gutachten 0.5.0: alter und neuer Name zugleich.
// fehler: gutachten.aufgabe: `punkte` (alt) und `points` (neu) zugleich – nur `points` schreiben
#import "@schule/gutachten:0.5.0": *

#set-options(max-points: 10)
#set-tasks(("A": (max-points: 10)))
#gutachten[#aufgabe("A", points: 5, punkte: 6)[x]]
