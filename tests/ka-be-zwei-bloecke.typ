// Zwei Klassenarbeiten in einer Datei: jede zeigt ihre eigenen BE
// (früher las Teil A die BE aus Teil B).
// erwartet: Aufgabe 1 5 BE
// erwartet: Aufgabe 1 26 BE
// erwartet: \[1 BE\]
// nicht: Aufgabe 2 26 BE
#import "@schule/klassenarbeit:0.4.0": *
#klassenarbeit(title: [Teil A], punkte: "alle", erwartungen: false)[
  #aufgabe[#teilaufgabe[a #erwartung(1)[]] #teilaufgabe[b #erwartung(4)[]]]
  #aufgabe[#teilaufgabe[c #erwartung(2)[]] #teilaufgabe[d #erwartung(3)[]]]
]
#klassenarbeit(title: [Teil B], punkte: "alle", erwartungen: false)[
  #aufgabe[#teilaufgabe[e #erwartung(26)[]]]
]
