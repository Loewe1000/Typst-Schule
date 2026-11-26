// erwartet: Ergebnis der Rechnung
// erwartet: Potenz mit Exponent
// nicht: Rechnu(ng)?(27|64|32)
// nicht: Exponent ?(3|4|2) ?[0-9]
// Lange Überschriften überdecken den Inhalt nicht: beim Stapel wird die
// Überschrift kleiner oder der Zeilenkopf breiter, in der Kette passt sie in
// eine Zeile (oder bricht um) und der Inhalt rückt nach unten.
#import "/trimino/0.5.0/src/internal.typ": themes
#import "/trimino/0.5.0/src/domino.typ": domino-tag-fit, domino-room, domino-tag-head, domino
#set page(paper: "a4", margin: 1.5cm)

#context {
  let tags = ([Ergebnis der Rechnung], [Potenz mit Exponent])
  let stack = domino-tag-fit(tags, themes.riso, (2, 0.62), 3.5)
  assert(stack.size * 3.5cm >= 5.99pt, message: "Überschrift unter 6 pt")
  assert(stack.room >= domino-tag-head)
  let chain = domino-tag-fit(tags, themes.riso, (1, 1), 3.5)
  assert(chain.size <= 0.1)
  assert(domino-room(themes.riso, chain, (1, 1), 0deg).at(1) < domino-room(themes.riso, none, (1, 1), 0deg).at(1))
  let long = domino-tag-fit(([Eine sehr, sehr lange Überschrift für den Stapel],), themes.riso, (2, 0.62), 3.5)
  assert(long.room > domino-tag-head, message: "Zeilenkopf wächst nicht")
}

#domino(layout: "stack", pairs: (([$3^3$], [27]), ([$4^3$], [64]), ([$2^5$], [32])),
  tags: ([Ergebnis der Rechnung], [Potenz mit Exponent]), cards: false)
#domino(pairs: (([$3^3$], [27]), ([$4^3$], [64]), ([$2^5$], [32])),
  tags: ([Ergebnis der Rechnung], [Potenz mit Exponent]), cards: false)
