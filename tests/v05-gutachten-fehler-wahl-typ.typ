// gutachten 0.5.0: `selected-tasks` nimmt Aufgabennamen als Text.
// fehler: gutachten.gutachten: `selected-tasks` enthält `1` (integer) – Aufgabennamen als Text schreiben: `("Aufgabe 2", "Aufgabe 4")`
#import "@schule/gutachten:0.5.0": *

#set-options(max-points: 10)
#gutachten(selected-tasks: (1, 2))[x]
