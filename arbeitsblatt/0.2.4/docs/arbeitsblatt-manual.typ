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

#show: codly-init.with()
#codly(number-format: none)

#pagebreak(weak: true)
= Über das Paket <sec:about>

Das `arbeitsblatt` Paket ist eine umfassende Lösung zur Erstellung professioneller Arbeitsblätter für den Schulbereich. Es wurde entwickelt, um Lehrkräften ein mächtiges Werkzeug für die Erstellung strukturierter, ansprechender Arbeitsblätter zu bieten.

Dieses Manual ist eine vollständige Referenz aller Funktionen des `arbeitsblatt` Pakets.

== Terminologie

In diesem Manual werden folgende Begriffe verwendet:

- *Arbeitsblatt*: Das Hauptdokument, das mit `#show: arbeitsblatt()` erstellt wird
- *Aufgabe*: Eine Hauptaufgabe mit optionaler Nummerierung und Titel
- *Teilaufgabe*: Unteraufgaben innerhalb einer Hauptaufgabe
- *Material*: Zusätzliche Ressourcen und Hilfsmittel für Aufgaben
- *Lösung*: Antworten zu Aufgaben, die je nach Modus angezeigt werden
- *Workspace*: Arbeitsbereich für Schüler:innen zum Bearbeiten

= Schnelleinstieg <sec:quickstart>

Für den schnellen Einstieg importieren Sie das Paket und erstellen Ihr erstes Arbeitsblatt:

```typ
#import "@schule/arbeitsblatt:0.2.4": *

#show: arbeitsblatt(
  title: "Mein erstes Arbeitsblatt",
  class: "Klasse 10a",
)

#aufgabe(title: [Einfache Rechnung])[
  Berechnen Sie: $2 + 3 = ?$

  #loesung[$2 + 3 = 5$]
]
```

Ihr Arbeitsblatt sollte nun eine strukturierte Aufgabe mit Header enthalten.

#pagebreak()

== Erste Schritte

1. *Installation*: Importieren Sie das Paket
2. *Template*: Wenden Sie das `arbeitsblatt`-Template an
3. *Aufgaben*: Erstellen Sie Aufgaben mit `#aufgabe()`
4. *Lösungen*: Fügen Sie Lösungen mit `#loesung()` hinzu
5. *Export*: Kompilieren Sie zu PDF

= Verwendung <sec:usage>

== Template-Initialisierung <sec:init>

Das Template wird durch eine Show-Rule mit dem `arbeitsblatt`-Befehl initialisiert:

```typ
#show: arbeitsblatt(
  title: "Titel des Arbeitsblatts",
  class: "Klassenbezeichnung",
  // weitere Optionen...
)
```

Alle verfügbaren Parameter sind in der API-Referenz dokumentiert.

== Aufgaben und Teilaufgaben <sec:tasks>

Das `arbeitsblatt` Paket integriert das `@schule/aufgaben` Paket für strukturierte Aufgaben. Die ausführliche Dokumentation aller Funktionen und erweiterten Features ist im Manual des `@schule/aufgaben` Pakets nachzulesen.

#command("aufgabe")[
  Erstellt eine Hauptaufgabe mit optionaler Nummerierung und Titel.

  #argument("title", types: "content", default: none)[
    Der Titel der Aufgabe, der nach der Nummerierung angezeigt wird.
  ]

  #argument("large", types: "boolean", default: false)[
    Wenn `true`, wird eine größere Schriftgröße für den Aufgabentitel verwendet.
  ]

  #argument("number", types: "boolean", default: true)[
    Wenn `false`, wird keine Aufgabennummerierung angezeigt.
  ]

  #argument("workspace", types: "content", default: none)[
    Arbeitsbereich, der nur unterhalb der Aufgabe angezeigt wird, wenn `workspaces: true` in `arbeitsblatt()` gesetzt ist.
  ]

  #argument("body", types: "content", default: [])[
    Der Inhalt der Aufgabe.
  ]

  #sourcecode[
    Beispiel:
    ```typ
    #aufgabe(
      title: [Gleichungen lösen],
    )[
      Löse die Gleichung $2x + 5 = 13$.

      #loesung[
        $x = 4$
      ]
    ]
    ```]
]

