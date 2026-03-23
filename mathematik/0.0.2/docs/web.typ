#import "@preview/manifesto:0.1.1": *

#let pkg = toml("../typst.toml")

#show: it => template(
  it,
  toml: pkg,
  universe: "https://typst.app/universe/package/mathematik",
  notices: (
    [Entwickelt für das Schule-Typst-Ökosystem],
  ),
  links: (
    (name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),
  ),
)

= Über dieses Paket

Das `mathematik`-Paket bietet Werkzeuge zur Visualisierung mathematischer Inhalte: Koordinatensysteme, Funktionsgraphen, Füllbereiche, Datensatz-Plots und strukturierte Teilaufgaben.

Dieses Manual gliedert sich wie folgt:

+ *Installation & Import* -- Erste Schritte
+ *Grundlegende Graphen* -- Einfache Funktionsgraphen
+ *Füllbereiche* -- Flächen unter/zwischen Kurven
+ *Datensätze* -- Messpunkte und diskrete Daten
+ *Koordinatensystem-Anpassung* -- Achsen, Gitter, Beschriftungen
+ *Teilaufgaben* -- Mehrspaltiges Aufgabenraster
+ *Funktionsreferenz* -- Vollständige Parameter-Dokumentation

== Installation & Import

```typ
#import "@schule/mathematik:0.0.2": *
```

Das Paket hängt ab von: `cetz`, `cetz-plot`, `eqalc`, `schule/random`, `schule/physik`, `schule/aufgaben`.

= Grundlegende Graphen

== Einfacher Funktionsgraph

```typ
#graphen(
  x: (-3, 3),
  y: (-1, 5),
  x => x * x,          // f(x) = x²
)
```

#schema(
  {
    import "/mathematik.typ": graphen
    graphen(
      x: (-3, 3),
      y: (-1, 5),
      x => x * x,
    )
  },
  code: ```typ
  #graphen(
    x: (-3, 3),
    y: (-1, 5),
    x => x * x,
  )
  ```,
  width: 14cm,
)

== Mehrere Funktionen

```typ
#graphen(
  x: (-3, 3),
  y: (-5, 5),
  x => x * x,          // f(x) = x²
  x => 2 * x - 1,      // g(x) = 2x - 1
)
```

Jede Funktion wird als positionales `..plots`-Argument übergeben.

== Graph-Beschriftungen

```typ
#graphen(
  x: (-4, 4),
  y: (-2, 6),
  x-label: $x$,
  y-label: $f(x)$,
  x => x * x - 2,
)
```

= Füllbereiche

Mit `fills` lassen sich Flächen unter oder zwischen Kurven einfärben:

```typ
#graphen(
  x: (-2, 4),
  y: (-1, 6),
  fills: (
    (
      domain: (0, 3),
      fill: blue.lighten(60%),
      func: x => x * x,
    ),
  ),
  x => x * x,
)
```

#schema(
  {
    import "/mathematik.typ": graphen
    graphen(
      x: (-2, 4),
      y: (-1, 6),
      fills: (
        (
          domain: (0, 3),
          fill: blue.lighten(60%),
          func: x => x * x,
        ),
      ),
      x => x * x,
    )
  },
  code: ```typ
  #graphen(
    x: (-2, 4),
    y: (-1, 6),
    fills: (
      (
        domain: (0, 3),
        fill: blue.lighten(60%),
        func: x => x * x,
      ),
    ),
    x => x * x,
  )
  ```,
  width: 14cm,
)

Jeder Füllbereich ist ein Dictionary mit:

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Schlüssel*], [*Beschreibung*]),
  [`domain`], [Tupel `(x_min, x_max)` – Bereich der Füllung],
  [`fill`], [Farbe (z. B. `blue.lighten(60%)`)],
  [`func`], [Funktion, deren Fläche zur x-Achse gefüllt wird],
)

= Datensätze

Diskrete Messpunkte können als Datensätze eingezeichnet werden:

```typ
#let messung = datensatz(
  name: "Messung 1",
  einheit: "m",
  werte: (1.0, 2.5, 3.0, 4.2, 5.1),
)

#graphen(
  x: (0, 6),
  y: (0, 6),
  datensätze: (messung,),
  x => x,
)
```

== Datensatz-Parameter

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Parameter*], [*Beschreibung*]),
  [`name`], [Bezeichnung des Datensatzes (für Legende)],
  [`einheit`], [Physikalische Einheit],
  [`werte`], [Array der y-Werte],
  [`prefix`], [SI-Präfix (z. B. `"k"` für Kilo)],
  [`max-digits`], [Maximale Nachkommastellen],
  [`auto-einheit`], [Automatische Einheitenskalierung],
)

