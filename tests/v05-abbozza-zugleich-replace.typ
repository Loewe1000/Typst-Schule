// fehler: abbozza.hathi-level: `replace` (alt) und `replacements` (neu) zugleich – nur `replacements` schreiben
// Alter und neuer Name zugleich.
#import "@schule/abbozza:0.5.0": hathi-level
#let level = xml("/abbozza/0.5.0/examples/level.abz")
#hathi-level(level, replace: (lion: "grass"), replacements: (lion: "rock"))