#command("teilaufgabe")[
  Erstellt eine Teilaufgabe innerhalb einer Hauptaufgabe.

  #argument("workspace", types: "content", default: none)[
    Arbeitsbereich für diese Teilaufgabe.
  ]

  #argument("body", types: "content", default: [])[
    Der Inhalt der Teilaufgabe.
  ]

  #sourcecode[```typ
  #aufgabe[
    Bearbeiten Sie die folgenden Teilaufgaben:

    #teilaufgabe[
      Berechnen Sie $2 + 3$.
      #loesung[$5$]
    ]
    // ... weitere Teilaufgaben
  ]
  ```]
]

#command("loesung")[
  Fügt eine Lösung zur aktuellen Aufgabe oder Teilaufgabe hinzu. Die Anzeige wird durch den `loesungen`-Parameter in `arbeitsblatt()` gesteuert.

  #argument("body", types: "content", default: [])[
    Der Inhalt der Lösung.
  ]
]

#command("erwartung")[
  Definiert ein Bewertungskriterium mit Punkteverteilung für die aktuelle Aufgabe oder Teilaufgabe.

  Diese Funktion wird für Bewertungsbögen und Erwartungshorizonte verwendet.

  #argument("punkte", types: "integer", default: 0)[
    Anzahl der Punkte für dieses Bewertungskriterium.
  ]

  #argument("text", types: "content", default: [])[
    Beschreibung des Bewertungskriteriums.
  ]

  #example[```
  #teilaufgabe[
    Beschreiben Sie den Photoeffekt.
    
    #erwartung(2, [Lichtteilchen-Charakter erklärt])
    #erwartung(1, [Energieerhaltung erwähnt])
  ]
  ```]
]

#command("material")[
  Fügt Material (Abbildunge, Diagramme, Messwerttabellen, ...) zur aktuellen Aufgabe hinzu, das je nach `materialien`-Einstellung angezeigt wird.

  #argument("body", types: "content", default: [])[
    Der Inhalt des Materials.
  ]

  #argument("caption", types: "content", default: none)[
    Eine Beschriftung für das Material.
  ]

  // #example[```
  // #aufgabe[
  //   Verwenden Sie das Material aus @formelsammlung.

  //   #material(
  //     caption: [Formelsammlung],
  //     label: <formelsammlung>
  //   )[
  //     - $E = m c^2$
  //     - $F = m a$
  //     - $P = U I$
  //   ]
  // ]
  // ```]
]

==== Erweiterte Funktionen

Für die vollständige API-Referenz und erweiterte Funktionen siehe die Dokumentation des `@schule/aufgaben` Pakets.

#pagebreak()

// = Arbeiten mit Lösungen und Materialien <sec:solutions-materials>

// == Lösungsmodi <subsec:solution-modes>

// Das `arbeitsblatt` Paket bietet verschiedene Modi für die Anzeige von Lösungen:

// #frame[
//   #set text(.88em)
//   #grid(
//     columns: (auto, 1fr),
//     column-gutter: 1em,
//     row-gutter: 0.5em,
//     [`"false"`], [Keine Lösungen anzeigen],
//     [`"sofort"`], [Lösungen direkt nach der zugehörigen Teilaufgabe],
//     [`"folgend"`], [Lösungen direkt nach der gesamten Aufgabe],
//     [`"seite"`], [Alle Lösungen auf separaten Seiten am Dokumentende],
//     [`"seiten"`], [Lösungen auf separaten Seiten, jede Aufgabe beginnt auf neuer Seite],
//   )
// ]

// == Materialienmodi <subsec:material-modes>

