#import "../../../schuldocs/0.1.0/lib.typ": show-example, show-module, show-code
#import "@preview/gentle-clues:1.2.0": tip, info

= Über dieses Paket

Das `physik`-Paket stellt Werkzeuge für den Physik-Unterricht bereit: Messwerttabellen, statistische Regressionen, Schaltkreis-Visualisierungen und eine Sammlung physikalischer Konstanten.

Dieses Manual gliedert sich wie folgt:

+ *Schnellstart* -- Erste Schritte
+ *Datensätze* -- Messdaten definieren und berechnen
+ *Messwerttabellen* -- Tabellen formatieren
+ *Regressionen* -- Statistische Auswertungen
+ *Schaltkreise* -- Elektrische Schaltpläne
+ *Physikalische Konstanten* -- Vordefinierte Konstanten
+ *API-Referenz* -- Vollständige Funktionsdokumentation

= Schnellstart

```typ
#import "@schule/physik:0.0.2": *

#let t = datensatz("Zeit", "s", (0, 1, 2, 3, 4, 5))
#let s = datensatz("Weg", "m", (0, 1.2, 4.8, 10.8, 19.2, 30.0))

#messwerttabelle(t, s)

#let r = lineare_regression(t, s)
Regressionsgerade: #r.math
```

= Datensätze

Datensätze sind die Grundlage für Tabellen und Regressionen. Sie werden mit `datensatz()`, `messdaten()` oder `berechnung()` erzeugt.

== Messdaten definieren

#show-example(
  rendered: {
    import "../messwerttabellen.typ": datensatz, messwerttabelle
    let t = datensatz("Zeit", "s", (0, 1, 2, 3, 4, 5))
    messwerttabelle(t)
  },
  source: ```typ
  #let t = datensatz("Zeit", "s", (0, 1, 2, 3, 4, 5))
  #messwerttabelle(t)
  ```,
  width: 14cm,
)

== Leere Datensätze für Schüler

Mit `messdaten()` werden leere Zeilen für Schüler-Eintragungen erzeugt:

#show-example(
  rendered: {
    import "../messwerttabellen.typ": messdaten, messwerttabelle
    let t = messdaten("Zeit", "s", 5)
    let s = messdaten("Weg", "m", 5)
    messwerttabelle(t, s)
  },
  source: ```typ
  #let t = messdaten("Zeit", "s", 5)
  #let s = messdaten("Weg", "m", 5)
  #messwerttabelle(t, s)
  ```,
  width: 14cm,
)

== Berechnete Datensätze

Mit `berechnung()` lassen sich Spalten aus bestehenden Datensätzen ableiten:

#show-example(
  rendered: {
    import "../messwerttabellen.typ": datensatz, berechnung, messwerttabelle
    let t = datensatz("Zeit", "s", (1.0, 2.0, 3.0, 4.0))
    let t2 = berechnung("Zeit²", "s²", t, t => t * t)
    messwerttabelle(t, t2)
  },
  source: ```typ
  #let t = datensatz("Zeit", "s", (1.0, 2.0, 3.0, 4.0))
  #let t2 = berechnung("Zeit²", "s²", t, t => t * t)
  #messwerttabelle(t, t2)
  ```,
  width: 14cm,
)

= Messwerttabellen

Die Funktion `messwerttabelle()` rendert einen oder mehrere Datensätze als formatierte Tabelle.

#show-example(
  rendered: {
    import "../messwerttabellen.typ": datensatz, messwerttabelle
    let x = datensatz("Zeit", "s", (1.0, 2.0, 3.0, 4.0, 5.0))
    let y = datensatz("Weg", "m", (1.5, 6.0, 13.5, 24.0, 37.5))
    messwerttabelle(x, y)
  },
  source: ```typ
  #let x = datensatz("Zeit", "s", (1.0, 2.0, 3.0, 4.0, 5.0))
  #let y = datensatz("Weg", "m", (1.5, 6.0, 13.5, 24.0, 37.5))
  #messwerttabelle(x, y)
  ```,
  width: 14cm,
)

#tip[
  Mit `max-digits` lässt sich die Anzahl der Nachkommastellen global steuern,
  oder pro Datensatz über den gleichnamigen Parameter von `datensatz()`.
]

= Regressionen

Alle Regressionsfunktionen akzeptieren Datensätze (von `datensatz()`) oder reine Werte-Arrays und geben ein Dictionary zurück mit:
- `math` -- Formeldarstellung als `content`
- `function` -- Typst-Funktion `x => y`
- Koeffizienten (je nach Regressions­typ)

== Lineare Regression

