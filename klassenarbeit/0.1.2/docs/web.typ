#import "@preview/manifesto:0.1.1": template
#import "../../../schuldocs/0.1.0/lib.typ": with-web, show-example as _show-example

#let pkg = toml("../typst.toml")

#let show-example = _show-example

#show: with-web(
  template-fn: template,
  toml: pkg,
  notices: (
    [Entwickelt für das Schule-Typst-Ökosystem],
  ),
  links: (
    (name: "GitHub", url: "https://github.com/Loewe1000/Typst-Schule"),
  ),
)

= Über dieses Paket

Das `klassenarbeit`-Paket erweitert das `arbeitsblatt`-Paket um schriftliche Prüfungen. Es bietet strukturierte Klassenarbeitsbögen, optionale Schülerschreibbögen (Klausurbögen) und vollständige Integration aller `aufgaben`- und `arbeitsblatt`-Funktionen.

Dieses Manual gliedert sich wie folgt:

+ *Grundlagen* -- Installation und einfache Klassenarbeit
+ *Parameter* -- Alle Konfigurationsmöglichkeiten
+ *Info-Tabelle* -- Kopfzeileninformationen anpassen
+ *Klausurbögen* -- Separate Schüler-Schreibbögen
+ *Bewertung* -- Erwartungshorizont und Punktevergabe
+ *Vollständiges Beispiel*

= Grundlagen

== Paket importieren

```typ
#import "@schule/klassenarbeit:0.1.2": *
```

Das Paket stellt alle Funktionen aus `arbeitsblatt` und `aufgaben` bereit:
`aufgabe`, `teilaufgabe`, `loesung`, `material`, `erwartung`, `lücke`, `minipage` usw.

== Einfache Klassenarbeit

```typ
#import "@schule/klassenarbeit:0.1.2": *

#show: klassenarbeit.with(
  title: "Klassenarbeit Nr. 2",
  class: "9a",
  date: "14.02.2025",
)

#aufgabe(punkte: 6)[
  Berechne die Lösungen der Gleichung $x^2 - 5x + 6 = 0$.
]
```

#show-example(
  rendered: {
    import "/klassenarbeit/0.1.2/src/klassenarbeit.typ": aufgabe, erwartung, show-erwartungen
    aufgabe("Quadratische Gleichungen")[
      Berechne die Lösungen von $x^2 - 5x + 6 = 0$.
      #erwartung(2)[Mitternachtsformel korrekt angewandt]
      #erwartung(1)[Beide Lösungen: $x_1 = 2$, $x_2 = 3$]
    ]
    show-erwartungen()
  },
  source: ```typ
  #aufgabe("Quadratische Gleichungen")[
    Berechne die Lösungen von $x^2 - 5x + 6 = 0$.
    #erwartung(2)[Mitternachtsformel korrekt angewandt]
    #erwartung(1)[Beide Lösungen: $x_1 = 2$, $x_2 = 3$]
  ]
  #show-erwartungen()
  ```,
  width: 14cm,
)

= Parameter

Die `klassenarbeit()`-Funktion akzeptiert alle Parameter von `arbeitsblatt()` sowie zusätzliche für Prüfungen.

== Basis-Parameter

#table(
  columns: (auto, auto, auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Parameter*], [*Typ*], [*Standard*], [*Beschreibung*]),
  [`title`], [`string`], [`""`], [Titel der Klassenarbeit],
  [`subtitle`], [`string`], [`""`], [Untertitel (z. B. "Wiederholung Algebra")],
  [`class`], [`string`], [`""`], [Klasse (z. B. `"9a"`)],
  [`date`], [`string`], [`""`], [Datum der Prüfung],
  [`teacher`], [`string`], [`""`], [Name der Lehrkraft],
  [`logo`], [`image|none`], [`none`], [Schullogo oben rechts],
)

== Schüler-Informationsfelder

```typ
#show: klassenarbeit.with(
  schueler: true,  // Standard: Felder für Name, Klasse, Datum
)
```

Mit `schueler: false` werden die Schülerausfüllfelder unterdrückt (z. B. für Lehrerkopie).

== Info-Tabelle

Die `info-table`-Option fügt eine Tabelle mit Zusatzinformationen ins Dokument ein:

```typ
#show: klassenarbeit.with(
  info-table: (
    ("Bearbeitungszeit", "45 Minuten"),
    ("Hilfsmittel", "Taschenrechner"),
    ("Bewertung", "ab 50% → Note 4"),
  ),
)
```

Jeder Eintrag ist ein Tupel `("Bezeichnung", "Wert")`. Bei `info-table: false` wird keine Tabelle erstellt.

== Erwartungshorizont

