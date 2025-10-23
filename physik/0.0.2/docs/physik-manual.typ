#import "@preview/mantys:1.0.2": *

#import "../lib.typ" as phys
#let pk = phys.pk

#import "@preview/codly:1.3.0": *
#import "@preview/zero:0.5.0": num

#show: mantys(
  name: "physik",
  version: "0.0.2",
  authors: (
    "Lukas Köhl",
    "Alexander Schulz",
  ),
  license: "MIT",
  description: "Ein umfassendes Paket für physikalische Berechnungen, Messwerttabellen, Schaltkreise und Regressionsanalysen für den Physikunterricht.",

  abstract: [
    Das `physik` Paket bietet eine umfassende Sammlung von Funktionen für den Physikunterricht. Es ermöglicht die Erstellung von Messwerttabellen mit automatischer Einheitenumrechnung, physikalischen Schaltkreisen, statistischen Regressionsanalysen und bietet Zugriff auf physikalische Konstanten. Das Paket integriert mehrere spezialisierte Module für verschiedene Bereiche der Physik.
  ],

  examples-scope: (
    scope: (physik: phys),
    imports: (physik: "*"),
  ),
)

#show heading.where(level: 3): set heading(numbering: none)

#show: codly-init.with()
#codly(number-format: none)

#pagebreak(weak: true)
= Über das Paket <sec:about>

Das `physik` Paket ist eine umfassende Lösung für physikalische Berechnungen und Visualisierungen im Schulbereich. Es wurde entwickelt, um Lehrkräften leistungsstarke Werkzeuge für Messwerttabellen, Schaltkreise, Regressionen und physikalische Konstanten zu bieten.

Dieses Manual ist eine vollständige Referenz aller Funktionen des `physik` Pakets.

== Terminologie

In diesem Manual werden folgende Begriffe verwendet:

- *Datensatz*: Eine Sammlung von Messwerten mit Name, Einheit und Werten
- *Messwerttabelle*: Tabellarische Darstellung von physikalischen Messdaten
- *Regression*: Mathematische Anpassung einer Funktion an Messdaten
- *Schaltkreis*: Elektrisches Schaltbild mit Bauteilen
- *Einheitenpräfix*: SI-Präfixe wie k (kilo), m (milli), μ (mikro)

== Module

Das Paket besteht aus mehreren spezialisierten Modulen:

- *messwerttabellen.typ*: Funktionen für Datensätze und Messwerttabellen
- *regressionen.typ*: Statistische Regressionsanalysen
- *schaltkreise.typ*: Elektrische Schaltkreise und Bauteile
- *konstanten.typ*: Physikalische Konstanten

== Abhängigkeiten

Das Paket nutzt folgende externe Pakete:
- `@preview/zap`: Für Schaltkreis-Visualisierungen
- `@preview/fancy-units`: Für Einheitendarstellung
- `@preview/zero`: Für Zahlenformatierung
- `@schule/random`: Für Zufallsfunktionen

= Schnelleinstieg <sec:quickstart>

Für den schnellen Einstieg importieren Sie das Paket und erstellen Ihre erste Messwerttabelle:

#example[```
// Datensätze erstellen
#let zeit = datensatz($t$, "s", (0, 1, 2, 3, 4, 5))
#let weg = datensatz($s$, "m", (0, 2, 8, 18, 32, 50))

// Messwerttabelle anzeigen
#messwerttabelle(zeit, weg)
```]

Regression durchführen:

#example[```
#let zeit = datensatz($t$, "s", (0, 1, 2, 3, 4))
#let weg = datensatz($s$, "m", (0, 5, 20, 45, 80))

#let reg = quadratische_regression(zeit, weg)
#reg.math
```]

== Erste Schritte

1. *Installation*: Importieren Sie das Paket
2. *Datensätze*: Erstellen Sie Datensätze mit `datensatz()`
3. *Tabellen*: Visualisieren Sie mit `messwerttabelle()`
4. *Regression*: Analysieren Sie mit Regressionsfunktionen
5. *Schaltkreise*: Zeichnen Sie mit `schaltkreis()`

= Messwerttabellen <sec:measurements>

== Datensätze erstellen <sec:datasets>

=== Grundlegende Datensätze

#example[```
// Einfacher Datensatz
#let zeit = datensatz($t$, "s", (0, 1, 2, 3, 4))

