// summify 0.5.0: ein vollständiges eigenes Thema-Dictionary und `theme: none`
// (aktives Thema bleibt stehen).
// erwartet: Wald
// erwartet: Stockwerke
#import "@schule/summify:0.5.0": *

#let forest = themes.default
#(forest.colors.primary = rgb("#166534"))
#(forest.sizes.header = (height: 7mm, font-size: 10pt))

#set-theme(forest)
#show: summify.with(title: none, paper: "a5", landscape: false, theme: none)

#topic(title: [Wald])[#section[Stockwerke] #cell[Kraut, Strauch, Baum]]
