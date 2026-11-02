// Lösungen ("folgend") und Material von Shortcode-Teilaufgaben erscheinen,
// ohne Doppelungen bei Teilaufgaben im Rumpf.
// erwartet: L-i1
// erwartet: L-s1
// erwartet: L-s2
// erwartet: M2-B
// nicht: M1-B
#import "@schule/arbeitsblatt:0.4.0": *
#show: arbeitsblatt.with(title: [T], loesungen: "folgend", materialien: "sofort", aufgaben-shortcodes: "alle")
#aufgabe[Innen][Rumpf #teilaufgabe[i1 #loesung[L-i1] #material[M-i1]]]
= Shortcode
Einleitung
+ s1 #loesung[L-s1] #material[M-s1]
+ s2 #loesung[L-s2] #material[M-s2]
