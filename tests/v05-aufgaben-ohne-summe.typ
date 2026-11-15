// points-total: false: keine Aufgabensumme, wenn Teilaufgaben nach dem Rumpf folgen;
// eine Aufgabe ohne Teilaufgaben zeigt ihre Punkte weiter.
// erwartet: \[2 BE\]
// erwartet: ^ *4 BE
// nicht: ^ *5 BE
#import "@schule/aufgaben:0.5.0": *
#set-options(points: "all", points-total: false)
#aufgabe(title: [A])[Einleitung]
#teilaufgabe[x #erwartung(2)[e]]
#teilaufgabe[y #erwartung(3)[f]]
#aufgabe(title: [B])[Allein #erwartung(4)[g]]
