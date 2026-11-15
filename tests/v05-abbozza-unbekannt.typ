// fehler: abbozza.hathi-level: unbekannter Parameter `tile-sise` – meintest du `tile-size`?
// Unbekannte Option wird abgelehnt, mit Vorschlag.
#import "@schule/abbozza:0.5.0": hathi-level
#let level = xml("/abbozza/0.5.0/examples/level.abz")
#hathi-level(level, tile-sise: 20mm)
