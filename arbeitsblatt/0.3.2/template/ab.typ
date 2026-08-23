#import "@schule/arbeitsblatt:0.3.2": *

#show: arbeitsblatt.with(
  title: [Titel],
  class: [Klasse],
  print: true,
  // Bundle-Export (typst compile --features bundle --format bundle):
  // varianten: ("druck", "digital", "loesung"),
  // Alle Varianten in der Preview sehen: im Editor den System-Input
  // vorschau=alle setzen, siehe Doku "Alle Varianten in der Vorschau".
)

#aufgabe[
  Aufgabe ohne Namen
]

#aufgabe(title: [Name])[
  + Teilaufgabe
  + Teilaufgabe
]