#import "@schule/trimino:0.5.0": trimino
#import "_paare.typ": *
#set page(paper: "a3", flipped: true, margin: 1.2cm)
#set text(lang: "de")
#grid(columns: (1fr,) * 4, column-gutter: 8mm, row-gutter: 8mm,
  ..themes.map(t => block(height: 12.6cm, width: 100%, trimino(title: [„#t“], pairs: paare,
    distractors: ablenker, corners: "wheel", theme: t, cards: false))))
