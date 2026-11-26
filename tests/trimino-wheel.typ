// erwartet: T ?R ?I ?M ?I ?N ?O +L ?Ö ?S ?U ?N ?G
// erwartet: In keinem Kreis kommt eine Farbe oder Augenzahl doppelt
// erwartet: In keinem Ring kommt eine Farbe doppelt
// erwartet: K ?O ?N ?T ?R ?O ?L ?L ?E
#import "@schule/trimino:0.5.0": trimino

#set page(paper: "a4", margin: 1.5cm)

#let paare = range(9).map(i => ([#(i + 2) · 4], [#((i + 2) * 4)]))
#trimino(pairs: paare, corners: "wheel")
#pagebreak()
#trimino(pairs: paare, corners: "wheel", theme: (tip: "ring", pips: false), cards: false)
#pagebreak()
#trimino(pairs: paare, corners: "wheel", theme: "klar", cards: false)
