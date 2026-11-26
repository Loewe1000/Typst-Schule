// erwartet: L ?Ö ?S ?U ?N ?G ?S ?W ?O ?R ?T
#import "@schule/trimino:0.5.0": domino

#set page(paper: "a4", margin: 1.5cm)

#for n in (3, 8, 15, 25) {
  domino(layout: "stack", pairs: range(n).map(i => ([#(i + 2) + 9], [#(i + 11)])))
}
