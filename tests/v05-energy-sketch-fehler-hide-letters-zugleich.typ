// Alter Schalter und neuer Parameter zugleich (neuer Wert weicht von der Vorgabe ab).
// fehler: energy-sketch.energy-sketch: `hide-letters` (alt) und `labeled` (neu) zugleich – nur `labeled` schreiben
#import "@schule/energy-sketch:0.5.0": energy-sketch

#energy-sketch(("A", "B"), hide-letters: true, labeled: false)
