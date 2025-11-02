#import "@preview/mantys:1.0.2": *

#import "../src/klassenarbeit.typ" as ka

#import "@preview/codly:1.3.0": *

#show: mantys(
  name: "klassenarbeit",
  version: "0.1.1",
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

#show: codly-init.with()
#codly(number-format: none)

#pagebreak(weak: true)
= Über das Paket <sec:about>

Das `klassenarbeit` Paket ist eine spezialisierte Lösung zur Erstellung von Klassenarbeiten und Tests für den Schulbereich. Es wurde entwickelt, um Lehrkräften die Erstellung standardisierter Prüfungsunterlagen zu erleichtern.

Dieses Manual ist eine vollständige Referenz aller Funktionen des `klassenarbeit` Pakets.

== Terminologie

In diesem Manual werden folgende Begriffe verwendet:

- *Klassenarbeit*: Das Hauptdokument, das mit `#show: klassenarbeit()` erstellt wird
- *Aufgabe*: Eine Hauptaufgabe mit optionaler Nummerierung und Titel
- *Teilaufgabe*: Unteraufgaben innerhalb einer Hauptaufgabe
- *Erwartung*: Bewertungskriterien mit Punkteverteilung
- *Erwartungshorizont*: Automatisch generierte Tabelle aller Erwartungen
- *Klausurbogen*: Doppelbogen für Schüler zum Beschriften

= Schnelleinstieg <sec:quickstart>

Für den schnellen Einstieg importieren Sie das Paket und erstellen Ihre erste Klassenarbeit:

```typ
#import "@schule/klassenarbeit:0.1.1": *

#show: klassenarbeit.with(
  title: [Klassenarbeit Nr. 1],
  subtitle: [Mathematik],
  class: [10a],
  date: [15.03.2025],
  teacher: [Müller],
  punkte: "alle",
  erwartungen: true,
)

#aufgabe(title: [Gleichungen lösen])[
  #teilaufgabe[
    Lösen Sie die Gleichung: $2x + 5 = 13$
    
    #erwartung(1, [Äquivalenzumformung durchgeführt])
    #erwartung(1, [Korrekte Lösung angegeben])
    
    #loesung[$x = 4$]
  ]
]
```

#pagebreak()

= Verwendung <sec:usage>

== Template-Initialisierung <sec:init>

Das Template wird durch eine Show-Rule mit dem `klassenarbeit`-Befehl initialisiert:

```typ
#show: klassenarbeit(
  title: "Titel der Klassenarbeit",
  class: "Klassenbezeichnung",
  // weitere Optionen...
)
```

== Aufgaben und Erwartungen <sec:tasks>

Das `klassenarbeit` Paket verwendet die Aufgaben-Funktionen aus dem `@schule/aufgaben` Paket. Zusätzlich können Erwartungen definiert werden:

```typ
#aufgabe(title: [Flächenberechnung])[
  Berechnen Sie die Fläche eines Rechtecks mit a = 5 cm und b = 8 cm.
  
  #erwartung(1, [Formel korrekt angewendet])
  #erwartung(1, [Ergebnis mit Einheit])
  
  #loesung[$A = 5 "cm" times 8 "cm" = 40 "cm"^2$]
]
```

#pagebreak()

= API-Referenz <sec:api-reference>

