// Ein points-format der ersten Klassenarbeit gilt nicht in der zweiten,
// auch nicht der fehlende Teil eines Dictionary.
// erwartet: XX1
// erwartet: Aufgabe 1 5 BE
// erwartet: \[5 BE\]
// erwartet: YY7
// nicht: XX5
// nicht: XX7
#import "@schule/klassenarbeit:0.5.0": *
#klassenarbeit(title: [A], expectations: false, points: "all", points-format: p => [XX#p])[
  #aufgabe[#teilaufgabe[A #erwartung(1)[x]]]
]
#klassenarbeit(title: [B], expectations: false, points: "all")[
  #aufgabe[#teilaufgabe[B #erwartung(5)[y]]]
]
#klassenarbeit(title: [A], expectations: false, points: "tasks", points-format: p => [XX#p])[
  #aufgabe[A #erwartung(1)[x]]
]
#klassenarbeit(title: [C], expectations: false, points: "all", points-format: (task: p => [YY#p]))[
  #aufgabe[#teilaufgabe[C #erwartung(7)[y]]]
]
