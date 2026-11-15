// points-format als Dictionary ändert nur das genannte Ziel; auto stellt die Paketvorlage wieder her.
// reset-tasks trennt Blöcke; select: "all" fasst sie mit Zwischensummen zusammen.
// erwartet: \(2 P\.\)
// erwartet: \[2 BE\]
// erwartet: Aufgabe 1 − B +3 BE
// erwartet: Summe Teil A +2
// erwartet: Summe Teil B +3
// erwartet: Gesamtsumme +5
#import "@schule/aufgaben:0.5.0": *
#set-options(points: "all", points-format: (task: p => [(#p P.)]))
#aufgabe(title: [A])[#teilaufgabe[a #erwartung(2)[x]]]
#reset-tasks()
#set-options(points-format: auto)
#aufgabe(title: [B])[y #erwartung(3)[z]]
#show-expectations(select: "all", blocks: ([Teil A],))
