#import "@schule/arbeitsblatt:0.3.0": *

#show: arbeitsblatt.with(
  title: [Titel],
  class: [Klasse],
  print: true,
  // Bundle-Export (typst compile --features bundle --format bundle):
  // varianten: ("druck", "digital", "loesung"),
)

#aufgabe[
  Aufgabe ohne Namen
]

#aufgabe(title: [Name])[
  + Teilaufgabe
  + Teilaufgabe
]