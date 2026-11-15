// typlace 0.5.0: unerfüllbare Vorgabe bricht mit Abhilfe ab.
// fehler: typlace.sitzordnung: Platz 9 für Anna gibt es nicht – erlaubt sind 0 bis 7
#import "@schule/typlace:0.5.0": *
#let layout = "TT.TT\nTT.TT\n..P.."
#let wishes = "Anna||Ben\nBen||Anna"

#sitzordnung(layout, wishes, constraints: (fixed: (Anna: 9)))
