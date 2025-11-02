#import "@preview/mantys:1.0.2": *

#import "../src/arbeitsblatt.typ" as ab
#import "@schule/aufgaben:0.1.2" as auf

#import "@preview/codly:1.3.0": *

#show: mantys(
  name: "arbeitsblatt",
  version: "0.2.4",
  authors: (
    "Lukas Köhl",
    "Alexander Schulz",
  ),
  license: "MIT",
  description: "Ein umfassendes Paket zur Erstellung von Arbeitsblättern für den Schulbereich mit zahlreichen Funktionen für Aufgaben, Materialien und Lösungen.",


  abstract: [
    Das `arbeitsblatt` Paket bietet eine umfassende Lösung zur Erstellung professioneller Arbeitsblätter für den Schulbereich. Es integriert verschiedene spezialisierte Pakete und bietet Funktionen für Aufgaben, Teilaufgaben, Materialien, Lösungen und vieles mehr. Das Paket unterstützt sowohl digitale als auch gedruckte Formate mit anpassbaren Layouts und Styling-Optionen.
  ],

  examples-scope: (
    scope: (arbeitsblatt: ab, aufgaben: auf),
    imports: (arbeitsblatt: "*", aufgaben: "aufgabe, teilaufgabe, loesung, material"),
  ),
)

= Über dieses Paket

Das #package[arbeitsblatt] Paket wurde entwickelt, um Lehrkräften das Erstellen professioneller Arbeitsblätter zu erleichtern. Es bietet eine Vielzahl von Funktionen zur Strukturierung von Aufgaben, zur Verwaltung von Lösungen und Materialien sowie zur automatischen Punktevergabe.

Dieses Manual ist in mehrere Teile gegliedert:
1. *Grundlagen* -- Erste Schritte mit dem Paket
2. *Lösungen und Material* -- Verwaltung von Lösungen und Materialien
3. *Bewertung* -- Punkte und Erwartungshorizonte
4. *Referenz* -- Vollständige Funktionsübersicht

= Grundlagen

== Paket importieren

Um das #package[arbeitsblatt] Paket zu verwenden, importieren Sie es einfach:

#sourcecode[```typ
#import "@schule/arbeitsblatt:0.2.4": *
```]

== Grundlegendes Arbeitsblatt erstellen

Ein Arbeitsblatt wird mit der `arbeitsblatt()` Funktion erstellt:

#sourcecode[```typ
#import "@schule/arbeitsblatt:0.2.4": *

#show: arbeitsblatt.with(
  title: "Quadratische Funktionen",
  class: "9a",
)

Das ist mein erstes Arbeitsblatt.
```]

#pagebreak(weak: true)
=== Wichtige Parameter

Die `arbeitsblatt()` Funktion akzeptiert viele Parameter zur Anpassung:

#argument("title", types: "string", default: "")[
  Der Titel des Arbeitsblatts, der im Kopfbereich angezeigt wird.
]

#argument("class", types: "string", default: "")[
  Die Klassenbezeichnung, z.B. "9a" oder "IF-11".
]

#argument("print", types: "boolean", default: false)[
  Wenn auf #value(true) gesetzt, werden die Seitenränder für den Druck optimiert (breiterer Rand auf der linken Seite zum Abheften).\
  Wenn auf #value(false) gesetzt, werden die Ränder für die Bildschirmansicht optimiert und die Seitengröße ist *nicht* auch DIN-A4 begrenzt.
]

#argument("duplex", types: "boolean", default: true)[
  Bei Verwendung mit #arg(print: true) werden abwechselnde Seitenränder für beidseitigen Druck verwendet.
]

#argument("landscape", types: "boolean", default: false)[
  Setzt die Seitenausrichtung auf Querformat.
]

#argument("font-size", types: "length", default: 12pt)[
  Die Schriftgröße für den Haupttext.
]

#argument("font", types: "string", default: "Myriad Pro")[
  Die Hauptschriftart des Dokuments.
]

#argument("math-font", types: "string", default: "Fira Math")[
  Die Schriftart für mathematische Formeln.
]

= Erweiterte Funktionen

== Shortcodes für Aufgaben

Das Paket kann Überschriften und Aufzählungen automatisch in Aufgaben umwandeln:

#sourcecode[```typ
#show: arbeitsblatt.with(
  aufgaben-shortcodes: "alle", // Überschriften → Aufgaben, Enum → Teilaufgaben
)