```typ
#show: klassenarbeit.with(
  erwartungen: true,  // Erwartungshorizont am Ende generieren
)

#aufgabe(punkte: 4)[
  Bestimme die Nullstellen.
  #erwartung(2)[Korrekte Anwendung der Formel]
  #erwartung(2)[Beide Lösungen korrekt angegeben]
]
```

#show-example(
  rendered: {
    import "/klassenarbeit/0.1.2/src/klassenarbeit.typ": aufgabe, teilaufgabe, erwartung, show-erwartungen
    aufgabe("Funktionsanalyse")[
      #teilaufgabe[
        Bestimme die Nullstellen von $f(x) = x^2 - 4$.
        #erwartung(2)[Korrekte Nullstellen: $x = ±2$]
      ]
      #teilaufgabe[
        Skizziere den Graphen.
        #erwartung(1)[Korrekte Form der Parabel]
        #erwartung(1)[Scheitelpunkt eingezeichnet]
      ]
    ]
    show-erwartungen()
  },
  source: ```typ
  #aufgabe("Funktionsanalyse")[
    #teilaufgabe[
      Bestimme die Nullstellen von $f(x) = x^2 - 4$.
      #erwartung(2)[Korrekte Nullstellen: $x = ±2$]
    ]
    #teilaufgabe[
      Skizziere den Graphen.
      #erwartung(1)[Korrekte Form der Parabel]
      #erwartung(1)[Scheitelpunkt eingezeichnet]
    ]
  ]
  #show-erwartungen()
  ```,
  width: 14cm,
)

= Erweiterte Funktionen

== Klausurbögen

Klausurbögen sind separate, leere Bögen für Schüler zum Schreiben der Antworten.

```typ
#show: klassenarbeit.with(
  klausurboegen: (
    stufe: "II",
    ergebnisse: csv("ergebnisse.csv"),
  ),
)
```

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*Feld*], [*Beschreibung*]),
  [`stufe`], [Anforderungsstufe: `"I"`, `"II"` oder `"III"`],
  [`ergebnisse`], [CSV-Daten mit Schülerergebnissen (für Notenspiegel)],
)

Mit `klausurboegen: false` (Standard) werden keine Bögen generiert.

== Seiteneinstellungen

```typ
#show: klassenarbeit.with(
  page-numbering: "1 / 1",  // Seitennummerierung
  page-settings: (
    margin: (top: 2.5cm, bottom: 2cm, x: 2cm),
  ),
)
```

== Bewertung und Punkte

Alle Punktefunktionen aus `aufgaben` stehen zur Verfügung:

```typ
#show: klassenarbeit.with(
  punkte: "alle",  // Punkte bei Aufgaben und Teilaufgaben
)

#aufgabe("Funktionsgraphen", punkte: 8)[

  #teilaufgabe(punkte: 3)[
    Zeichne den Graphen von $f(x) = x^2$.
    #erwartung(3)[Korrekte Form; Scheitelpunkt bei (0,0); Nullstelle(n) korrekt]
  ]

  #teilaufgabe(punkte: 5)[
    Beschreibe das Verhalten für $x → ∞$.
    #erwartung(5)[Fachkorrekte Beschreibung]
  ]

]
```

= Vollständiges Beispiel

```typ
#import "@schule/klassenarbeit:0.1.2": *

#show: klassenarbeit.with(
  title: "2. Klassenarbeit",
  subtitle: "Lineare und quadratische Funktionen",
  class: "9a",
  date: "28.03.2025",
  teacher: "Frau Müller",
  punkte: "alle",
  loesungen: "seiten",
  erwartungen: true,
  info-table: (
    ("Bearbeitungszeit", "45 Minuten"),
    ("Hilfsmittel", "Geodreieck, Bleistift"),
    ("Punkte", "Notenschlüssel auf der Rückseite"),
  ),
  klausurboegen: false,
)

= Grundlagen

+ Bestimme die Steigung der Geraden durch $A(1|3)$ und $B(4|9)$.
  #erwartung(2)[Korrekte Steigungsformel; $m = 2$]
  #loesung[$m = (9-3)/(4-1) = 2$]

+ Berechne den Schnittpunkt von $f(x) = 2x + 1$ und $g(x) = -x + 7$.
  #erwartung(3)[Gleichsetzung; korrekte Lösung; Probe]
  #loesung[
    $2x + 1 = -x + 7 => 3x = 6 => x = 2$, $y = 5$
    
    Schnittpunkt: $S(2|5)$
  ]

= Quadratische Gleichungen

#teilaufgabe(punkte: 4)[
  Löse $x^2 - 3x - 10 = 0$.
  #erwartung(4)[Mitternachtsformel; Diskriminante; beide Lösungen]
  #loesung[$x_1 = 5$, $x_2 = -2$]
]
```
