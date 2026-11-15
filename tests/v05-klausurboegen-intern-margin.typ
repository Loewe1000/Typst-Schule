// klausurboegen 0.5.0: answer-sheet-pages: nur top, bottom, x
// fehler: klausurboegen.internal.answer-sheet-pages: unbekannter Schlüssel `margin.left` – erlaubt: `margin.top`, `margin.bottom`, `margin.x`
#import "@schule/klausurboegen:0.5.0": *
#internal.answer-sheet-pages(margin: (left: 1cm)).page.paper
