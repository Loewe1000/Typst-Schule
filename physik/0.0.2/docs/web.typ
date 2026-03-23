#import "@preview/manifesto:0.1.1": *

#let pkg = toml("../typst.toml")

#show: it => template(
  it,
  toml: pkg,
  universe: "https://typst.app/universe/package/physik",
  notices: (
    [Entwickelt für das Schule-Typst-Ökosystem],
  ),
  links: (
    (name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),
  ),
)

= Über dieses Paket

Das `physik`-Paket stellt Werkzeuge für den Physik-Unterricht bereit: Messwerttabellen, statistische Regressionen, Schaltkreis-Visualisierungen und eine Sammlung physikalischer Konstanten.

Dieses Manual gliedert sich wie folgt:

+ *Installation & Import* -- Erste Schritte
+ *Datensätze* -- Messdaten definieren und berechnen
+ *Messwerttabellen* -- Tabellen formatieren
+ *Regressionen* -- Statistische Auswertungen
+ *Schaltkreise* -- Elektrische Schaltpläne
+ *Physikalische Konstanten* -- Vordefinierte Konstanten
+ *Funktionsreferenz*

== Installation & Import

```typ
#import "@schule/physik:0.0.2": *
```

Das Paket hängt ab von: `cetz`, `zap` (Schaltkreise), `schule/aufgaben`.

= Datensätze

Datensätze sind die Grundlage für Tabellen und Regressionen.

== Messdaten definieren

```typ
#let zeit = datensatz(
  name: "Zeit",
  einheit: "s",
  werte: (0, 1, 2, 3, 4, 5),
)

#let weg = datensatz(
  name: "Weg",
  einheit: "m",
  werte: (0, 1.2, 4.8, 10.8, 19.2, 30.0),
)
```

== Leere Messdaten für Schüler

```typ
#let temperatur = messdaten(
  name: "Temperatur",
  einheit: "°C",
  anzahl-messwerte: 6,  // Leere Zeilen
)
```

== Berechnete Datensätze

```typ
#let zeit2 = berechnung(
  name: "Zeit²",
  einheit: "s²",
  datensaetze: (zeit,),
  formel: (t,) => t * t,
)
```

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Parameter*], [*Beschreibung*]),
  [`name`], [Bezeichnung (für Tabellenkopf)],
  [`einheit`], [Physikalische Einheit],
  [`datensaetze`], [Array von Datensätzen als Eingabe],
  [`formel`], [Funktion `(werte...) => ergebnis`],
)

= Messwerttabellen

```typ
#messwerttabelle(
  zeit,
  weg,
  zeit2,
  header: true,       // Kopfzeile mit Einheiten
  row-height: 1cm,    // Zeilenhöhe
  width: 100%,        // Tabellenbreite
  max-digits: 2,      // Maximale Nachkommastellen
)
```

#schema(
  {
    import "/lib.typ": datensatz, messwerttabelle
    let zeit = datensatz("Zeit", "s", (0, 1, 2, 3, 4, 5))
    let weg = datensatz("Weg", "m", (0, 1.2, 4.8, 10.8, 19.2, 30.0))
    messwerttabelle(
      zeit,
      weg,
      width: 100%,
      max-digits: 1,
    )
  },
  code: ```typ
  #let zeit = datensatz("Zeit", "s", (0, 1, 2, 3, 4, 5))
  #let weg = datensatz("Weg", "m", (0, 1.2, 4.8, 10.8, 19.2, 30.0))
  #messwerttabelle(
    zeit,
    weg,
    width: 100%,
    max-digits: 1,
  )
  ```,
  width: 14cm,
)

Leere Datensätze (via `messdaten()`) erzeugen leere Zeilen für Schüler-Eintragungen.

= Regressionen

Das Paket bietet fünf Regressionsfunktionen. Alle geben ein Dictionary zurück:

```typ
#let r = lineare_regression(x: zeit, y: weg)

// r enthält:
// r.math           → Formeldarstellung (content)
// r.function       → Typst-Funktion x => y
// r.coefficients   → (m, b) bei linearer Regression
```

== Lineare Regression (y = m·x + b)

```typ
#let r = lineare_regression(x: zeit, y: weg)

Regressionsgerade: #r.math

// In Graphen einzeichnen:
#graphen(
  x: (0, 6),
  y: (0, 35),
  r.function,
)
```

== Quadratische Regression (y = a·x² + b·x + c)

```typ
#let r = quadratische_regression(x: zeit, y: weg)
// r.coefficients = (a, b, c)
```

== Potenz-Regression (y = a·xᵇ)

```typ
#let r = potenz_regression(x: zeit, y: weg)
// r.coefficients = (a, b)
```

== Exponentielle Regression (y = a·eˣ)

```typ
#let r = exponentielle_regression(x: zeit, y: weg)
// r.coefficients = (a, b)
```

== Polynom-Regression (beliebiger Grad)

