// Exportiert werden nur `energy-sketch` und `internal`; `canvas`, `draw` und
// die alten Unterstrich-Namen sind weg.
// erwartet: energy-sketch, internal
#import "@schule/energy-sketch:0.5.0" as es

#dictionary(es).keys().sorted().join(", ")
