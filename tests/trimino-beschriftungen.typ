// erwartet: T ?R ?I ?M ?I ?N ?O +S ?C ?H ?N ?I ?T ?T ?B ?O ?G ?E ?N
// erwartet: 50 %
#import "@schule/trimino:0.5.0": trimino

#set page(paper: "a4", margin: 1.5cm)

#let paare = (([$1/2$], [50 %]), ([$1/4$], [25 %]), ([$3/4$], [75 %]),
  ([$1/5$], [20 %]), ([$1/10$], [10 %]), ([$1/20$], [5 %]))
#for l in ("pill", "plain", "outline", "field", "tab") {
  trimino(pairs: paare, corners: "wheel", theme: (label: l))
  pagebreak(weak: true)
}
#trimino(pairs: paare, label-size: 11pt, theme: "kontur")
