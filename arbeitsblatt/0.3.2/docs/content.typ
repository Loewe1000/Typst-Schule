#import "../../../schuldocs/0.1.0/lib.typ": show-example, show-module, show-code
#import "@preview/gentle-clues:1.2.0": tip, info, warning

= Über dieses Paket

Das `arbeitsblatt`-Paket ist das zentrale Template-Paket des Schule-Ökosystems. Es bietet eine vollständige Lösung zur Erstellung professioneller Arbeitsblätter mit strukturierten Aufgaben, Lösungen, Materialien und automatischer Bewertung.

Dieses Manual gliedert sich wie folgt:

+ *Schnellstart* -- Minimales Beispiel zum Einstieg
+ *Bundle-Export* -- Mehrere Varianten (Druck, Digital, Lösung) aus einer Datei
+ *Grundlagen* -- Installation, Import, erste Arbeitsblätter
+ *Aufgaben-Shortcodes* -- Automatische Umwandlung von Überschriften und Listen
+ *Kopfzeile & Layout* -- Anpassung von Kopfzeile und Seitenformat
+ *Hilfsfunktionen* -- Lücken, Minipage, QR-Codes, Arbeitsbereiche
+ *Paket-Integration* -- Physik, CeTZ, Fancy-Units
+ *API-Referenz* -- Vollständige Parameterdokumentation

= Schnellstart

#show-code[```typ
#import "@schule/arbeitsblatt:0.3.2": *

#show: arbeitsblatt.with(
  title: "Quadratische Funktionen",
  class: "9a",
  print: true,
  punkte: "alle",
  loesungen: "seiten",
)

= Grundlagen

+ Bestimme die Nullstellen von $f(x) = x^2 - 4x + 3$.
  #erwartung(2)[Mitternachtsformel; beide Nullstellen korrekt]
  #loesung[$x_1 = 1$, $x_2 = 3$]

+ Beschreibe den Graphen in @graph.

#material(caption: "Graph von f(x)", label: <graph>)[
  #rect(width: 100%, height: 6cm)[Platzhalter]
]

= Anwendung

+ Skizziere den Graphen von $g(x) = -x^2 + 2x$.
  #erwartung(3)[Scheitelform; Öffnungssinn; Nullstellen markiert]

  #workspace(height: 6cm)[#kariert(3)]