#zeit
```]

Mit Präfix (z.B. Millisekunden):

#example[```
#let spannung = datensatz($U$, "mV", (1.5, 3.0, 4.5))

#messwerttabelle(spannung)
```]

Mit automatischer Einheitenumrechnung:

#example[```
#let strom = datensatz($I$, "A", (0.001, 0.002, 0.003), auto-einheit: true)

#messwerttabelle(strom)
```]

=== Leere Messwerttabellen

Für Experimente, bei denen Werte eingetragen werden sollen:

#example[```
// 10 leere Messfelder
#let zeit = messdaten($t$, "s", 10)
#let temperatur = messdaten($T$, "K", 10)

#messwerttabelle(zeit, temperatur)
```]

=== Datensatz-Parameter

#command("datensatz")[
  Erstellt einen Datensatz mit Namen, Einheit und Werten.

  #argument("name", types: "content", default: none)[
    Der Name der Messgröße (typischerweise als Math-Content, z.B. `$t$`, `$U$`).
  ]

  #argument("einheit", types: "string, content", default: none)[
    Die physikalische Einheit (z.B. `"s"`, `"m"`, `"kg"`).
  ]

  #argument("werte", types: "array", default: ())[
    Array mit Messwerten als Zahlen.
  ]

  #argument("prefix", types: "string", default: "1")[
    SI-Präfix für die Einheit. Unterstützte Werte:
    - `"Q"`: Quetta ($10^30$)
    - `"R"`: Ronna ($10^27$)
    - `"Y"`: Yotta ($10^24$)
    - `"Z"`: Zetta ($10^21$)
    - `"E"`: Exa ($10^18$)
    - `"P"`: Peta ($10^15$)
    - `"T"`: Tera ($10^12$)
    - `"G"`: Giga ($10^9$)
    - `"M"`: Mega ($10^6$)
    - `"k"`: Kilo ($10^3$)
    - `"c"`: Zenti ($10^(-2)$)
    - `"m"`: Milli ($10^(-3)$)
    - `"u"`: Mikro ($10^(-6)$)
    - `"n"`: Nano ($10^(-9)$)
    - `"p"`: Piko ($10^(-12)$)
    - `"f"`: Femto ($10^(-15)$)
    - `"a"`: Atto ($10^(-18)$)
    - `"z"`: Zepto ($10^(-21)$)
    - `"y"`: Yokto ($10^(-24)$)
    - `"r"`: Ronto ($10^(-27)$)
    - `"q"`: Quekto ($10^(-30)$)

    *Hinweis:* Der Präfix kann auch direkt in der Einheit übergeben werden, z.B. `einheit: "mV"` statt `einheit: "V", prefix: "m"`. Beide Schreibweisen sind äquivalent.
  ]

  #argument("max-digits", types: "integer", default: none)[
    Maximale Anzahl von Nachkommastellen für die Darstellung in Tabellen. Überschreibt den globalen Wert von `messwerttabelle()`.
  ]

  #argument("auto-einheit", types: "boolean", default: false)[
    Wenn `true`, wird automatisch der passende SI-Präfix gewählt, um Werte im Bereich 1-1000 darzustellen.
  ]

  #sourcecode[```typ
  // Zeitwerte in Sekunden
  #let t = datensatz($t$, "s", (0, 0.5, 1.0, 1.5, 2.0))

  // Spannung in Millivolt
  #let U = datensatz($U$, "V", (1.5, 3.0, 4.5, 6.0), prefix: "m")

  // Strom mit automatischer Einheit
  #let I = datensatz($I$, "A", (0.001, 0.002, 0.003), auto-einheit: true)
  // → Wird automatisch als mA dargestellt

  // Mit spezifischer Nachkommastellen-Anzahl
  #let E = datensatz($E$, "J", (1.234, 2.345, 3.456), max-digits: 3)
  ```]
]

=== Berechnung

#command("berechnung")[
  Erstellt einen berechneten Datensatz basierend auf einem oder mehreren Eingabe-Datensätzen.

  #argument("name", types: "content", default: none)[
    Der Name der berechneten Messgröße.
  ]

  #argument("einheit", types: "string, content", default: none)[
    Die physikalische Einheit des Ergebnisses.
  ]

  #argument("datensaetze", types: "dictionary, array", default: none)[
    Ein einzelner Datensatz oder ein Array von Datensätzen als Eingabe für die Berechnung.
  ]

  #argument("formel", types: "function", default: none)[
    Eine Funktion, die die Berechnung durchführt. Akzeptiert 1-5 Parameter entsprechend der Anzahl der Eingabe-Datensätze.
  ]

  #argument("prefix", types: "string", default: "1")[
    SI-Präfix für die Zieleinheit (siehe `datensatz()`).
  ]

  #argument("auto-einheit", types: "boolean", default: true)[
    Automatische Wahl des besten SI-Präfix für das Ergebnis.
  ]

  #argument("fehler", types: "number", default: 0)[
    Fügt zufällige Messfehler hinzu (in Prozent). Nützlich für Simulationen.
  ]

  #argument("max-digits", types: "integer", default: none)[
    Maximale Anzahl von Nachkommastellen für die Darstellung.
  ]

  #sourcecode[```typ
  // Einfache Berechnung: v = s/t
  #let t = datensatz($t$, "s", (1, 2, 3, 4))
  #let s = datensatz($s$, "m", (10, 20, 30, 40))
  #let v = berechnung($v$, "m/s", (t, s), (zeit, weg) => weg / zeit)

  // Mit physikalischen Konstanten
  #let f = berechnung($f$, "Hz", lambda, l => pk.c.wert / l, auto-einheit: true)

  // Mit Fehler-Simulation (±2%)
  #let messung = berechnung($x$, "m", original, x => x, fehler: 2)
  ```]
]

=== Messwerttabelle

#command("messwerttabelle")[
  Erstellt eine formatierte Tabelle zur Darstellung von Messdaten.

  #argument("datensaetze", types: "array")[
    Ein oder mehrere Datensätze als positionale Argumente, die in der Tabelle angezeigt werden sollen.
  ]

  #argument("amount", types: "integer, auto", default: "auto")[
    Maximale Anzahl von Werten pro Tabelle. Bei `auto` werden alle Werte in einer Tabelle angezeigt. Größere Datensätze werden automatisch auf mehrere Tabellen aufgeteilt.
  ]

  #argument("row-height", types: "length, auto", default: "auto")[
    Höhe der Tabellenzeilen.
  ]

  #argument("header", types: "array, none", default: none)[
    Optionale Kopfzeile mit Namen für die Messwerte-Spalten.
  ]

  #argument("width", types: "relative", default: "100%")[
    Breite der Tabelle.
  ]

  #argument("max-digits", types: "integer", default: 2)[
    Standard-Anzahl von Nachkommastellen. Wird von `max-digits` im Datensatz überschrieben.
  ]

  #sourcecode[```typ
  // Einfache Tabelle
  #messwerttabelle(zeit, weg)

  // Mit Kopfzeile
  #messwerttabelle(
    zeit, spannung,
    header: ([Messung 1], [Messung 2], [Messung 3])
  )

  // Aufteilung bei vielen Werten
  #messwerttabelle(zeit, temp, amount: 10)  // Max 10 Werte pro Tabelle

  // Mit globaler Nachkommastellen-Einstellung
  #messwerttabelle(x, y, max-digits: 3)
  ```]
]

== Messwerttabellen erstellen <sec:tables>

=== Einfache Tabellen

#example[```
#let zeit = datensatz($t$, "s", (0, 1, 2, 3))
#let weg = datensatz($s$, "m", (0, 5, 20, 45))

