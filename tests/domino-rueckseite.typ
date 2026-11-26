// erwartet: D ?O ?M ?I ?N ?O
// erwartet: Grundaufgaben
// erwartet: B3
#import "@schule/trimino:0.5.0": domino

#set page(paper: "a4", margin: 1.5cm)

#domino(back: [Grundaufgaben], copies: 2, cut-marks: true, theme: "kontur",
  pairs: range(5).map(i => ([#(i + 2) · 4], [#((i + 2) * 4)])))
