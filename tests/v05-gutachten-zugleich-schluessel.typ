// gutachten 0.5.0: alter und neuer Schlüssel zugleich.
// fehler: gutachten.set-tasks: `be` (alt) und `max-points` (neu) zugleich – nur `max-points` schreiben
#import "@schule/gutachten:0.5.0": *

#set-tasks(("A": (be: 10, max-points: 10)))