#messwerttabelle(zeit, weg)
```]

=== Mehrere Spalten

#example[```
#let t = datensatz($t$, "s", (0, 1, 2, 3, 4))
#let s = datensatz($s$, "m", (0, 5, 20, 45, 80))
#let v = datensatz($v$, "m/s", (0, 10, 20, 30, 40))
#let a = datensatz($a$, "m/s²", (10, 10, 10, 10, 10))

#messwerttabelle(t, s, v, a)
```]

== Einheitenumrechnung <sec:unit-conversion>

=== Automatische Umrechnung

Die Funktion `umrechnungseinheit()` wählt automatisch den passenden SI-Präfix:

```typ
#let (faktor, neue-einheit) = umrechnungseinheit(0.001, "A")
// → (1000, "mA")

#let (faktor, neue-einheit) = umrechnungseinheit(1000000, "Hz")
// → (1e-6, "MHz")
```

=== Manuelle Anwendung

```typ
// Konvertiere Array von Werten
#let werte = (0.001, 0.002, 0.003)
#let (neue-werte, neue-einheit) = auto_einheit_anwenden(werte, "A")
// → ((1, 2, 3), "mA")
```

= Regressionen <sec:regressions>

== Lineare Regression <sec:linear-regression>

Findet die beste lineare Anpassung $y = m x + b$:

#example[```
#let x = datensatz($x$, "", (1, 2, 3, 4, 5))
#let y = datensatz($y$, "", (2, 4, 6, 8, 10))