= Quadratische Funktionen

+ Bestimme die Nullstellen
+ Berechne den Scheitelpunkt

// Wird automatisch zu:
// #aufgabe("Quadratische Funktionen")[
//   #teilaufgabe[Bestimme die Nullstellen]
//   #teilaufgabe[Berechne den Scheitelpunkt]
// ]
```]

Optionen:
- `"keine"` -- Keine automatische Umwandlung
- `"aufgaben"` -- Nur Überschriften → Aufgaben
- `"teilaufgaben"` -- Nur Enum → Teilaufgaben
- `"alle"` -- Beides (Standard)
#pagebreak(weak: true)
== Benutzerdefinierte Kopfzeile

Sie können eine eigene Kopfzeile definieren:

#sourcecode[```typ
#let meine-kopfzeile = [
  #text(size: 16pt, weight: "bold")[Mein Arbeitsblatt]
  #h(1fr)
  #text[Klasse 9a]
  #line(length: 100%)
]

#show: arbeitsblatt.with(
  custom-header: meine-kopfzeile,
  header-ascent: 15%, // Anpassung der Kopfzeilen-Position
)
```]

== Copyright und QR-Codes

Sie können einen QR-Code mit Copyright-Information in der Kopfzeile hinzufügen:

#sourcecode[```typ
#show: arbeitsblatt.with(
  title: "Mein Arbeitsblatt",
  copyright: "https://meine-website.de/arbeitsblatt-123",
)
```]

Der QR-Code wird in der Kopfzeile rechts neben der Klassenbezeichnung angezeigt.

== Seiten-Einstellungen

Benutzerdefinierte Seiteneinstellungen können übergeben werden:

#sourcecode[```typ
#show: arbeitsblatt.with(
  page-settings: (
    margin: (top: 3cm, bottom: 2cm, x: 2cm),
    columns: 2,
  ),
)
```]

== Hilfsfunktionen

=== Lücken erstellen

Für einfache Lückentexte:

#example[```typ
Die Hauptstadt von Deutschland ist #lücke[Berlin].

// Kompakte Lücke ohne Abstand:
Der Wert ist #lücke(tight: true)[42].
```]

=== Minipage (Mehrspaltiges Layout)

#example[```typ
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
```]

=== Icon-Links

#example[```typ
#icon-link(
  "https://example.com",
  "Beispiel-Link",
  icon: emoji.chain,
  color: blue
)
```]

=== QR-Box

#example[```typ
#qrbox(
  "https://example.com",
  "Zur Website",
  width: 3cm
)
```]

=== Arbeitsbereich-Wrapper

#example[```typ
#workspace(height: 5cm)[
  #kariert(2)
]

// Wird nur angezeigt wenn workspaces: true
```]

=== Seitenumbrüche

#sourcecode[```typ
#print-pagebreak()     // Nur im Druckmodus
#non-print-pagebreak() // Nur im Nicht-Druckmodus
```]

= Integration mit anderen Paketen

Das #package[arbeitsblatt] Paket importiert und integriert automatisch viele nützliche Pakete:

- #package[aufgaben] -- Aufgabenverwaltung (intern verwendet)
- #package[fontawesome] -- Icons
- #package[gentle-clues] -- Info-Boxen
- #package[cetz] -- Diagramme und Zeichnungen
- #package[codly] -- Code-Syntax-Highlighting
- #package[colorful-boxes] -- Farbige Boxen
- #package[fancy-units] -- Physikalische Einheiten
- Viele weitere Schule-spezifische Pakete

== Physikalische Einheiten

Das Paket konfiguriert automatisch `fancy-units`:

#example[```typ
#fancy-units-configure(per-mode: "fraction", decimal-separator: ",")

