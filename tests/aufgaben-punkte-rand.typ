// position "rand" in einer grid-Spalte: Rauchtest (kompiliert, BE erscheinen).
// Die Lage am Seitenrand lässt sich am Text nicht prüfen.
// erwartet: \[2 BE\]
#import "@schule/arbeitsblatt:0.4.0": *
#show: arbeitsblatt.with(title: [T], print: true, punkte: (anzeige: "alle", position: "rand"))
#aufgabe[A][#grid(columns: (1fr, 1fr), [+ links #erwartung(2)[e]], [])]
