#import "@preview/mantys:1.0.2": *

#import "../src/klassenarbeit.typ" as ka

#import "@preview/codly:1.3.0": *

#show: mantys(
  name: "klassenarbeit",
  version: "0.1.2",
  authors: (
    "Lukas Köhl",
    "Alexander Schulz",
  ),
  license: "MIT",
  description: "Ein Typst-Paket zur Erstellung von Klassenarbeiten und Tests für den Schulunterricht mit Erwartungshorizonten, Bewertungsbögen und Klausurbögen-Generierung.",

  abstract: [
    Das `klassenarbeit` Paket bietet eine spezialisierte Lösung zur Erstellung von Klassenarbeiten und Tests für den Schulbereich. Es basiert auf dem `arbeitsblatt` Paket und erweitert es um spezielle Funktionen für Prüfungssituationen, einschließlich Erwartungshorizonte, Bewertungsbögen und automatischer Klausurbögen-Generierung.
  ],

  examples-scope: (
    scope: (klassenarbeit: ka),
    imports: (klassenarbeit: "*"),
  ),
)

= Über dieses Paket

Das #package[klassenarbeit] Paket ist speziell für Lehrkräfte entwickelt, die Klassenarbeiten, Tests und Klausuren erstellen möchten. Es baut auf dem #package[arbeitsblatt] Paket auf und fügt klassenarbeitsspezifische Funktionen hinzu.

Dieses Manual gliedert sich wie folgt:
1. *Erste Schritte* -- Installation und grundlegende Verwendung
2. *Deckblatt gestalten* -- Anpassung des Kopfbereichs
3. *Informationstabelle* -- Schülerdaten und Metainformationen
4. *Aufgabenverwaltung* -- Erstellung von Aufgaben (wie in #package[arbeitsblatt])
5. *Erwartungshorizont* -- Automatische Bewertungskriterien
6. *Klausurbögen* -- Optionale Ergebnisbögen
7. *Referenz* -- Vollständige Funktionsübersicht

= Erste Schritte

== Paket importieren

Um das #package[klassenarbeit] Paket zu verwenden, importieren Sie es einfach:

#sourcecode[```typ
#import "@schule/klassenarbeit:0.1.2": *
```]

== Abhängigkeiten

Das #package[klassenarbeit] Paket importiert automatisch:
- #package[arbeitsblatt] -- Alle Arbeitsblatt-Funktionen
- #package[aufgaben] -- Aufgabenverwaltung (über arbeitsblatt)
- #package[klausurboegen] -- Für optionale Klausurbögen
#pagebreak()
== Grundlegende Klassenarbeit

Eine einfache Klassenarbeit wird so erstellt:

#sourcecode[```typ
#import "@schule/klassenarbeit:0.1.2": *

#show: klassenarbeit.with(
  title: "Klassenarbeit Nr. 2",
  subtitle: "Quadratische Funktionen",
  class: "9a",
  date: "15.03.2024",
  teacher: "Müller",
)

#aufgabe("Nullstellen berechnen")[
  Bestimme die Nullstellen von $f(x) = x^2 - 5x + 6$.
]