```]

= Bundle-Export

Neu in 0.3.0: Mit Typst 0.15+ kann eine Quelldatei mehrere Ausgabedateien
erzeugen. Das Arbeitsblatt-Paket nutzt das, um Druck-, Digital- und
Lösungsfassung in einem Lauf zu generieren:

#show-code[```bash
typst compile --features bundle --format bundle ab.typ ausgabe/
```]

Ohne weitere Konfiguration entstehen `digital.pdf` und `loesung.pdf`. Über
`varianten:` lassen sich die Varianten wählen:

#show-code[```typ
#show: arbeitsblatt.with(
  title: "Quadratische Funktionen",
  class: "9a",
  varianten: ("druck", "digital", "loesung"),
  dateiname: "quadratische-funktionen",  // optionales Präfix
)
```]

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Variante*], [*Bedeutung*]),
  [`"druck"`], [Druckfassung: A4-Seiten, Heftrand, Arbeitsbereiche],
  [`"digital"`], [Bildschirmfassung: eine endlose Seite (Standard)],
  [`"loesung"`], [Lösungsblatt: nur die Lösungen, Drucklayout (Standard)],
  [`"zweifach"`], [Kopiervorlage: jede Seite zweimal auf einem Bogen],
)

Als Dictionary können pro Variante beliebige `arbeitsblatt`-Parameter
überschrieben und eigene Varianten definiert werden:

#show-code[```typ
#show: arbeitsblatt.with(
  title: "Mein AB",
  varianten: (
    druck: (punkte: "alle"),
    loesung: (:),
    lehrer: (print: true, loesungen: "sofort", workspaces: false),
  ),
)
```]

Der Override-Schlüssel `datei:` ersetzt den Ausgabepfad einer Variante
komplett (z. B. `datei: "uebung.svg"` für eine SVG-Ausgabe).

#info[
  Außerhalb des Bundle-Modus (normales `typst compile`) wird `varianten:`
  ignoriert und es entsteht wie bisher genau ein Dokument. Bestehende
  Dokumente funktionieren unverändert.
]

#warning[
  Der Bundle-Export ist in Typst 0.15 noch experimentell und muss mit
  `--features bundle` (oder `TYPST_FEATURES=bundle`) aktiviert werden.
]

== Zweifach: zwei Kopien pro Bogen

Neu in 0.3.2: Die Variante `"zweifach"` legt jede Seite zweimal auf einen
Bogen der nächsten Größe und zieht eine gestrichelte Schnittlinie dazwischen –
ein A5-Blatt wird so zur A4-Kopiervorlage für zwei Exemplare.

#show-code[```typ
#show: arbeitsblatt.with(
  title: "Bruchrechnung – Kurzcheck",
  class: "6a",
  paper: "a5",
  landscape: true,
  varianten: ("druck", "zweifach"),
)
```]

Die Ausrichtung ergibt sich aus dem Format: A5 quer landet zweimal
untereinander auf A4 hoch, A5 hoch zweimal nebeneinander auf A4 quer.
Unterstützt werden A6, A5 und A4 (jeweils auf das nächstgrößere Format).

Der Seitenumbruch ist derselbe wie in der A5-Fassung – zeilengenau, auch
mitten im Absatz. Möglich macht das ein Kunstgriff: Der Inhalt wird intern in
Spalten gesetzt, die exakt die Maße des A5-Textbereichs haben. Typst bricht
Spalten genauso um wie Seiten, also entspricht jede Spalte einer A5-Seite.
Jeder Bogen zeigt dann zweimal dieselbe Spalte.

#info[
  `zweifach` setzt `print: true`, denn die Digitalfassung hat eine endlos
  hohe Seite und ließe sich nicht in Bögen aufteilen.
]

#warning[
  Die Aufgabennummerierung startet in jeder Kopie neu bei 1 – beide Hälften
  sind identisch. Wer stattdessen fortlaufende Seiten nebeneinander drucken
  will (Seite 1 | Seite 2), nutzt dafür den Druckdialog, nicht diese Variante.
]

Explizite Seitenumbrüche gehen dabei nicht verloren: `pagebreak()` wird im
Zweifach-Modus zu einem Spaltenumbruch, und weil eine Spalte eine A5-Seite
ist, bricht das Blatt an derselben Stelle. Das gilt auch für `page[..]` ohne
Argumente – intern sind das nur zwei schwache Seitenumbrüche um den Inhalt
herum.

#warning[
  Nicht möglich ist `page()` mit Argumenten, also etwa `page(fill: aqua)[..]`.
  Eine Seitenkonfiguration ist in Containern verboten, und Typst lässt darauf
  keine Show-Rule zu – das Paket kann den Fall darum weder übersetzen noch
  vorab erkennen; es bleibt bei Typsts Meldung `page configuration is not
  allowed inside of containers`. Wer eine ganzseitige Fläche braucht, nimmt
  `pagebreak()` und einen `block` in Seitenhöhe.
]

== Alle Varianten in der Vorschau

Die Editor-Preview rendert das paged-Target und zeigt darum von Haus aus
genau ein Dokument – auch dann, wenn der Bundle-Export mehrere Dateien
erzeugen würde. Seit 0.3.1 kann sie stattdessen alle Varianten
hintereinander zeigen, was vor allem beim Schreiben der Lösungen hilft.

Dazu setzt der Editor den System-Input `vorschau=alle`. In VS Code mit
Tinymist genügt eine Zeile in den Einstellungen:

#show-code[```json
"tinymist.preview.sysInputs": { "vorschau": "alle" }
```]

Auf der Kommandozeile entspricht das `typst compile --input vorschau=alle`.

Gezeigt werden genau die Varianten, die auch der Bundle-Export erzeugen
würde – ohne `varianten:` also `digital` und `loesung`. Einzelne Dokumente
können sich mit `vorschau-alle: false` davon ausnehmen.

#info[
  Die Kopplung an den System-Input ist Absicht: `typst compile` und die
  Preview nutzen beide das paged-Target und sind im Dokument nicht
  unterscheidbar. Am Target festgemacht, lägen die Lösungsseiten sonst auch
  in der Datei, die man vor dem Kopieren erzeugt.
]

#warning[
  Bei mehreren Varianten zeigt eine Quellzeile auf mehrere Stellen in der
  Vorschau. Das Scroll-Sync springt dann zur ersten Fundstelle, also in die
  erste Variante.
]

= Grundlagen

== Paket importieren

#show-code[```typ
#import "@schule/arbeitsblatt:0.3.2": *
```]

Das Paket integriert automatisch alle wichtigen Funktionen aus dem `aufgaben`-Paket sowie zahlreiche externe Pakete (siehe _Paket-Integration_).

== Minimales Arbeitsblatt

#show-code[```typ
#import "@schule/arbeitsblatt:0.3.2": *

