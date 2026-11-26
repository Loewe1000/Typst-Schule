// Passermarken und Schnittdaten: Stern aus 12 Kärtchen, A4, Rand 1,5 cm.
// Mit Passermarken wird der Schnittbogen mit 30 mm Rand gesetzt: 4 Kärtchen
// je Reihe, 3 Reihen ohne Abstand, jede zweite versetzt. Je Reihe 9 Kanten;
// die beiden Grenzen zwischen den Reihen teilen je 2 waagerechte Kanten:
// 27 − 4 = 23 Strecken.
// erwartet: T ?R ?I ?M ?I ?N ?O +S ?C ?H ?N ?I ?T ?T ?B ?O ?G ?E ?N
// erwartet: Bögen 1, Seite 2, Strecken 23
// erwartet: Marken 10 10 190 277
// erwartet: erste Strecke 20 [0-9.]+ 80 [0-9.]+
// erwartet: alle Strecken doppelt frei ja
#import "@schule/trimino:0.5.0": trimino

#set page(paper: "a4", margin: 1.5cm)

#trimino(pairs: range(12).map(i => ([#i + 1], [#(i + 1)])), cut-marks: true)

#context {
  let data = query(<cut-data>).map(m => m.value)
  let d = data.first()
  let m = d.marks
  let keys = d.paths.map(s => s.map(p => p.map(str).join(",")).sorted().join(";"))
  [Bögen #data.len(), Seite #d.page, Strecken #d.paths.len() \
  Marken #m.left #m.top #m.width #m.length \
  erste Strecke #d.paths.first().flatten().map(str).join(" ") \
  alle Strecken doppelt frei #if keys.dedup().len() == keys.len() [ja] else [nein]]
}
