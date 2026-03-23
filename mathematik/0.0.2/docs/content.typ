#import "../../../schuldocs/0.1.0/lib.typ": show-example, show-module, show-code
#import "@preview/gentle-clues:1.2.0": tip

= Über dieses Paket

Das `mathematik`-Paket bietet Werkzeuge zur Visualisierung mathematischer Inhalte im Schulbereich:
Koordinatensysteme, Funktionsgraphen, Füllbereiche, Datensatz-Plots, strukturierte Teilaufgaben,
Steckbriefe und Kreisdiagramme.

Dieses Manual gliedert sich wie folgt:

+ *Schnellstart* -- Erste Schritte
+ *Grundlegende Graphen* -- Einfache Funktionsgraphen
+ *Füllbereiche* -- Flächen unter/zwischen Kurven
+ *Datensätze* -- Messpunkte und diskrete Daten
+ *Koordinatensystem-Anpassung* -- Achsen, Gitter, Beschriftungen
+ *Teilaufgaben-Raster* -- Mehrspaltiges Aufgabenlayout
+ *Steckbrief* -- Polynomfunktion aus Bedingungen berechnen
+ *Kreisdiagramm* -- Tortendiagramme
+ *GeoGebra-Integration* -- GeoGebra-Algebra-Ansicht nachbilden
+ *API-Referenz* -- Vollständige Parameterdokumentation

= Schnellstart

```typ
#import "@schule/mathematik:0.0.2": *
```

Das Paket hängt ab von: `cetz` (0.4.2), `cetz-plot` (0.1.3), `eqalc` (0.1.3),
`schule/random`, `schule/physik`, `schule/aufgaben`.

== Minimales Beispiel

#show-example(
  rendered: {
    import "/mathematik/0.0.2/mathematik.typ": graphen
    graphen(x => x * x, x: (-3, 3), y: (-1, 9))
  },
  source: ```typ
  #graphen(x => x * x, x: (-3, 3), y: (-1, 9))
  ```,
  width: 14cm,
)

= Grundlegende Graphen

== Einfacher Funktionsgraph

Funktionen können als Typst-Closure oder als Mathe-Content übergeben werden:

#show-example(
  rendered: {
    import "/mathematik/0.0.2/mathematik.typ": graphen
    graphen(
      x => x * x - 2,
      x: (-3, 3),
      y: (-3, 7),
    )
  },
  source: ```typ
  #graphen(
    x => x * x - 2,
    x: (-3, 3),
    y: (-3, 7),
  )
  ```,
  width: 14cm,
)

== Mehrere Funktionen

Jede Funktion wird als weiteres positionales Argument übergeben:

#show-example(
  rendered: {
    import "/mathematik/0.0.2/mathematik.typ": graphen
    graphen(
      x => x * x,
      x => 2 * x - 1,
      x: (-3, 3),
      y: (-3, 9),
    )
  },
  source: ```typ
  #graphen(
    x => x * x,
    x => 2 * x - 1,
    x: (-3, 3),
    y: (-3, 9),
  )
  ```,
  width: 14cm,
)

== Funktion als Dictionary (erweiterte Konfiguration)

Für Farben, Definitionsbereiche und Labels kann ein Dictionary übergeben werden:

```typ
#graphen(
  (
    term: x => x * x,
    color: blue,
    domain: (0, 3),
    label: (x: 2, content: $f(x) = x^2$, position: "br"),
  ),
  x: (-1, 4),
  y: (-1, 10),
)
```

Dictionary-Format:
- `term`: Funktion als Closure oder Mathe-Content (erforderlich)
- `domain`: Definitionsbereich `(min, max)` (optional, Standard: x-Bereich)
- `color`/`clr`: Farbe oder Farbindex 1–10 (optional)
- `label`: Dictionary mit `x`, `content`, `position` (`"tl"`, `"tr"`, `"bl"`, `"br"`)

= Füllbereiche

Mit `fills` können Flächen unter oder zwischen Kurven eingefärbt werden.

== Fläche unter einer Funktion

#show-example(
  rendered: {
    import "/mathematik/0.0.2/mathematik.typ": graphen
    graphen(
      x => calc.sin(x),
      x: (-1, 4),
      y: (-1.5, 1.5),
      fills: (
        (
          term: x => calc.sin(x),
          domain: (0, calc.pi),
          color: blue.transparentize(60%),
        ),
      ),
    )
  },
  source: ```typ
  #graphen(
    x => calc.sin(x),
    x: (-1, 4),
    y: (-1.5, 1.5),
    fills: (
      (
        term: x => calc.sin(x),
        domain: (0, calc.pi),
        color: blue.transparentize(60%),
      ),
    ),
  )
  ```,
  width: 14cm,
)

