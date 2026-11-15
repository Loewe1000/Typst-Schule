// aufgaben 0.3.1 und 0.5.0 im selben Dokument stören sich nicht: eigene States,
// eigene Zähler, eigene Optionen.
// erwartet: Aufgabe 1 − Alt +2 BE
// erwartet: Aufgabe 1 − Neu
// erwartet: Aufgabe 2 − Neu zwei +\(5\)
// erwartet: Punkte neu: 0 5, alt: 2
// nicht: Aufgabe 3
#import "@schule/aufgaben:0.3.1" as alt
#import "@schule/aufgaben:0.5.0": *
#set-options(points: "tasks", points-format: p => [(#p)])
#alt.aufgabe(title: [Alt])[alter Text #alt.erwartung(2)[a]]
#aufgabe(title: [Neu])[neuer Text]
#aufgabe(title: [Neu zwei])[#teilaufgabe[x #erwartung(5)[b]]]
#context [Punkte neu: #get-points(1) #get-points(2), alt: #alt.get-points(1)]