#erwartung(3)[Korrekte Nullstellen berechnet]
```]

Das Paket erstellt automatisch:
- Ein professionelles Deckblatt
- Namensfeld für Schüler
- Seitennummerierung
- Optional: Erwartungshorizont am Ende
#pagebreak(weak: true)
= Deckblatt gestalten

== Titel und Untertitel

#sourcecode[```typ
#show: klassenarbeit.with(
  title: "Klassenarbeit Nr. 1",
  subtitle: "Bruchrechnung und Dezimalzahlen",
  class: "6b",
  date: "22.01.2024",
  teacher: "SLZ",
)
```]

Das Deckblatt zeigt: Titel (fett, groß), Untertitel (normal, kleiner), Datum (rechts oben), Klasse und Lehrer (rechts unten)

== Logo hinzufügen

Sie können ein Logo im Kopfbereich anzeigen:

#sourcecode[```typ
#show: klassenarbeit.with(
  title: "Mathe-Test",
  logo: "angela",  // Vordefiniertes Logo
  // ...
)
```]

Sie können auch ein eigenes Logo verwenden:

#sourcecode[```typ
#show: klassenarbeit.with(
  title: "Test",
  logo: image("mein-logo.png"),  // Benutzerdefiniertes Logo
  // ...
)
```]

Um kein Logo anzuzeigen:

#sourcecode[```typ
#show: klassenarbeit.with(
  logo: none,  // Kein Logo
)
```]

= Informationstabelle

== Namensfeld

Standardmäßig wird ein einfaches Namensfeld angezeigt:

#sourcecode[```typ
#show: klassenarbeit.with(
  name-field: "Name:",
  // ...
)
```]

Das zeigt: *Name:* #box(line()). Die Beschrift kann angepasst (`name-field: "Name, Vorname"`) oder entfernt werden (`name-field: none`).

== Informationstabelle aktivieren

Mit `info-table` wird eine Tabelle mit Informationen angezeigt:
#sourcecode[```typ
#show: klassenarbeit.with(
  info-table: (
    ([Hilfsmittel], [Taschenrechner, Formelsammlung]),
    ([Bearbeitungszeit], [90 Minuten]),
  ),
  // ...
)
```]

Jedes Element ist ein Tupel `(label, wert)`. Die Tabelle wird formatiert mit:
- Label in Fettdruck mit Doppelpunkt
- Wert rechtsbündig
- Horizontale Trennlinien

== Informationstabelle deaktivieren

Um die Tabelle komplett zu deaktivieren:

#sourcecode[```typ
#show: klassenarbeit.with(
  info-table: false,
  // ...
)
```]

= Klausurbögen

== Was sind Klausurbögen?

Klausurbögen sind leere Doppelbögen (Schreibbögen) für Schüler*innen, auf denen sie ihre Lösungen schreiben. Sie enthalten:
- Kopfbereich mit Titel, Datum und weiteren Metadaten der Arbeit
- Name des Schülers / der Schülerin
- Linierte oder karierte Schreibfläche
- Optional: Bereich für erreichte Punkte und Note (zum automatisierten Eintragen und Bedrucken nach der Korrektur)

== Klausurbögen aktivieren

Klausurbögen werden über den `klausurboegen` Parameter aktiviert:

#sourcecode[```typ
#show: klassenarbeit.with(
  klausurboegen: (
    stufe: "I",  // "I" für Sek I, "II" für Sek II
  ),
  // ...
)
```]

Dies erzeugt leere Schreibbögen für die Schüler*innen am Ende des Dokuments.

== Stufe festlegen

Die Schulstufe bestimmt das Layout der Bögen:

#sourcecode[```typ
#show: klassenarbeit.with(
  klausurboegen: (
    stufe: "I",   // Sekundarstufe I
  ),
  // oder
  klausurboegen: (
    stufe: "II",  // Sekundarstufe II
  ),
  // ...
)
```]

== Ergebnisse eintragen

Optional können Sie Schülernamen direkt aus einer passend formatierten .csv Datei importieren:

#sourcecode[```typ
#show: klassenarbeit.with(
  klausurboegen: (
    stufe: "I",
    ergebnisse: csv("schueler.csv"),
  ),
  // ...
)
```]

Für jeden Schüler wird dann ein individueller Klausurbogen mit vorgedrucktem Namen erstellt. Die erreichten Punkte und Noten können nach der Korrektur händisch oder mit einem separaten Durchlauf ergänzt werden.

== Klausurbögen ohne Schülerdaten

Wenn Sie nur leere Bögen ohne vorgedruckte Namen erstellen möchten:

#sourcecode[```typ
#show: klassenarbeit.with(
  klausurboegen: (
    stufe: "I",
    // kein ergebnisse-Parameter
  ),
  // ...
)
```]

Dies erzeugt generische Bögen mit Namensfeld zum manuellen Ausfüllen.

== Klausurbögen deaktivieren

Um keine Klausurbögen zu erzeugen:

#sourcecode[```typ
#show: klassenarbeit.with(
  klausurboegen: false,  // Standard
  // ...
)
```]

= Seitenlayout

== Seitenränder

Das #package[klassenarbeit] Paket verwendet optimierte Ränder für Klassenarbeiten:

- Oben: 1cm
- Unten: 1cm  
- Links: 1.5cm
- Rechts: 1.5cm

Diese können mit `page-settings` überschrieben werden:

#sourcecode[```typ
#show: klassenarbeit.with(
  page-settings: (
    margin: (top: 2cm, bottom: 2cm, x: 2.5cm),
  ),
  // ...
)
```]

== Seitennummerierung

Standardmäßig werden Seiten nummeriert ("Seite X von Y" rechts unten):

#sourcecode[```typ
#show: klassenarbeit.with(
  page-numbering: true,  // Standard
  // ...
)
```]

Um die Nummerierung zu deaktivieren:

#sourcecode[```typ
#show: klassenarbeit.with(
  page-numbering: false,
  // ...
)
```]

Die Nummerierung endet automatisch vor den Lösungen und dem Erwartungshorizont.

= Weitere Einstellungen

== Schriftarten und -größen

Das Paket nutzt die Einstellungen von #package[arbeitsblatt]:

#sourcecode[```typ
#show: klassenarbeit.with(
  font: "Linux Libertine",
  math-font: "Fira Math",
  font-size: 11pt,
  figure-font-size: 9pt,
  // ...
)
```]

Standard:
- `font: "Myriad Pro"`
- `math-font: "Fira Math"`
- `font-size: 12pt`

== Teilaufgaben-Nummerierung

#sourcecode[```typ
#show: klassenarbeit.with(
  teilaufgabe-numbering: "a)",  // a), b), c)... (Standard)
  // oder
  teilaufgabe-numbering: "1.",  // 1.1, 1.2, 1.3...
  // ...
)
```]

== Lösungen und Materialien

Wie in #package[arbeitsblatt] können Sie Lösungen und Materialien verwalten:

#sourcecode[```typ
#show: klassenarbeit.with(
  loesungen: "keine",    // Standard für Klassenarbeiten
  materialien: "sofort", // Material direkt nach Aufgabe
)
```]

In der Regel werden bei Klassenarbeiten keine Lösungen mitgedruckt (`loesungen: "keine"`).

= Funktionsreferenz

#command("klassenarbeit",
  arg(title: ""),
  arg(subtitle: ""),
  arg(date: ""),
  arg(class: ""),
  arg(teacher: ""),
  arg(logo: "angela"),
  arg(schueler: ""),
  arg(info-table: false),
  arg(erwartungen: true),
  arg(page-numbering: true),
  arg(klausurboegen: false),
  arg(page-settings: (:)),
  sarg[arbeitsblatt-args],
  arg[body]
)[
  Erstellt eine Klassenarbeit mit Deckblatt und optionalem Erwartungshorizont.

  #argument("title", types: "string", default: "")[
    Titel der Klassenarbeit (z.B. "Klassenarbeit Nr. 1").
  ]

  #argument("subtitle", types: "string", default: "")[
    Untertitel mit Thema (z.B. "Quadratische Funktionen").
  ]

  #argument("date", types: "string", default: "")[
    Datum der Klassenarbeit.
  ]

  #argument("class", types: "string", default: "")[
    Klassenbezeichnung (z.B. "9a").
  ]

  #argument("teacher", types: "string", default: "")[
    Name der Lehrkraft.
  ]

  #argument("logo", types: ("string", "content", none), default: "angela")[
    Logo für die Kopfzeile. Kann sein:
    - `"angela"`: Vordefiniertes Logo
    - `image(...)`: Benutzerdefiniertes Bild
    - `none`: Kein Logo
  ]

  #argument("schueler", types: "string", default: "")[
    Name des Schülers / der Schülerin oder Linie für Namenseintrag.
  ]

  #argument("info-table", types: ("boolean", "array"), default: false)[
    - `false`: Keine Informationstabelle
    - Array: Benutzerdefinierte Informationen als `(label, wert)` Tupel
  ]

  #argument("erwartungen", types: "boolean", default: true)[
    Wenn `true`, wird automatisch ein Erwartungshorizont auf neuer Seite am Ende eingefügt.
  ]

  #argument("page-numbering", types: "boolean", default: true)[
    Wenn `true`, werden Seiten nummeriert ("Seite X von Y").
  ]

  #argument("klausurboegen", types: ("boolean", "dictionary"), default: false)[
    - `false`: Keine Klausurbögen
    - Dictionary mit:
      - `stufe`: `"I"` oder `"II"` (Sekundarstufe)
      - `ergebnisse`: CSV-Daten mit Schülernamen (optional) – erzeugt individuelle Bögen pro Schüler*in
      
    Klausurbögen sind leere Doppelbögen zum Beschreiben mit Kopfbereich.
  ]

  #argument("page-settings", types: "dictionary", default: (:))[
    Zusätzliche Seiteneinstellungen, die an `page()` übergeben werden.
    
    *Hinweis*: Margin-Einstellungen werden mit den Standard-Klassenarbeit-Margins kombiniert.
  ]

  #argument("arbeitsblatt-args", types: "any")[
    Alle weiteren Parameter werden an die `arbeitsblatt()` Funktion weitergereicht.
    
    Verfügbare Parameter:
    - `font`, `math-font`, `font-size`, `figure-font-size`
    - `loesungen`, `materialien`, `punkte`
    - `teilaufgabe-numbering`, `workspaces`
    - Siehe #package[arbeitsblatt] Manual für Details
  ]

  #argument("body", types: "content")[
    Inhalt der Klassenarbeit (Aufgaben, Materialien, etc.).
  ]
]

Alle Funktionen aus #package[arbeitsblatt] sind verfügbar:
- `#aufgabe()`, `#teilaufgabe()`
- `#loesung()`, `#erwartung()`, `#material()`
- `#show-erwartungen()`, `#show-bewertung()`
- `#lücke()`, `#minipage()`, etc.