// #frame[
//   #set text(.88em)
//   #grid(
//     columns: (auto, 1fr),
//     column-gutter: 1em,
//     row-gutter: 0.5em,
//     [`"false"`], [Keine Materialien anzeigen],
//     [`"sofort"` / `"folgend"`], [Materialien direkt nach der zugehörigen Aufgabe],
//     [`"seite"`], [Alle Materialien auf separaten Seiten am Dokumentende],
//     [`"seiten"`], [Materialien auf separaten Seiten, jede Aufgabe beginnt auf neuer Seite],
//   )
// ]

// == Druckoptionen <subsec:print-options>

// #frame[
//   #set text(.88em)
//   #grid(
//     columns: (auto, 1fr),
//     column-gutter: 1em,
//     row-gutter: 0.5em,
//     [`print: true`], [Aktiviert Druckränder für physischen Druck],
//     [`duplex: true`], [Unterschiedliche Innen-/Außenränder für Duplex-Druck],
//     [`equal-margins: true`], [Gleichmäßige Ränder ohne Bindungsrand],
//   )
// ]

= Anpassung des Templates <sec:customization>

== Layout-Optionen

Das `arbeitsblatt` Paket bietet verschiedene Optionen zur Anpassung des Layouts:

- *Papierformat*: Alle Typst-Papierformate werden unterstützt
- *Orientierung*: Hoch- oder Querformat via `landscape`-Parameter
- *Ränder*: Anpassbar für Druck und digitale Anzeige
- *Schriftarten*: Konfigurierbare Haupt- und Mathematik-Schriftarten

== Header-Anpassung

Der Header kann vollständig angepasst oder ersetzt werden:

```typ
#let custom-header = [
  #grid(
    columns: (1fr, auto),
    [*Mein Arbeitsblatt*],
    [Datum: #datetime.today().display()]
  )
  #line(length: 100%)
]

#show: arbeitsblatt(
  custom-header: custom-header
)
```

#pagebreak()

= Beispiele <sec:examples>

==== Einfaches Arbeitsblatt

```typ
#import "@schule/arbeitsblatt:0.2.4": *

#show: arbeitsblatt(
  title: "Geometrie",
  class: "Klasse 9b",
  loesungen: "seiten"
)

#aufgabe(
  title: [Flächenberechnung],
)[
  Bearbeiten Sie die folgenden Teilaufgaben:

  #teilaufgabe(workspace: kariert(rows: 10))[
    Berechnen Sie die Fläche eines Rechtecks mit den Seitenlängen 5 cm und 8 cm.
    #loesung[$A = 5 "cm" times 8 "cm" = 40 "cm"^2$]
  ]

  #teilaufgabe(workspace: kariert(height: 5cm))[
    Berechnen Sie die Fläche eines Quadrats mit der Seitenlänge 6 cm.
    #loesung[$A = 6 "cm" times 6 "cm" = 36 "cm"^2$]
  ]
]
```

#pagebreak()

= API-Referenz <sec:api-reference>