#command("klassenarbeit")[
  Die Hauptfunktion des Pakets zur Erstellung von Klassenarbeiten.\
  Erstellt ein neues Klassenarbeits-Dokument mit den angegebenen Parametern.

  #argument("title", types: "content", default: [])[
    Der Titel der Klassenarbeit (z.B. "Klassenarbeit Nr. 1").
  ]

  #argument("subtitle", types: "content", default: [])[
    Untertitel (z.B. Fach oder Thema).
  ]

  #argument("class", types: "content", default: [])[
    Die Klassenbezeichnung (z.B. "10a").
  ]

  #argument("date", types: "content", default: [])[
    Datum der Klassenarbeit.
  ]

  #argument("teacher", types: "content", default: [])[
    Name der Lehrkraft.
  ]

  #argument("schueler", types: "content", default: [])[
    Vorausgefüllter Schülername (optional).
  ]

  #argument("logo", types: "content", default: [])[
    Logo für den Header (optional).
  ]

  #argument("font", types: "string", default: "Myriad Pro")[
    Die Standard-Schriftart des Dokuments.
  ]

  #argument("math-font", types: "string", default: "Fira Math")[
    Die Schriftart für mathematische Formeln.
  ]

  #argument("font-size", types: "length", default: "12pt")[
    Die Standard-Schriftgröße des Dokuments.
  ]

  #argument("figure-font-size", types: "length", default: "12pt")[
    Die Schriftgröße für Abbildungsunterschriften.
  ]

  #argument("table", types: "array", default: ())[
    Zusätzliche Zeilen für die Info-Tabelle am Anfang.\
    Format: `(("Label", "Wert"), ...)`
  ]

  #argument("stufe", types: "string, boolean", default: false)[
    Schulstufe für Klausurbögen:\
    - `"I"`: Sekundarstufe I\
    - `"II"`: Sekundarstufe II\
    - `false`: Keine Angabe
  ]

  #argument("loesungen", types: "string", default: none)[
    Lösungsmodus (siehe `arbeitsblatt` Paket).
  ]

  #argument("materialien", types: "string", default: none)[
    Materialienmodus (siehe `arbeitsblatt` Paket).
  ]

  #argument("info-table", types: "boolean", default: true)[
    Ob die Info-Tabelle mit Name und Zusatzinformationen angezeigt werden soll.
  ]

  #argument("erwartungen", types: "boolean", default: false)[
    Ob ein Erwartungshorizont am Ende generiert werden soll.
  ]

  #argument("teilaufgabe-numbering", types: "string", default: "1.")[
    Das Nummerierungsschema für Teilaufgaben.\
    Unterstützte Werte: `"a)"`, `"1."`
  ]

  #argument("punkte", types: "string", default: "keine")[
    Modus für die Anzeige von Bewertungspunkten.\
    - `"keine"`: Keine Punkte anzeigen\
    - `"aufgaben"`: Nur Gesamtpunkte pro Aufgabe\
    - `"teilaufgaben"`: Nur Punkte pro Teilaufgabe\
    - `"alle"`: Punkte für Aufgaben und Teilaufgaben
  ]

  #argument("bewertung", types: "boolean", default: false)[
    Ob ein Bewertungsbogen generiert werden soll (veraltet).
  ]

  #argument("page-numbering", types: "boolean", default: true)[
    Ob Seitenzahlen angezeigt werden sollen.
  ]

  #argument("klausurboegen", types: "boolean", default: false)[
    Ob Klausurbögen am Ende generiert werden sollen.
  ]

  #argument("ergebnisse", types: "array", default: none)[
    Array mit Schülerergebnissen für Klausurbögen.\
    Format: siehe `@schule/klausurboegen` Paket.
  ]

  #argument("page-settings", types: "dictionary", default: ())[
    Zusätzliche Seiteneinstellungen.\
    Standard-Margins: `(top: 1cm, bottom: 1cm, left: 1.5cm, right: 1.5cm)`
  ]

  #argument("klausurboegen-settings", types: "dictionary", default: ())[
    Einstellungen für die Klausurbögen-Generierung.\
    Siehe `@schule/klausurboegen` Paket für Details.
  ]

  #argument("body", types: "content", default: [])[
    Der Hauptinhalt der Klassenarbeit.
  ]
]

#pagebreak()

= Erwartungshorizonte <sec:expectations>

Ein Erwartungshorizont wird automatisch generiert, wenn `erwartungen: true` gesetzt ist:

```typ
#show: klassenarbeit.with(
  title: [Klassenarbeit],
  erwartungen: true,
)

#aufgabe(title: [Rechnen])[
  #teilaufgabe[
    $2 + 3 = ?$
    #erwartung(1, [Korrekte Addition])
  ]
  
  #teilaufgabe[
    $5 times 7 = ?$
    #erwartung(1, [Korrekte Multiplikation])
  ]
]
```

Der Erwartungshorizont wird automatisch am Ende des Dokuments auf einer neuen Seite eingefügt und enthält:
- Aufgabennummern und -titel
- Teilaufgaben-Nummerierung
- Erwartungstexte
- Punkteverteilung
- Gesamtpunktzahl