#show: arbeitsblatt.with(
  title: "Quadratische Funktionen",
  class: "9a",
)

Hier beginnt der Inhalt des Arbeitsblatts.
```]

== Druck-optimiertes Arbeitsblatt

#show-code[```typ
#show: arbeitsblatt.with(
  title: "Klassenarbeit – Vorbereitung",
  class: "10b",
  print: true,   // Breiteren linken Rand für Heftung
  duplex: true,  // Abwechselnde Ränder für Doppelseitendruck
)
```]

#tip[
  Im *Bildschirmmodus* (`print: false`) ist die Seitenhöhe automatisch (`height: auto`), sodass kein Seitenumbruch entsteht und das Arbeitsblatt als einzelne scrollbare Seite erscheint.
]

= Aufgaben-Shortcodes

Das Paket kann Überschriften und nummerierte Listen automatisch in Aufgaben und Teilaufgaben umwandeln – kein explizites `#aufgabe[]` nötig.

#show-code[```typ
#show: arbeitsblatt.with(
  aufgaben-shortcodes: "alle",  // Standard
)

= Quadratische Funktionen   // → aufgabe("Quadratische Funktionen")[...]

+ Nullstellen berechnen      // → teilaufgabe[Nullstellen berechnen]
+ Scheitelpunkt bestimmen    // → teilaufgabe[Scheitelpunkt bestimmen]
```]

Mögliche Werte für `aufgaben-shortcodes`:

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Wert*], [*Verhalten*]),
  [`"alle"`], [Überschriften → Aufgaben _und_ Aufzählung → Teilaufgaben (Standard)],
  [`"aufgaben"`], [Nur Überschriften → Aufgaben],
  [`"teilaufgaben"`], [Nur Aufzählung → Teilaufgaben],
  [`"keine"`], [Keine automatische Umwandlung],
)

== Lösungsmodus

#show-code[```typ
#show: arbeitsblatt.with(
  loesungen: "seiten",  // Lösungen als separate letzte Seite(n)
)

#aufgabe[
  Berechne $3 + 4$.
  #loesung[Das Ergebnis ist $7$.]
]
```]

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Wert*], [*Verhalten*]),
  [`"keine"`], [Lösungen werden nicht angezeigt (Standard)],
  [`"sofort"`], [Lösungen direkt nach der Aufgabe],
  [`"folgend"`], [Lösungen gesammelt nach dem gesamten Inhalt],
  [`"seiten"`], [Lösungen auf separaten Seiten am Ende],
)

== Materialien

#show-code[```typ
#aufgabe[
  Beschreibe den Graphen in @mein-material.
]

#material(
  caption: "Graph der Funktion",
  label: <mein-material>,
)[
  #canvas({ ... }) // CeTZ-Diagramm
]
```]

Der `materialien`-Parameter steuert die Darstellung analog zu `loesungen`.

== Punkte & Erwartungen

#show-code[```typ
#show: arbeitsblatt.with(
  punkte: "alle",
)

#aufgabe[
  Erkläre das Energieerhaltungsgesetz.
  #erwartung(3)[Korrekte Nennung aller drei Energieformen]
]
```]

= Kopfzeile & Layout

== Standard-Kopfzeile

Die Standardkopfzeile zeigt links den Titel, rechts die Klassenbezeichnung und – wenn gesetzt – einen kleinen Copyright-QR-Code.

== Benutzerdefinierte Kopfzeile

#show-code[```typ
#let meine-kopfzeile = [
  #text(size: 14pt, weight: "bold")[Gymnasium Musterstadt]
  #h(1fr)
  Klasse 9a
  #move(dy: -.4em, line(length: 100%, stroke: 0.5pt + luma(200)))
]

