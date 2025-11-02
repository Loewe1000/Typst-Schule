#import "@preview/mantys:1.0.2": *

#import "../lib.typ" as phys
#import "@schule/mathematik:0.0.2" as mathe
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
    scope: (physik: phys, mathe: mathe),
    imports: (physik: "*", mathe: "*"),
  ),
)

= Über dieses Paket

Das #package[physik] Paket ist eine umfassende Lösung für physikalische Berechnungen und Visualisierungen im Schulbereich. Es wurde entwickelt, um Lehrkräften leistungsstarke Werkzeuge für Messwerttabellen, Schaltkreise, Regressionen und physikalische Konstanten zu bieten.

Dieses Manual gliedert sich wie folgt:
1. *Installation und Import* -- Erste Schritte
2. *Messwerttabellen* -- Datensätze und Tabellen
3. *Regressionen* -- Statistische Analysen
4. *Schaltkreise* -- Elektrische Schaltpläne
5. *Physikalische Konstanten* -- Vordefinierte Werte
6. *Funktionsreferenz* -- Vollständige API-Dokumentation

= Installation und Import

== Paket importieren

Das Paket kann einfach am Anfang des Dokuments importiert werden:

#sourcecode[```typ
#import "@schule/physik:0.0.2": *
```]

== Abhängigkeiten

Das Paket nutzt folgende externe Pakete:
- #package[zap] (0.4.0) -- Für Schaltkreis-Visualisierungen
- #package[fancy-units] (0.1.1) -- Für Einheitendarstellung
- #package[zero] (0.5.0) -- Für Zahlenformatierung
- #package[schule/random] (0.0.1) -- Für Zufallsfunktionen

= Messwerttabellen

== Datensätze erstellen

=== Grundlegende Datensätze

Ein Datensatz kombiniert Name, Einheit und Messwerte:

#example[```typ
// Einfacher Datensatz
#let zeit = datensatz($t$, "s", (0, 1, 2, 3, 4))

#messwerttabelle(zeit)
```]

=== Mit Präfix

SI-Präfixe können direkt in der Einheit oder als Parameter angegeben werden:

#example[```typ
// Präfix in der Einheit
#let spannung1 = datensatz($U$, "mV", (1.5, 3.0, 4.5))

// Präfix als Parameter
#let spannung2 = datensatz($U$, "V", (1.5, 3.0, 4.5), prefix: "m")

#messwerttabelle(spannung1, spannung2)
```]

=== Automatische Einheitenumrechnung

#example[```typ
#let strom = datensatz($I$, "A", (0.001, 0.002, 0.003), auto-einheit: true)

#messwerttabelle(strom)
```]

=== Leere Messwerttabellen

Für Experimente, bei denen Werte eingetragen werden sollen:

#example[```typ
// 5 leere Messfelder
#let zeit = messdaten($t$, "s", 5)
#let temperatur = messdaten($T$, "K", 5)

#messwerttabelle(zeit, temperatur)
```]

== Berechnete Datensätze

Werte können aus anderen Datensätzen berechnet werden:

#example[```typ
// Einfache Berechnung: v = s/t
#let t = datensatz($t$, "s", (1, 2, 3, 4))
#let s = datensatz($s$, "m", (10, 20, 30, 40))
#let v = berechnung($v$, "m/s", (t, s), (zeit, weg) => weg / zeit)

#messwerttabelle(t, s, v)
```]

Mit physikalischen Konstanten:

#example[```typ
#let lambda = datensatz($lambda$, "m", (600e-9, 550e-9, 500e-9))
#let f = berechnung($f$, "Hz", lambda, l => pk.c.wert / l, auto-einheit: true)

#messwerttabelle(lambda, f)
```]

== Messwerttabellen erstellen

=== Einfache Tabellen

#example[```typ
#let zeit = datensatz($t$, "s", (0, 1, 2, 3))
#let weg = datensatz($s$, "m", (0, 5, 20, 45))

#messwerttabelle(zeit, weg)
```]

=== Mehrere Spalten

#example[```typ
#let t = datensatz($t$, "s", (0, 1, 2, 3, 4))
#let s = datensatz($s$, "m", (0, 5, 20, 45, 80))
#let v = datensatz($v$, "m/s", (0, 10, 20, 30, 40))
#let a = datensatz($a$, "m/s^2", (10, 10, 10, 10, 10))