#show-example(
  rendered: {
    import "../messwerttabellen.typ": datensatz
    import "../regressionen.typ": lineare_regression
    let t = datensatz("$t$", "s", (1.0, 2.0, 3.0, 4.0, 5.0))
    let s = datensatz("$s$", "m", (2.1, 4.0, 5.9, 8.1, 9.8))
    let r = lineare_regression(t, s)
    r.math
  },
  source: ```typ
  #let t = datensatz("$t$", "s", (1.0, 2.0, 3.0, 4.0, 5.0))
  #let s = datensatz("$s$", "m", (2.1, 4.0, 5.9, 8.1, 9.8))
  #let r = lineare_regression(t, s)
  #r.math
  ```,
  width: 14cm,
)

== Quadratische Regression

```typ
#let r = quadratische_regression(t, s)
// Koeffizienten: r.a, r.b, r.c
Regressionskurve: #r.math
```

== Wurzel-Regression

```typ
#let r = wurzel_regression(t, s)
// Koeffizienten: r.a, r.b
Regressionskurve: #r.math
```

== Exponentielle Regression

```typ
#let r = exponentielle_regression(t, s)
// Koeffizienten: r.a, r.b  (y = b·eᵃˣ)
Regressionskurve: #r.math
```

== Potenz-Regression

```typ
#let r = potenz_regression(t, s)
// Koeffizienten: r.a, r.m  (y = a·xᵐ)
Regressionskurve: #r.math
```

== Polynom-Regression

```typ
#let r = polynom_regression(t, s, 3)
// Koeffizienten: r.c0, r.c1, r.c2, r.c3
Regressionskurve: #r.math
```

= Schaltkreise

`schaltkreis` ist ein Alias für `zap.circuit`. Alle `zap`-Komponenten können im Block verwendet werden.

```typ
#schaltkreis[
  #source("U", (0,0)--(0,3), current: "dc")
  #lamp("L", (0,3)--(3,3))
  #amperemeter("A", (3,3)--(3,0))
  -- (3,0)--(0,0) --
]
```

== Verfügbare Komponenten

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Funktion*], [*Bauteil*]),
  [`source`], [Spannungs-/Stromquelle (DC oder AC)],
  [`multimeter`], [Multimeter (Kreis mit Zeiger)],
  [`lamp`], [Glühlampe (Kreis mit X)],
  [`amperemeter`], [Amperemeter (Kreis mit A)],
  [`voltmeter`], [Voltmeter (Kreis mit V)],
  [`motor`], [Motor (Kreis mit M)],
  [`generator`], [Generator (Kreis mit G)],
)

#info[
  Weitere Bauteile (Widerstände, Kondensatoren, Dioden …) stehen direkt aus dem `zap`-Paket zur Verfügung.
]

= Physikalische Konstanten

Das Dictionary `pk` enthält vordefinierte physikalische Konstanten:

```typ
#import "@schule/physik:0.0.2": pk

// Zugriff auf Einzelkonstanten:
pk.c.mit-einheit    // → 299 792 458 m/s
pk.h.symbol         // → h
pk.g.wert           // → 9.81

// Teilchenmassen:
pk.m.elektron.mit-einheit
pk.m.proton.mit-einheit

// Schallgeschwindigkeit:
pk.v.schall.mit-einheit
```

Verfügbare Konstanten:

#table(
  columns: (auto, auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Schlüssel*], [*Symbol*], [*Bezeichnung*]),
  [`pk.c`], [$c$], [Lichtgeschwindigkeit],
  [`pk.h`], [$h$], [Planck-Konstante],
  [`pk.h_eV`], [$h$], [Planck-Konstante in eV],
  [`pk.e`], [$e$], [Elementarladung],
  [`pk.g`], [$g$], [Erdbeschleunigung],
  [`pk.G`], [$G$], [Gravitationskonstante],
  [`pk.k_B`], [$k_B$], [Boltzmann-Konstante],
  [`pk.N_A`], [$N_A$], [Avogadro-Konstante],
  [`pk.R`], [$R$], [Allgemeine Gaskonstante],
  [`pk.epsilon_0`], [$epsilon_0$], [Elektrische Feldkonstante],
  [`pk.mu_0`], [$mu_0$], [Magnetische Feldkonstante],
  [`pk.m.elektron`], [$m_e$], [Elektronenmasse],
  [`pk.m.proton`], [$m_p$], [Protonenmasse],
  [`pk.m.neutron`], [$m_n$], [Neutronenmasse],
  [`pk.m.u`], [$u$], [Atomare Masseneinheit],
  [`pk.v.schall`], [$v_"Schall"$], [Schallgeschwindigkeit in Luft (20 °C)],
)

= API-Referenz

== Messwerttabellen
#show-module(read("../messwerttabellen.typ"), name: "messwerttabellen")

== Regressionen
#show-module(read("../regressionen.typ"), name: "regressionen")

== Schaltkreise
#show-module(read("../schaltkreise.typ"), name: "schaltkreise")

== Konstanten
#show-module(read("../konstanten.typ"), name: "konstanten")
