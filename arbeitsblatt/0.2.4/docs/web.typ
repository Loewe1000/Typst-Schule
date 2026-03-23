#import "@preview/manifesto:0.1.1": *

#let pkg = toml("../typst.toml")

#show: it => template(
  it,
  toml: pkg,
  universe: "https://typst.app/universe/package/arbeitsblatt",
  notices: (
    [Entwickelt für das Schule-Typst-Ökosystem],
  ),
  links: (
    (name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),
  ),
)

= Über dieses Paket

Das `arbeitsblatt`-Paket ist das zentrale Template-Paket des Schule-Ökosystems. Es bietet eine vollständige Lösung zur Erstellung professioneller Arbeitsblätter mit strukturierten Aufgaben, Lösungen, Materialien und automatischer Bewertung.

Dieses Manual gliedert sich wie folgt:

+ *Grundlagen* -- Installation, Import, erstes Dokument
+ *Aufgaben-Shortcodes* -- Automatische Umwandlung von Überschriften
+ *Kopfzeile & Layout* -- Anpassung von Kopfzeile und Seite
+ *Hilfsfunktionen* -- Lücken, Minipage, QR-Codes, Arbeitsbereiche
+ *Paket-Integration* -- Physik, CeTZ, Fancy-Units
+ *Funktionsreferenz* -- Vollständige Parameter-Dokumentation

= Grundlagen

== Paket importieren

```typ
#import "@schule/arbeitsblatt:0.2.4": *
```

Das Paket integriert automatisch alle wichtigen Funktionen aus dem `aufgaben`-Paket.

== Erstes Arbeitsblatt

```typ
#import "@schule/arbeitsblatt:0.2.4": *

#show: arbeitsblatt.with(
  title: "Quadratische Funktionen",
  class: "9a",
)

Hier beginnt der Inhalt des Arbeitsblatts.
```

== Druck-optimiertes Arbeitsblatt

```typ
#show: arbeitsblatt.with(
  title: "Klassenarbeit – Vorbereitung",
  class: "10b",
  print: true,      // Breiteren linken Rand für Heftung
  duplex: true,     // Abwechselnde Ränder für Doppelseitendruck
)
```

= Aufgaben, Lösungen & Materialien

== Aufgaben-Shortcodes

Das Paket kann Überschriften und Aufzählungen automatisch in Aufgaben umwandeln – kein explizites `#aufgabe[]` nötig.

```typ
#show: arbeitsblatt.with(
  aufgaben-shortcodes: "alle",  // Standard
)

= Quadratische Funktionen   // → #aufgabe("Quadratische Funktionen")[...]

+ Nullstellen berechnen      // → #teilaufgabe[Nullstellen berechnen]
+ Scheitelpunkt bestimmen    // → #teilaufgabe[Scheitelpunkt bestimmen]
```

Mögliche Werte für `aufgaben-shortcodes`:

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Wert*], [*Verhalten*]),
  [`"alle"`], [Überschriften → Aufgaben, Aufzählung → Teilaufgaben (Standard)],
  [`"aufgaben"`], [Nur Überschriften → Aufgaben],
  [`"teilaufgaben"`], [Nur Aufzählung → Teilaufgaben],
  [`"keine"`], [Keine automatische Umwandlung],
)

== Lösungsmodus

Der `loesungen`-Parameter steuert, wie Musterlösungen angezeigt werden:

```typ
#show: arbeitsblatt.with(
  loesungen: "seiten",  // Lösungen als separate letzte Seite(n)
)

#aufgabe[
  Berechne $3 + 4$.
  #loesung[Das Ergebnis ist $7$.]
]
```

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Wert*], [*Verhalten*]),
  [`"keine"`], [Lösungen werden nicht angezeigt (Standard)],
  [`"sofort"`], [Lösungen direkt nach der Aufgabe],
  [`"folgend"`], [Lösungen nach dem gesamten Inhalt],
  [`"seiten"`], [Lösungen auf separaten Seiten am Ende],
)

== Materialien

Materialien (z. B. Texte, Bilder, Diagramme) werden mit `#material[]` definiert und können mit `<label>` referenziert werden:

```typ
#aufgabe[
  Beschreibe den Graphen in @mein-material.
]

#material(
  caption: "Graph der Funktion",
  label: <mein-material>,
)[
  #canvas({ ... }) // CeTZ-Diagramm
]
```

Der `materialien`-Parameter steuert die Darstellung (wie `loesungen`).

= Bewertung

== Punkte vergeben

```typ
#show: arbeitsblatt.with(
  punkte: "alle",  // Punkte bei Aufgaben und Teilaufgaben anzeigen
)

#aufgabe(punkte: 5)[
  Hauptaufgabe mit 5 Punkten.

  #teilaufgabe(punkte: 2)[
    Löse...
  ]
]
```

== Erwartungshorizont

```typ
#aufgabe[
  Erkläre das Energieerhaltungsgesetz.
  #erwartung(3)[
    Korrekte Nennung aller drei Energieformen; Anwendungsbeispiel
  ]
]
```

= Kopfzeile & Layout

== Benutzerdefinierte Kopfzeile

```typ
#let meine-kopfzeile = [
  #text(size: 14pt, weight: "bold")[Gymnasium Musterstadt]
  #h(1fr)
  Klasse 9a
  #line(length: 100%)
]

#show: arbeitsblatt.with(
  custom-header: meine-kopfzeile,
  header-ascent: 12%,
)
```

== QR-Code in Kopfzeile

```typ
#show: arbeitsblatt.with(
  title: "Arbeitsblatt",
  copyright: "https://meine-schule.de/material/ab-001",
)
```

== Seiteneinstellungen

```typ
#show: arbeitsblatt.with(
  page-settings: (
    margin: (top: 3cm, bottom: 2cm, x: 2cm),
    columns: 2,
  ),
)
```

= Hilfsfunktionen

== Lückentext

```typ
// Lücke mit Beschriftung:
Die Hauptstadt ist #lücke[Berlin].

// Kompakte Lücke (kein horizontaler Abstand):
Wert: #lücke(tight: true)[42]
```

#schema(
  {
    import "/src/arbeitsblatt.typ": lücke
    [Die Hauptstadt von Frankreich ist #lücke[Paris]. Der Wert beträgt #lücke(tight: true)[42].]
  },
  code: ```typ
  Die Hauptstadt von Frankreich ist #lücke[Paris].
  Der Wert beträgt #lücke(tight: true)[42].
  ```,
  width: 14cm,
)

== Minipage – Mehrspaltiges Layout

```typ
// Explizite Spaltenbreiten:
#minipage(
  columns: (1fr, 2fr),
  spacing: 1cm,
)[
  Linke Spalte
][
  Rechte Spalte
]

// Automatische Spaltenanzahl:
#minipage(spacing: 5mm)[
  Spalte 1
][
  Spalte 2
][
  Spalte 3
]
```

#schema(
  {
    import "/src/arbeitsblatt.typ": minipage
    minipage(
      columns: (1fr, 2fr),
      spacing: 1cm,
    )[
      Linke Spalte
    ][
      Rechte Spalte (doppelt so breit)
    ]
  },
  code: ```typ
  #minipage(
    columns: (1fr, 2fr),
    spacing: 1cm,
  )[
    Linke Spalte
  ][
    Rechte Spalte (doppelt so breit)
  ]
  ```,
  width: 14cm,
)

== QR-Box

```typ
#qrbox(
  "https://example.com",
  "Zur Website",
  width: 3cm,
)
```

== Icon-Link

```typ
#icon-link(
  "https://example.com",
  "Beschreibung",
  icon: emoji.chain,
  color: blue,
)
```

== Arbeitsbereich

```typ
#workspace(height: 5cm)[
  #kariert(2)  // kariertes Papier mit 2mm-Raster
]
```

Arbeitsbereiche werden nur angezeigt, wenn `workspaces: true` (Standard).

== Seitenumbrüche

```typ
#print-pagebreak()      // Nur im Druckmodus
#non-print-pagebreak()  // Nur außerhalb des Druckmodus
```

= Paket-Integration