```typ
#let r = polynom_regression(x: zeit, y: weg, grad: 3)
// r.coefficients = (a_0, a_1, ..., a_n)
```

= Schaltkreise

Schaltkreise werden mit dem `zap`-Paket gezeichnet:

```typ
#schaltkreis[
  #source(label: "U")
  #resistor(label: "R₁")
  #lamp(label: "L₁")
  -- close-circuit --
]
```

`#schaltkreis[...]` ist ein Wrapper um `zap`, der deutsche Bezeichnungen bereitstellt.

== Verfügbare Komponenten

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Funktion*], [*Bauteil*]),
  [`source`], [Spannungsquelle],
  [`resistor`], [Widerstand],
  [`lamp`], [Glühlampe],
  [`amperemeter`], [Amperemeter],
  [`voltmeter`], [Voltmeter],
  [`capacitor`], [Kondensator],
  [`inductor`], [Spule],
  [`diode`], [Diode],
  [`led`], [LED],
  [`motor`], [Motor],
  [`generator`], [Generator],
)

= Physikalische Konstanten

Das Paket stellt das Dictionary `pk` (physikalische Konstanten) bereit:

```typ
#import "@schule/physik:0.0.2": pk

// Zugriff:
pk.c          // Lichtgeschwindigkeit
pk.h          // Plancksche Konstante
pk.e          // Elementarladung
pk.G          // Gravitationskonstante
pk.g          // Erdbeschleunigung
pk.k_B        // Boltzmann-Konstante
pk.N_A        // Avogadro-Konstante
pk.R          // Gaskonstante
pk.epsilon_0  // Elektrische Feldkonstante
pk.mu_0       // Magnetische Feldkonstante
```

== Teilchenmassen

```typ
pk.m.elektron   // Elektronenmasse
pk.m.proton     // Protonenmasse
pk.m.neutron    // Neutronenmasse
pk.m.u          // Atomare Masseneinheit
```

== Konstanten-Felder

Jede Konstante hat folgende Felder:

```typ
pk.c.wert           // Zahlenwert (float)
pk.c.einheit        // Einheit (string)
pk.c.symbol         // Formelzeichen (content)
pk.c.mit-einheit    // Wert mit Einheit (content)
```

Beispiel-Ausgabe:

```typ
Die Lichtgeschwindigkeit beträgt #pk.c.mit-einheit.
// → "Die Lichtgeschwindigkeit beträgt 299 792 458 m/s."
```

= Funktionsreferenz

== `datensatz()`

```typ
#datensatz(
  name: "",           // Bezeichnung
  einheit: "",        // Physikalische Einheit
  werte: (),          // Array mit Messwerten (float)
  prefix: none,       // SI-Präfix (z. B. "k", "m", "µ")
  max-digits: auto,   // Maximale Nachkommastellen
  auto-einheit: false,// Automatische Einheitenskalierung
)
```

== `messdaten()`

```typ
#messdaten(
  name: "",           // Bezeichnung
  einheit: "",        // Physikalische Einheit
  anzahl-messwerte: 5,// Anzahl leerer Zeilen
  prefix: none,       // SI-Präfix
)
```

== `berechnung()`

```typ
#berechnung(
  name: "",           // Bezeichnung
  einheit: "",        // Physikalische Einheit
  datensaetze: (),    // Eingabe-Datensätze
  formel: none,       // (werte...) => ergebnis
)
```

== `messwerttabelle()`

```typ
#messwerttabelle(
  ..datensaetze,      // Datensätze (positionale Argumente)
  amount: auto,       // Anzahl Zeilen (auto = aus Daten)
  row-height: 0.8cm,  // Zeilenhöhe
  header: true,       // Kopfzeile anzeigen
  width: auto,        // Tabellenbreite
  max-digits: auto,   // Maximale Nachkommastellen
)
```

= Vollständiges Beispiel

```typ
#import "@schule/physik:0.0.2": *
#import "@schule/mathematik:0.0.2": graphen
#import "@schule/arbeitsblatt:0.2.4": *

#show: arbeitsblatt.with(
  title: "Auswertung: Gleichförmige Bewegung",
  class: "9a",
  loesungen: "seiten",
)

#let t = datensatz(
  name: "Zeit",
  einheit: "s",
  werte: (0, 1, 2, 3, 4, 5),
)

#let s = datensatz(
  name: "Weg",
  einheit: "m",
  werte: (0, 2.1, 4.0, 6.2, 8.1, 10.0),
)

#aufgabe("Messwerte")[
  #teilaufgabe[
    Erstelle eine Tabelle der Messwerte.
    #loesung[#messwerttabelle(t, s)]
  ]

  #teilaufgabe[
    Führe eine lineare Regression durch und trage die Geraden ein.
    #let r = lineare_regression(x: t, y: s)
    #loesung[
      #r.math
      #graphen(x: (0, 5), y: (0, 11), t.werte.zip(s.werte), r.function)
    ]
  ]
]
```
