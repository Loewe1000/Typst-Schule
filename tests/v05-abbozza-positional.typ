// fehler: abbozza.hathi-level: 1 Positionsargument, erlaubt ist keines
// Überzähliges Positionsargument wird abgelehnt.
#import "@schule/abbozza:0.5.0": hathi-level
#let level = xml("/abbozza/0.5.0/examples/level.abz")
#hathi-level(level, 0.8)
