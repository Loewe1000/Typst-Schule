// Bewertungstabelle: BE direkt an der Aufgabe bekommen eine Spalte „–“,
// Erwartungshorizont: Aufgabe ohne Titel mit einer Teilaufgabe behält ihre Nummer.
// erwartet: – a\) b\) a\)
// erwartet: 2 3 4 2 11
// erwartet: ^ *2 2$
#import "@schule/aufgaben:0.3.1": *
#aufgabe[Mix][
  Einleitung #erwartung(2)[g]
  #teilaufgabe[a #erwartung(3)[aa]]
  #teilaufgabe[b #erwartung(4)[bb]]
]
#aufgabe[#teilaufgabe[nur eine #erwartung(2)[e]]]
#show-bewertung()
#show-erwartungen()
