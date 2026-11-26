#import "@schule/trimino:0.5.0": domino

#set page(paper: "a4", margin: 1.5cm)

#let paare = (([$1/2$], [50 %]), ([$1/4$], [25 %]), ([$3/4$], [75 %]))
#for t in ("riso", "klar", "leiste", "atlas", "skizze", "labor", "kontur") { domino(pairs: paare, theme: t, solution: false) }
#for l in ("pill", "plain", "outline", "field", "tab") { domino(pairs: paare, theme: (label: l), solution: false, label-size: 12pt) }
