#import "@preview/mantys:1.0.2": *

#import "../mathematik.typ" as math

#import "@preview/codly:1.3.0": *

#show: mantys(
  name: "mathematik",
  version: "0.0.2",
  authors: (
    "Lukas Köhl",
    "Alexander Schulz",
  ),
  license: "MIT",
  description: "Ein umfassendes Paket für mathematische Visualisierungen und Funktionen für den Mathematikunterricht.",

  abstract: [
    Das `mathematik` Paket bietet eine umfassende Sammlung von Funktionen für den Mathematikunterricht. Es ermöglicht die Erstellung von Funktionsgraphen mit automatischer Achsenskalierung, Koordinatensystemen, Füllbereichen zwischen Funktionen und vielen weiteren Features. Das Paket integriert CeTZ für hochwertige Visualisierungen und bietet spezielle Hilfsfunktionen für die Strukturierung von Aufgaben.
  ],

  examples-scope: (
    scope: (mathematik: math),
    imports: (mathematik: "*"),
  ),
)

#show: codly-init.with()
#codly(number-format: none)

#pagebreak(weak: true)
= Über das Paket <sec:about>

Das `mathematik` Paket ist eine umfassende Lösung zur Erstellung mathematischer Visualisierungen und Diagramme für den Schulbereich. Es wurde entwickelt, um Lehrkräften ein mächtiges Werkzeug für die Darstellung von Funktionsgraphen, Koordinatensystemen und mathematischen Konzepten zu bieten.

Dieses Manual ist eine vollständige Referenz aller Funktionen des `mathematik` Pakets.

== Terminologie

In diesem Manual werden folgende Begriffe verwendet:

- *Graph*: Die visuelle Darstellung einer mathematischen Funktion
- *Domain*: Der Definitionsbereich einer Funktion (x-Bereich)
- *Fill*: Gefüllter Bereich zwischen zwei Funktionen oder einer Funktion und der x-Achse
- *Annotation*: Beschriftungen und Markierungen im Koordinatensystem
- *Plot*: Gesamtdarstellung mit Achsen, Gitternetz und Funktionsgraphen

== Abhängigkeiten

Das Paket nutzt folgende externe Pakete:
- `@preview/cetz`: Für Grafikfunktionen
- `@preview/cetz-plot`: Für Plot-Funktionalität
- `@preview/eqalc`: Für Konvertierung von Mathe-Content zu Funktionen
- `@schule/random`: Für Zufallsfunktionen
- `@schule/physik`: Für Einheitenumrechnung

= Schnelleinstieg <sec:quickstart>

== Erste Schritte

1. *Installation*: Importieren Sie das Paket
2. *Einfacher Graph*: Erstellen Sie einen Graph mit `#graphen()`
3. *Anpassungen*: Konfigurieren Sie Achsen, Gitternetz und Farben
4. *Erweitert*: Nutzen Sie Füllbereiche, Datensätze und Annotationen

= Verwendung <sec:usage>

== Funktionsgraphen <sec:graphs>

=== Einfache Graphen

Die grundlegende Syntax für Funktionsgraphen:

#example[```
// Eine Funktion als Math-Content
#graphen($x^2$)
```]

Mehrere Funktionen in einem Koordinatensystem:

#example[```
#graphen(
  x: (-3, 3),
  y: (-5, 10),
  $x^2$,
  $x^3$,
  $2 dot x$
)
```]

Mit benutzerdefinierten Achsenbereichen:

#example[```
#graphen(
  x: (-7, 7),
  y: (-5, 5),
  $sin(x)$,
  $cos(x)$
)
```]

=== Funktionen mit Domains

Jede Funktion kann einen eigenen Definitionsbereich haben:

#example[```
#graphen(
  x: (-5, 5),
  y: (-3, 3),
  // (domain, function)
  ((-2, 2), $x^2$),
  ((-5, -2), $-x - 2$),
  ((2, 5), $x - 2$)
)
```]

=== Funktionen mit Farben

Farben können als Integer (Index) oder als Farbobjekt angegeben werden:

#example[```
#graphen(
  x: (-3, 3),
  y: (-2, 10),
  // (domain, function, color)
  ((-3, 3), $x^2$, 3),        // Grün (Farbe 3)
  ((-3, 3), $2 dot x + 1$, red),  // Rot
  ((-3, 3), $sin(x)$, 1)      // Blau (Farbe 1)
)
```]

=== Funktionen mit Labels

Funktionen können direkt im Graph beschriftet werden:

#example[```
#graphen(
  x: (-3, 3),
  y: (-2, 10),
  ($x^2$, (
    label: (
      x: 2,
      content: [$f(x) = x^2$],
      position: "br",  // bottom-right
      color: blue
    )
  ))
)
```]

Label-Optionen:
- `x`: x-Position des Labels (erforderlich)
- `content`: Beschriftungstext (erforderlich)
- `position`: Position relativ zum Punkt (`"tl"`, `"tr"`, `"bl"`, `"br"`)
- `color`: Textfarbe
- `fill`: Hintergrundfarbe
- `size`: Schriftgröße
- `padding`: Abstand vom Punkt

== Füllbereiche <sec:fills>

=== Fläche unter einer Funktion

#example[```
#graphen(
  x: (-5, 5),
  y: (-3, 3),
  $sin(x)$,
  fills: ((0, calc.pi), $sin(x)$)
)
```]

=== Fläche zwischen zwei Funktionen

#example[```
#graphen(
  x: (-3, 3),
  y: (-2, 10),
  $x^2$,
  $2 dot x + 1$,
  fills: ((0, 2), $x^2$, $2 dot x + 1$)
)
```]

=== Automatische Schnittpunkt-Erkennung

Ohne Angabe einer Domain werden automatisch die Schnittpunkte (numerisch) ermittelt:

#example[```
#graphen(
  x: (-3, 3),
  y: (-2, 10),
  $x^2$,
  $2 dot x + 1$,
  fills: ($x^2$, $2 dot x + 1$)
)
```]

=== Mehrere Füllbereiche

#example[```
#graphen(
  x: (-1, 8),
  y: (-3, 3),
  $sin(x)$,
  fills: (
    ((0, calc.pi), $sin(x)$, green.transparentize(70%)),
    ((calc.pi, 2*calc.pi), $sin(x)$, red.transparentize(70%))
  )
)
```]

== Datensätze aus Physik-Paket <sec:datasets>

Das Paket kann Datensätze aus dem Physik-Paket direkt plotten:

#example[```
  #import "@schule/physik:0.0.2": datensatz

  #let zeit = datensatz($t$, "s", (0, 1, 2, 3, 4, 5))
  #let strecke = datensatz($s$, "m", (0, 2, 8, 18, 32, 50))

  #graphen(
    size: (10, 7),
    datensätze: (zeit, strecke),
    x: auto, // Automatische Bereichserkennung
    y: auto,
  )
```]

Mit benutzerdefinierten Markern und Farben:

```typ
#graphen(
  datensätze: (
    ((zeit, strecke), (marker: "o", color: blue)),
    ((zeit, geschw), (marker: "x", color: red))
  )
)
```

== Koordinatensystem-Anpassungen <sec:customization>

=== Achsenbeschriftung

```typ
#graphen(
  x: (-5, 5),
  y: (-3, 3),
  x-label: [$t$ in s],
  y-label: [$v$ in m/s],
  $x$
)
```

=== Gitternetz

```typ
#graphen(
  x: (-5, 5),
  y: (-5, 5),
  grid: "both",      // "major", "minor", "both", "none"
  x-step: 1,         // Hauptgitterlinien alle 1 Einheit
  y-step: (2, 0.5),  // Haupt alle 2, Neben alle 0.5
  $x^2$
)
```

=== Skalierung

```typ
#graphen(
  size: (10, 5),  // Breite 10cm, Höhe 5cm
  scale: 1.5,     // Gesamtskalierung
  x: (-5, 5),
  y: (-3, 3),
  $sin(x)$
)
```

=== Sampling

Für glattere oder detailliertere Kurven:

```typ
#graphen(
  x: (-10, 10),
  y: (-2, 2),
  samples: 500,  // Standard: 200
  $sin(x) / x$
)
```

== Teilaufgaben <sec:tasks>

=== Layout für Teilaufgaben

Die `teilaufgaben()` Funktion erstellt ein Grid-Layout für Aufgaben und unterstützt verschiedene Syntax-Varianten:

==== Variante 1: Positionelle Argumente

```typ
#import "@schule/aufgaben:0.1.2": aufgabe, teilaufgabe, loesung

