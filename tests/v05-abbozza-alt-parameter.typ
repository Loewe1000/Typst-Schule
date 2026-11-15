// fehler: abbozza.hathi-level: `replace` heißt jetzt `replacements`
// Alter Parametername bricht mit „heißt jetzt" ab.
#import "@schule/abbozza:0.5.0": hathi-level
#let level = xml("/abbozza/0.5.0/examples/level.abz")
#hathi-level(level, replace: (bananas: "grass"))
