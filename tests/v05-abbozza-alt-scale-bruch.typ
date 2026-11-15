// fehler: abbozza.hathi-level: `scale: 0.3333333333333333` heißt jetzt `tile-size: 0.3333333333333333 * 25mm`
// Geht die Umrechnung nicht auf, nennt die Meldung das Produkt statt eines gerundeten Werts.
#import "@schule/abbozza:0.5.0": hathi-level
#let level = xml("/abbozza/0.5.0/examples/level.abz")
#hathi-level(level, scale: 1/3)
