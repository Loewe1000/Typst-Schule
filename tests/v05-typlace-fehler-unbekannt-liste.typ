// typlace 0.5.0: unbekannte Option ohne nahen Treffer nennt die erlaubten Namen.
// fehler: typlace.wunschliste: unbekannter Parameter `encoding` – erlaubt: `delimiter`, `header-row`, `seat-count`, `max-wishes`, `strict`
#import "@schule/typlace:0.5.0": *
#let layout = "TT.TT\nTT.TT\n..P.."
#let wishes = "Anna||Ben\nBen||Anna"

#wunschliste(wishes, encoding: "utf8")
