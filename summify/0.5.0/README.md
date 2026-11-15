# summify

Zusammenfassungen und Spickzettel im Raster: eine Seite (in der Vorgabe A3
quer) mit farbigen Themenboxen, Abschnitten und Zellen. Vier Farbthemen sind
dabei; ein Lernmodus blendet die Inhalte aus, sodass ein Blatt zum Ausfüllen
entsteht.

## Import

```typ
#import "@schule/summify:0.5.0": *
```

## Beispiel

```typ
#import "@schule/summify:0.5.0": *

#show: summify.with(title: [Physik – Mechanik], theme: "modern-blue")

#beside[
  #topic(title: [Kinematik])[
    #section[Gleichförmige Bewegung]
    #cell[$s = v dot t$]
  ]
][
  #topic(title: [Dynamik])[
    #cell-columns[
      #cell(title: [Kraft])[$F = m dot a$]
    ][
      #cell(title: [Impuls])[$p = m dot v$]
    ]
  ]
]
```

`visible: false` in `summify` blendet die Inhalte aller Zellen aus.

## Umstieg von älteren Versionen

Namen siehe Handbuch, Abschnitt „Umstieg auf 0.5.0". Alte Namen brechen beim
Kompilieren mit der Meldung „heißt jetzt" und dem neuen Namen ab.
