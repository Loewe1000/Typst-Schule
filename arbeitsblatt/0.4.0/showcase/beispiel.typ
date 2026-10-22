// Beispielblatt für den Theme-Showcase. Nur die üblichen Befehle – das Theme
// kommt von außen:
//
//   typst compile --root ../.. --input theme=klar beispiel.typ klar.pdf
//   typst compile --input theme=klar --input loesungen=sofort beispiel.typ
#import "@schule/arbeitsblatt:0.4.0": *

#show: arbeitsblatt.with(
  title: "Größen umrechnen",
  class: sys.inputs.at("class", default: "MA-05"),
  print: true,
  theme: sys.inputs.at("theme", default: "klar"),
  loesungen: sys.inputs.at("loesungen", default: "keine"),
)

#info(title: "Darum geht es")[
  Größen bestehen aus einer *Maßzahl* und einer *Maßeinheit*. Wer umrechnet,
  ändert beide – die Größe selbst bleibt gleich.
  - Du rechnest Längen und Gewichte in benachbarte Einheiten um.
  - Du vergleichst Größen mit verschiedenen Einheiten.
]

== Längen

#memo[
  Von einer Einheit zur nächstkleineren multiplizierst du mit der
  *Umrechnungszahl*, zur nächstgrößeren dividierst du.
  #align(center, table(
    columns: 5,
    align: center,
    inset: (x: 10pt, y: 6pt),
    table.header[*km*][*m*][*dm*][*cm*][*mm*],
    [], [$dot 1000$], [$dot 10$], [$dot 10$], [$dot 10$],
  ))
]

#aufgabe(title: "Längen umrechnen")[
  Rechne in die angegebene Einheit um.
  #teilaufgaben(
    columns: 3,
    tasks: ([$4 "m" =$ #lücke[400] cm], [$7 "cm" =$ #lücke[70] mm], [$3 "km" =$ #lücke[3000] m],
      [$800 "cm" =$ #lücke[8] m], [$50 "mm" =$ #lücke[5] cm], [$9000 "m" =$ #lücke[9] km]),
    loesungen: ([400 cm], [70 mm], [3000 m], [8 m], [5 cm], [9 km]),
  )
]

#aufgabe(title: "Wer ist länger?")[
  Setze $<$, $>$ oder $=$ ein und begründe kurz.
  + $3 "m"$ #box(width: 1.4em, height: 1.2em, stroke: 0.6pt + luma(140), baseline: 0.25em) $250 "cm"$
    #loesung[$3 "m" = 300 "cm" > 250 "cm"$]
  + $4 "km"$ #box(width: 1.4em, height: 1.2em, stroke: 0.6pt + luma(140), baseline: 0.25em) $4000 "m"$
    #loesung[$4 "km" = 4000 "m"$, also gleich lang.]
]

#tip[Rechne zuerst beide Größen in *dieselbe* Einheit um – dann kannst du sie direkt vergleichen.]

#aufgabe(title: "Der Schulweg", method: "PA")[
  Mia läuft morgens $1 "km"$ und $350 "m"$ zur Schule, Ben nur $1200 "m"$.
  + Wie weit ist Mias Schulweg in Metern?
    #loesung[$1 "km" + 350 "m" = 1000 "m" + 350 "m" = 1350 "m"$]
  + Um wie viele Meter ist Mias Weg länger als Bens?
    #loesung[$1350 "m" - 1200 "m" = 150 "m"$]
  #workspace(kariert(4))
]

== Gewichte

#aufgabe[
  Ordne die Tiere nach ihrem Gewicht. Beginne mit dem leichtesten.
  #align(center, table(
    columns: 4,
    align: center,
    inset: (x: 12pt, y: 6pt),
    table.header[*Katze*][*Hund*][*Pferd*][*Maus*],
    [$4 "kg"$], [$12000 "g"$], [$0.5 "t"$], [$20 "g"$],
  ))
  #loesung[Maus ($20 "g"$) – Katze ($4 "kg"$) – Hund ($12 "kg"$) – Pferd ($500 "kg"$)]
]

#warning(title: "Vorsicht, Falle")[Bei *Zeit* ist die Umrechnungszahl nicht 10 oder 1000: $1 "h" = 60 "min"$.]
