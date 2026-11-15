// conditional-pagebreak: wirkt nur, wenn die Bedingung zutrifft (hier Bildschirmfassung ohne Lösungen).
// erwartet: Seiten: 2
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(title: [S], page-settings: (height: 10cm))
Erste Seite
#conditional-pagebreak(print: true)
#conditional-pagebreak(solutions-visible: true)
#conditional-pagebreak(print: false, solutions-visible: false)
Zweite Seite
#context [Seiten: #counter(page).final().first()]