#command("arbeitsblatt")[
  Die Hauptfunktion des Pakets zur Erstellung von Arbeitsblättern.\
  Erstellt ein neues Arbeitsblatt-Dokument mit den angegebenen Parametern.

  #argument("title", types: "content", default: [])[
    Der Titel des Arbeitsblatts, der im Header angezeigt wird.
  ]

  #argument("class", types: "content", default: [])[
    Die Klassenbezeichnung (z.B. "IF-11"), die im Header angezeigt wird.
  ]

  #argument("paper", types: "string", default: "a4")[
    Das Papierformat. Unterstützte Werte sind alle Typst-Papierformate.
  ]

  #argument("print", types: "boolean", default: false)[
    Aktiviert spezielle Einstellungen für den Druck, einschließlich angepasster Ränder.

    Insbesondere sorgt #raw("print: false", lang: "typc") dafür, dass die Höhe der Seite variabel ist, sodass der Inhalt nicht an die Grenzen des Seitenformats gebunden ist, und sich die Maße des Dokuments an den Inhalt anpassen.
  ]

  #argument("duplex", types: "boolean", default: true)[
    Aktiviert Duplex-Druck mit unterschiedlichen Innen- und Außenrändern.
  ]

  #argument("workspaces", types: "boolean", default: false)[
    Zeigt Arbeitsbereich-Elemente an, wenn aktiviert.
  ]

  #argument("font-size", types: "length", default: "12pt")[
    Die Standard-Schriftgröße des Dokuments.
  ]

  #argument("title-font-size", types: "length", default: "16pt")[
    Die Schriftgröße für den Titel im Header.
  ]

  #argument("figure-font-size", types: "length", default: "9pt")[
    Die Schriftgröße für Abbildungsunterschriften.
  ]

  #argument("font", types: "string", default: "Myriad Pro")[
    Die Standard-Schriftart des Dokuments.
  ]

  #argument("math-font", types: "string", default: "Fira Math")[
    Die Schriftart für mathematische Formeln.
  ]

  #argument("landscape", types: "boolean", default: false)[
    Setzt die Seitenorientierung auf Querformat.
  ]

  #argument("custom-header", types: "content", default: [])[
    Ein benutzerdefinierter Header, der den Standard-Header ersetzt.
  ]

  #argument("header-ascent", types: "percentage", default: "20%")[
    Steuert die vertikale Position des Headers. Positive Werte heben den Header an, negative senken ihn ab.
  ]

  #argument("teilaufgabe-numbering", types: "string", default: "a)")[
    Das Nummerierungsschema für Teilaufgaben. Unterstützte Werte: "a)", "1.".
  ]

  #argument("page-settings", types: "dictionary", default: ())[
    Zusätzliche Seiteneinstellungen, die an die `page`-Funktion weitergegeben werden.

    #frame[
      #set text(.88em)
      Beispiel für page-settings:
      ```typ
      page-settings: (
        margin: 2cm,
        width: 1cm,
        fill: gray
      )
      ```
    ]
  ]

  #colbreak()

  #argument("loesungen", types: "string", default: "false")[
    Modus für die Anzeige von Lösungen.

    #frame[
      #set text(.88em)
      *Verfügbare Modi:*
      - `"false"`: Keine Lösungen anzeigen
      - `"sofort"`: Lösungen direkt nach der zugehörigen (Teil)aufgabe
      - `"folgend"`: Lösungen direkt nach der gesamten Aufgabe
      - `"seite"`: Alle Lösungen auf separaten Seiten am Dokumentende
      - `"seiten"`: Lösungen auf separaten Seiten, jede Aufgabe beginnt auf neuer Seite
    ]
  ]

  #argument("materialien", types: "string", default: "seiten")[
    Modus für die Anzeige von Materialien.

    #frame[
      #set text(.88em)
      *Verfügbare Modi:*
      - `"false"`: Keine Materialien anzeigen
      - `"sofort"` oder `"folgend"`: Materialien direkt nach der Aufgabe
      - `"seite"`: Alle Materialien auf separaten Seiten am Dokumentende
      - `"seiten"`: Materialien auf separaten Seiten, jede Aufgabe beginnt auf neuer Seite
    ]
  ]
  #argument("punkte", types: "string", default: "keine")[
    Modus für die Anzeige von Bewertungspunkten.

    #frame[
      #set text(.88em)
      *Verfügbare Modi:*
      - `"keine"`: Keine Punkte anzeigen
      - `"aufgaben"`: Nur Gesamtpunkte pro Aufgabe
      - `"teilaufgaben"`: Nur Punkte pro Teilaufgabe
      - `"alle"`: Punkte sowohl für Aufgaben als auch Teilaufgaben
    ]
  ]

  #argument("aufgaben-shortcodes", types: "string", default: "alle")[
    Aktiviert automatische Konvertierung von Markdown-Syntax zu Aufgaben und Teilaufgaben.

    #frame[
      #set text(.88em)
      *Verfügbare Modi:*
      - `"false"`: Keine automatische Konvertierung
      - `"aufgaben"`: Nur Überschriften werden zu Aufgaben konvertiert
      - `"teilaufgaben"`: Nur Aufzählungspunkte werden zu Teilaufgaben konvertiert
      - `"alle"`: Sowohl Überschriften als auch Aufzählungspunkte werden konvertiert

      *Beispiel:*
      ```typ
      // Mit aufgaben-shortcodes: "alle"
      = Meine Aufgabe
      + Teilaufgabe a
      + Teilaufgabe b
      
      // Wird automatisch zu:
      #aufgabe(title: [Meine Aufgabe], large: true)[]
      #teilaufgabe[Teilaufgabe a]
      #teilaufgabe[Teilaufgabe b]
      ```
    ]
  ]

  #argument("copyright", types: "content", default: none)[
    Copyright-Information, die als QR-Code im Header angezeigt wird.
  ]

  #argument("body", types: "content", default: [])[
    Der Hauptinhalt des Arbeitsblatts.
  ]
]