#let reg = lineare_regression(x, y)

#reg.math
```]

Die Regression liefert auch die Koeffizienten:

#example[```
#let x = datensatz($x$, "", (1, 2, 3, 4, 5))
#let y = datensatz($y$, "", (2, 4, 6, 8, 10))
#let reg = lineare_regression(x, y)

Steigung m: #reg.m \
Achsenabschnitt b: #reg.b
```]

=== Regression mit Einheiten

#example[```
#let t = datensatz($t$, "s", (0, 1, 2, 3))
#let s = datensatz($s$, "m", (0, 2, 4, 6))

#let reg = lineare_regression(t, s)
#reg.math
```]

=== Als Funktion für Graphen

```typ
#import "@schule/mathematik:0.0.2": graphen

#let reg = lineare_regression(x, y)
#let f = reg.function

#graphen(
  x: (0, 6),
  y: (0, 12),
  datensätze: (x, y),
  f  // Regressionsgerade
)
```

== Quadratische Regression <sec:quadratic-regression>

Findet die beste quadratische Anpassung $y = a x^2 + b x + c$:

#example[```
#let t = datensatz($t$, "s", (0, 1, 2, 3, 4))
#let s = datensatz($s$, "m", (0, 5, 20, 45, 80))

#let reg = quadratische_regression(t, s)

#reg.math
```]

Die Koeffizienten sind einzeln abrufbar:

#example[```
#let t = datensatz($t$, "s", (0, 1, 2, 3, 4))
#let s = datensatz($s$, "m", (0, 5, 20, 45, 80))
#let reg = quadratische_regression(t, s)

a: #reg.a, b: #reg.b, c: #reg.c
```]

== Potenz-Regression <sec:power-regression>

Findet die beste Potenzanpassung $y = a dot x^b$:

#example[```
#let x = datensatz($x$, "", (1, 2, 3, 4, 5))
#let y = datensatz($y$, "", (1, 4, 9, 16, 25))

#let reg = potenz_regression(x, y)

#reg.math
```]

== Exponential-Regression <sec:exponential-regression>

Findet die beste Exponentialanpassung $y = a dot e^(b x)$:

#example[```
#let x = datensatz($x$, "", (0, 1, 2, 3, 4))
#let y = datensatz($y$, "", (1, 2.718, 7.389, 20.086, 54.598))

#let reg = exponentielle_regression(x, y)

#reg.math
```]

== Polynom-Regression <sec:polynomial-regression>

Findet die beste Polynom-Anpassung beliebigen Grades $y = c_n x^n + c_(n-1) x^(n-1) + dots + c_1 x + c_0$:

#example[```
#let x = datensatz($x$, "", (0, 1, 2, 3, 4, 5))
#let y = datensatz($y$, "", (1, 2, 5, 10, 17, 26))

// Polynom 3. Grades
#let reg = polynom_regression(x, y, 3)

#reg.math
```]

Die Koeffizienten sind als `c0`, `c1`, `c2`, ... abrufbar:

#example[```
#let x = datensatz($x$, "", (0, 1, 2, 3, 4))
#let y = datensatz($y$, "", (2, 3, 6, 11, 18))

#let reg = polynom_regression(x, y, 2)

#reg.math

c0: #reg.c0, c1: #reg.c1, c2: #reg.c2
```]

== Regressions-Eigenschaften <sec:regression-properties>

Alle Regressionsfunktionen geben ein Dictionary mit folgenden Eigenschaften zurück:

#example[```
#let x = datensatz($x$, "", (1, 2, 3, 4, 5))
#let y = datensatz($y$, "", (2, 4, 6, 8, 10))
#let reg = lineare_regression(x, y)

