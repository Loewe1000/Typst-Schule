// Zwei Sätze auf einem Schnittbogen: 24 Kärtchen bei 4,6 cm Kantenlänge,
// eigener Text auf der Rückseite unter „TRIMINO“.
// erwartet: TRIMINO
// erwartet: Grundaufgaben
// erwartet: Bögen 1, Kärtchen 24
// erwartet: 24
#import "@schule/trimino:0.5.0": trimino

#set page(paper: "a4", margin: 1.5cm)

#trimino(pairs: range(12).map(i => ([#i + 1], [#(i + 1)])), side: 4.6cm, copies: 2,
  cut-marks: true, back: [*Prozentrechnung*\ Grundaufgaben])

#context [Bögen #query(<cut-data>).len(), Kärtchen #query(<cut-data>).first().value.pieces.len()]
