// erwartet: D ?O ?M ?I ?N ?O +L ?Ö ?S ?U ?N ?G
// nicht: S ?T ?A ?R ?T
// nicht: E ?N ?D ?E
#import "@schule/trimino:0.5.0": domino

#set page(paper: "a4", margin: 1.5cm)

#domino(loop: true, theme: "klar", pairs: range(6).map(i => ([#(i + 2) · 3], [#((i + 2) * 3)])))
