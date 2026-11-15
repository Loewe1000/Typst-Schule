// Mit sichtbaren Lösungen stehen `luecke` und `lsg` ausgefüllt da; `fallback` entfällt.
// erwartet: ist Paris\.
// erwartet: Wert 42
// erwartet: Lösung a\)
// erwartet: Lösungsfassung
// nicht: NUR-IM-BLATT
#import "@schule/arbeitsblatt:0.5.0": *
#show: arbeitsblatt.with(title: [L], solutions: "in-place", print: true)
#aufgabe[
  + Die Hauptstadt ist #luecke[Paris]. #loesung[Paris]
  + Wert #lsg[42] #lsg(fallback: [NUR-IM-BLATT])[sichtbar]
]
#context if has-solutions() [Lösungsfassung] else [Blattfassung]
