// gutachten 0.5.0: Vor- und Nachname stehen benannt; der Inhalt in eckigen Klammern zählt nicht mit.
// fehler: gutachten.gutachten: 1 Positionsargument, erlaubt ist keines – Vor- und Nachname benannt schreiben: `gutachten(first-name: "Max", last-name: "Mustermann")[...]`
#import "@schule/gutachten:0.5.0": *

#set-options(max-points: 10)
#gutachten("Max")[x]