== Fläche zwischen zwei Funktionen

#show-example(
  rendered: {
    import "/mathematik/0.0.2/mathematik.typ": graphen
    graphen(
      x => x * x,
      x => 2 * x + 1,
      x: (-2, 4),
      y: (-1, 10),
      fills: (
        (
          between: (x => x * x, x => 2 * x + 1),
          domain: (-1, 3),
          color: green.transparentize(60%),
        ),
      ),
    )
  },
  source: ```typ
  #graphen(
    x => x * x,
    x => 2 * x + 1,
    x: (-2, 4),
    y: (-1, 10),
    fills: (
      (
        between: (x => x * x, x => 2 * x + 1),
        domain: (-1, 3),
        color: green.transparentize(60%),
      ),
    ),
  )
  ```,
  width: 14cm,
)

#tip[
  Mit `domain: "auto"` werden Schnittpunkte numerisch ermittelt. Das ist praktisch,
  aber langsamer als eine explizite Domain.
]

= Datensätze

Diskrete Messpunkte aus dem Physik-Paket oder als einfache Arrays können direkt eingezeichnet werden.

== Datensatz aus dem Physik-Paket

#show-example(
  rendered: {
    import "/mathematik/0.0.2/mathematik.typ": graphen
    import "@schule/physik:0.0.2": datensatz
    let t = datensatz($t$, "s", (0, 1, 2, 3, 4))
    let s = datensatz($s$, "m", (0, 5, 20, 45, 80))
    graphen(
      datensätze: (x: t, y: s),
      x: auto,
      y: auto,
    )
  },
  source: ```typ
  #import "@schule/physik:0.0.2": datensatz
  #let t = datensatz($t$, "s", (0, 1, 2, 3, 4))
  #let s = datensatz($s$, "m", (0, 5, 20, 45, 80))
  #graphen(
    datensätze: (x: t, y: s),
    x: auto,
    y: auto,
  )
  ```,
  width: 14cm,
)

== Einfache Arrays

```typ
#let x-werte = (0, 1, 2, 3, 4)
#let y-werte = (0, 1, 4, 9, 16)

#graphen(
  datensätze: (x-werte, y-werte),
  x: auto,
  y: auto,
)
```

== Mehrere Datensätze

```typ
#graphen(
  datensätze: (
    (x: t, y: s1, marker: "o", color: blue),
    (x: t, y: s2, marker: "x", color: red),
  ),
  x: auto,
  y: auto,
)
```

= Koordinatensystem-Anpassung

Die meisten Eigenschaften des Koordinatensystems können direkt als Parameter übergeben werden.

== Achsenbeschriftung und Größe

#show-code(```typ
#graphen(
  x: (-5, 5),
  y: (-3, 3),
  x-label: [$t$ in s],
  y-label: [$v$ in m/s],
  size: (10, 6),   // Breite × Höhe in cm
  scale: 1,        // Skalierungsfaktor
  x => x,
)
```)

== Gitterlinien und Schrittweiten

#show-code(```typ
#graphen(
  x: (-5, 5),
  y: (-5, 5),
  step: 1,           // Schrittweite für beide Achsen
  x-step: (1, 0.5),  // x: Haupt- alle 1, Neben- alle 0.5
  y-step: 2,         // y: Hauptschrittweite 2
  grid: "both",      // "both", "major", "minor", "none"
  x-grid: "major",   // Überschreibt grid nur für x
  x => calc.sin(x),
)
```)

== Sampling und Linienbreite

#show-code(```typ
#graphen(
  samples: 400,        // Mehr Stützstellen für glattere Kurven
  line-width: 2pt,     // Dickere Linien
  x => calc.sin(x) / x,
)
```)

= Teilaufgaben-Raster

Die `teilaufgaben()`-Funktion (Alias: `tasks`) erzeugt ein mehrspaltiges Grid für Teilaufgaben.

== Enum-Syntax (empfohlen)

#show-example(
  rendered: {
    import "/mathematik/0.0.2/mathematik.typ": teilaufgaben
    import "@schule/aufgaben:0.1.2": teilaufgabe, loesung
    teilaufgaben(columns: 2)[
      + Berechne $2 + 3$.
        #loesung[$5$]
      + Berechne $5 times 7$.
        #loesung[$35$]
      + Vereinfache $sqrt(16)$.
        #loesung[$4$]
      + Berechne $10 / 2$.
        #loesung[$5$]
    ]
  },
  source: ```typ
  #teilaufgaben(columns: 2)[
    + Berechne $2 + 3$.
      #loesung[$5$]
    + Berechne $5 times 7$.
      #loesung[$35$]
    + Vereinfache $sqrt(16)$.
      #loesung[$4$]
    + Berechne $10 / 2$.
      #loesung[$5$]
  ]
  ```,
  width: 14cm,
)

== Mit tasks- und loesungen-Parameter

```typ
#teilaufgaben(
  columns: 2,
  tasks: ([$2 + 3$], [$5 times 7$], [$sqrt(16)$], [$10 / 2$]),
  loesungen: ([$5$], [$35$], [$4$], [$5$]),
)
```

= Steckbrief

`steckbrief()` berechnet eine Polynomfunktion aus einem System von Bedingungen per Gauß-Elimination.
Der Polynomgrad ergibt sich automatisch aus der Anzahl der Bedingungen (Grad = Anzahl − 1).

== Beispiel: Kubische Funktion

#show-code(```typ
#let sb = steckbrief("f(0)=2", "f'(0)=0", "f(2)=0", "f'(2)=0")

