// typlace 0.5.0: alter Funktionsname ist ein abbrechender Stub.
// fehler: typlace.sitzplan-bericht: `sitzplan-bericht` heißt jetzt `seating-report`
#import "@schule/typlace:0.5.0": *
#let layout = "TT.TT\nTT.TT\n..P.."
#let wishes = "Anna||Ben\nBen||Anna"

#sitzplan-bericht(sitzordnung(layout, wishes))
