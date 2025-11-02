#import "@preview/mantys:1.0.2": *

#import "../mathematik.typ" as math
#import "@schule/arbeitsblatt:0.2.4" as ab

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
    scope: (mathematik: math, arbeitsblatt: ab),
    imports: (mathematik: "*", arbeitsblatt: "*"),
  ),
)

= Über dieses Paket

Das #package[mathematik] Paket ist eine umfassende Lösung zur Erstellung mathematischer Visualisierungen und Diagramme für den Schulbereich. Es wurde entwickelt, um Lehrkräften ein mächtiges Werkzeug für die Darstellung von Funktionsgraphen, Koordinatensystemen und mathematischen Konzepten zu bieten.

Dieses Manual gliedert sich wie folgt:
1. *Installation und Import* -- Erste Schritte
2. *Funktionsgraphen* -- Erstellen von Graphen
3. *Füllbereiche* -- Flächen zwischen Funktionen
4. *Datensätze* -- Integration mit dem Physik-Paket
5. *Teilaufgaben* -- Layout-Hilfsfunktionen
6. *Funktionsreferenz* -- Vollständige API-Dokumentation

= Installation und Import

== Paket importieren

Das Paket kann aus dem Typst-Repository importiert werden:

#sourcecode[```typ
#import "@schule/mathematik:0.0.2": *
```]

Für lokale Entwicklung:

#sourcecode[```typ
#import "@schule/mathematik:0.0.2": *
```]

== Abhängigkeiten

Das Paket importiert automatisch:
- #package[cetz] (Version 0.4.2) -- Grafikfunktionen
- #package[cetz-plot] (Version 0.1.3) -- Plot-Funktionalität
- #package[eqalc] (Version 0.1.3) -- Konvertierung von Mathe-Content zu Funktionen
- #package[schule/random] -- Zufallsfunktionen
- #package[schule/physik] -- Einheitenumrechnung und Datensätze
- #package[schule/aufgaben] -- Für Teilaufgaben-Integration

= Funktionsgraphen

== Einfache Graphen

Die grundlegende Syntax für Funktionsgraphen:

#example[```typ
#import "@schule/mathematik:0.0.2": *

#graphen($x^2$)
```]

Mehrere Funktionen in einem Koordinatensystem:

#example[```typ
#graphen(
  x: (-3, 3),
  y: (-5, 10),
  $x^2$,
  $x^3$,
  $2 dot x$
)
```]
#pagebreak(weak: true)
== Funktionen als Content oder Closures

Funktionen können als Math-Content oder als Typst-Closures übergeben werden:

#example[```typ
// Als Math-Content
#graphen($sin(x)$, size: 7)

