// Rückseite ohne Passermarken, nur Schnittbogen: Seite 1 Vorderseite,
// Seite 2 Rückseite, Seite 3 der Prüftext.
// erwartet: TRIMINO
// erwartet: Seiten 3
#import "@schule/trimino:0.5.0": trimino

#set page(paper: "a4", margin: 1.5cm)

#trimino(pairs: range(9).map(i => ([#i + 1], [#(i + 1)])), solution: false, back: true)

#context [Seiten #counter(page).final().first()]