// Formatierte Gleichung
#reg.math \

// Koeffizienten (für lineare_regression)
Steigung: #reg.m, Achsenabschnitt: #reg.b \

// Funktion für Berechnungen
Wert bei x=6: #(reg.function)(6)
```]

== Formatierungsoptionen <sec:formatting>

=== Notation

```typ
// Dezimalnotation (Standard)
#let reg = lineare_regression(x, y, notation: "dec")

// Wissenschaftliche Notation
#let reg = lineare_regression(x, y, notation: "sci")
// Gibt z.B.: $y = 1,23 dot 10^6 dot x$
```

=== Präzision

```typ
// Nur signifikante Terme anzeigen
#let reg = quadratische_regression(x, y, precision: 1e-10)
// Terme mit Koeffizienten < 1e-10 werden ausgelassen
```

= Schaltkreise <sec:circuits>

== Grundlagen <sec:circuit-basics>

Schaltkreise werden mit der `schaltkreis()` Funktion (Alias für `circuit()` aus dem zap-Paket) erstellt:

#example[```
#schaltkreis({
  import zap: *

    // Branch 1
	resistor("r1", (0,3), (3,3), label: $3 Omega$)
	source("v1", (0,0), (0,3), label: (content: "V1", anchor: "south"))
  resistor("r2", (0,0), (0,-3), label: $4 Omega$)

  // Branch 2
  led("l1", "r1.out", (rel: (0,-6)), label: (content: "LED", anchor: "south"))
  capacitor("i2", "r1.out", (rel: (3,0)), label: $6 "mF"$)
  resistor("r3", "i2.out", (rel: (0,-6)), label: $2 Omega$)

  // Wiring
  wire("r2.out", "r3.out")
})
```]

== Bauteile <sec:components>

=== Spannungsquellen

#example[```typ
  // DC-Quelle mit Symbolen (+ und -)
  #schaltkreis({
    import zap: *
    source("V", (0,0), (2,0), current: "dc", variant: "symbol")
  })

  // DC-Quelle mit Linien (lang = +, kurz = -)
  #schaltkreis({
    import zap: *
    source("V", (0,0), (2,0), current: "dc", variant: "lines")
  })

  // AC-Quelle (Wechselspannung mit ~)
  #schaltkreis({
    import zap: *
    source("V", (0,0), (2,0), current: "ac")
  })

  // Geflippt (Polarität umkehren)
  #schaltkreis({
    import zap: *
    source("V", (0,0), (2,0), flipped: true)
  })
  ```
]

=== Widerstände

#example[```
// Standardwiderstand (aus zap-Paket)
#schaltkreis({
  import zap: *
  resistor("R", (0,0), (2,0), label: $100 Omega$)
})
```]

=== Lampen

#example[```
// Glühlampe (Kreis mit X)
#schaltkreis({
  import zap: *
  lamp("L", (0,0), (2,0))
})
```]

=== Messgeräte

#example[```
// Amperemeter (Strommessung)
#schaltkreis({
  import zap: *
  amperemeter("A", (0,0), (2,0))
})

// Voltmeter (Spannungsmessung)
#schaltkreis({
  import zap: *
  voltmeter("V", (0,0), (2,0))
})
```]

=== Kondensatoren

#example[```
// Kondensator
#schaltkreis({
  import zap: *
  capacitor("C", (0,0), (2,0), label: $10 mu "F"$)
})
```]

=== Spulen

#example[```
// Induktivität/Spule
#schaltkreis({
  import zap: *
  inductor("L", (0,0), (2,0), label: $5 "mH"$)
})
```]

=== Dioden

#example[```
// Standard-Diode
#schaltkreis({
  import zap: *
  diode("D", (0,0), (2,0))
})

// LED (Leuchtdiode)
#schaltkreis({
  import zap: *
  led("LED", (0,0), (2,0))
})

// Zener-Diode
#schaltkreis({
  import zap: *
  zener("Z", (0,0), (2,0))
})
```]

=== Maschinen

#example[```
// Motor
#schaltkreis({
  import zap: *
  motor("M", (0,0), (2,0))
})