// Als Closure
#graphen(x => calc.sin(x), size: 7)
```]
#pagebreak(weak: true)
== Funktionen als Dictionary

Für erweiterte Kontrolle können Funktionen als Dictionary übergeben werden:

#example[```typ
#graphen(
  x: (-5, 5),
  y: (-3, 3),
  (
    term: $x^2$,
    domain: (0, 2),
    color: red,
  ),
  (
    term: $sin(x)$,
    color: blue,
  )
)
```]

Dictionary-Format:
- `term`: Funktion als Content oder Closure (erforderlich)
- `domain`: Definitionsbereich als `(min, max)` (optional, Standard: x-Bereich)
- `color` oder `clr`: Farbe als Color-Objekt oder Integer 1-10 (optional)
- `label`: Label-Definition als Dictionary (optional)

== Achsenbereiche anpassen

#example[```typ
#graphen(
  x: (-7, 7),
  y: (-5, 5),
  $sin(x)$,
  $cos(x)$
)
```]
#pagebreak(weak: true)
== Farben

Farben können als Integer (Index 1-10) oder als Farbobjekt angegeben werden:

#example[```typ
#graphen(
  x: (-3, 3),
  y: (-2, 10),
  (term: $x^2$, color: 3),        // Grün (Farbindex 3)
  (term: $2 dot x + 1$, color: red),  // Rot
  (term: $sin(x)$, color: 1)      // Blau (Farbindex 1)
)
```]

Verfügbare Farbindizes (1-10):
1. Blau, 2. Rot, 3. Grün, 4. Orange, 5. Violett, 6. Braun, 7. Pink, 8. Grau, 9. Olivgrün, 10. Cyan
#pagebreak(weak: true)
== Funktions-Labels

Funktionen können direkt im Graph beschriftet werden:

#example[```typ
#graphen(
  x: (-3, 3),
  y: (-2, 4),
  (
    term: $x^2$,
    label: (
      x: 1,
      content: [$f(x) = x^2$],
      position: "br",  // bottom-right
      color: blue
    )
  )
)
```]

Label-Optionen:
- `x`: x-Position des Labels (erforderlich)
- `content`: Beschriftungstext (erforderlich)
- `position`: Position relativ zum Punkt: `"tl"` (top-left), `"tr"` (top-right), `"bl"` (bottom-left), `"br"` (bottom-right)
- `color`: Textfarbe (optional)
- `fill`: Hintergrundfarbe (optional, Standard: weiß)
- `size`: Schriftgröße (optional)
- `padding`: Abstand vom Punkt (optional, Standard: 1mm)

= Füllbereiche

== Fläche unter einer Funktion

#example[```typ
#graphen(
  x: (-5, 5),
  y: (-3, 3),
  $sin(x)$,
  fills: (
    (
      term: $sin(x)$,
      domain: (0, calc.pi),
    )
  )
)
```]

== Fläche zwischen zwei Funktionen

#example[```typ
#graphen(
  x: (-3, 3),
  y: (-2, 10),
  $x^2$,
  $2 dot x + 1$,
  fills: (
    (
      between: ($x^2$, $2 dot x + 1$),
      domain: (0, 2),
    )
  )
)
```]
#pagebreak(weak: true)
== Automatische Schnittpunkt-Erkennung

Ohne Angabe einer Domain werden automatisch die Schnittpunkte numerisch ermittelt:

#example[```typ
#graphen(
  x: (-3, 3),
  y: (-2, 10),
  $x^2$,
  $2 dot x + 1$,
  fills: (
    (
      between: ($x^2$, $2 dot x + 1$),
      domain: "auto",
    )
  )
)
```]

== Mehrere Füllbereiche

#example[```typ
#graphen(
  x: (-1, 8),
  y: (-3, 3),
  $sin(x)$,
  fills: (
    (
      term: $sin(x)$,
      domain: (0, calc.pi),
      color: green.transparentize(70%),
    ),
    (
      term: $sin(x)$,
      domain: (calc.pi, 2*calc.pi),
      color: red.transparentize(70%),
    )
  )
)
```]
#pagebreak(weak: true)
= Datensätze

== Datensätze aus dem Physik-Paket

Das Paket kann Datensätze aus dem Physik-Paket direkt plotten:

#example[```typ
#import "@schule/physik:0.0.2": datensatz

#let zeit = datensatz($t$, "s", (0, 1, 2, 3, 4, 5))
#let strecke = datensatz($s$, "m", (0, 2, 8, 18, 32, 50))

#graphen(
  size: (10, 7),
  datensätze: (x: zeit, y: strecke),
  x: auto, // Automatische Bereichserkennung
  y: auto,
)
```]
#pagebreak(weak: true)
== Einfache Arrays

Datensätze können auch als einfache Zahlen-Arrays übergeben werden:

#example[```typ
#let x-werte = (0, 1, 2, 3, 4)
#let y-werte = (0, 1, 4, 9, 16)

