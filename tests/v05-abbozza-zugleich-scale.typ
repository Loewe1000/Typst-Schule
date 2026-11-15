// fehler: abbozza.hathi-level: `scale` (alt) und `tile-size` (neu) zugleich – nur `tile-size` schreiben
// Alter Faktor und neue Länge zugleich.
#import "@schule/abbozza:0.5.0": hathi-level
#let level = xml("/abbozza/0.5.0/examples/level.abz")
#hathi-level(level, scale: 0.8, tile-size: 20mm)
