// typlace 0.5.0: alter Zonenwert in einem selbst gebauten Eintrag (Dictionary
// mit `students`) wird gemeldet statt in einer rohen Typst-Meldung zu enden.
// fehler: typlace.sitzordnung: `depth: "vorne"` heißt jetzt `"front"`
#import "@schule/typlace:0.5.0": *
#let layout = "TT.TT\nTT.TT\n..P.."

#sitzordnung(layout, (students: ((name: "Anna", wishes: ("Ben",), position: (depth: "vorne")), (name: "Ben")), notes: ()))
