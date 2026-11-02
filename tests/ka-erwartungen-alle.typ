// Gemeinsamer Erwartungshorizont über zwei Blöcke, ohne Seitenzahl.
// erwartet: Summe Teil A – ohne 3
// erwartet: Summe Teil B 4
// erwartet: Gesamtsumme 7
// nicht: Seite 2 von
#import "@schule/klassenarbeit:0.4.0": *
#klassenarbeit(title: [K], erwartungen: false)[
  #aufgabe[A #erwartung(3)[a]]
]
#klassenarbeit(title: [K], erwartungen: (alle: true, teile: ([Teil A -- ohne],)))[
  #aufgabe[B #erwartung(4)[b]]
]
