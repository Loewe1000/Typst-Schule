// gutachten 0.5.0: `set-tasks` nimmt genau ein Dictionary; gezählt wird das Pflichtargument mit.
// fehler: gutachten.set-tasks: 2 Positionsargumente, erlaubt ist höchstens 1 – alle Aufgaben in ein einziges Dictionary schreiben: `set-tasks(("Aufgabe 1": (max-points: 30)))`
#import "@schule/gutachten:0.5.0": *

#set-tasks(("A": (max-points: 5)), ("B": (max-points: 5)))
