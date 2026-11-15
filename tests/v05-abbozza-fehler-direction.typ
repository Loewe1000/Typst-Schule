// fehler: abbozza.hathi-level: `direction: 2` – die Blickrichtung ist ein Text: `direction: "2"` schreiben
// Blickrichtung als Zahl statt als Text.
#import "@schule/abbozza:0.5.0": hathi-level
#let level = xml("/abbozza/0.5.0/examples/level.abz")
#hathi-level(level, extra-tiles: ((kind: "hathi", at: (1, 3), direction: 2),))