#messwerttabelle(t, s, v, a)
```]

=== Mit Kopfzeile

#example[```typ
#let t = datensatz($t$, "s", (0, 1, 2))
#let U = datensatz($U$, "V", (0, 1.5, 3.0))

#messwerttabelle(
  header: ([Messung 1], [Messung 2], [Messung 3]),
  t, U,
)
```]

= Regressionen

== Lineare Regression

Findet die beste lineare Anpassung $y = m x + b$:

#example[```typ
#let x = datensatz($x$, "", (1, 2, 3, 4, 5))
#let y = datensatz($y$, "", (2, 4, 6, 8, 10))

#let reg = lineare_regression(x, y)

#reg.math
```]
Koeffizienten einzeln abrufen:

#example[```typ
#let x = datensatz($x$, "", (1, 2, 3, 4, 5))
#let y = datensatz($y$, "", (2, 4, 6, 8, 10))
#let reg = lineare_regression(x, y)

Steigung m: #reg.m\
Achsenabschnitt b: #reg.b
```]

== Quadratische Regression

Findet die beste quadratische Anpassung $y = a x^2 + b x + c$:

#example[```typ
#let t = datensatz($t$, "s", (0, 1, 2, 3, 4))
#let s = datensatz($s$, "m", (0, 5, 20, 45, 80))

#let reg = quadratische_regression(t, s)

#reg.math
```]
#pagebreak(weak: true)
Koeffizienten einzeln abrufen:

#example[```typ
#let t = datensatz($t$, "s", (0, 1, 2, 3, 4))
#let s = datensatz($s$, "m", (0, 5, 20, 45, 80))
#let reg = quadratische_regression(t, s)

a: #reg.a, b: #reg.b, c: #reg.c
```]

== Weitere Regressionstypen

=== Potenz-Regression

Findet die beste Potenzanpassung $y = a dot x^b$:

#example[```typ
#let x = datensatz($x$, "", (1, 2, 3, 4, 5))
#let y = datensatz($y$, "", (1, 4, 9, 16, 25))

#let reg = potenz_regression(x, y)

#reg.math
```]

=== Exponential-Regression

Findet die beste Exponentialanpassung $y = a dot e^(b x)$:

#example[```typ
#let x = datensatz($x$, "", (0, 1, 2, 3, 4))
#let y = datensatz($y$, "", (1, 2.718, 7.389, 20.086, 54.598))

#let reg = exponentielle_regression(x, y)

#reg.math
```]
#pagebreak(weak: true)
=== Polynom-Regression

Findet die beste Polynom-Anpassung beliebigen Grades:

#example[```typ
#let x = datensatz($x$, "", (0, 1, 2, 3, 4, 5))
#let y = datensatz($y$, "", (1, 2, 5, 10, 17, 26))

// Polynom 3. Grades
#let reg = polynom_regression(x, y, 3)

#reg.math
```]

Koeffizienten sind als `c0`, `c1`, `c2`, ... abrufbar:

#example[```typ
#let x = datensatz($x$, "", (0, 1, 2, 3, 4))
#let y = datensatz($y$, "", (2, 3, 6, 11, 18))

#let reg = polynom_regression(x, y, 2)

c0: #reg.c0, c1: #reg.c1, c2: #reg.c2
```]
#pagebreak(weak: true)
== Als Funktion für Graphen

Regressionen können mit dem Mathematik-Paket visualisiert werden:

#example[```typ
#let x = datensatz($t$, "s", (1, 2, 3, 4, 5))
#let y = datensatz($s$, "m", (2, 4, 6, 8, 10))
#let reg = lineare_regression(x, y)

#graphen(
  size: 6,
  datensätze: (x: x, y: y),
  (term: reg.function, label: (x: 4, content: reg.math, position: "tl"))
)
```]
#pagebreak(weak: true)
= Schaltkreise

== Grundlagen

Schaltkreise werden mit der `schaltkreis()` Funktion erstellt:

#example[```typ
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

== Bauteile

=== Spannungsquellen

