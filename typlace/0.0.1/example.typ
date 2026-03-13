#import "typlace.typ": typlace

#set page(paper: "presentation-16-9", margin: 0cm)
#set text(lang: "de", font: "Arial", weight: "bold", size: 16pt)
#set align(center + horizon)

#let namen = (
  "Levin", "Mats B.", "", "Emanuel",
  "", "Jante", "Liam", "Tom",
  "Mats V.", "Mascha", "Mia", "Finn",
  "Jannik", "Leonora", "Lotta", "Leni",
  "Linus", "Lia", "Caroline", "Vincent",
  "Max", "Anna-Malou", "Alissa", "Theo",
  "Juri", "Charlotte", "Frida", "Kira",
  "Valerii", "Elisabeth", "Felina", "Matheo",
)

#let layout = "
XXXXPPPPXXX
XXXXXXXXXXXX
XTTTTXXTTTTX
XXXXXXXXXXXX
XTTTTXXTTTTX
XXXXXXXXXXXX
XTTTTXXTTTTX
XXXXXXXXXXXX
XTTTTXXTTTTX
"

#typlace(layout, namen: namen, tisch-breite: 2.4cm, tisch-hoehe: 1.5cm, tisch-farbe: gray.lighten(80%))

#pagebreak()

#typlace(layout, namen: namen, rotation: 180, tisch-breite: 2.4cm, tisch-hoehe: 1.5cm, tisch-farbe: gray.lighten(80%))