#qty[5][m/s]      // 5 m/s
#unit[N/m^2]      // N/m²
```]

Dezimaltrennzeichen ist automatisch auf Komma (,) eingestellt.

== CeTZ-Diagramme

#example[```typ
#canvas({
  import draw: *
  
  line((0,0), (6,1))
  circle((2,2), radius: 1)
})
```]

= Kommandoreferenz

== Hauptfunktionen

#command("arbeitsblatt", 
  arg(title: ""),
  arg(class: ""),
  arg(paper: "a4"),
  arg(print: false),
  arg(duplex: true),
  arg(landscape: false),
  arg(font: "Myriad Pro"),
  arg(math-font: "Fira Math"),
  arg(font-size: 12pt),
  arg(title-font-size: 16pt),
  arg(figure-font-size: 9pt),
  arg(teilaufgabe-numbering: "a)"),
  arg(workspaces: true),
  arg(loesungen: "keine"),
  arg(materialien: "seiten"),
  arg(punkte: "keine"),
  arg(aufgaben-shortcodes: "alle"),
  arg(custom-header: none),
  arg(copyright: none),
  arg(page-settings: (:)),
  arg[body]
)[
  Erstellt ein Arbeitsblatt mit den angegebenen Einstellungen.

  #argument("title", types: "string", default: "")[
    Titel des Arbeitsblatts.
  ]

  #argument("class", types: "string", default: "")[
    Klassenbezeichnung.
  ]

  #argument("print", types: "boolean", default: false)[
    Aktiviert Druck-Modus mit optimierten Rändern.
  ]

  #argument("paper", types: "string", default: "a4")[
    Papierformat/Voreinstellung für die Seite (z. B. "a4", "a5", "letter").
  ]

  #argument("duplex", types: "boolean", default: true)[
    Aktiviert abwechselnde Seitenränder für beidseitigen Druck (linke/rechte Seite unterschiedlich). Wirkt in Kombination mit #arg(print: true).
  ]

  #argument("landscape", types: "boolean", default: false)[
    Setzt die Seitenausrichtung auf Querformat.
  ]

  #argument("font", types: "string", default: "Myriad Pro")[
    Primäre Textschrift des Dokuments.
  ]

  #argument("math-font", types: "string", default: "Fira Math")[
    Mathematische Schriftart für Formeln.
  ]

  #argument("font-size", types: "length", default: 12pt)[
    Grundschriftgröße des Haupttexts.
  ]

  #argument("title-font-size", types: "length", default: 16pt)[
    Schriftgröße für den Titel im Kopfbereich.
  ]

  #argument("figure-font-size", types: "length", default: 9pt)[
    Schriftgröße für Abbildungsbeschriftungen und Figuren.
  ]

  #argument("loesungen", types: "string", default: "keine")[
    Modus für Lösungsanzeige: `"keine"`, `"sofort"`, `"folgend"`, `"seiten"`.
  ]

  #argument("materialien", types: "string", default: "seiten")[
    Modus für Materialanzeige: `"keine"`, `"sofort"`, `"folgend"`, `"seiten"`.
  ]

  #argument("punkte", types: "string", default: "keine")[
    Modus für Punkteanzeige: `"keine"`, `"aufgaben"`, `"teilaufgaben"`, `"alle"`.
  ]

  #argument("teilaufgabe-numbering", types: "string", default: "a)")[
    Nummerierungsschema für Teilaufgaben: z. B. `"a)"` (a, b, c, …) oder `"1."` (1.1, 1.2, …).
  ]

  #argument("workspaces", types: "boolean", default: true)[
    Zeigt Arbeitsbereiche (Antwortfelder) unter Aufgaben/Teilaufgaben an.
  ]

  #argument("aufgaben-shortcodes", types: "string", default: "alle")[
    Automatische Umwandlung von Überschriften/Aufzählungen in Aufgaben:
    `"keine"`, `"aufgaben"`, `"teilaufgaben"`, `"alle"`.
  ]

  #argument("custom-header", types: "content, none", default: none)[
    Eigene Kopfzeile als Inhalt-Block. Überschreibt den Standardkopf.
  ]

  #argument("copyright", types: "string, none", default: none)[
    Text oder URL für Copyright-/Quellhinweis (optional mit QR-Code in der Kopfzeile).
  ]

  #argument("page-settings", types: "dictionary", default: (:))[
    Zusätzliche Seiteneinstellungen (an `page` durchgereicht), z. B. `margin`, `columns`.
  ]

  #argument("body", types: "content")[
    Inhalt des Arbeitsblatts.
  ]
]

= Beispiele

== Vollständiges Arbeitsblatt

#sourcecode(breakable: true)[```typ
#import "@schule/arbeitsblatt:0.2.4": *

