// Alte Funktionsnamen (bis arbeitsblatt 0.4.0). Jeder Aufruf bricht mit einer
// Meldung ab, die den neuen Namen oder den Ersatz nennt. Vom Namens-Lint
// ausgenommen (konvention.md 9.3).
//
// Keinen Stub haben `mono` (er überdeckte `math.mono` in Formeln; Ersatz:
// `text(font: "SF Mono", …)`) und `print-state` (ein State, kein Aufruf;
// Ersatz: `is-print()`).
#import "internal/check.typ": fail, stub

// Für Namen ohne Nachfolger: „gibt es nicht mehr" mit Abhilfe.
#let gone(old, hint) = (..args) => fail("arbeitsblatt", old, "`" + old + "` gibt es nicht mehr – " + hint)

#let lücke = stub("arbeitsblatt", "lücke", "luecke")
#let loesungsmodus = stub("arbeitsblatt", "loesungsmodus", "has-solutions")
#let tasks = stub("arbeitsblatt", "tasks", "teilaufgaben")
#let print-pagebreak = stub("arbeitsblatt", "print-pagebreak", "conditional-pagebreak(print: true)")
#let non-print-pagebreak = stub("arbeitsblatt", "non-print-pagebreak", "conditional-pagebreak(print: false)")
#let qrbox = stub("arbeitsblatt", "qrbox", "qr-box")
#let c_canvas = gone("c_canvas", "`cetz.canvas` nach `#import \"@preview/cetz:0.4.2\"` benutzen")