#pagebreak()

== Hilfsfunktionen <sec:utilities>

Das `arbeitsblatt` Paket stellt verschiedene Hilfsfunktionen zur Verfügung, die die Erstellung von Arbeitsblättern vereinfachen.

#command("lücke")[
  Erstellt eine Lücke zum Ausfüllen mit einer gestrichelten Linie.

  #argument("body", types: "content", default: [])[
    Der Inhalt, der als unsichtbarer Platzhalter dient.
  ]

  #argument("tight", types: "boolean", default: false)[
    Wenn `true`, wird kein zusätzlicher Abstand hinzugefügt.
  ]

  #example[```
  Das Wort #lücke[Typst] ist ein Satzsystem.
  Das Wort #lücke(tight: true)[Typst] ist ein Satzsystem.
  ```]
]

#command("minipage")[
  Teilt Inhalt in mehrere Spalten auf.

  #argument("columns", types: "array", default: "(1fr, 1fr)")[
    Definition der Spaltenbreiten.
  ]

  #argument("align", types: "alignment", default: "horizon")[
    Ausrichtung des Inhalts in den Spalten.
  ]

  #argument("spacing", types: "length", default: "5mm")[
    Abstand zwischen den Spalten.
  ]

  #argument("body", types: "content", default: [])[
    Der Inhalt, der in Spalten aufgeteilt werden soll.
  ]

  #example[```
  #minipage(
    columns: (1fr, 2fr),
    align: bottom
  )[
    Erste Spalte
  ][
    Zweite Spalte mit mehr Inhalt\
    und zwei Zeilen.
  ]
  ```]
]

#command("workspace")[
  Erstellt einen (zusätzlichen) bedingten Arbeitsbereich für Schüler:innen, der nur angezeigt wird, wenn `workspaces: true` gesetzt ist (und nicht konkret einer Aufgabe zugeordnet werden kann).

  #argument("height", types: "length", default: "5cm")[
    Die Höhe des Arbeitsbereichs.
  ]

  #argument("body", types: "content", default: [])[
    Der Inhalt des Arbeitsbereichs.
  ]

  #example[```
  #workspace(kariert(rows: 2))
  ```]
]

#command("print-pagebreak")[
  Fügt einen Seitenumbruch hinzu, aber nur im Druckmodus (`print: true`).

  Diese Funktion ist nützlich, wenn bestimmte Inhalte nur in gedruckten Versionen auf einer neuen Seite beginnen sollen, während sie in digitalen Versionen ohne Seitenumbruch angezeigt werden.

  #sourcecode[```typ
  // Dieser Abschnitt beginnt nur beim Drucken auf einer neuen Seite
  #print-pagebreak()
  = Nächster Abschnitt
  ```]
]

#command("non-print-pagebreak")[
  Fügt einen Seitenumbruch hinzu, aber nur im Nicht-Druckmodus (`print: false`).

  Diese Funktion ist nützlich, wenn bestimmte Inhalte nur in digitalen Versionen auf einer neuen Seite beginnen sollen, während sie in gedruckten Versionen ohne Seitenumbruch angezeigt werden.

  #sourcecode[```typ
  // Dieser Abschnitt beginnt nur in digitaler Ansicht auf einer neuen Seite
  #non-print-pagebreak()
  = Nächster Abschnitt
  ```]
]

#command("icon-link")[
  Erstellt einen Link mit Icon.

  #argument("url", types: "string", default: none)[
    Die URL des Links.
  ]

  #argument("name", types: "string", default: none)[
    Der Anzeigetext des Links.
  ]

  #argument("icon", types: "content", default: emoji.chain)[
    Das Icon, das vor dem Link angezeigt wird.
  ]

  #argument("color", types: color, default: blue)[
    Die Farbe des Links.
  ]

  #example(```
  #icon-link(
    "https://typst.app",
    "Typst Website",
    icon: emoji.books,
    color: red
  )```)
]

#command("qrbox")[
  Erstellt eine Box mit QR-Code und Link.

  #argument("url", types: "string", default: "")[
    Die URL für den QR-Code.
  ]

  #argument("name", types: "string", default: "")[
    Der Anzeigetext unter dem QR-Code.
  ]

  #argument("width", types: "length", default: "3cm")[
    Die Breite der Box.
  ]

  #argument("rotation", types: "angle", default: 0deg)[
    Die Drehung der Box.
  ]

  #example[```
  #qrbox("https://typst.app", "Typst", rotation: 2deg, fill: yellow)
  ```]
]

#command("mono")[
  Stellt Text in einer Monospace-Schrift dar.

  #argument("body", types: "content", default: [])[
    Der Text, der in Monospace dargestellt werden soll.
  ]

  #example[```
  Der Code #mono("print('Hello')") ist Python.
  ```]
]

#pagebreak()

= Anpassung des Templates <sec:customization>

==== Layout-Optionen

Das `arbeitsblatt` Paket bietet verschiedene Optionen zur Anpassung des Layouts:

- *Papierformat*: Alle Typst-Papierformate werden unterstützt
- *Orientierung*: Hoch- oder Querformat via `landscape`-Parameter
- *Ränder*: Anpassbar für Druck und digitale Anzeige
- *Schriftarten*: Konfigurierbare Haupt- und Mathematik-Schriftarten

==== Header-Anpassung

Der Header kann vollständig angepasst oder ersetzt werden:

```typ
#let custom-header = [
  #grid(
    columns: (1fr, auto),
    [*Mein Arbeitsblatt*],
    [Datum: #datetime.today().display()]
  )
  #line(length: 100%)
]

