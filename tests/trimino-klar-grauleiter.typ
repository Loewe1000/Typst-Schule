// erwartet: Grauleiter 6 Stufen
// erwartet: K ?O ?N ?T ?R ?O ?L ?L ?E
// erwartet: In keinem Kreis kommt eine Farbe oder Augenzahl doppelt
// Das Theme „klar“ setzt die Eckspitzen als Grauleiter (nicht ein einheitliches
// Grau): sechs Stufen, von dunkel nach hell, je mindestens 10 % auseinander.
#import "@schule/trimino:0.5.0": trimino
#import "/trimino/0.5.0/src/internal.typ": themes, wheel-greys, wheel-grey-pips

#set page(paper: "a4", margin: 1.5cm)

#let stufen = wheel-greys.map(c => c.components().first() / 100%)
#assert(themes.klar.wheel == none, message: "klar muss die Grauleiter nutzen")
#assert(stufen.len() == 6)
#for i in range(1, 6) {
  assert(stufen.at(i) - stufen.at(i - 1) >= 0.1, message: "Grauleiter: Stufe " + str(i) + " zu nah an der vorigen")
}
// Augen hell auf dunklen, dunkel auf hellen Stufen
#for (k, p) in wheel-grey-pips.enumerate() {
  let hell = p.components().first() / 100% > 0.5
  assert(hell == (stufen.at(k) < 0.6), message: "Augenfarbe passt nicht zur Stufe " + str(k))
}
Grauleiter #stufen.len() Stufen

#trimino(pairs: range(9).map(i => ([#(i + 2) · 4], [#((i + 2) * 4)])), corners: "wheel", theme: "klar", cards: false)
