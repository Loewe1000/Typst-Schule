// typlace 0.5.0: alter Parametername wird mit „heißt jetzt" abgelehnt.
// fehler: typlace.typlace: `namen` heißt jetzt `names`
#import "@schule/typlace:0.5.0": *
#let layout = "TT.TT\nTT.TT\n..P.."
#let wishes = "Anna||Ben\nBen||Anna"

#typlace(layout, namen: ("Anna", "Ben"))