#aufgabe[
  Berechnen Sie:

  #teilaufgaben(
    columns: 2,
    [$2 + 3$],
    [$5 times 7$],
    [$sqrt(16)$],
    [$10 / 2$]
  )
]
```

==== Variante 2: Mit tasks-Parameter und Lösungen

```typ
#teilaufgaben(
  columns: 2,
  tasks: (
    [$2 + 3$],
    [$5 times 7$],
    [$sqrt(16)$],
    [$10 / 2$]
  ),
  loesungen: (
    [$5$],
    [$35$],
    [$4$],
    [$5$]
  )
)
```

==== Variante 3: Enum-Syntax (mit aufgaben-Paket)

Die eleganteste Variante nutzt die native Enum-Syntax von Typst:

```typ
#teilaufgaben[
  + Berechnen Sie $2 + 3$
    #loesung[$5$]
  + Berechnen Sie $5 times 7$
    #loesung[$35$]
  + Berechnen Sie $sqrt(16)$
    #loesung[$4$]
  + Berechnen Sie $10 / 2$
    #loesung[$5$]
]
```

Diese Variante ist besonders praktisch, da:
- Die Nummerierung automatisch erfolgt
- Lösungen direkt bei der jeweiligen Aufgabe stehen
- Die Syntax natürlicher und lesbarer ist
- Keine explizite Angabe der tasks oder loesungen nötig ist

= API-Referenz <sec:api-reference>

== Hauptfunktionen

#command("graphen")[
  Erstellt ein Koordinatensystem mit Funktionsgraphen.

  #argument("size", types: "content, array", default: none)[
    Größe des Koordinatensystems. Kann eine Zahl (für quadratisch) oder ein Array `(breite, höhe)` sein. Wenn `none`, wird die Größe aus den Achsenbereichen berechnet.
  ]

  #argument("scale", types: "float", default: 1)[
    Skalierungsfaktor für das gesamte Koordinatensystem.
  ]

  #argument("x", types: "array", default: (-5, 5))[
    x-Achsenbereich als Array `(min, max)`. Kann auch `auto` sein für automatische Erkennung (bei Datensätzen).
  ]

  #argument("y", types: "array", default: (-5, 5))[
    y-Achsenbereich als Array `(min, max)`. Kann auch `auto` sein für automatische Erkennung (bei Datensätzen).
  ]

  #argument("step", types: "integer, float, array", default: 1)[
    Schrittweite für Gitterlinien. Kann ein Wert (für beide Achsen) oder ein Array für unterschiedliche Schrittweiten sein. Format: `wert` oder `(major, minor)`.
  ]

  #argument("x-step", types: "integer, float, array", default: none)[
    Spezifische Schrittweite für x-Achse. Überschreibt `step` für x-Achse.
  ]

  #argument("y-step", types: "integer, float, array", default: none)[
    Spezifische Schrittweite für y-Achse. Überschreibt `step` für y-Achse.
  ]

  #argument("x-label", types: "content", default: [$x$])[
    Beschriftung der x-Achse.
  ]

  #argument("y-label", types: "content", default: [$y$])[
    Beschriftung der y-Achse.
  ]

  #argument("grid", types: "string", default: "both")[
    Gitternetz-Modus: `"major"`, `"minor"`, `"both"`, oder `"none"`.
  ]

  #argument("x-grid", types: "string", default: none)[
    Spezifisches Gitternetz für x-Achse. Überschreibt `grid`.
  ]

  #argument("y-grid", types: "string", default: none)[
    Spezifisches Gitternetz für y-Achse. Überschreibt `grid`.
  ]

  #argument("line-width", types: "length", default: 1.5pt)[
    Linienbreite für Funktionsgraphen.
  ]

  #argument("samples", types: "integer", default: 200)[
    Anzahl der Samplingpunkte für Funktionsgraphen.
  ]

  #argument("fills", types: "array", default: ())[
    Array von Füllbereichs-Definitionen. Formate:
    - `($f$)`: Fläche unter Funktion f
    - `((x1, x2), $f$, $g$)`: Fläche zwischen f und g im Bereich x1 bis x2
    - `($f$, $g$)`: Automatische Schnittpunkt-Erkennung
    - `((x1, x2), $f$, $g$, color)`: Mit benutzerdefinierter Farbe
  ]

  #argument("datensätze", types: "array, tuple", default: ())[
    Datensätze aus dem Physik-Paket zum Plotten. Formate:
    - `(x-ds, y-ds)`: Ein Datensatz-Paar
    - `(x-ds, y1-ds, y2-ds, ...)`: Mehrere y-Datensätze mit gleichem x
    - `((x-ds, y-ds), (options))`: Mit Marker und Farbe
    - `(x-array, y-array)`: Einfache Zahlen-Arrays
  ]

  #argument("plots", types: "content, function, array", default: ())[
    Funktionsdefinitionen zum Plotten. Formate:
    - `$f$`: Funktion als Math-Content
    - `x => expr`: Funktion als Closure
    - `((x1, x2), $f$)`: Funktion mit Domain
    - `((x1, x2), $f$, color)`: Mit Farbe
    - `($f$, (label: ..., color: ...))`: Mit Label und Optionen
  ]

  #argument("annotations", types: "content", default: none)[
    Zusätzliche Annotationen, die mit CeTZ-Draw-Befehlen erstellt werden.
  ]
]

#command("teilaufgaben", alias: "tasks")[
  Erstellt ein Grid-Layout für Teilaufgaben mit mehreren Syntax-Varianten.

  #argument("tasks", types: "array", default: ())[
    Array von Aufgaben-Content. Kann auch leer sein, wenn Aufgaben als positionelle Argumente übergeben werden oder als Body mit Enum-Syntax.
  ]

  #argument("columns", types: "integer, auto", default: auto)[
    Anzahl der Spalten. Bei `auto` werden die Aufgaben in einer Zeile angeordnet.
  ]

  #argument("numbering", types: "string", default: "a)")[
    Nummerierungsschema für Teilaufgaben.
  ]

  #argument("gutter", types: "length", default: 1.25em)[
    Abstand zwischen Aufgaben (horizontal und vertikal).
  ]

  #argument("loesungen", types: "array", default: ())[
    Array von Lösungen für die Teilaufgaben. Wird automatisch jeder Aufgabe zugeordnet.
  ]

  Die Funktion unterstützt drei verschiedene Syntax-Varianten:

  *Variante 1: Positionelle Argumente*
  ```typ
  #teilaufgaben(columns: 2, [$2 + 3$], [$5 times 7$])
  ```

  *Variante 2: Mit tasks und loesungen Parameter*
  #sourcecode[```typ
  #teilaufgaben(
    columns: 2,
    gutter: 2em,
    tasks: (
      [$2 + 3$],
      [$5 times 7$],
      [$sqrt(16)$],
      [$10 / 2$]
    ),
    loesungen: (
      [$5$],
      [$35$],
      [$4$],
      [$5$]
    )
  )
  ```]

  *Variante 3: Enum-Syntax (empfohlen)*
  #sourcecode[```typ
  #teilaufgaben[
    + Berechnen Sie $2 + 3$
      #loesung[$5$]
    + Berechnen Sie $5 times 7$
      #loesung[$35$]
    + Berechnen Sie $sqrt(16)$
      #loesung[$4$]
    + Berechnen Sie $10 / 2$
      #loesung[$5$]
  ]
  ```]
]

= Erweiterte Techniken <sec:advanced>

== Mathematische Funktionen

Das Paket unterstützt alle Typst-Mathe-Funktionen:

```typ
#graphen(
  x: (-2*calc.pi, 2*calc.pi),
  y: (-2, 2),
  $sin(x)$,
  $cos(x)$,
  $tan(x)$,
  $sin(x) / x$
)
```

== Kombination mit Aufgaben-Paket

Vollständige Integration mit dem `@schule/aufgaben` Paket:

```typ
#import "@schule/aufgaben:0.1.2": *