Die Funktion lautet: #sb.math

#graphen(sb.function, x: (-1, 3), y: (-1, 3))
```)

Die Rückgabe ist ein Dictionary mit:
- `math`: Formatierte Gleichung als Content
- `math-digits`: Funktion für angepasste Nachkommastellen
- `function`: Typst-Closure `x => f(x)`
- `gleichungssystem`: Array der Gleichungen (für Aufgabendarstellung)
- `a`, `b`, `c`, …: Koeffizienten (höchster Grad zuerst)

== Bedingungsformat

```typ
"f(2)=3"     // f(2) = 3
"f'(-1)=0"   // f'(-1) = 0  (erste Ableitung)
"f''(0)=6"   // f''(0) = 6  (zweite Ableitung)
"f(1/2)=1"   // Brüche als x-Wert möglich
```

= Kreisdiagramm

`kreisdiagramm()` erzeugt ein Tortendiagramm aus `(label, wert)`-Paaren.

#show-example(
  rendered: {
    import "/mathematik/0.0.2/mathematik.typ": kreisdiagramm
    kreisdiagramm(
      (
        ("Äpfel", 35),
        ("Birnen", 45),
        ("Kirschen", 20),
      ),
      legend: "r",
    )
  },
  source: ```typ
  #kreisdiagramm(
    (
      ("Äpfel", 35),
      ("Birnen", 45),
      ("Kirschen", 20),
    ),
    legend: "r",
  )
  ```,
  width: 14cm,
)

== Optionen

#show-code(```typ
#kreisdiagramm(
  data,
  legend: "b",           // "r", "l", "t", "b" oder false
  show-percentage: true, // Prozent/Werte im Segment anzeigen
  label-color: white,    // Farbe der Segment-Beschriftungen
  mode: "absolute",      // "percent" oder "absolute"
  radius: 3.5,           // Radius des Diagramms
  gap: 0.1,              // Lücke zwischen Segmenten
)
```)

= GeoGebra-Integration

Das Paket enthält Hilfsfunktionen, um die GeoGebra-Algebra-Ansicht in Typst nachzubilden.

== GeoGebra-Algebra-Tabelle

#show-example(
  rendered: {
    import "/mathematik/0.0.2/mathematik.typ": geogebra-algebra, geogebra-style
    geogebra-algebra(
      $v = vec(2, 1, 5)$,
      $u = vec(1, -1, 3)$,
      $P = (3, 1, -3)$,
      last-has-approx: true,
    )
  },
  source: ```typ
  #geogebra-algebra(
    $v = vec(2, 1, 5)$,
    $u = vec(1, -1, 3)$,
    $P = (3, 1, -3)$,
    last-has-approx: true,
  )
  ```,
  width: 14cm,
)

== GeoGebra-Stil

```typ
#geogebra-style[
  $g(t) = v + t u$
]
```

`geogebra-style` rendert Gleichungen aufrecht, serifenlos und im Display-Modus –
wie in der GeoGebra-Benutzeroberfläche.

== Einzelne Zelle

```typ
#geogebra-cell($f(x) = x^2$, menu: true, approx: false)
```

= API-Referenz

#show-module(read("../mathematik.typ"), name: "mathematik")
