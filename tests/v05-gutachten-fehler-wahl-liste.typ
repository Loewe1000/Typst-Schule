// gutachten 0.5.0: Im Dictionary von `selected-tasks` braucht jeder Prüfungsteil eine Liste.
// fehler: gutachten.gutachten: `selected-tasks`: der Prüfungsteil `Wahlteil` braucht eine Liste – `("Wahlteil": ("2A",))` schreiben
#import "@schule/gutachten:0.5.0": *

#set-options(max-points: 10)
#gutachten(selected-tasks: ("Wahlteil": "2A"))[x]
