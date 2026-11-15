// Zwei Klassenarbeiten in einer Datei: jede zeigt ihre eigenen BE.
// erwartet: Aufgabe 1 5 BE
// erwartet: Aufgabe 1 26 BE
// erwartet: \[1 BE\]
// nicht: Aufgabe 2 26 BE
#import "@schule/klassenarbeit:0.5.0": *
#klassenarbeit(title: [Teil A], points: "all", expectations: false)[
  #aufgabe[#teilaufgabe[a #erwartung(1)[]] #teilaufgabe[b #erwartung(4)[]]]
  #aufgabe[#teilaufgabe[c #erwartung(2)[]] #teilaufgabe[d #erwartung(3)[]]]
]
#klassenarbeit(title: [Teil B], points: "all", expectations: false)[
  #aufgabe[#teilaufgabe[e #erwartung(26)[]]]
]
