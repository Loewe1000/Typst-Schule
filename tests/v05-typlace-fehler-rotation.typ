// typlace 0.5.0: rotation ist ein Winkel, keine Zahl.
// fehler: typlace.typlace: `rotation` erwartet einen Winkel, bekam `90` (int) – zum Beispiel `90deg`
#import "@schule/typlace:0.5.0": *
#let layout = "TT.TT\nTT.TT\n..P.."
#let wishes = "Anna||Ben\nBen||Anna"

#typlace(layout, rotation: 90)
