// erwartet: L ?Ö ?S ?U ?N ?G ?S ?W ?O ?R ?T
// erwartet: S ?U ?P ?E ?R
// erwartet: S ?T ?A ?R ?T
#import "@schule/trimino:0.5.0": domino

#set page(paper: "a4", margin: 1.5cm)

// Vier Paare, also fünf Kärtchen: das Wort hat fünf Buchstaben.
#domino(layout: "stack", word: "SUPER", tags: ([Ergebnis], [Aufgabe]),
  pairs: range(4).map(i => ([#(i + 2) · 6], [#((i + 2) * 6)])))
