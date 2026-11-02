// Ein punkte-template der ersten Klassenarbeit gilt nicht in der zweiten.
// erwartet: XX1
// erwartet: 5 BE
// nicht: XX5
#import "@schule/klassenarbeit:0.4.0": *
#klassenarbeit(title: [A], erwartungen: false, punkte: "aufgaben", punkte-template: p => [XX#p])[
  #aufgabe[A #erwartung(1)[x]]
]
#klassenarbeit(title: [B], erwartungen: false, punkte: "aufgaben")[
  #aufgabe[B #erwartung(5)[y]]
]