= Beispiele

== Einfache Klassenarbeit

#sourcecode(breakable: true)[```typ
#import "@schule/klassenarbeit:0.1.2": *

#show: klassenarbeit.with(
  title: "Klassenarbeit Nr. 1",
  subtitle: "Lineare Funktionen",
  class: "8b",
  date: "12.02.2024",
  teacher: "Schmidt",
)

#aufgabe("Funktionsgraphen")[
  Zeichne den Graphen der Funktion $f(x) = 2x + 1$.
]
#erwartung(2)[Achsen beschriftet]
#erwartung(3)[Graph korrekt eingezeichnet]

#aufgabe("Steigung berechnen")[
  Berechne die Steigung der Geraden durch $A(1|3)$ und $B(4|9)$.
]
#erwartung(1)[Formel angegeben]
#erwartung(2)[Steigung berechnet: $m=2$]
```]

== Klassenarbeit mit Teilaufgaben

#sourcecode(breakable: true)[```typ
#import "@schule/klassenarbeit:0.1.2": *

#show: klassenarbeit.with(
  title: "Test: Bruchrechnung",
  class: "6a",
  date: "05.03.2024",
  teacher: "Müller",
  info-table: (
    ("Hilfsmittel", "keine"),
    ("Zeit", "45 Minuten"),
  ),
  punkte: "teilaufgaben",
)

