// fehler: abbozza.hathi-level: `tile-size` erwartet eine Länge, bekam `2` (int)
// Nackte Zahl statt Länge.
#import "@schule/abbozza:0.5.0": hathi-level
#let level = xml("/abbozza/0.5.0/examples/level.abz")
#hathi-level(level, tile-size: 2)
