// "continuous": Seiten des Erwartungshorizonts zählen nicht mit und
// bekommen keine Seitenzahl.
// erwartet: Seite 1 von 3
// erwartet: Seite 3 von 3
// nicht: Seite 4
#import "@schule/klassenarbeit:0.5.0": *
#klassenarbeit(title: [KA A], page-counter: "continuous")[
  #aufgabe[A1 #erwartung(1)[x]]
  // feste Umbrüche statt Fülltext: unabhängig von den installierten Schriften
  #pagebreak()
  Zweite Seite
]
#klassenarbeit(title: [KA B], page-counter: "continuous")[
  #aufgabe[B1 #erwartung(5)[z]]
]