#show: arbeitsblatt.with(
  title: "Quadratische Funktionen",
  class: "9a",
  print: true,
  punkte: "alle",
  loesungen: "seiten",
)

#aufgabe("Grundlagen")[
  Gegeben ist die Funktion $f(x) = x^2 - 4x + 3$.
  #teilaufgabe[
    Bestimme die Nullstellen.
  ]
  #erwartung(2)[Ansatz mit Mitternachtsformel; Korrekte Berechnung beider Nullstellen]
  #loesung[
    $x_(1,2) = (4 plus.minus sqrt(16-12))/2 = (4 plus.minus 2)/2$
    
    $x_1 = 3$, $x_2 = 1$
  ]
]

#aufgabe("Anwendung", method: "PA")[
  Eine Brücke hat die Form einer Parabel.
  
  #teilaufgabe[
    Stelle eine passende Funktionsgleichung auf.
  ]
  #erwartung(3)[Korrekte Funktionsgleichung]
]

#material(
  caption: "Foto der Brücke",
  label: <bruecke>
)[
  #rect(width: 100%, height: 5cm, fill: gray.lighten(80%))[
    [Hier könnte ein Bild sein]
  ]
]
```]

= Fehlerbehebung

== Häufige Probleme

=== Aufgaben werden nicht nummeriert
Prüfen Sie, ob `number: true` gesetzt ist (Standard).

=== Lösungen erscheinen nicht
Überprüfen Sie den `loesungen` Parameter. Standard ist `"keine"`.

=== Materialien werden nicht angezeigt
Der `materialien` Parameter muss auf `"sofort"`, `"folgend"` oder `"seiten"` gesetzt sein.

=== Punkte werden nicht angezeigt
Setzen Sie `punkte` auf `"aufgaben"`, `"teilaufgaben"` oder `"alle"`.

=== Erwartungen fehlen im Erwartungshorizont
Stellen Sie sicher, dass Sie `#erwartung()` nach den entsprechenden Aufgaben/Teilaufgaben aufrufen.

= Zusammenfassung

Das #package[arbeitsblatt] Paket bietet:

- ✓ Strukturierte Aufgabenverwaltung mit automatischer Nummerierung
- ✓ Flexible Lösungsverwaltung mit verschiedenen Anzeigemodi
- ✓ Materialverwaltung mit Referenzierung
- ✓ Automatische Punktevergabe und Erwartungshorizonte
- ✓ Bewertungstabellen für Schüler
- ✓ Druck-Optimierung
- ✓ Integration mit vielen nützlichen Paketen
- ✓ Umfangreiche Anpassungsmöglichkeiten

Das Paket ist ideal für Lehrkräfte, die professionelle Arbeitsblätter mit konsistenter Formatierung erstellen möchten.