// Generator
#schaltkreis({
  import zap: *
  generator("G", (0,0), (2,0))
})
```]

== Beispiel-Schaltkreise <sec:circuit-examples>

=== Einfacher Stromkreis

#example[```
#schaltkreis({
  import zap: *

  // Spannungsquelle
  source("V", (0, 0), (0, 2), current: "dc", variant: "lines")

  // Verbindungsleitungen und Lampe
  wire((0, 2), (2, 2))
  lamp("L", (2, 2), (2, 0))
  wire((2, 0), (0, 0))
})
```]

=== Reihenschaltung

#example[```
#schaltkreis({
  import zap: *

  source("V", (0, 0), (0, 3), current: "dc", variant: "symbol", label: $U$)
  wire((0, 3), (1, 3))
  resistor("R1", (1, 3), (3, 3), label: $R_1$)
  resistor("R2", (3, 3), (5, 3), label: $R_2$)
  wire((5, 3), (5, 0))
  wire((5, 0), (0, 0))
})
```]

=== Parallelschaltung

#example[```
#schaltkreis({
  import zap: *

  source("V", (0, 0), (0, 4), current: "dc", variant: "symbol", label: $U$)
  wire((0, 4), (4, 4))

  // Verzweigungsknoten
  node("A", (2, 4))

  // Rechter Zweig (R1)
  resistor("R1", (2, 4), (2, 0), label: (content: $R_1$, anchor: "north-west"))

  // Linker Zweig (R2)
  resistor("R2", (4, 4), (4, 0), label: (content: $R_2$, anchor: "north-west"))

  // Zusammenführungsknoten
  node("B", (2, 0))
  wire((4, 0), (2, 0))
  wire((0, 0), (2, 0))
})
```]

= Physikalische Konstanten <sec:constants>

Das Paket stellt wichtige physikalische Konstanten bereit, die über das Dictionary `pk` (physikalische Konstanten) zugänglich sind.

== Verwendung <sec:constants-usage>

=== Grundlegende Verwendung

Konstanten können direkt verwendet werden:

#example[```
// Zugriff auf den Wert
#pk.c.wert

// Mit Einheit formatiert
#pk.c.mit-einheit

// Nur die Einheit
#pk.c.einheit

// Das Symbol
#pk.c.symbol
```]

=== In Berechnungen

#example[```
// Energie eines Photons: E = h·f
#let frequenz = 5e14  // Hz
#let energie = pk.h.wert * frequenz

Energie: #energie J
```]

#example[```
// Gravitationskraft: F = G·m₁·m₂/r²
#let m1 = 1000  // kg
#let m2 = 2000  // kg
#let r = 10     // m

#let kraft = pk.G.wert * m1 * m2 / (r * r)

