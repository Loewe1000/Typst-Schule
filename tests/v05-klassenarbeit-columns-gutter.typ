// erwartet: Gutter: 0% \+ 85\.04pt
// nicht: Gutter: 4%
// Ohne `answer-sheet-pages` setzt klassenarbeit keinen Spaltenabstand: Ein
// `#set columns(gutter: …)` vor dem `#show:` bleibt wirksam (wie in 0.4.0).
#import "@schule/klassenarbeit:0.5.0": *
#set columns(gutter: 3cm)
#show: klassenarbeit.with(title: [T], preview-variant: "print")
#context [Gutter: #columns.gutter]
#columns(2)[#lorem(40)]
