// fehler: abbozza.hathi-level: `at: ("a", 3)` – beide Einträge sind ganze Zahlen, zum Beispiel `at: (2, 3)`
// Feld einer Zusatzkachel ist keine Zahl.
#import "@schule/abbozza:0.5.0": hathi-level
#let level = xml("/abbozza/0.5.0/examples/level.abz")
#hathi-level(level, extra-tiles: ((kind: "flag", at: ("a", 3)),))