Das Paket integriert automatisch folgende externe Pakete:

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Paket*], [*Verwendung*]),
  [`fontawesome`], [Icons überall im Dokument],
  [`gentle-clues`], [Info-/Warn-/Tipp-Boxen],
  [`cetz`], [Zeichnungen und Diagramme],
  [`codly`], [Code-Syntax-Highlighting],
  [`colorful-boxes`], [Farbige Text-Boxen],
  [`fancy-units`], [Physikalische Einheiten],
  [`zeigt`], [QR-Code-Generierung],
)

== CeTZ-Diagramme

```typ
#canvas({
  import draw: *

  line((0, 0), (6, 1))
  circle((2, 2), radius: 1)
  content((3, 0), [Beschriftung])
})
```

== Fancy-Units

Das Paket konfiguriert `fancy-units` automatisch mit deutschen Einstellungen (Komma als Dezimaltrennzeichen):

```typ
#qty[9.81][m/s^2]   // 9,81 m/s²
#unit[N/m^2]        // N/m²
```

= Funktionsreferenz

== `arbeitsblatt()`

Haupt-Template-Funktion, wird über `#show: arbeitsblatt.with(...)` angewendet.

#table(
  columns: (auto, auto, auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Parameter*], [*Typ*], [*Standard*], [*Beschreibung*]),
  [`title`], [`string`], [`""`], [Titel des Arbeitsblatts],
  [`class`], [`string`], [`""`], [Klassenbezeichnung],
  [`print`], [`bool`], [`false`], [Druckmodus mit optimierten Rändern],
  [`duplex`], [`bool`], [`true`], [Abwechselnde Ränder für Doppelseitendruck],
  [`landscape`], [`bool`], [`false`], [Querformat],
  [`paper`], [`string`], [`"a4"`], [Papierformat],
  [`font`], [`string`], [`"Myriad Pro"`], [Hauptschrift],
  [`math-font`], [`string`], [`"Fira Math"`], [Mathematikschrift],
  [`font-size`], [`length`], [`12pt`], [Grundschriftgröße],
  [`title-font-size`], [`length`], [`16pt`], [Titelschriftgröße],
  [`figure-font-size`], [`length`], [`9pt`], [Abbildungsschriftgröße],
  [`loesungen`], [`string`], [`"keine"`], [Lösungsanzeige-Modus],
  [`materialien`], [`string`], [`"seiten"`], [Materialanzeige-Modus],
  [`punkte`], [`string`], [`"keine"`], [Punkteanzeige-Modus],
  [`teilaufgabe-numbering`], [`string`], [`"a)"`], [Nummerierungsschema für Teilaufgaben],
  [`workspaces`], [`bool`], [`true`], [Arbeitsbereiche anzeigen],
  [`aufgaben-shortcodes`], [`string`], [`"alle"`], [Shortcode-Modus],
  [`custom-header`], [`content | none`], [`none`], [Eigene Kopfzeile],
  [`copyright`], [`string | none`], [`none`], [Copyright-URL für QR-Code],
  [`page-settings`], [`dict`], [`(:)`], [Zusätzliche Seiteneinstellungen],
  [`body`], [`content`], [—], [Inhalt des Arbeitsblatts],
)

= Vollständiges Beispiel

```typ
#import "@schule/arbeitsblatt:0.2.4": *

#show: arbeitsblatt.with(
  title: "Quadratische Funktionen",
  class: "9a",
  print: true,
  punkte: "alle",
  loesungen: "seiten",
  materialien: "seiten",
)

= Grundlagen

+ Bestimme die Nullstellen von $f(x) = x^2 - 4x + 3$.
  #erwartung(2)[Mitternachtsformel; beide Nullstellen korrekt]
  #loesung[$x_1 = 1$, $x_2 = 3$]

+ Beschreibe den Graphen in @graph.

#material(caption: "Graph von f(x)", label: <graph>)[
  #rect(width: 100%, height: 6cm)[Platzhalter für Diagramm]
]

= Anwendung

+ Skizziere den Graphen von $g(x) = -x^2 + 2x$.
  #erwartung(3)[Korrekte Scheitelform; richtiger Öffnungssinn; Nullstellen markiert]
  
  #workspace(height: 6cm)[#kariert(3)]
```
