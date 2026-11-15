// mathematik 0.5.0: kreisdiagramm verschluckt keine unbekannten Argumente mehr.
// fehler: mathematik.kreisdiagramm: unbekannter Parameter `foo` – erlaubt: `legend`, `legend-position`, `labeled`, `percent`, `text-fill`, `accents`, `stroke`, `width`
#import "@schule/mathematik:0.5.0": *

#kreisdiagramm((("A", 1), ("B", 2)), foo: 1)
