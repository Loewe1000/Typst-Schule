// typlace 0.5.0: alter Schlüssel in `constraints` wird gemeldet.
// fehler: typlace.sitzordnung: `muss-vorne` heißt jetzt `must-front`
#import "@schule/typlace:0.5.0": *
#let layout = "TT.TT\nTT.TT\n..P.."
#let wishes = "Anna||Ben\nBen||Anna"

#sitzordnung(layout, wishes, constraints: (muss-vorne: ("Anna",)))
