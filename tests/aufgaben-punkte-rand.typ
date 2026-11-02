// position "rand" in einer grid-Spalte: Rauchtest (kompiliert, BE erscheinen).
// Die Lage am Seitenrand lässt sich am Text nicht prüfen.
// erwartet: \[2 BE\]
#import "@schule/arbeitsblatt:0.4.0": *
// Digitalfassung (1,75 cm Rand): Im Duplex-Druck ist der äußere Rand nur
// 1,25 cm, mit Ersatzschriften ragt „[2 BE]“ dann über die Blattkante.
#show: arbeitsblatt.with(title: [T], print: false, punkte: (anzeige: "alle", position: "rand"))
#aufgabe[A][#grid(columns: (1fr, 1fr), [+ links #erwartung(2)[e]], [])]