#show: arbeitsblatt(
  custom-header: custom-header
)
```

#pagebreak()

= Integrierte Pakete <sec:integrations>

Das `arbeitsblatt` Paket integriert verschiedene spezialisierte Pakete, um eine umfassende Lösung für Arbeitsblätter zu bieten:

==== Kern-Abhängigkeiten

#frame[
  #set text(.88em)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    [
      *Schule-Pakete:*
      - `@schule/aufgaben`: Aufgaben und Teilaufgaben
      - `@schule/patterns`: Papiermuster (kariert, liniert)
      - `@schule/insert-a-word`: Lückentexte
      - `@schule/physik`: Messwerttabellen, ...
      - `@schule/energy-sketch`: Energiediagramme
      - `@schule/operatoren`: Operatoren-Listen
    ],
    [
      *Community-Pakete:*
      - `@preview/fontawesome` 0.6.0: Icons
      - `@preview/rustycure` 0.1.0: QR-Codes
      - `@preview/cetz` 0.4.2: Diagramme
      - `@preview/cetz-plot` 0.1.2: Plot-Funktionen
      - `@preview/codly` 1.3.0: Code-Highlighting
      - `@preview/colorful-boxes` 1.4.3: Farbige Boxen
      - `@preview/fancy-units` 0.1.1: Einheiten-Formatierung
      - `@preview/eqalc` 0.1.3: Gleichungsberechnungen
      - `@preview/zero` 0.5.0: Zero-Paket
    ],
  )
]

#pagebreak()

= Changelog

==== Version 0.2.4 (September 2025)
- *Neues Material-System*: Vollständige Überarbeitung der Material-Verwaltung mit konfigurierbaren Anzeigemodi
- *Tablex zu std.table Migration*: Vollständige Umstellung auf Typst's Standard-Tabellensystem
- *Physik-Paket Integration*: Aktualisierte Unterstützung für physikalische Formeln und Berechnungen
- *Erweiterte QR-Code-Funktionalität*: Verbesserte QR-Code-Generierung mit alt-text Unterstützung
- *Verbesserte Einheiten-Formatierung*: Integration von fancy-units für bessere Einheitendarstellung

==== Version 0.2.3 (September 2025)
- *Dependency Updates*: Aktualisierung auf cetz 0.4.2, fontawesome 0.6.0, codly 1.3.0
- *Rustycure Integration*: Wechsel von cades zu rustycure für QR-Code-Generierung
- *Margin-Fixes*: Korrektur der Druckränder für Querformat
- *Insert-a-word Verbesserungen*: Bessere Paragraph-Handhabung und Formatierung
- *Processing Syntax*: Erweiterte Syntax-Hervorhebung für Processing-Code

==== Version 0.2.2 (2024)
- *Typst 0.13 Kompatibilität*: Vollständige Unterstützung für Typst 0.13
- *Cetz Updates*: Aktualisierung auf cetz 0.4.1 und cetz-plot 0.1.2
- *Verbesserte Druckränder*: Optimierte Margin-Logik für physischen Druck

==== Version 0.2.1 (2024)
- *Font-Parameter*: Neue Konfigurationsoptionen für Schriftarten
- *Erweiterte Anpassbarkeit*: Mehr Optionen für Template-Anpassung

==== Version 0.2.0 (Dezember 2024)
- *Aufgaben-Integration*: Vollständige Integration des `@schule/aufgaben` Pakets
- *Processing Syntax*: Syntax-Highlighting für Processing-Code
- *Asset-Unterstützung*: Erweiterte Unterstützung für Medien und Assets
- *Neue Nummerierungsschemata*: Verbesserte Aufgaben- und Teilaufgaben-Nummerierung

==== Version 0.1.9 (2024)
- *Tablex Entfernt*: (Möglichst) alle Abhängigkeiten von tablex entfernt
- *Figure-Nummerierung*: Korrektur der Aufgaben/Figure-Nummerierung
- *Layout-Verbesserungen*: Optimierte Darstellung und Spacing

==== Version 0.1.8 (2024)
- *CeTZ Updates*: Aktualisierung der CeTZ-Abhängigkeiten
- *Diagram-Verbesserungen*: Bessere Integration von Diagrammen und Plots

==== Version 0.1.7 (September 2024)
- *Compiler-Kompatibilität*: Mindestanforderung Typst 0.12
- *Dependency-Updates*: Aktualisierung verschiedener Abhängigkeiten
- *Asset-Beispiele*: Erweiterte Beispiel-Assets

==== Version 0.1.6 (2024)
- *Layout-Optionen*: Neue Anpassungsmöglichkeiten für Arbeitsblatt-Layouts
- *Aufgaben-Verbesserungen*: Erweiterte Aufgaben-Funktionalität

==== Version 0.1.5 (2024)
- *Performance-Optimierungen*: Verbesserte Rendering-Performance
- *Bug-Fixes*: Diverse Korrekturen in der Darstellung

==== Version 0.1.4 (2024)
- *Formatierung*: Verbesserte Text- und Mathematik-Formatierung
- *Template-Erweiterungen*: Zusätzliche Template-Optionen

==== Version 0.1.3 (2024)
- *Aufgaben-System*: Erweiterte Aufgaben-Funktionalität
- *Nummerierung*: Verbesserte Nummerierungsschemata

==== Version 0.1.1 (2024)
- *Initial Release*: Erste stabile Version mit Basis-Funktionalität
- *Header-System*: Grundlegendes Header- und Layout-System
- *Aufgaben-Support*: Basis-Unterstützung für Aufgaben und Teilaufgaben

==== Version 0.1.0 (Dezember 2023)
- *Initial Version*: Erste Veröffentlichung des arbeitsblatt-Pakets
- *Grundfunktionen*: Template-System, Header, Basis-Layout
- *Asset-Support*: Grundlegende Unterstützung für Medien