#graphen(
  size: (8, 6),
  datensätze: (x-werte, y-werte),
  x: auto,
  y: auto,
)
```]

#pagebreak(weak: true)
== Datensätze als Dictionary

Für erweiterte Kontrolle können Datensätze als Dictionary übergeben werden:

#example[```typ
#let zeit = datensatz($t$, "s", (0, 1, 2, 3, 4, 5))
#let strecke = datensatz($s$, "m", (0, 2, 8, 18, 32, 50))

#graphen(
  size: (10, 7),
  datensätze: (
    x: zeit,
    y: strecke,
    marker: "o",
    color: blue
  ),
  x: auto,
  y: auto,
)
```]

Dictionary-Format:
- `x`: x-Datensatz (erforderlich)
- `y`: y-Datensatz (erforderlich)
- `marker`: Marker-Stil (optional, Standard: `"x"`)
- `color` oder `clr`: Farbe als Color-Objekt oder Integer 1-10 (optional)

#pagebreak(weak: true)
== Mehrere Datensätze

Mehrere Datensätze können als Array von Dictionaries übergeben werden:

#example[```typ
#let zeit = datensatz($t$, "s", (0, 1, 2, 3))
#let weg1 = datensatz($s_1$, "m", (0, 2, 8, 18))
#let weg2 = datensatz($s_2$, "m", (0, 1, 4, 9))

#graphen(
  size: (10, 7),
  datensätze: (
    (x: zeit, y: weg1, marker: "o", color: blue),
    (x: zeit, y: weg2, marker: "x", color: red),
  ),
  x: auto,
  y: auto,
)
```]

= Koordinatensystem-Anpassungen

== Achsenbeschriftung

#example[```typ
#graphen(
  x: (-5, 5),
  y: (-3, 3),
  x-label: [$t$ in s],
  y-label: [$v$ in m/s],
  $x$
)
```]

== Gitternetz

#example[```typ
#graphen(
  x: (-5, 5),
  y: (-5, 5),
  grid: "major",      // "major", "minor", "both", "none"
  x-step: 1,         // Hauptgitterlinien alle 1 Einheit
  y-step: (2, 0.5),  // Haupt alle 2, Neben alle 0.5
  $x^2$
)
```]

Grid-Optionen:
- `"both"`: Haupt- und Nebengitterlinien (Standard)
- `"major"`: Nur Hauptgitterlinien
- `"minor"`: Nur Nebengitterlinien
- `"none"`: Kein Gitternetz

== Skalierung

#example[```typ
#graphen(
  size: (10, 5),  // Breite 10cm, Höhe 5cm
  scale: 0.5,     // Gesamtskalierung
  x: (-5, 5),
  y: (-3, 3),
  $sin(x)$
)
```]

== Sampling

Für glattere oder detailliertere Kurven:

#example[```typ
#graphen(
  size: (10, 6),
  x: (-10, 10),
  y: (-2, 2),
  samples: 10,  // Standard: 200
  $sin(x) / x$
)
```]

= Teilaufgaben

== Layout für Teilaufgaben

Die `teilaufgaben()` Funktion erstellt ein Grid-Layout für Aufgaben:

#example[```typ
#import "@schule/aufgaben:0.1.2": aufgabe, teilaufgabe, loesung