Kraft: #kraft N
```]


#pagebreak()
== Verfügbare Konstanten <sec:constants-list>

=== Fundamentale Konstanten
#set table(stroke: 0.5pt)
#table(
  columns: (auto, auto, auto, auto, auto),
  align: (left, center, right, left, left),
  [*Name*], [*Symbol*], [*Wert*], [*Einheit*], [*Zugriff*],
  
  [Lichtgeschwindigkeit], [#pk.c.symbol], [#num("2.99792458e8")], [#pk.c.einheit], [`pk.c`],
  [Planck-Konstante], [#pk.h.symbol], [#num("6.62607015e-34")], [#pk.h.einheit], [`pk.h`],
  [Planck-Konstante (eV)], [#pk.h_eV.symbol], [#num("4.135667696e-15")], [#pk.h_eV.einheit], [`pk.h_eV`],
  [Elementarladung], [#pk.e.symbol], [#num("1.602176634e-19")], [#pk.e.einheit], [`pk.e`],
  [Gravitationskonstante], [#pk.G.symbol], [#num("6.67430e-11")], [#pk.G.einheit], [`pk.G`],
  [Erdbeschleunigung], [#pk.g.symbol], [#num("9.81e0")], [#pk.g.einheit], [`pk.g`],
  [Schallgeschwindigkeit (Luft, 20°C)], [#pk.v.schall.symbol], [#num("3.43e2")], [#pk.v.schall.einheit], [`pk.v.schall`],
)
=== Thermodynamische Konstanten

#table(
  columns: (auto, auto, auto, auto, auto),
  align: (left, center, right, left, left),
  [*Name*], [*Symbol*], [*Wert*], [*Einheit*], [*Zugriff*],

  [Boltzmann-Konstante], [#pk.k_B.symbol], [#num("1.380649e-23")], [#pk.k_B.einheit], [`pk.k_B`],
  [Avogadro-Konstante], [#pk.N_A.symbol], [#num("6.02214076e23")], [#pk.N_A.einheit], [`pk.N_A`],
  [Allgemeine Gaskonstante], [#pk.R.symbol], [#num("8.314462618e0")], [#pk.R.einheit], [`pk.R`],
)

=== Elektromagnetische Konstanten

#table(
  columns: (auto, auto, auto, auto, auto),
  align: (left, center, right, left, left),
  [*Name*], [*Symbol*], [*Wert*], [*Einheit*], [*Zugriff*],
  
  [Elektrische Feldkonstante], [#pk.epsilon_0.symbol], [#num("8.8541878128e-12")], [#pk.epsilon_0.einheit], [`pk.epsilon_0`],
  [Magnetische Feldkonstante], [#pk.mu_0.symbol], [#num("1.25663706212e-6")], [#pk.mu_0.einheit], [`pk.mu_0`],
)
=== Teilchenmassen

#table(
  columns: (auto, auto, auto, auto, auto),
  align: (left, center, right, left, left),
  [*Name*], [*Symbol*], [*Wert*], [*Einheit*], [*Zugriff*],

  [Elektronenmasse], [#pk.m.elektron.symbol], [#num("9.1093837015e-31")], [#pk.m.elektron.einheit], [`pk.m.elektron`],
  [Protonenmasse], [#pk.m.proton.symbol], [#num("1.67262192369e-27")], [#pk.m.proton.einheit], [`pk.m.proton`],
  [Neutronenmasse], [#pk.m.neutron.symbol], [#num("1.67492749804e-27")], [#pk.m.neutron.einheit], [`pk.m.neutron`],
  [Atomare Masseneinheit], [#pk.m.u.symbol], [#num("1.6605390666e-27")], [#pk.m.u.einheit], [`pk.m.u`],
)
== Beispiele <sec:constants-examples>

=== Freier Fall

Berechnung von Geschwindigkeit und Weg beim freien Fall:

#example[```
// Zeitwerte
#let t = datensatz($t$, "s", (0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0))

// Geschwindigkeit: v = g·t
#let v = berechnung($v$, "m/s", t, zeit => pk.g.wert * zeit)

// Fallstrecke: s = ½·g·t²
#let s = berechnung($s$, "m", t, zeit => 0.5 * pk.g.wert * zeit * zeit)

#messwerttabelle(t, v, s)
```]

=== Coulomb-Kraft

Kraft zwischen zwei Elementarladungen bei verschiedenen Abständen:

#example[```
// F = (1/(4πε₀)) · (q₁·q₂)/r²
#let k = 1 / (4 * calc.pi * pk.epsilon_0.wert)  // Coulomb-Konstante

#let r = datensatz($r$, "m", (1e-10, 2e-10, 3e-10, 4e-10, 5e-10))

// Kraft berechnen (zwischen zwei Elektronen)
#let F = berechnung($F$, "N", r, 
  abstand => k * (pk.e.wert * pk.e.wert) / (abstand * abstand),
  auto-einheit: true
)

#messwerttabelle(r, F)
```]


= Integration mit anderen Paketen <sec:integration>

== Mit Mathematik-Paket <sec:with-math>

Datensätze können direkt im `graphen()` des Mathematik-Pakets verwendet werden:

```typ
#import "@schule/physik:0.0.2": *
#import "@schule/mathematik:0.0.2": graphen

#let t = datensatz($t$, "s", (0, 1, 2, 3, 4))
#let s = datensatz($s$, "m", (0, 5, 20, 45, 80))

// Regression durchführen
#let reg = quadratische_regression(t, s)

// Graph mit Datenpunkten und Regressionskurve
#graphen(
  datensätze: (t, s),
  x: auto,
  y: auto,
  reg.function
)
```

== Mit Aufgaben-Paket <sec:with-tasks>

Vollständige Integration für Physik-Aufgaben:

```typ
#import "@schule/physik:0.0.2": *
#import "@schule/aufgaben:0.1.2": *

#set_options((loesungen: "folgend"))

