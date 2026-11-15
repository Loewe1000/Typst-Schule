// solutions: "at-end" mit solutions-pagebreak: "before": Lösungsblock auf neuer Seite; Material nach der Aufgabe.
// erwartet: Material zu Aufgabe 1
// erwartet: Lösung 1 – Titel
// erwartet: a\) La
#import "@schule/aufgaben:0.5.0": *
#set-options(solutions: "at-end", solutions-pagebreak: "before", materials-pagebreak: none)
#aufgabe(title: [Titel])[Text #loesung[Haupt] #material(caption: [Quelle])[Mat] #teilaufgabe[a #loesung[La]]]
#show-solutions()