= Koordinatensystem-Anpassung

```typ
#graphen(
  x: (-5, 5),
  y: (-3, 7),
  size: (10, 8),          // Größe in cm
  scale: 1.5,             // Skalierungsfaktor
  step: 1,                // Schrittweite für beide Achsen
  x-step: 0.5,            // Eigene Schrittweite x-Achse
  y-step: 2,              // Eigene Schrittweite y-Achse
  grid: true,             // Gitterlinien anzeigen
  line-width: 1.5pt,      // Linienbreite der Graphen
  samples: 200,           // Anzahl Stützstellen
  x => calc.sin(x),
)
```

== Annotations

Punkte und Beschriftungen können als Annotationen hinzugefügt werden:

```typ
#graphen(
  x: (-2, 4),
  y: (-1, 6),
  annotations: (
    (x: 1, y: 1, label: $P(1|1)$),
    (x: 3, y: 9, label: $Q(3|9)$),
  ),
  x => x * x,
)
```

= Teilaufgaben

Die `teilaufgaben()`-Funktion erzeugt ein Raster mehrerer Teilaufgaben:

```typ
#teilaufgaben(
  columns: 3,
  (
    ([Zeichne den Graphen von $f(x) = x^2$.], 6cm),
    ([Bestimme die Nullstellen von $g(x) = x - 2$.]),
    ([Berechne $integral_0^1 x^2 dif x$.]),
  ),
)
```

Jede Teilaufgabe ist entweder:
- Ein einfacher Inhalt `[Text]`
- Ein Tupel `([Text], höhe)` für einen Workspace mit definierter Höhe

== Teilaufgaben-Parameter

#table(
  columns: (auto, auto, auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Parameter*], [*Typ*], [*Standard*], [*Beschreibung*]),
  [`tasks`], [`array`], [—], [Liste der Teilaufgaben],
  [`columns`], [`int`], [`2`], [Anzahl Spalten],
  [`numbering`], [`string`], [`"a)"`], [Nummerierungsschema],
  [`gutter`], [`length`], [`5mm`], [Abstand zwischen Zellen],
  [`loesungen`], [`bool|content`], [`false`], [Lösungen einblenden],
)

= Funktionsreferenz

== `graphen()`

```typ
#graphen(
  size: auto,         // (breite, höhe) in cm; auto = (8, 6)
  scale: 1,           // Skalierungsfaktor
  x: (-5, 5),         // x-Achsenbereich
  y: (-5, 5),         // y-Achsenbereich
  step: 1,            // Standard-Schrittweite beider Achsen
  x-step: auto,       // Schrittweite x-Achse (überschreibt step)
  y-step: auto,       // Schrittweite y-Achse (überschreibt step)
  x-label: $x$,       // Beschriftung x-Achse
  y-label: $y$,       // Beschriftung y-Achse
  grid: false,        // Gitterlinien
  line-width: 1pt,    // Linienbreite der Graphen
  samples: 100,       // Stützstellen pro Funktion
  fills: (),          // Füllbereiche (s. Abschnitt Füllbereiche)
  datensätze: (),     // Datensätze als Punkte einzeichnen
  annotations: (),    // Beschriftete Punkte
  ..plots,            // Funktionen f(x) -> y
)
```

== `teilaufgaben()`

```typ
#teilaufgaben(
  tasks,              // Array der Teilaufgaben
  columns: 2,         // Anzahl Spalten
  numbering: "a)",    // Nummerierungsschema
  gutter: 5mm,        // Abstand zwischen Zellen
  loesungen: false,   // Lösungen anzeigen (bool oder content)
  ..args,             // Weitergabe an grid
)
```

= Vollständiges Beispiel

```typ
#import "@schule/mathematik:0.0.2": *
#import "@schule/arbeitsblatt:0.2.4": *

#show: arbeitsblatt.with(
  title: "Funktionsgraphen",
  class: "9a",
)

= Funktionsgraphen zeichnen

Zeichne die folgenden Funktionen in je ein Koordinatensystem.

#teilaufgaben(
  columns: 2,
  (
    (
      [Zeichne $f(x) = x^2 - 2x$. Markiere Nullstellen und Scheitelpunkt.

      #graphen(
        x: (-1, 3),
        y: (-2, 4),
        size: (7, 6),
        x => x * x - 2 * x,
      )],
    ),
    (
      [Zeichne $g(x) = -x + 2$ im selben Bereich und markiere den Schnittpunkt.

      #graphen(
        x: (-1, 3),
        y: (-2, 4),
        size: (7, 6),
        x => x * x - 2 * x,
        x => -x + 2,
      )],
    ),
  ),
)
```
