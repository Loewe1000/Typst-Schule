// typlace 0.5.0: alter Name mit Umlaut wird gefaltet und gemeldet.
// fehler: typlace.sitzordnung: `qualität` heißt jetzt `quality`
#import "@schule/typlace:0.5.0": *
#let layout = "TT.TT\nTT.TT\n..P.."
#let wishes = "Anna||Ben\nBen||Anna"

#sitzordnung(layout, wishes, qualität: "schnell")