#example[```typ
// DC-Quelle mit Symbolen (+ und -)
#schaltkreis({
  import zap: *
  source("V", (0,0), (2,0), current: "dc", variant: "symbol")
})
```]

#example[```typ
// DC-Quelle mit Linien (lang = +, kurz = -)
#schaltkreis({
  import zap: *
  source("V", (0,0), (2,0), current: "dc", variant: "lines")
})
```]

#example[```typ
// AC-Quelle (Wechselspannung mit ~)
#schaltkreis({
  import zap: *
  source("V", (0,0), (2,0), current: "ac")
})
```]

=== Widerstände

#example[```typ
// Standardwiderstand
#schaltkreis({
  import zap: *
  resistor("R", (0,0), (2,0), label: $100 Omega$)
})
```]

=== Lampen

#example[```typ
// Glühlampe (Kreis mit X)
#schaltkreis({
  import zap: *
  lamp("L", (0,0), (2,0))
})
```]

=== Messgeräte

#example[```typ
// Amperemeter
#schaltkreis({
  import zap: *
  amperemeter("A", (0,0), (2,0))
})
```]

#example[```typ
// Voltmeter
#schaltkreis({
  import zap: *
  voltmeter("V", (0,0), (2,0))
})
```]

=== Kondensatoren und Spulen

#example[```typ
// Kondensator
#schaltkreis({
  import zap: *
  capacitor("C", (0,0), (2,0), label: $10 mu "F"$)
})
```]

#example[```typ
// Induktivität/Spule
#schaltkreis({
  import zap: *
  inductor("L", (0,0), (2,0), label: $5 "mH"$)
})
```]

=== Dioden

#example[```typ
// Standard-Diode
#schaltkreis({
  import zap: *
  diode("D", (0,0), (2,0))
})
```]

#example[```typ
// LED (Leuchtdiode)
#schaltkreis({
  import zap: *
  led("LED", (0,0), (2,0))
})
```]

=== Maschinen

#example[```typ
// Motor
#schaltkreis({
  import zap: *
  motor("M", (0,0), (2,0))
})
```]

#example[```typ
// Generator
#schaltkreis({
  import zap: *
  generator("G", (0,0), (2,0))
})
```]

== Beispiel-Schaltkreise

=== Reihenschaltung

#example[```typ
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

#example[```typ
#schaltkreis({
  import zap: *

  source("V", (0, 0), (0, 4), current: "dc", variant: "symbol", label: $U$)
  wire((0, 4), (4, 4))

  // Verzweigungsknoten
  node("A", (2, 4))

  // Linker Zweig (R1)
  resistor("R1", (2, 4), (2, 0), label: (content: $R_1$, anchor: "north-west"))

  // Rechter Zweig (R2)
  resistor("R2", (4, 4), (4, 0), label: (content: $R_2$, anchor: "north-west"))

  // Zusammenführungsknoten
  node("B", (2, 0))
  wire((4, 0), (2, 0))
  wire((0, 0), (2, 0))
})
```]
#pagebreak(weak: true)
= Physikalische Konstanten

== Grundlegende Verwendung

Konstanten können direkt über das `pk` Dictionary verwendet werden:

#example[```typ
// Zugriff auf den Wert
#pk.c.wert
// Mit Einheit formatiert
#pk.c.mit-einheit
// Nur die Einheit
#pk.c.einheit
// Das Symbol
#pk.c.symbol
```]

== In Berechnungen

#example[```typ
// Energie eines Photons: E = h·f
#let frequenz = 5e14  // Hz
#let energie = pk.h.wert * frequenz

Energie: #energie J
```]

#example[```typ
// Gravitationskraft: F = G·m₁·m₂/r²
#let m1 = 1000  // kg
#let m2 = 2000  // kg
#let r = 10     // m

#let kraft = pk.G.wert * m1 * m2 / (r * r)

