// typlace 0.5.0: alter Schlüssel in einem selbst gebauten Eintrag wird auch
// dann gemeldet, wenn die Liste als Dictionary mit `students` kommt.
// fehler: typlace.sitzordnung: `wuensche` heißt jetzt `wishes`
#import "@schule/typlace:0.5.0": *
#let layout = "TT.TT\nTT.TT\n..P.."

#sitzordnung(layout, (students: ((name: "Anna", wuensche: ("Ben",)), (name: "Ben")), notes: ()))