#aufgabe(title: [Freier Fall])[
  Ein Körper fällt aus 20m Höhe. Berechnen Sie die Fallzeit.

  #loesung[
    Mit $s = 1/2 g t^2$ folgt:

    $t = sqrt((2 s) / g) = sqrt((2 dot 20) / 9.81) approx 2.02 "s"$

    #let t = datensatz($t$, "s", (0, 0.5, 1.0, 1.5, 2.0))
    #let s = datensatz($s$, "m", (0, 1.23, 4.91, 11.04, 19.62))

    #messwerttabelle(t, s)
  ]
]
```

== Häufige Probleme

=== Einheiten werden nicht korrekt umgerechnet

- Stellen Sie sicher, dass `auto-einheit: true` gesetzt ist
- Überprüfen Sie, ob die Einheit als String übergeben wird
- Verwenden Sie SI-Einheiten (m, s, kg, A, K, mol, cd)

=== Regression konvergiert nicht

- Überprüfen Sie, ob die Daten für das gewählte Modell geeignet sind
- Entfernen Sie Ausreißer aus den Datensätzen
- Versuchen Sie ein anderes Regressionsmodell

=== Schaltkreis wird nicht angezeigt

- Importieren Sie `zap.components: *` innerhalb von `schaltkreis()`
- Überprüfen Sie die Koordinaten und Verbindungen
- Stellen Sie sicher, dass alle Bauteile korrekt benannt sind

=== Datensatz-Integration mit Mathematik-Paket

- Verwenden Sie `datensätze:` Parameter, nicht `plots:`
- Achten Sie darauf, dass x- und y-Datensätze gleiche Länge haben
- Nutzen Sie `x: auto, y: auto` für automatische Bereiche

= Beispielsammlung <sec:examples-collection>

== Beschleunigungsexperiment

#example[
```typ
#import "@schule/physik:0.0.2": *
#import "@schule/mathematik:0.0.2": graphen

// Messwerte
#let t = datensatz($t$, "s", (0, 0.5, 1.0, 1.5, 2.0, 2.5))
#let s = datensatz($s$, "m", (0, 1.23, 4.91, 11.04, 19.62, 30.66))

// Tabelle
#messwerttabelle(t, s)

// Regression
#let reg = quadratische_regression(t, s)

// Graph
#graphen(
  datensätze: (t, s),
  size: (10, 5.5),
  (reg.function, (label: (
    x: 2.4,
    position: "tl",
    content: reg.math
  )))
)
```
]

== Ohmsches Gesetz
#example[
```typ
// Messwerte
#let U = datensatz($U$, "V", (0, 1, 2, 3, 4, 5))
#let I = datensatz($I$, "A", (0, 0.1, 0.2, 0.3, 0.4, 0.5), auto-einheit: true)

// Tabelle
#messwerttabelle(U, I)

// Regression
#let reg = lineare_regression(U, I)
#reg.math

// Widerstand aus Steigung
#let R = 1 / reg.m
Der Widerstand beträgt: $R = #R Omega$

// Schaltkreis
#schaltkreis({
  import zap: *

  source("V", (0, 0), (0, 2), current: "dc", variant: "symbol", label: $U$)
  wire((0, 2), (2, 2))
  resistor("R", (2, 2), (2, 0), label: $R$)
  wire((2, 0), (0, 0))
})
```
]

== Radioaktiver Zerfall

#example[```
// Zeitwerte in Stunden
#let t = datensatz($t$, "h", (0, 1, 2, 3, 4, 5, 6))

// Aktivität
#let A = datensatz($A$, "Bq", (1000, 500, 250, 125, 62.5, 31.25, 15.625))

// Tabelle
#messwerttabelle(t, A)

// Exponentielle Regression
#let reg = exponentielle_regression(t, A)
#reg.math

// Halbwertszeit aus Zerfallskonstante
#let lambda = -reg.a
#let t_halb = calc.ln(2) / lambda
Die Halbwertszeit beträgt: $t_(1/2) = #calc.round(t_halb, digits: 2) "h"$
```]

= Lizenz und Beiträge <sec:license>

Das Paket steht unter der MIT-Lizenz und ist Teil der `@schule` Paketfamilie.

Entwickelt von Lukas Köhl und Alexander Schulz.
