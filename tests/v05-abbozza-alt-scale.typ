// fehler: abbozza.hathi-level: `scale: 1.3` heißt jetzt `tile-size: 32.5mm`
// Der alte Faktor wird in die Kachelhöhe umgerechnet.
#import "@schule/abbozza:0.5.0": hathi-level
#let level = xml("/abbozza/0.5.0/examples/level.abz")
#hathi-level(level, scale: 1.3)
