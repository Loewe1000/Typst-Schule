#import "@schule/trimino:0.5.0": domino
#import "_paare.typ": *
#set page(paper: "a3", flipped: true, margin: 1.2cm)
#set text(lang: "de")
#grid(columns: (1fr,) * 4, column-gutter: 8mm, row-gutter: 8mm,
  ..themes.map(t => block(height: 12.6cm, width: 100%, domino(title: [„#t“], theme: t, cards: false,
    side: 2.6cm, pairs: range(5).map(i => ([#(i + 3) · 7], [#((i + 3) * 7)]))))))
