// typlace 0.5.0: alter Enum-Wert wird mit „heißt jetzt" abgelehnt.
// fehler: typlace.sitzordnung: `quality: "gruendlich"` heißt jetzt `"thorough"`
#import "@schule/typlace:0.5.0": *
#let layout = "TT.TT\nTT.TT\n..P.."
#let wishes = "Anna||Ben\nBen||Anna"

#sitzordnung(layout, wishes, quality: "gruendlich")
