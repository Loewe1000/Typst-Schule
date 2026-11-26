// erwartet: T ?R ?I ?M ?I ?N ?O +L ?Ö ?S ?U ?N ?G
// erwartet: 66
// Eckmarken: Bogen, Drachen (Vorgabe), flaches Dreieck, Kreissektor, Messskala, keine; dazu alle Themes mit
// eigener Matheschrift und das Feld in jedem Theme.
#import "@schule/trimino:0.5.0": trimino

#set page(paper: "a4", margin: 1.5cm)

#let paare = (([$1/2$], [50 %]), ([$1/4$], [25 %]), ([$3/4$], [75 %]), ([$66$], [$6 dot 11$]),
  ([$1/10$], [10 %]), ([$1/20$], [5 %]))
#for m in ("arc", "kite", "triangle", "dot", "ticks", none) {
  trimino(pairs: paare, theme: (corner-mark: m), cards: false)
  pagebreak(weak: true)
}
#for t in ("klar", "leiste", "atlas", "skizze", "labor", "kontur") {
  trimino(pairs: paare, theme: t, corners: false, cards: false)
  pagebreak(weak: true)
}
#trimino(pairs: paare, theme: (font: "serifenlos", label: "field"), cards: false)
#trimino(pairs: paare, theme: (math: "STIX Two Math", label: "outline", band: "edge", band-depth: 0.06), cards: false)
