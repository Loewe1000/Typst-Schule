// erwartet: Level gesetzt
// erwartet: Druckfassung gesetzt
// erwartet: Zusatzkacheln gesetzt
// erwartet: Breite waechst: true
// abbozza 0.5.0: hathi-level mit allen Parametern. Die Zeichnung selbst enthält
// keinen Text; geprüft wird, dass jeder Aufruf kompiliert und Inhalt liefert.
#import "@schule/abbozza:0.5.0": hathi-level
#let level = xml("/abbozza/0.5.0/examples/level.abz")
#set page(width: 21cm, height: auto, margin: 1cm)

#hathi-level(level)
Level gesetzt

#hathi-level(level, tile-size: 17.5mm, print: true)
Druckfassung gesetzt

#hathi-level(
  level,
  tile-size: 20mm,
  replacements: (bananas: "grass", lion: "rock"),
  extra-tiles: (
    (kind: "flag", at: (1, 3), hue: 344),
    (kind: "hartmut", at: ("4", "3"), direction: "2"),
    (kind: "bananas", at: (0, 0), capacity: 7),
    (kind: "unbekannt", at: (9, 9)),
  ),
)
Zusatzkacheln gesetzt

#context {
  let small = measure(hathi-level(level, tile-size: 10mm)).width
  let large = measure(hathi-level(level, tile-size: 20mm)).width
  [Breite waechst: #(calc.abs(large / small - 2) < 0.01)]
}
