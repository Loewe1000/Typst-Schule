// keine-summe: keine Aufgabensumme, wenn Teilaufgaben nach dem Rumpf folgen.
// erwartet: \[2 BE\]
// nicht: ^ *5 BE
#import "@schule/aufgaben:0.3.1": *
#set-options((punkte: "keine-summe"))
#aufgabe[A][Einleitung]
#teilaufgabe[x #erwartung(2)[e]]
#teilaufgabe[y #erwartung(3)[f]]
