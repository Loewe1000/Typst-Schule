// klausurboegen 0.5.0: answer-sheet-pages: Gestalt von task-points
// fehler: klausurboegen.internal.answer-sheet-pages: `task-points` erwartet Paare `(name, points)`, bekam `("1", "4")` – zum Beispiel `(("1", 4), ("2", (3, 3)))`
#import "@schule/klausurboegen:0.5.0": *
#internal.answer-sheet-pages(task-points: (("1", "4"),)).page.paper