#set_options((
  loesungen: "folgend"
))

#aufgabe(title: [Funktionsanalyse])[
  Skizzieren Sie den Graphen der Funktion $f(x) = x^2 - 4$.

  #loesung[
    #graphen(
      x: (-5, 5),
      y: (-5, 5),
      $x^2 - 4$
    )

    Die Funktion hat Nullstellen bei $x = plus.minus 2$.
  ]
]
```

== Performance-Optimierung

Für komplexe Graphen mit vielen Funktionen:

```typ
// Weniger Samples für schnelleres Rendern
#graphen(
  samples: 100,
  $sin(x) * cos(x) * tan(x)$
)

// Mehr Samples für glattere Kurven (langsamer)
#graphen(
  samples: 500,
  $1 / x$
)
```

= Beispielgalerie <sec:examples>

== Quadratische Funktionen

#example[```
#graphen(
  x: (-5, 5),
  y: (-2, 15),
  $x^2$,
  $x^2 + 2 dot x + 1$,
  $-x^2 + 4$,
  fills: (
    ((-2, 2), $x^2$, $-x^2 + 4$)
  )
)
```]

== Trigonometrische Funktionen

#example[```
#graphen(
  x: (-2*calc.pi, 2*calc.pi),
  y: (-1.5, 1.5),
  x-step: calc.pi / 2,
  $sin(x)$,
  $cos(x)$
)
```]

== Exponentialfunktionen

#example[```
#graphen(
  x: (-3, 3),
  y: (0, 8),
  $e^x$,
  $2^x$,
  $e^(-x)$
)
```]

== Datensatz-Visualisierung

```typ
#import "@schule/physik:0.0.2": datensatz

