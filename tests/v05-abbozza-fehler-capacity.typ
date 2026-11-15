// fehler: abbozza.hathi-level: `capacity` erwartet eine ganze Zahl oder eine Zahl oder einen Text (`str`), bekam `[x]` (content) – zum Beispiel `3`
// Anzahl ist Inhalt statt Zahl.
#import "@schule/abbozza:0.5.0": hathi-level
#let level = xml("/abbozza/0.5.0/examples/level.abz")
#hathi-level(level, extra-tiles: ((kind: "crate", at: (1, 3), capacity: [x]),))
