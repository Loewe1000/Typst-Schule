// fehler: abbozza.hathi-level: `hue` erwartet eine ganze Zahl oder eine Zahl, bekam `"rot"` (str) – zum Beispiel `344`
// Farbton der Flagge ist keine Zahl.
#import "@schule/abbozza:0.5.0": hathi-level
#let level = xml("/abbozza/0.5.0/examples/level.abz")
#hathi-level(level, extra-tiles: ((kind: "flag", at: (1, 3), hue: "rot"),))