#pagebreak()

= Klausurbögen <sec:exam-sheets>

Klausurbögen können automatisch generiert werden, wenn das `@schule/klausurboegen` Paket integriert wird:

```typ
#show: klassenarbeit.with(
  title: [Klassenarbeit],
  klausurboegen: true,
  stufe: "I",  // Sekundarstufe I
  ergebnisse: (
    (name: "Max Mustermann", points: 42),
    (name: "Anna Beispiel", points: 38),
  ),
)
```

Die Klausurbögen werden am Ende des Dokuments eingefügt und enthalten.

#pagebreak()

= Beispiele <sec:examples>

== Vollständige Klassenarbeit

```typ
#import "@schule/klassenarbeit:0.1.1": *

#show: klassenarbeit.with(
  title: [Klassenarbeit Nr. 2],
  subtitle: [Quadratische Funktionen],
  class: [10a],
  date: [15.03.2025],
  teacher: [Müller],
  punkte: "alle",
  erwartungen: true,
  teilaufgabe-numbering: "a)",
  table: (
    ("Hilfsmittel", "Taschenrechner, Formelsammlung"),
    ("Bearbeitungszeit", "45 Minuten"),
  ),
)

#aufgabe(title: [Funktionsgleichungen])[
  Gegeben ist die Funktion $f(x) = x^2 + 2x - 3$.

  #teilaufgabe[
    Bestimmen Sie die Nullstellen der Funktion.
    #erwartung(2, [p-q-Formel korrekt angewendet])
    #erwartung(1, [Beide Nullstellen angegeben])
    
    #loesung[
      $x^2 + 2x - 3 = 0$\
      $x_(1,2) = -1 plus.minus sqrt(1 + 3)$\
      $x_1 = 1$, $x_2 = -3$
    ]
  ]

  #teilaufgabe[
    Berechnen Sie den Scheitelpunkt.
    #erwartung(2, [Scheitelpunktform bestimmt])
    
    #loesung[
      $f(x) = (x + 1)^2 - 4$\
      Scheitelpunkt: $S(-1 | -4)$
    ]
  ]
]

#aufgabe(title: [Textaufgabe])[
  Ein rechteckiger Garten hat einen Umfang von 40 m.
  
  #teilaufgabe[
    Stellen Sie eine Funktion für die Fläche $A$ in Abhängigkeit
    von einer Seitenlänge $x$ auf.
    
    #erwartung(1, [Nebenbedingung aufgestellt])
    #erwartung(2, [Zielfunktion korrekt formuliert])
  ]
  
  #teilaufgabe[
    Bestimmen Sie die maximale Fläche.
    
    #erwartung(2, [Extremwert berechnet])
    #erwartung(1, [Interpretation])
  ]
]
```

#pagebreak()

= Integration mit anderen Paketen <sec:integration>

Das `klassenarbeit` Paket integriert nahtlos mit anderen Schul-Paketen:

== Arbeitsblatt-Basis

Das Paket basiert auf `@schule/arbeitsblatt` und erbt alle dessen Funktionen:
- Aufgaben und Teilaufgaben
- Lösungen und Materialien
- Layout-Anpassungen

== Aufgaben-System

Verwendet `@schule/aufgaben` für:
- Strukturierte Aufgabenverwaltung
- Erwartungen und Punkteverteilung
- Automatische Nummerierung

== Klausurbögen

Optional kann `@schule/klausurboegen` für die automatische Generierung von
Dokumentationsbögen verwendet werden.

#pagebreak()

= Changelog

== Version 0.1.1 (Januar 2025)
- *Ordnerstruktur*: Migration zu `src/` Struktur analog zu `arbeitsblatt`
- *Template*: Hinzufügen eines Template-Ordners mit Beispieldatei
- *Dokumentation*: Erstellung eines vollständigen Manuals
- *README*: Aktualisierte README mit Installationsanleitung

== Version 0.1.0 (2024)
- *Initial Release*: Erste Version des klassenarbeit-Pakets
- *Basis-Funktionalität*: Header, Info-Tabelle, Erwartungshorizonte
- *Klausurbögen-Integration*: Automatische Generierung von Klausurbögen
- *Bewertungssystem*: Punkteverteilung und Bewertungstabellen
