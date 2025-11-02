#import "lib.typ": *

// Einfaches Beispiel mit drei Energie-Labels
= Einfaches Beispiel
#let energies = ("E", "E₁", "E₂")

Hier ein einfaches Diagramm mit drei Energieleveln:

#energy-sketch(energies)

// Labels ausblenden
= Labels ausblenden
Wenn wir die Beschriftungen nicht benötigen, können wir sie ausblenden:

#energy-sketch(energies, hide-letters: true)

// Höhe anpassen
= Höhe anpassen
Wenn wir das Diagramm größer anzeigen möchten, erhöhen wir einfach die Höhe:

#let more-energies = ("A", "B", "C", "D")
#energy-sketch(more-energies, height: 5cm)

Hier sehen wir ein höheres Diagramm mit vier Energieniveaus.