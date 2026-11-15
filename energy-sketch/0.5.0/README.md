# energy-sketch

`energy-sketch` zeichnet Energiekonten für Arbeitsblätter in Physik und Chemie: je Energieform eine karierte Spalte mit Beschriftung, in die die Energiebalken eingezeichnet werden.

## Import

```typ
#import "@schule/energy-sketch:0.5.0": energy-sketch
```

## Beispiel

```typ
#energy-sketch(
  ($E_"kin"$, $E_"pot"$, $E_"ges"$),
  labeled: true,   // false: Beschriftungen weglassen
  height: 3cm,     // Höhe des Rasters (immer 10 Zeilen)
  gutter: 6pt,     // Abstand zwischen den Spalten
)
```

Das Handbuch unter `docs/` zeigt alle Varianten mit gesetzten Beispielen.

Umstieg von älteren Versionen: Namen siehe Handbuch, Abschnitt Umstieg.
