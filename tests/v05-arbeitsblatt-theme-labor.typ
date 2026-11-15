// Theme "labor": Kopf mit Fachzeile, Aufgabenkopf, Teilaufgabe, Lösung, Kasten, Material.
// erwartet: [Mm] ?[Aa] ?[Tt] ?[Hh] ?[Ee] ?[Mm] ?[Aa] ?[Tt] ?[Ii] ?[Kk]
// erwartet: (Größen|GRÖẞEN)
// erwartet: (Längen umrechnen|LÄNGEN UMRECHNEN)
// erwartet: a\) +Rechne
// erwartet: Lösung a\)
// erwartet: [Mm] ?[Ee] ?[Rr] ?[Kk] ?[Ee]
// erwartet: (Material zu Aufgabe 1|MATERIAL ZU AUFGABE 1)
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(title: [Größen], class: "MA-05", theme: "labor", print: true, solutions: "in-place", points: "all", copyright-url: "https://example.org")
#aufgabe(title: [Längen umrechnen], method: "pair")[
  + Rechne um. #loesung[400 cm] #erwartung(2)[richtig]
  #material(caption: [Tabelle])[Daten]
]
#aufgabe[Ohne Titel, mit hängender Marke.]
#memo[Zur nächstkleineren Einheit multiplizieren.]
#warning(title: none)[Ohne Titelzeile.]