#aufgabe[
  Berechnen Sie:

  #teilaufgaben(
    columns: 2,
  )[
    + $2 + 3$
    + $5 times 7$
    + $sqrt(16)$
    + $10 / 2$
  ]
]
```]

== Mit Lösungen

#sourcecode[```typ
#import "@schule/aufgaben:0.1.2": aufgabe, teilaufgabe, loesung
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
```]

== Enum-Syntax (empfohlen)

Die eleganteste Variante nutzt die native Enum-Syntax von Typst:

#sourcecode[```typ
#import "@schule/aufgaben:0.1.2": aufgabe, teilaufgabe, loesung
#teilaufgaben[
  + Berechnen Sie $2 + 3$
    #loesung[$5$]
  + Berechnen Sie $5 times 7$
    #loesung[$35$]
  + Berechnen Sie $sqrt(16)$
    #loesung[$4$]
]
```]

Diese Variante ist besonders praktisch, da:
- Die Nummerierung automatisch erfolgt
- Lösungen direkt bei der jeweiligen Aufgabe stehen
- Die Syntax natürlicher und lesbarer ist

= Funktionsreferenz

== Hauptfunktionen

#command(
  "graphen",
  arg(size: none),
  arg(scale: 1),
  arg(x: (-5, 5)),
  arg(y: (-5, 5)),
  arg(step: 1),
  arg(x-step: none),
  arg(y-step: none),
  arg(x-label: [$x$]),
  arg(y-label: [$y$]),
  arg(grid: "both"),
  arg(x-grid: none),
  arg(y-grid: none),
  arg(line-width: 1.5pt),
  arg(samples: 200),
  arg(fills: ()),
  arg(datensätze: ()),
  arg(annotations: {}),
  sarg[plots],
)[
  Erstellt ein Koordinatensystem mit Funktionsgraphen.

  #argument("size", types: ("content", "array", none), default: none)[
    Größe des Koordinatensystems. Kann eine Zahl (für quadratisch) oder ein Array `(breite, höhe)` sein. Wenn `none`, wird die Größe aus den Achsenbereichen berechnet.
  ]

  #argument("scale", types: "float", default: 1)[
    Skalierungsfaktor für das gesamte Koordinatensystem.
  ]

  #argument("x", types: ("array", "auto"), default: (-5, 5))[
    x-Achsenbereich als Array `(min, max)`. Kann auch `auto` sein für automatische Erkennung (bei Datensätzen).
  ]

  #argument("y", types: ("array", "auto"), default: (-5, 5))[
    y-Achsenbereich als Array `(min, max)`. Kann auch `auto` sein für automatische Erkennung (bei Datensätzen).
  ]

  #argument("step", types: ("integer", "float", "array"), default: 1)[
    Schrittweite für Gitterlinien. Kann ein Wert (für beide Achsen) oder ein Array `(major, minor)` für unterschiedliche Schrittweiten sein.
  ]

  #argument("x-step", types: ("integer", "float", "array", none), default: none)[
    Spezifische Schrittweite für x-Achse. Überschreibt `step` für x-Achse. Format: einzelner Wert oder `(major, minor)`.
  ]

  #argument("y-step", types: ("integer", "float", "array", none), default: none)[
    Spezifische Schrittweite für y-Achse. Überschreibt `step` für y-Achse. Format: einzelner Wert oder `(major, minor)`.
  ]

  #argument("x-label", types: "content", default: [$x$])[
    Beschriftung der x-Achse.
  ]

  #argument("y-label", types: "content", default: [$y$])[
    Beschriftung der y-Achse.
  ]

  #argument("grid", types: "string", default: "both")[
    Gitternetz-Modus für beide Achsen: `"major"`, `"minor"`, `"both"`, oder `"none"`.
  ]

  #argument("x-grid", types: ("string", none), default: none)[
    Spezifisches Gitternetz für x-Achse. Überschreibt `grid` für x-Achse.
  ]

  #argument("y-grid", types: ("string", none), default: none)[
    Spezifisches Gitternetz für y-Achse. Überschreibt `grid` für y-Achse.
  ]

  #argument("line-width", types: "length", default: 1.5pt)[
    Linienbreite für Funktionsgraphen.
  ]

  #argument("samples", types: "integer", default: 200)[
    Anzahl der Samplingpunkte für Funktionsgraphen. Höhere Werte ergeben glattere Kurven.
  ]

  #argument("fills", types: "array", default: ())[
    Array von Füllbereichs-Definitionen. Jeder Eintrag ist ein Dictionary mit:
    - `term`: Funktion (füllt zur x-Achse) *oder* `between`: Array mit zwei Funktionen `($f$, $g$)` (füllt zwischen f und g)
    - `domain`: Bereich als `(x1, x2)` oder keine Übergabe für automatische Schnittpunkt-Erkennung
    - `color` Farbe (optional)
  ]

  #argument("datensätze", types: ("array", "tuple", "dictionary"), default: ())[
    Datensätze zum Plotten. Unterstützt mehrere Formate:
    
    *Einfaches Tupel:*
    - `(x-ds, y-ds)`: Ein Datensatz-Paar (Physik-Paket Datensätze)
    - `(x-array, y-array)`: Einfache Zahlen-Arrays
    
    *Dictionary-Format (empfohlen):*
    - `(x: x-ds, y: y-ds)`: Einzelner Datensatz
    - `(x: x-ds, y: y-ds, marker: "o", color: blue)`: Mit Optionen
    
    *Array von Dictionaries:*
    - `((x: x, y: y1, ...), (x: x, y: y2, ...))`: Mehrere Datensätze
    
    Jedes Dictionary kann enthalten:
    - `x`: x-Datensatz (erforderlich)
    - `y`: y-Datensatz (erforderlich)
    - `marker`: Marker-Stil (optional, Standard: `"x"`)
    - `color`/`clr`: Farbe als Color-Objekt oder Integer 1-10 (optional)
  ]

  #argument("annotations", types: "content", default: {})[
    Zusätzliche Annotationen, die mit CeTZ-Draw-Befehlen erstellt werden.
  ]

  #argument("plots", types: ("content", "function", "array"))[
    Funktionsdefinitionen zum Plotten (als variadic arguments). Formate:
    - `$f$`: Funktion als Math-Content
    - `x => expr`: Funktion als Closure
    - Dictionary mit `term`, `domain`, `color`, `label`
  ]
]

#command("teilaufgaben", arg(tasks: ()), arg(columns: auto), arg(numbering: "a)"), arg(gutter: 1.25em), arg(loesungen: ()), sarg[args])[
  Erstellt ein Grid-Layout für Teilaufgaben mit mehreren Syntax-Varianten.

  #argument("tasks", types: "array", default: ())[
    Array von Aufgaben-Content. Kann leer sein, wenn Aufgaben als Body mit Enum-Syntax übergeben werden.
  ]

  #argument("columns", types: ("integer", "auto"), default: auto)[
    Anzahl der Spalten. Bei `auto` wird die Anzahl aus den Aufgaben bestimmt.
  ]

  #argument("numbering", types: "string", default: "a)")[
    Nummerierungsschema für Teilaufgaben (wird an `teilaufgabe()` aus aufgaben-Paket übergeben).
  ]

  #argument("gutter", types: "length", default: 1.25em)[
    Abstand zwischen Aufgaben (horizontal und vertikal).
  ]

  #argument("loesungen", types: "array", default: ())[
    Array von Lösungen für die Teilaufgaben. Wird automatisch jeder Aufgabe zugeordnet.
  ]
  
  Die Funktion unterstützt zwei verschiedene Syntax-Varianten:

  *Variante 1: Mit tasks und loesungen Parameter*
  ```typ
  #import "@schule/aufgaben:0.1.2": aufgabe, teilaufgabe, loesung
  #teilaufgaben(
    columns: 2,
    tasks: ([$2 + 3$], [$5 times 7$]),
    loesungen: ([$5$], [$35$])
  )
  ```

  *Variante 2: Enum-Syntax (empfohlen)*
  ```typ
  #teilaufgaben[
    + Aufgabe 1
      #loesung[Lösung 1]
    + Aufgabe 2
      #loesung[Lösung 2]
  ]
  ```
]

= Beispiele

== Quadratische Funktionen

#example[```typ
#graphen(
  size: (10, 6),
  x: (-5, 5),
  y: (-2, 6),
  $x^2$,
  $x^2 + 2 dot x + 1$,
  $-x^2 + 4$,
  fills: (
    (
      between: ($x^2$, $-x^2 + 4$),
      domain: (-2, 2),
    )
  )
)
```]

== Trigonometrische Funktionen

#example[```typ
#graphen(
  x: (-2*calc.pi, 2*calc.pi),
  y: (-1.5, 1.5),
  x-step: calc.pi / 2,
  $sin(x)$,
  $cos(x)$
)
```]

== Exponentialfunktionen

#example[```typ
#graphen(
  x: (-3, 3),
  y: (0, 4),
  $e^x$,
  $2^x$,
  $e^(-x)$
)
```]

== Funktionen mit Labels

#example[```typ
#graphen(
  x: (-3, 3),
  y: (-2, 6),
  (
    term: $x^2$,
    color: blue,
    label: (
      x: 2,
      content: $f(x) = x^2$,
      position: "br",
      color: blue,
    )
  ),
  (
    term: $2 dot x + 1$,
    color: red,
    label: (
      x: 2,
      content: $g(x) = 2x+1$,
      position: "tl",
      color: red,
    )
  )
)
```]

== Datensatz-Visualisierung

#example[```typ
#import "@schule/physik:0.0.2": datensatz

