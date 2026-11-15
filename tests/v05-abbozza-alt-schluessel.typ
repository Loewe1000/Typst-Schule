// fehler: abbozza.hathi-level: `type` heißt jetzt `kind`
// Alte Schlüssel in extra-tiles brechen mit „heißt jetzt" ab.
#import "@schule/abbozza:0.5.0": hathi-level
#let level = xml("/abbozza/0.5.0/examples/level.abz")
#hathi-level(level, extra-tiles: ((type: "flag", pos: (1, 3)),))