Kraft: #kraft N
```]

== Verfügbare Konstanten

=== Fundamentale Konstanten

#set table(stroke: 0.5pt)
#table(
  columns: (auto, auto, 1fr, auto, auto),
  align: (left, center, right, left, left),
  [*Name*], [*Symbol*], [*Wert*], [*Einheit*], [*Zugriff*],
  
  [Lichtgeschwindigkeit], [#pk.c.symbol], [$2.998 dot 10^8$], [#pk.c.einheit], [`pk.c`],
  [Planck-Konstante], [#pk.h.symbol], [$6.626 dot 10^(-34)$], [#pk.h.einheit], [`pk.h`],
  [Elementarladung], [#pk.e.symbol], [$1.602 dot 10^(-19)$], [#pk.e.einheit], [`pk.e`],
  [Gravitationskonstante], [#pk.G.symbol], [$6.674 dot 10^(-11)$], [#pk.G.einheit], [`pk.G`],
  [Erdbeschleunigung], [#pk.g.symbol], [$9.81$], [#pk.g.einheit], [`pk.g`],
)

=== Thermodynamische Konstanten

#table(
  columns: (auto, auto, 1fr, auto, auto),
  align: (left, center, right, left, left),
  [*Name*], [*Symbol*], [*Wert*], [*Einheit*], [*Zugriff*],

  [Boltzmann-Konstante], [#pk.k_B.symbol], [$1.381 dot 10^(-23)$], [#pk.k_B.einheit], [`pk.k_B`],
  [Avogadro-Konstante], [#pk.N_A.symbol], [$6.022 dot 10^23$], [#pk.N_A.einheit], [`pk.N_A`],
  [Gaskonstante], [#pk.R.symbol], [$8.314$], [#pk.R.einheit], [`pk.R`],
)

=== Elektromagnetische Konstanten

#table(
  columns: (auto, auto, 1fr, auto, auto),
  align: (left, center, right, left, left),
  [*Name*], [*Symbol*], [*Wert*], [*Einheit*], [*Zugriff*],
  
  [Elektrische Feldkonstante], [#pk.epsilon_0.symbol], [$8.854 dot 10^(-12)$], [#pk.epsilon_0.einheit], [`pk.epsilon_0`],
  [Magnetische Feldkonstante], [#pk.mu_0.symbol], [$1.257 dot 10^(-6)$], [#pk.mu_0.einheit], [`pk.mu_0`],
)

=== Teilchenmassen

#table(
  columns: (auto, auto, 1fr, auto, auto),
  align: (left, center, right, left, left),
  [*Name*], [*Symbol*], [*Wert*], [*Einheit*], [*Zugriff*],

  [Elektronenmasse], [#pk.m.elektron.symbol], [$9.109 dot 10^(-31)$], [#pk.m.elektron.einheit], [`pk.m.elektron`],
  [Protonenmasse], [#pk.m.proton.symbol], [$1.673 dot 10^(-27)$], [#pk.m.proton.einheit], [`pk.m.proton`],
  [Neutronenmasse], [#pk.m.neutron.symbol], [$1.675 dot 10^(-27)$], [#pk.m.neutron.einheit], [`pk.m.neutron`],
  [Atomare Masseneinheit], [#pk.m.u.symbol], [$1.661 dot 10^(-27)$], [#pk.m.u.einheit], [`pk.m.u`],
)

= Funktionsreferenz

== Messwerttabellen

#command("datensatz", arg(name), arg("einheit"), arg("werte"), arg(prefix: "1"), arg(max-digits: none), arg(auto-einheit: false))[
  #text(9pt)[Erstellt einen Datensatz mit Namen, Einheit und Werten.]

  #argument("name", types: "content")[
    Der Name der Messgröße (typischerweise als Math-Content, z.B. `$t$`, `$U$`).
  ]

  #argument("einheit", types: ("string", "content"))[
    Die physikalische Einheit (z.B. `"s"`, `"m"`, `"kg"`).
  ]

  #argument("werte", types: "array")[
    Array mit Messwerten als Zahlen.
  ]

  #argument("prefix", types: "string", default: "1")[
    SI-Präfix für die Einheit. #[#set text(8pt); (`"Q"` (Quetta), ... `"T"` (Tera), `"G"` (Giga), `"M"` (Mega), `"k"` (Kilo), `"c"` (Zenti), `"m"` (Milli), `"u"` (Mikro), `"n"` (Nano), `"p"` (Piko), `"f"` (Femto), `"a"` (Atto), ... `"q"` (Quekto))].
    
    *Hinweis:* Der Präfix kann auch direkt in der Einheit übergeben werden.
  ]

  #argument("max-digits", types: ("integer", none), default: none)[
    Maximale Anzahl von Nachkommastellen für die Darstellung in Tabellen. Überschreibt den globalen Wert von `messwerttabelle()`.
  ]

  #argument("auto-einheit", types: "boolean", default: false)[
    Wählt automatisch einen passenden SI-Präfix (Werte zwischen 1-1000).
  ]
]

#command("messdaten", arg(name), arg("einheit"), arg("anzahl-messwerte"), arg(prefix: "1"))[
  Erstellt einen leeren Datensatz für Messwerttabellen zum Ausfüllen.

  #argument("name", types: "content")[
    Der Name der Messgröße (typischerweise als Math-Content, z.B. `$t$`, `$U$`).
  ]

  #argument("einheit", types: ("string", "content"))[
    Die physikalische Einheit (z.B. `"s"`, `"m"`, `"kg"`).
  ]

  #argument("anzahl-messwerte", types: "integer")[
    Anzahl der leeren Felder in der Tabelle.
  ]

  #argument("prefix", types: "string", default: "1")[
    SI-Präfix für die Einheit (z.B. `"m"` für Milli, `"k"` für Kilo).
  ]
]

#command("berechnung", arg(name), arg("einheit"), arg("datensaetze"), arg("formel"), arg(prefix: "1"), arg(auto-einheit: true), arg(fehler: 0), arg(max-digits: none))[
  Erstellt einen berechneten Datensatz basierend auf Eingabe-Datensätzen.

  #argument("datensaetze", types: ("dictionary", "array"))[
    Ein einzelner Datensatz oder mehrere als Eingabe für die Berechnung.
  ]

  #argument("formel", types: "function")[
    Eine Funktion, die die Berechnung durchführt. Akzeptiert mehrere Parameter entsprechend der Anzahl der Eingabe-Datensätze.
  ]

  #argument("fehler", types: "number", default: 0)[
    Fügt zufällige Messfehler hinzu (in Prozent). Nützlich für 'Messwerte'.
  ]
]

#command("messwerttabelle", sarg[datensaetze], arg(amount: auto), arg(row-height: auto), arg(header: none), arg(width: 100%), arg(max-digits: 2))[
  Erstellt eine formatierte Tabelle zur Darstellung von Messdaten.

  #argument("datensaetze", types: "array")[
    Ein oder mehrere Datensätze als positionale Argumente, die in der Tabelle angezeigt werden sollen.
  ]

  #argument("amount", types: ("integer", "auto"), default: auto)[
    Maximale Anzahl von Werten pro Tabelle. Bei `auto` werden alle Werte in einer Tabelle angezeigt. Größere Datensätze werden automatisch auf mehrere Tabellen aufgeteilt.
  ]

  #argument("row-height", types: ("length", "auto"), default: auto)[
    Höhe der Tabellenzeilen.
  ]

  #argument("header", types: ("array", none), default: none)[
    Optionale Kopfzeile mit Namen für die Messwerte-Spalten.
  ]

  #argument("width", types: "relative", default: 100%)[
    Breite der Tabelle.
  ]

  #argument("max-digits", types: "integer", default: 2)[
    Standard-Anzahl von Nachkommastellen. Wird von `max-digits` im Datensatz überschrieben.
  ]
]
#pagebreak(weak: true)
== Regressionen

#command("lineare_regression", arg("x_param"), arg("y_param"), arg(notation: "dec"), arg(precision: 1e-10))[
  Findet die beste lineare Anpassung $y = m x + b$.

  #argument("x_param", types: ("dictionary", "array"))[
    x-Datensatz oder Array von x-Werten.
  ]

  #argument("y_param", types: ("dictionary", "array"))[
    y-Datensatz oder Array von y-Werten.
  ]

  #argument("notation", types: "string", default: "dec")[
    Zahlenformat: `"dec"` (Dezimal) oder `"sci"` (wissenschaftlich).
  ]

  #argument("precision", types: "float", default: 1e-10)[
    Schwellwert für Term-Unterdrückung. Terme mit Koeffizienten kleiner als dieser Wert werden ausgelassen.
  ]

  Rückgabe: Dictionary mit:
  - `math`: Formatierte Gleichung
  - `m`: Steigung
  - `b`: Achsenabschnitt
  - `function`: Funktion für Berechnungen
]

#command("quadratische_regression", arg("x_param"), arg("y_param"), arg(notation: "dec"), arg(precision: 1e-10))[
  Findet die beste quadratische Anpassung $y = a x^2 + b x + c$.

  Rückgabe: Dictionary mit `math`, `a`, `b`, `c`, `function`.
]

#command("potenz_regression", arg("x_param"), arg("y_param"), arg(notation: "dec"), arg(precision: 1e-10))[
  Findet die beste Potenzanpassung $y = a dot x^m$.

  Rückgabe: Dictionary mit `math`, `a`, `m`, `function`.
]

#command("exponentielle_regression", arg("x_param"), arg("y_param"), arg(notation: "dec"), arg(precision: 1e-10))[
  Findet die beste Exponentialanpassung $y = b dot e^(a x)$.

  Rückgabe: Dictionary mit `math`, `a`, `b`, `function`.
]

#command("polynom_regression", arg("x_param"), arg("y_param"), arg("grad"), arg(notation: "dec"), arg(precision: 1e-10))[
  Findet die beste Polynom-Anpassung beliebigen Grades.

  #argument("grad", types: "integer")[
    Grad des Polynoms (z.B. 3 für kubisch).
  ]

  Rückgabe: Dictionary mit `math`, `c0`, `c1`, ..., `cN`, `function`.
]

== Schaltkreise

#command("schaltkreis", arg("body"))[
  Erstellt einen elektrischen Schaltkreis (Alias für `circuit()` aus dem zap-Paket).

  #argument("body", types: "content")[
    Schaltkreis-Beschreibung. Muss `import zap: *` enthalten.
  ]
]

#command("source", arg(name), arg("node"), arg(current: "dc"), arg(variant: "symbol"), arg(flipped: false), sarg[params])[
  Spannungsquelle.

  #argument("current", types: "string", default: "dc")[
    Stromtyp: `"dc"` (Gleichstrom) oder `"ac"` (Wechselstrom).
  ]

  #argument("variant", types: "string", default: "symbol")[
    Darstellung: `"symbol"` (+ und −) oder `"lines"` (langer/kurzer Strich).
  ]

  #argument("flipped", types: "boolean", default: false)[
    Polarität umkehren.
  ]
]

#command("lamp", arg(name), arg("node"), sarg[params])[
  Glühlampe (Kreis mit X).
]

#command("resistor", arg(name), arg("node"), sarg[params])[
  Widerstand (aus zap-Paket).
]

#command("amperemeter", arg(name), arg("node"), sarg[params])[
  Amperemeter (Kreis mit A).
]

#command("voltmeter", arg(name), arg("node"), sarg[params])[
  Voltmeter (Kreis mit V).
]

#command("capacitor", arg(name), arg("node"), sarg[params])[
  Kondensator (aus zap-Paket).
]

#command("inductor", arg(name), arg("node"), sarg[params])[
  Induktivität/Spule (aus zap-Paket).
]

#command("diode", arg(name), arg("node"), sarg[params])[
  Standard-Diode (aus zap-Paket).
]

#command("led", arg(name), arg("node"), sarg[params])[
  LED (Leuchtdiode).
]

#command("motor", arg(name), arg("node"), sarg[params])[
  Motor (Kreis mit M).
]

#command("generator", arg(name), arg("node"), sarg[params])[
  Generator (Kreis mit G).
]

Weitere Informationen zu Schaltkreis-Komponenten und erweiterten Funktionen finden Sie in der offiziellen #link("https://zap.grangelouis.ch/docs", "Dokumentation des zap-Pakets")


#pagebreak(weak: true)
== Konstanten

Alle Konstanten sind über das `pk` Dictionary verfügbar und haben folgende Eigenschaften:

- `wert`: Numerischer Wert
- `einheit`: Formatierte Einheit
- `symbol`: Mathematisches Symbol
- `mit-einheit`: Wert mit Einheit formatiert

Beispiel: `pk.c.wert`, `pk.c.einheit`, `pk.c.symbol`, `pk.c.mit-einheit`

= Beispielsammlung

== Ohmsches Gesetz

#example[```typ
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
```]

== Radioaktiver Zerfall

#example[```typ
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
#pagebreak(weak: true)
= Integration mit anderen Paketen

