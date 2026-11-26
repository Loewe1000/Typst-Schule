// erwartet: T ?R ?I ?M ?I ?N ?O +L ?Ö ?S ?U ?N ?G
// erwartet: T ?R ?I ?M ?I ?N ?O +S ?C ?H ?N ?I ?T ?T ?B ?O ?G ?E ?N
// erwartet: star 1 12
// erwartet: triangle 3 9
#import "@schule/trimino:0.5.0": trimino, trimino-shapes

#set page(paper: "a4", margin: 1.5cm)

#for n in (12, 9) {
  let e = trimino-shapes(n).first()
  [#e.shape #e.shape-size #e.cards \ ]
}

#trimino(pairs: range(12).map(i => ([#i + 1], [#(i + 1)])))
