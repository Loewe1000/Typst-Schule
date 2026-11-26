// erwartet: D ?O ?M ?I ?N ?O +L ?Ö ?S ?U ?N ?G
// erwartet: S ?C ?H ?N ?I ?T ?T ?B ?O ?G ?E ?N
// erwartet: S ?T ?A ?R ?T
// erwartet: E ?N ?D ?E
#import "@schule/trimino:0.5.0": domino

#set page(paper: "a4", margin: 1.5cm)

#domino(title: [Einmaleins], tags: ([Ergebnis], [Aufgabe]), pairs: range(12).map(i => ([#(i + 2) · 7], [#((i + 2) * 7)])))
