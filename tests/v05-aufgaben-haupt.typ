// Hauptfunktionen: Aufgabe, Teilaufgaben, Lösung, Erwartung, Punktetabelle, Erwartungshorizont.
// erwartet: Aufgabe 1 − Addition +4,5 BE
// erwartet: a\) erste +\[1,5 BE\]
// erwartet: ★ zweite +\[1 BE\]
// erwartet: Lösung a\)
// erwartet: – a\) b\) a\) b\)
// erwartet: mögliche Punkte 2 1,5 1 3 7,5
// erwartet: Σ Summe 7,5
// erwartet: GP: 4,5 1,5 3 0
// erwartet: Format: 3 BE \[2,5 BE\]
// erwartet: Lösungen an: true, Druck: false
#import "@schule/aufgaben:0.5.0": *
#set-options(solutions: "in-place", points: "all")
#aufgabe(title: [Addition], method: "pair")[
  Einleitung #erwartung(2)[Ansatz]
  #teilaufgabe[erste #loesung[L1] #erwartung(1.5)[x]]
  #teilaufgabe(marker: [★])[zweite #erwartung(1)[y]]
]
#aufgabe[
  #teilaufgaben(columns: 2, items: ([$2 + 3$], [$5 dot 7$]), item-solutions: ([$5$], [$35$]))
  #erwartung(3)[beide]
]
#show-points-table()
#show-expectations()
#context [GP: #str(get-points(1)).replace(".", ",") #str(get-points(1, subtask-number: 1)).replace(".", ",") #get-points(2) #get-points(9)]

Format: #context format-points(3) #context format-points(2.5, target: "subtask")

#context [Lösungen an: #has-solutions(), Druck: #is-print()]
