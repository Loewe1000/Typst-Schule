# mathematik

Werkzeuge für den Mathematikunterricht in Typst: Funktionsgraphen im Koordinatensystem mit Flächen, Punkten und Messreihen, Steckbriefaufgaben mit Gleichungssystem und Funktionsgleichung, Kreisdiagramme und die nachgebildete Algebra-Ansicht von GeoGebra.

Die Bausteine haben deutsche Namen (`graphen`, `steckbrief`, `kreisdiagramm`), alles in den Klammern ist englisch. Dazu kommen `geogebra-algebra`, `geogebra-cell` und `geogebra-style`.

## Import

```typ
#import "@schule/mathematik:0.5.0": *
```

## Beispiel

```typ
#import "@schule/mathematik:0.5.0": *

#graphen(
  $x^2 - 2$,
  (term: $0,5 x + 1$, accent: red, labels: ((x: 2, body: $g$),)),
  domain: (x: (-3, 3), y: (-3, 5)),
  areas: ((between: ($x^2 - 2$, $0,5 x + 1$), domain: "intersections"),),
  marks: ((at: (0, -2), body: [$S$], position: "bottom-right"),),
)

#let sb = steckbrief("f(0)=2", "f'(0)=0", "f(2)=0", "f'(2)=0")
Ansatz #sb.ansatz, Ergebnis #sb.math

#kreisdiagramm((("Äpfel", 35), ("Birnen", 45), ("Kirschen", 20)), legend-position: "bottom")

#geogebra-algebra($v = vec(2, 1, 5)$, $P = (3, 1, -3)$)
```

## Umstieg von älteren Versionen

Namen siehe Handbuch, Abschnitt „Umstieg auf 0.5.0". Alte Namen brechen beim Kompilieren mit einer Meldung ab, die den neuen Namen nennt.
