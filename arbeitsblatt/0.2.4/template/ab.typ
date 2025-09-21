#import "@schule/arbeitsblatt:0.2.4": *

#show: arbeitsblatt.with(
  title: [Titel],
  class: [Klasse],
  print: true,
)

#aufgabe[
  Aufgabe ohne Namen
]

#aufgabe(title: [Name])[
  + Teilaufgabe
  + Teilaufgabe
]