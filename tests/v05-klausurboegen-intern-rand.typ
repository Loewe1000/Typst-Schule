// klausurboegen 0.5.0: answer-sheet-pages: `rand` und `unten` sind `margin`
// fehler: klausurboegen.internal.answer-sheet-pages: `rand` gibt es nicht mehr – der Seitenrand steht in `margin: (top:, bottom:, x:)`
#import "@schule/klausurboegen:0.5.0": *
#internal.answer-sheet-pages(rand: 1cm).page.paper