#let zeit = datensatz($t$, "s", (0, 1, 2, 3, 4))
#let weg = datensatz($s$, "m", (0, 5, 20, 45, 80))

#graphen(
  size: (10, 6),
  datensätze: (x: zeit, y: weg),
  // Regressionskurve hinzufügen
  (term: $5 dot x^2$, color: red)
)
```]

#pagebreak()

== Komplexes Beispiel mit allem

#example(breakable: true)[```typ
#graphen(
  size: (8, 6),
  x: (-3, 3),
  y: (-1, 7),
  step: 1,
  (
    term: $x^2$,
    color: 1, // Blau
    label: (
      x: 2,
      content: [$f(x) = x^2$],
      position: "br",
    )
  ),
  (
    term: $2 dot x + 1$,
    color: 2, // Rot
    label: (
      x: 2,
      content: [$g(x) = 2x+1$],
      position: "tl",
    )
  ),
  fills: (
    (
      between: ($x^2$, $2 dot x + 1$),
      domain: "auto",
      color: green.transparentize(70%),
    )
  )
)
```]

= Tipps und Best Practices

== Performance

1. *Samples anpassen*: Für einfache Funktionen reichen 100-200 Samples, für komplexe Funktionen 300-500
2. *Datensätze*: Bei vielen Datenpunkten kann die Renderzeit steigen
3. *Füllbereiche*: Automatische Schnittpunkt-Erkennung ist rechenintensiv, manuelle Domain ist schneller

== Gestaltung

1. *Farben*: Nutzen Sie die vordefinierten Farbindizes für konsistente Darstellung
2. *Labels*: Positionieren Sie Labels so, dass sie die Funktion nicht verdecken
3. *Gitternetz*: `"both"` für Schüler-freundliche Darstellung, `"major"` für cleane Präsentationen
4. *Achsenbereiche*: Wählen Sie Bereiche so, dass wichtige Features sichtbar sind

= Zusammenfassung

Das #package[mathematik] Paket bietet:

- ✓ Einfache Erstellung von Funktionsgraphen mit Math-Content
- ✓ Automatische Achsenskalierung und Beschriftung
- ✓ Füllbereiche zwischen Funktionen mit automatischer Schnittpunkt-Erkennung
- ✓ Integration mit Physik-Paket für Datensätze
- ✓ Flexible Farb- und Styling-Optionen
- ✓ Label-System für Funktionsbeschriftungen
- ✓ Grid-Layout für Teilaufgaben
- ✓ CeTZ-Integration für erweiterte Annotationen

Das Paket ist ideal für Mathematik-Lehrkräfte, die schnell professionelle Funktionsgraphen und Koordinatensysteme erstellen möchten.
