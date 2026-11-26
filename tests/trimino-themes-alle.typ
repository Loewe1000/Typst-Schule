// erwartet: Brüche
// erwartet: T ?R ?I ?M ?I ?N ?O
// erwartet: D ?O ?M ?I ?N ?O
// erwartet: In keinem Sechseck kommt eine Farbe oder Augenzahl doppelt vor
// erwartet: Rot statt Blau
// Alle sieben Themes für Trimino (Eckspitzen, Schnittbogen, Rückseite) und
// Domino (Kette und Stapel mit Lösungswort und Rückseite); dazu ein Theme
// mit `base` und eigener Akzentfarbe, aus der die abgeleiteten Farben folgen.
#import "@schule/trimino:0.5.0": trimino, domino
#import "/trimino/0.5.0/src/internal.typ": themes, resolve-theme

#set page(paper: "a4", margin: 1.5cm)

#let paare = (([$1/2$], [50 %]), ([$1/4$], [25 %]), ([$3/4$], [75 %]),
  ([$1/5$], [20 %]), ([$1/10$], [10 %]), ([$1/20$], [5 %]))
#assert.eq(themes.keys(), ("riso", "klar", "leiste", "atlas", "skizze", "labor", "kontur"))
#for t in themes.keys() {
  trimino(title: [Brüche], pairs: paare, corners: "wheel", theme: t, back: true)
  pagebreak(weak: true)
  domino(title: [Brüche], pairs: paare, theme: t, tags: ([Prozent], [Bruch]))
  pagebreak(weak: true)
  domino(title: [Brüche], pairs: paare, theme: t, layout: "stack", back: true)
  pagebreak(weak: true)
}
#let rot = resolve-theme("trimino", "test", (base: "atlas", accent: red))
#assert.eq(rot.accent, red)
#assert.eq(rot.fill, red.lighten(89%))
#assert.eq(rot.head, "band")
#trimino(title: [Rot statt Blau], pairs: paare, theme: (base: "atlas", accent: red), cards: false)
