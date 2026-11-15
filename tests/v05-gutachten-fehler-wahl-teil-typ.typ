// gutachten 0.5.0: Auch in der Liste eines Prüfungsteils stehen Aufgabennamen als Text.
// fehler: gutachten.gutachten: `selected-tasks`: der Prüfungsteil `Wahlteil` enthält `2` (integer) – Aufgabennamen als Text schreiben: `("Wahlteil": ("Aufgabe 2",))`
#import "@schule/gutachten:0.5.0": *

#set-options(max-points: 10)
#gutachten(selected-tasks: ("Wahlteil": (2,)))[x]
