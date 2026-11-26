// Rückseite: hinter dem Schnittbogen eine Seite mit „TRIMINO“ und dem Titel,
// ohne Schnittdaten und ohne eigene Passermarken. Damit das ganze Dokument
// beidseitig gedruckt werden kann, beginnt der Schnittbogen auf einer
// ungeraden Seite: 1 Lösung, 2 leer, 3 Schnittbogen, 4 Rückseite. Seite 5
// trägt den Prüftext unten.
// erwartet: T ?R ?I ?M ?I ?N ?O +S ?C ?H ?N ?I ?T ?T ?B ?O ?G ?E ?N
// erwartet: TRIMINO
// erwartet: Brüche und Prozente
// erwartet: Seiten 5, Bögen 1, Seite 3
#import "@schule/trimino:0.5.0": trimino

#set page(paper: "a4", margin: 1.5cm)

#trimino(title: [Brüche und Prozente], pairs: range(12).map(i => ([#i + 1], [#(i + 1)])),
  cut-marks: true, back: true)

#context [Seiten #counter(page).final().first(), Bögen #query(<cut-data>).len(), Seite #query(<cut-data>).first().value.page]
