// Hauptfunktionen: Vorlage, Kurzschreibweise, Lücke, lsg, Spalten, Kästen, Einheiten, Links.
// erwartet: Brüche
// erwartet: MA-06
// erwartet: Aufgabe 1 − Kürzen
// erwartet: a\) Kürze
// erwartet: b\) Erweitere
// erwartet: Die Hälfte ist
// erwartet: Info
// erwartet: Merksatz
// erwartet: links +rechts
// erwartet: 9,81
// erwartet: Zur App
// erwartet: Blattfassung
// erwartet: Bildschirm
// nicht: GEHEIM
// nicht: Lösung
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(title: [Brüche], class: "MA-06", shortcodes: "all")

= Kürzen
+ Kürze $4/8$. #loesung[GEHEIM]
+ Erweitere $1/2$.

Die Hälfte ist #luecke[GEHEIM] und #lsg[GEHEIM].

#info[Ein Hinweis.]
#memo(title: [Merksatz])[Zähler und Nenner durch dieselbe Zahl teilen.]
#minipage[links][rechts]
#qty[9.81][m/s^2] #num[3.14] #unit[N/m^2]
#icon-link("https://typst.app")[Zur App]
#qr-box("https://typst.app", width: 3cm)[Zur App]
#workspace[#kariert(2)]
#conditional-pagebreak(print: true)
#context if has-solutions() [Lösungsfassung] else [Blattfassung]
#context if is-print() [Druck] else [Bildschirm]
