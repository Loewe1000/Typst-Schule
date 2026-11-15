// arbeitsblatt 0.4.0 und 0.5.0 im selben Dokument: Zähler, Punkte, Optionen
// und Lückentext-Wörter laufen getrennt (eigene State-Schlüssel je Version).
// erwartet: Aufgabe 1 − Neu eins 5 BE
// erwartet: Aufgabe 1 − Alt eins 2 BE
// erwartet: Aufgabe 2 − Neu zwei 1 BE
// erwartet: NEULSG
// erwartet: Punkte neu: 5 1, alt: 2
// nicht: ALTLSG
// nicht: ALTLUECKE
#import "@schule/arbeitsblatt:0.4.0" as alt
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(title: [Misch], class: "MA-08", points: "all", solutions: "in-place")
#aufgabe(title: [Neu eins])[neuer Text
  #teilaufgabe[neu-a #erwartung(5)[b] #loesung[NEULSG]]
  #teilaufgabe[neu-b #luecke[NEULUECKE] #lsg[NEUL]]
]
#alt.aufgabe(title: [Alt eins])[alter Text #alt.erwartung(2)[a]
  #alt.teilaufgabe[alt-a #alt.loesung[ALTLSG]]
  #alt.teilaufgabe[alt-b #alt.lücke[ALTLUECKE]]
]
#aufgabe(title: [Neu zwei])[#teilaufgabe[neu2-a #erwartung(1)[c]] #insert-a-word[Der #iaword[Hund].] #alt.insert-a-word[Die #alt.iaword[Katze].]]
#context [Punkte neu: #get-points(1) #get-points(2), alt: #alt.get-points(1)]
