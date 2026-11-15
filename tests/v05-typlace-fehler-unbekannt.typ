// typlace 0.5.0: unbekannte Option mit Tippfehlervorschlag.
// fehler: typlace.typlace: unbekannter Parameter `cell-widht` – meintest du `cell-width`?
#import "@schule/typlace:0.5.0": *
#let layout = "TT.TT\nTT.TT\n..P.."
#let wishes = "Anna||Ben\nBen||Anna"

#typlace(layout, cell-widht: 2cm)