#aufgabe("Addition von Brüchen")[
  #teilaufgabe[
    Berechne: $1/2 + 1/3$
  ]
  #erwartung(1)[Hauptnenner: 6]
  #erwartung(1)[Ergebnis: $5/6$]
  
  #teilaufgabe[
    Berechne: $2/5 + 1/4$
  ]
  #erwartung(2)[Ergebnis: $13/20$]
]

#aufgabe("Multiplikation")[
  #teilaufgabe[
    Berechne: $2/3 times 3/4$
  ]
  #erwartung(2)[Ergebnis: $1/2$]
]
```]

= Integration

Das #package[klassenarbeit] Paket integriert sich mit:

== Arbeitsblatt-Paket
Alle Funktionen von #package[arbeitsblatt] sind verfügbar:
- Aufgaben- und Teilaufgabenverwaltung
- Lösungen und Materialien
- Erwartungshorizonte und Bewertung
- Hilfsfunktionen wie `lücke()`, `minipage()`, etc.

== Klausurbögen-Paket  
Automatische Integration von #package[klausurboegen] für leere Schreibbögen mit Kopfbereich und optionalen Bewertungsfeldern.

= Zusammenfassung

Das #package[klassenarbeit] Paket bietet:

- ✓ Professionelles Deckblatt mit Logo und Metadaten
- ✓ Flexible Informationstabelle für Schülerdaten
- ✓ Alle Funktionen des #package[arbeitsblatt] Pakets
- ✓ Automatischer Erwartungshorizont
- ✓ Optionale leere Klausurbögen (Schreibbögen) mit Kopfbereich

Das Paket ist ideal für Lehrkräfte, die professionelle Klassenarbeiten mit minimalem Aufwand erstellen möchten.

= Weiterführende Ressourcen

- #package[arbeitsblatt] Manual -- Für alle Arbeitsblatt-Funktionen
- #package[aufgaben] Manual -- Für Aufgabenverwaltung im Detail
- #package[klausurboegen] Manual -- Für erweiterte Klausurbogen-Optionen

Bei Fragen oder Problemen wenden Sie sich an den Paket-Maintainer oder erstellen Sie ein Issue auf GitHub.