#let zeit = datensatz($t$, "s", (0, 1, 2, 3, 4))
#let weg = datensatz($s$, "m", (0, 5, 20, 45, 80))

#graphen(
  datensätze: (zeit, weg),
  x: auto,
  y: auto,
  // Regressionskurve hinzufügen
  ($5 * x^2$)
)
```

= Fehlerbehebung <sec:troubleshooting>

== Häufige Probleme

=== Funktion wird nicht angezeigt

- Überprüfen Sie, ob die Funktion im angegebenen Bereich definiert ist
- Erhöhen Sie `samples` für komplexe Funktionen
- Passen Sie die Achsenbereiche an

=== Automatische Domain-Erkennung funktioniert nicht

- Die Funktion benötigt mindestens zwei Schnittpunkte im sichtbaren Bereich
- Verwenden Sie manuelle Domain-Angaben als Fallback
- Erhöhen Sie `samples` für bessere Schnittpunkt-Erkennung

=== Farben werden nicht korrekt angezeigt

- Farb-Indizes sind 1-basiert (1-10)
- RGB-Werte müssen als `rgb("#...")` übergeben werden
- Transparenz mit `.transparentize(percentage)` hinzufügen

= Lizenz und Beiträge <sec:license>

Das Paket steht unter der MIT-Lizenz und ist Teil der `@schule` Paketfamilie.

Entwickelt von Lukas Köhl und Alexander Schulz.