== Mit Mathematik-Paket

Datensätze können direkt im `graphen()` des Mathematik-Pakets verwendet werden:

#sourcecode[```typ
#let t = datensatz($t$, "s", (0, 1, 2, 3, 4))
#let s = datensatz($s$, "m", (0, 5, 20, 45, 80))

// Regression durchführen
#let reg = quadratische_regression(t, s)

// Graph mit Datenpunkten und Regressionskurve
#graphen(
  datensätze: (x: t, y: s),
  x: auto,
  y: auto,
  (reg.function, (label: (x: 3, content: reg.math, position: "tl")))
)
```]
= Zusammenfassung

Das #package[physik] Paket bietet:

- ✓ Messwerttabellen mit automatischer Einheitenumrechnung
- ✓ Berechnete Datensätze aus physikalischen Formeln
- ✓ Lineare, quadratische, Potenz- und Exponential-Regressionen
- ✓ Elektrische Schaltkreise mit erweiterten Bauteilen
- ✓ Physikalische Konstanten (Fundamentale, Thermodynamik, Elektromagnetismus, Teilchen)
- ✓ Integration mit Mathematik-Paket für Visualisierungen
- ✓ Integration mit Aufgaben-Paket für Übungen

Das Paket ist ideal für Physik-Lehrkräfte, die professionelle Messwerttabellen, Analysen und Schaltpläne erstellen möchten.
