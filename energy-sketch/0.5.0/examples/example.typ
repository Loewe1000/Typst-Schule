#import "@schule/energy-sketch:0.5.0": energy-sketch

= Einfaches Beispiel
#let energies = ($E_"kin"$, $E_"pot"$, $E_"ges"$)

Hier ein einfaches Diagramm mit drei Energieformen:

#energy-sketch(energies)

= Labels ausblenden
Wenn die Beschriftungen erst von Schülerinnen und Schülern ergänzt werden sollen,
können sie ausgeblendet werden:

#energy-sketch(energies, labeled: false)

= Höhe anpassen
Wenn das Diagramm größer dargestellt werden soll, kann die Höhe erhöht werden:

#let more-energies = ("A", "B", "C", "D")
#energy-sketch(more-energies, height: 5cm)

Hier sehen wir ein höheres Diagramm mit vier Energieniveaus.

= Abstand zwischen Spalten

Mit `gutter` lässt sich zusätzlicher Abstand zwischen den einzelnen Konten einfügen:

#energy-sketch(
  ($E_"kin"$, $E_"pot"$, $E_"ges"$),
  gutter: 6pt,
)

= Typst-Content als Label

Auch formatierter Typst-Content ist als Beschriftung möglich:

#energy-sketch((
  [*kinetisch*],
  [potenziell],
  [$E_("ges")$],
), gutter: 6pt)