#show: arbeitsblatt.with(
  custom-header: meine-kopfzeile,
  header-ascent: 12%,
)
```]

== Copyright-QR-Code in der Kopfzeile

#show-code[```typ
#show: arbeitsblatt.with(
  title: "Arbeitsblatt",
  copyright: "https://meine-schule.de/material/ab-001",
)
```]

Der QR-Code erscheint klein zwischen Titel und Klasse in der Kopfzeile.

== Seiteneinstellungen

#show-code[```typ
#show: arbeitsblatt.with(
  page-settings: (
    margin: (top: 3cm, bottom: 2cm, x: 2cm),
    columns: 2,
  ),
)
```]

= Hilfsfunktionen

== Lückentext

#show-example(
  rendered: {
    import "../src/arbeitsblatt.typ": lücke
    [Die Hauptstadt von Frankreich ist #lücke[Paris]. Der Wert beträgt #lücke(tight: true)[42].]
  },
  source: ```typ
  Die Hauptstadt von Frankreich ist #lücke[Paris].
  Der Wert beträgt #lücke(tight: true)[42].
  ```,
  width: 14cm,
)

== Minipage – Mehrspaltiges Layout

#show-example(
  rendered: {
    import "../src/arbeitsblatt.typ": minipage
    minipage(
      columns: (1fr, 2fr),
      spacing: 1cm,
    )[
      Linke Spalte
    ][
      Rechte Spalte (doppelt so breit)
    ]
  },
  source: ```typ
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

Ohne `columns`-Angabe werden alle übergebenen Blöcke gleichmäßig verteilt:

#show-code[```typ
#minipage[Spalte 1][Spalte 2][Spalte 3]
```]

== QR-Box

#show-example(
  rendered: {
    import "../src/arbeitsblatt.typ": qrbox
    qrbox("https://typst.app", "typst.app", width: 3cm)
  },
  source: ```typ
  #qrbox(
    "https://typst.app",
    "typst.app",
    width: 3cm,
  )
  ```,
  width: 14cm,
)

== Icon-Link

#show-example(
  rendered: {
    import "../src/arbeitsblatt.typ": icon-link
    icon-link("https://typst.app", "Typst-Website")
  },
  source: ```typ
  #icon-link("https://typst.app", "Typst-Website")
  ```,
  width: 14cm,
)

#show-code[```typ
// Mit eigenem Icon und Farbe:
#icon-link(
  "https://github.com",
  "GitHub",
  icon: "🐙",
  color: black,
)
```]

== Monospace-Text

#show-example(
  rendered: {
    import "../src/arbeitsblatt.typ": mono
    [Öffne die Datei #mono[ab.typ] im Editor.]
  },
  source: ```typ
  Öffne die Datei #mono[ab.typ] im Editor.
  ```,
  width: 14cm,
)

== Arbeitsbereich

#show-code[```typ
#workspace(height: 5cm)[
  #kariert(2)  // kariertes Papier mit 2 mm-Raster
]
```]

#info[
  Arbeitsbereiche werden nur angezeigt, wenn `workspaces: true` in `arbeitsblatt()` gesetzt ist (Standard). So kann dieselbe Quelldatei für Schüler (mit Platz) und Lehrkraft (ohne Platz) kompiliert werden.
]

== Seitenumbrüche

#show-code[```typ
#print-pagebreak()      // Seitenumbruch nur im Druckmodus (print: true)
#non-print-pagebreak()  // Seitenumbruch nur im Bildschirmmodus (print: false)
```]

= Paket-Integration

Das Paket integriert automatisch folgende externe Pakete:

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Paket*], [*Funktion*]),
  [`fontawesome`], [Icons überall im Dokument],
  [`gentle-clues`], [Info-/Warn-/Tipp-Boxen],
  [`cetz`], [Zeichnungen und Diagramme],
  [`codly`], [Code-Syntax-Highlighting],
  [`colorful-boxes`], [Farbige Text-Boxen (stickybox etc.)],
  [`fancy-units`], [Physikalische Einheiten (deutsch konfiguriert)],
  [`zebra`], [QR-Code-Generierung],
)

== CeTZ-Diagramme

#show-code[```typ
#canvas({
  import draw: *

  line((0, 0), (6, 1))
  circle((2, 2), radius: 1)
  content((3, 0), [Beschriftung])
})
```]

Der `canvas`-Wrapper setzt schulfreundliche Standardstile (innen liegende Achsenmarkierungen, solide Gitternetzlinien).

== Physikalische Einheiten (Fancy-Units)

Das Paket konfiguriert `fancy-units` automatisch mit deutschen Einstellungen (Komma als Dezimaltrennzeichen, Bruchschreibweise für Einheiten):

#show-code[```typ
#qty[9.81][m/s^2]   // 9,81 m/s²
#qty("9.81", "m/s^2") // Kurzschreibweise
#num[3.14]          // 3,14
#unit[N/m^2]        // N/m²
```]

= API-Referenz

#show-module(read("../src/arbeitsblatt.typ"), name: "arbeitsblatt")
