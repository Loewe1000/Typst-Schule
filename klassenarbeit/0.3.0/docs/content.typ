#import "@schule/schuldocs:0.2.0": doc-target, info, show-code, show-example, show-module, tip, warning

= Über dieses Paket

Das `klassenarbeit` Paket ist speziell für Lehrkräfte entwickelt, die Klassenarbeiten, Tests und Klausuren erstellen möchten. Es baut auf dem `arbeitsblatt` Paket auf und fügt klassenarbeitsspezifische Funktionen hinzu.

Dieses Manual gliedert sich wie folgt:
1. *Erste Schritte* -- Installation und grundlegende Verwendung
2. *Deckblatt gestalten* -- Anpassung des Kopfbereichs
3. *Informationstabelle* -- Schülerdaten und Metainformationen
4. *Aufgabenverwaltung* -- Erstellung von Aufgaben (wie in `arbeitsblatt`)
5. *Erwartungshorizont* -- Automatische Bewertungskriterien
6. *Klausurbögen* -- Optionale Ergebnisbögen
7. *Referenz* -- Vollständige Funktionsübersicht

= Erste Schritte

== Paket importieren

Um das `klassenarbeit` Paket zu verwenden, importieren Sie es einfach:

#show-code(```typ
#import "@schule/klassenarbeit:0.3.0": *
```)

== Abhängigkeiten

Das `klassenarbeit` Paket importiert automatisch:
- `arbeitsblatt` -- Alle Arbeitsblatt-Funktionen
- `aufgaben` -- Aufgabenverwaltung (über arbeitsblatt)
- `klausurboegen` -- Für optionale Klausurbögen

== Grundlegende Klassenarbeit

Eine einfache Klassenarbeit wird so erstellt:

#show-code(```typ
#import "@schule/klassenarbeit:0.3.0": *

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
```)

Das Paket erstellt automatisch:
- Ein professionelles Deckblatt
- Namensfeld für Schüler
- Seitennummerierung
- Optional: Erwartungshorizont am Ende

= Deckblatt gestalten

== Titel und Untertitel

#show-code(```typ
#show: klassenarbeit.with(
  title: "Klassenarbeit Nr. 1",
  subtitle: "Bruchrechnung und Dezimalzahlen",
  class: "6b",
  date: "22.01.2024",
  teacher: "SLZ",
)
```)

Das Deckblatt zeigt: Titel (fett, groß), Untertitel (normal, kleiner), Datum (rechts oben), Klasse und Lehrer (rechts unten)

== Logo hinzufügen

Sie können ein Logo im Kopfbereich anzeigen:

#show-code(```typ
#show: klassenarbeit.with(
  title: "Mathe-Test",
  logo: "angela",  // Vordefiniertes Logo
  // ...
)
```)

Sie können auch ein eigenes Logo verwenden:

#show-code(```typ
#show: klassenarbeit.with(
  title: "Test",
  logo: image("mein-logo.png"),  // Benutzerdefiniertes Logo
  // ...
)
```)

Um kein Logo anzuzeigen:

#show-code(```typ
#show: klassenarbeit.with(
  logo: none,  // Kein Logo
)
```)

= Informationstabelle

== Namensfeld

Standardmäßig wird ein einfaches Namensfeld angezeigt:

#show-code(```typ
#show: klassenarbeit.with(
  name-field: "Name:",
  // ...
)
```)

Das zeigt: *Name:* #context {
  let feld = box(width: 5cm, line(length: 100%))
  if doc-target() == "web" { html.frame(feld) } else { feld }
}. Die Beschrift kann angepasst (`name-field: "Name, Vorname"`) oder entfernt werden (`name-field: none`).

== Name eintragen

`student` nimmt einen Namen und setzt ihn statt des leeren Feldes ein — für
vorbereitete Kopien oder für die Lehrerfassung.

#show-code(```typ
#show: klassenarbeit.with(
  student: "Mia Schneider",
)
```)

== Name auf jeder Seite

Wenn das normale Namensfeld auf jeder Seite in der Kopfzeile erscheinen soll, kann die Wiederholung aktiviert werden:

#show-code(```typ
#show: klassenarbeit.with(
  name-repeat: true,
  // ...
)
```)

Dann wird das Namensfeld auf jeder Seite im Seitenkopf ausgegeben.

== Informationstabelle aktivieren

Mit `info-table` wird eine Tabelle mit Informationen angezeigt:

#show-code(```typ
#show: klassenarbeit.with(
  info-table: (
    ([Hilfsmittel], [Taschenrechner, Formelsammlung]),
    ([Bearbeitungszeit], [90 Minuten]),
  ),
  // ...
)
```)

Jedes Element ist ein Tupel `(label, wert)`. Die Tabelle wird formatiert mit:
- Label in Fettdruck mit Doppelpunkt
- Wert rechtsbündig
- Horizontale Trennlinien

== Informationstabelle deaktivieren

Um die Tabelle komplett zu deaktivieren:

#show-code(```typ
#show: klassenarbeit.with(
  info-table: false,
  // ...
)
```)

= Klausurbögen

== Was sind Klausurbögen?

Klausurbögen sind leere Doppelbögen (Schreibbögen) für Schüler\*innen, auf denen sie ihre Lösungen schreiben. Sie enthalten:
- Kopfbereich mit Titel, Datum und weiteren Metadaten der Arbeit
- Name des Schülers / der Schülerin
- Linierte oder karierte Schreibfläche
- Optional: Bereich für erreichte Punkte und Note (zum automatisierten Eintragen und Bedrucken nach der Korrektur)

== Klausurbögen aktivieren

Klausurbögen werden über den `klausurboegen` Parameter aktiviert:

#show-code(```typ
#show: klassenarbeit.with(
  klausurboegen: (
    stufe: "I",  // "I" für Sek I, "II" für Sek II
  ),
  // ...
)
```)

Dies erzeugt leere Schreibbögen für die Schüler\*innen am Ende des Dokuments.

== Stufe festlegen

Die Schulstufe bestimmt das Layout der Bögen:

#show-code(```typ
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
```)

== Ergebnisse eintragen

Optional können Sie Schülernamen direkt aus einer passend formatierten .csv Datei importieren:

#show-code(```typ
#show: klassenarbeit.with(
  klausurboegen: (
    stufe: "I",
    ergebnisse: csv("student.csv"),
  ),
  // ...
)
```)

Für jeden Schüler wird dann ein individueller Klausurbogen mit vorgedrucktem Namen erstellt. Die erreichten Punkte und Noten können nach der Korrektur händisch oder mit einem separaten Durchlauf ergänzt werden.

== Klausurbögen ohne Schülerdaten

Wenn Sie nur leere Bögen ohne vorgedruckte Namen erstellen möchten:

#show-code(```typ
#show: klassenarbeit.with(
  klausurboegen: (
    stufe: "I",
    // kein ergebnisse-Parameter
  ),
  // ...
)
```)

Dies erzeugt generische Bögen mit Namensfeld zum manuellen Ausfüllen.

== Klausurbögen deaktivieren

Um keine Klausurbögen zu erzeugen:

#show-code(```typ
#show: klassenarbeit.with(
  klausurboegen: false,  // Standard
  // ...
)
```)

= Erwartungshorizont

Mit `erwartungen: true` — der Vorgabe — sammelt das Paket alle `erwartung()`
einer Arbeit und setzt daraus am Ende einen Erwartungshorizont mit Punkten.
Im Bündel steht er nur im Lösungsdokument.

#show-example(
  rendered: {
    import "../src/klassenarbeit.typ": aufgabe, teilaufgabe
    import "@schule/aufgaben:0.3.0": reset-aufgaben
    // Der Aufgabenzähler läuft durchs ganze Dokument; im Ausschnitt soll die
    // Nummer die des Ausschnitts sein.
    reset-aufgaben()
    aufgabe("Funktionsanalyse")[
      #teilaufgabe[Bestimme die Nullstellen von $f(x) = x^2 - 4$.]
      #teilaufgabe[Skizziere den Graphen.]
    ]
  },
  source: ```typ
  #aufgabe("Funktionsanalyse")[
    #teilaufgabe[Bestimme die Nullstellen von $f(x) = x^2 - 4$.]
    #teilaufgabe[Skizziere den Graphen.]
  ]
  ```,
  width: 14cm,
)

Die Erwartungen hängen sich an die Teilaufgaben, `show-erwartungen()` setzt am
Ende die Tabelle daraus:

#show-code(```typ
#aufgabe("Funktionsanalyse")[
  #teilaufgabe[
    Bestimme die Nullstellen von $f(x) = x^2 - 4$.
    #erwartung(2)[Korrekte Nullstellen: $x = plus.minus 2$]
  ]
  #teilaufgabe[
    Skizziere den Graphen.
    #erwartung(1)[Korrekte Form der Parabel]
    #erwartung(1)[Scheitelpunkt eingezeichnet]
  ]
]
#show-erwartungen()
```)

Die Punkte einer Aufgabe stehen an ihr selbst (`aufgabe(punkte: 6)`) oder an den
Teilaufgaben; `erwartung(n)` trägt die Punkte des einzelnen Kriteriums.

#info[
  Warum das zweite Stück nur als Quelltext steht: Aufgabenzähler, Punktesummen und
  der Erwartungshorizont gehören einem *ganzen* Dokument — sie werden über einen
  Zustand gesammelt und am Schluss abgelesen. In einem Handbuch mit mehreren
  Beispielen zeigte ein Ausschnitt deshalb die Zahlen der anderen mit. In einer
  echten Klassenarbeit — ein Dokument, eine Arbeit — stimmt es.
]

= Seitenlayout

== Seitenränder

Das `klassenarbeit` Paket verwendet optimierte Ränder für Klassenarbeiten:

- Oben: 1cm
- Unten: 1cm
- Links: 1.5cm
- Rechts: 1.5cm

Diese können mit `page-settings` überschrieben werden:

#show-code(```typ
#show: klassenarbeit.with(
  page-settings: (
    margin: (top: 2cm, bottom: 2cm, x: 2.5cm),
  ),
  // ...
)
```)

== Seitennummerierung

Standardmäßig werden Seiten nummeriert ("Seite X von Y" rechts unten):

#show-code(```typ
#show: klassenarbeit.with(
  page-numbering: true,  // Standard
  // ...
)
```)

Um die Nummerierung zu deaktivieren:

#show-code(```typ
#show: klassenarbeit.with(
  page-numbering: false,
  // ...
)
```)

Die Nummerierung endet automatisch vor den Lösungen und dem Erwartungshorizont.

= Weitere Einstellungen

== Schriftarten und -größen

Das Paket nutzt die Einstellungen von `arbeitsblatt`:

#show-code(```typ
#show: klassenarbeit.with(
  font: "Linux Libertine",
  math-font: "Fira Math",
  font-size: 11pt,
  figure-font-size: 9pt,
  // ...
)
```)

Standard:
- `font: "Myriad Pro"`
- `math-font: "Fira Math"`
- `font-size: 12pt`

== Teilaufgaben-Nummerierung

#show-code(```typ
#show: klassenarbeit.with(
  teilaufgabe-numbering: "a)",  // a), b), c)... (Standard)
  // oder
  teilaufgabe-numbering: "1.",  // 1.1, 1.2, 1.3...
  // ...
)
```)

== Lösungen und Materialien

Wie in `arbeitsblatt` können Sie Lösungen und Materialien verwalten:

#show-code(```typ
#show: klassenarbeit.with(
  loesungen: "keine",    // Standard für Klassenarbeiten
  materialien: "sofort", // Material direkt nach Aufgabe
)
```)

In der Regel werden bei Klassenarbeiten keine Lösungen mitgedruckt (`loesungen: "keine"`).

= Funktionsreferenz

Erzeugt aus den Kommentaren von `src/klassenarbeit.typ` und damit immer auf dem
Stand der Quelle.

#show-module(read("../src/klassenarbeit.typ"), name: "klassenarbeit")

Alle Bausteine aus `arbeitsblatt` und `aufgaben` stehen zusätzlich zur
Verfügung: `aufgabe`, `teilaufgabe`, `loesung`, `erwartung`, `material`,
`show-erwartungen`, `show-bewertung`, `lücke`, `minipage`. Ihre Beschreibung
steht in den Handbüchern dieser Pakete.

= Beispiele

== Einfache Klassenarbeit

#show-code(```typ
#import "@schule/klassenarbeit:0.3.0": *

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
```)

#show-example(
  rendered: {
    import "../src/klassenarbeit.typ": aufgabe
    import "@schule/aufgaben:0.3.0": reset-aufgaben
    reset-aufgaben()
    aufgabe("Quadratische Gleichungen")[
      Berechne die Lösungen von $x^2 - 5x + 6 = 0$.
    ]
  },
  source: ```typ
  #aufgabe("Quadratische Gleichungen")[
    Berechne die Lösungen von $x^2 - 5x + 6 = 0$.
  ]
  ```,
  width: 14cm,
)

== Klassenarbeit mit Teilaufgaben

#show-code(```typ
#import "@schule/klassenarbeit:0.3.0": *

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
```)

= Integration

Das `klassenarbeit` Paket integriert sich mit:

== Arbeitsblatt-Paket

Alle Funktionen von `arbeitsblatt` sind verfügbar:
- Aufgaben- und Teilaufgabenverwaltung
- Lösungen und Materialien
- Erwartungshorizonte und Bewertung
- Hilfsfunktionen wie `lücke()`, `minipage()`, etc.

== Klausurbögen-Paket

Automatische Integration von `klausurboegen` für leere Schreibbögen mit Kopfbereich und optionalen Bewertungsfeldern.

= Zusammenfassung

Das `klassenarbeit` Paket bietet:

- ✓ Professionelles Deckblatt mit Logo und Metadaten
- ✓ Flexible Informationstabelle für Schülerdaten
- ✓ Alle Funktionen des `arbeitsblatt` Pakets
- ✓ Automatischer Erwartungshorizont
- ✓ Optionale leere Klausurbögen (Schreibbögen) mit Kopfbereich

Das Paket ist ideal für Lehrkräfte, die professionelle Klassenarbeiten mit minimalem Aufwand erstellen möchten.

= Weiterführende Ressourcen

- `arbeitsblatt` Manual -- Für alle Arbeitsblatt-Funktionen
- `aufgaben` Manual -- Für Aufgabenverwaltung im Detail
- `klausurboegen` Manual -- Für erweiterte Klausurbogen-Optionen

Bei Fragen oder Problemen wenden Sie sich an den Paket-Maintainer oder erstellen Sie ein Issue auf GitHub.
