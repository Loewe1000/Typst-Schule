#import "@preview/mantys:1.0.2": *

#import "../aufgaben.typ" as auf

#import "@preview/codly:1.3.0": *

#show: mantys(
  name: "aufgaben",
  version: "0.1.2",
  authors: (
    "Lukas Köhl",
    "Alexander Schulz",
  ),
  license: "MIT",
  description: "Ein spezialisiertes Paket zur Erstellung strukturierter Aufgaben mit Teilaufgaben, Lösungen, Materialien und Bewertungsschemata für den Schulbereich.",

  abstract: [
    Das `aufgaben` Paket bietet eine umfassende Lösung zur Erstellung strukturierter Aufgaben für den Schulbereich. Es ermöglicht die Definition von Hauptaufgaben mit Teilaufgaben, integrierte Lösungsdarstellung, Material-Management und flexible Bewertungsschemata. Das Paket unterstützt verschiedene Anzeigemodi für Lösungen und Materialien sowie erweiterte Funktionen für Erwartungshorizonte und Punkteverteilung.
  ],

  examples-scope: (
    scope: (aufgaben: auf),
    imports: (aufgaben: "aufgabe, teilaufgabe, loesung, material, erwartung, set_options"),
  ),
)

#show: codly-init.with()
#codly(number-format: none)

#pagebreak(weak: true)
= Über das Paket <sec:about>

Das `aufgaben` Paket ist eine spezialisierte Lösung zur Erstellung strukturierter Aufgaben für den Schulbereich. Es wurde entwickelt, um Lehrkräften ein mächtiges Werkzeug für die Erstellung von Aufgaben mit Teilaufgaben, Lösungen und Materialien zu bieten.

Dieses Manual ist eine vollständige Referenz aller Funktionen des `aufgaben` Pakets.

== Terminologie

In diesem Manual werden folgende Begriffe verwendet:

- *Aufgabe*: Eine Hauptaufgabe mit optionaler Nummerierung, Titel und Methode
- *Teilaufgabe*: Unteraufgaben innerhalb einer Hauptaufgabe mit eigener Nummerierung
- *Lösung*: Antworten zu Aufgaben oder Teilaufgaben, die je nach Modus angezeigt werden
- *Material*: Zusätzliche Ressourcen wie Abbildungen, Tabellen oder Hilfsmittel
- *Erwartung*: Bewertungskriterien mit Punkteverteilung für Aufgaben
- *Workspace*: Arbeitsbereich für Schüler:innen zum Bearbeiten

== Architektur

Das Paket basiert auf einem State-Management-System, das die Aufgaben, Lösungen und Materialien zentral verwaltet. Dies ermöglicht flexible Anzeigemodi und automatische Nummerierung.

= Schnelleinstieg <sec:quickstart>

Für den schnellen Einstieg importieren Sie das Paket und erstellen Ihre erste Aufgabe:

```typ
#import "@schule/aufgaben:0.1.2": *

#set_options((
  loesungen: "folgend",
  materialien: "sofort"
))

#aufgabe(title: [Grundrechenarten])[
  Berechnen Sie die folgenden Ausdrücke:
  
  #teilaufgabe[
    $2 + 3 = ?$
    #loesung[$2 + 3 = 5$]
  ]
  
  #teilaufgabe[
    $5 times 7 = ?$
    #loesung[$5 times 7 = 35$]
  ]
]
```

== Erste Schritte

1. *Import*: Importieren Sie das Paket mit `#import "@schule/aufgaben:0.1.2": *`
2. *Konfiguration*: Setzen Sie gewünschte Optionen mit `#set_options()`
3. *Aufgaben*: Erstellen Sie Aufgaben mit `#aufgabe()`
4. *Teilaufgaben*: Fügen Sie Teilaufgaben mit `#teilaufgabe()` hinzu
5. *Lösungen*: Definieren Sie Lösungen mit `#loesung()`

= Verwendung <sec:usage>

== Konfiguration <sec:configuration>

Das Paket wird über die `set_options()` Funktion konfiguriert:

```typ
#set_options((
  loesungen: "seiten",      // Lösungsmodus
  materialien: "folgend",   // Materialienmodus  
  workspaces: true,         // Arbeitsbereiche anzeigen
  teilaufgabe-numbering: "a)", // Nummerierungsschema
  punkte: "alle"           // Punkteanzeige
))
```

== Aufgaben erstellen <sec:creating-tasks>

=== Hauptaufgaben

Hauptaufgaben werden mit der `aufgabe()` Funktion erstellt:

```typ
#aufgabe(
  title: [Quadratische Gleichungen],
  method: "EA",  // Einzelarbeit
  large: false,
  number: true
)[
  Lösen Sie die folgenden quadratischen Gleichungen...
]
```

=== Teilaufgaben

Teilaufgaben strukturieren komplexe Aufgaben:

```typ
#aufgabe[
  Bearbeiten Sie die folgenden Teilaufgaben:
  
  #teilaufgabe[
    Berechnen Sie den Flächeninhalt.
    #loesung[42 cm²]
  ]
  
  #teilaufgabe[
    Bestimmen Sie den Umfang.
    #loesung[26 cm]
  ]
]
```

== Lösungen und Materialien <sec:solutions-materials>

=== Lösungsmodi

Das Paket bietet verschiedene Modi für die Anzeige von Lösungen:

- `"keine"`: Keine Lösungen anzeigen
- `"sofort"`: Lösungen direkt nach der zugehörigen (Teil)aufgabe
- `"folgend"`: Lösungen nach der gesamten Aufgabe
- `"seite"`: Alle Lösungen auf separaten Seiten am Dokumentende
- `"seiten"`: Lösungen auf separaten Seiten, jede Aufgabe beginnt auf neuer Seite

=== Materialien

Materialien werden mit der `material()` Funktion definiert:

```typ
#aufgabe[
  Nutzen Sie die Formelsammlung aus @formeln.
  
  #material(
    caption: [Wichtige Formeln],
    label: <formeln>
  )[
    $A = pi r^2$\
    $U = 2 pi r$\
    $V = 4/3 pi r^3$
  ]
]
```

= API-Referenz <sec:api-reference>

== Konfigurationsfunktionen

#command("set_options")[
  Konfiguriert die globalen Optionen für die Aufgabendarstellung.

  #argument("options", types: "dictionary", default: ())[
    Dictionary mit Konfigurationsoptionen.
    
    Verfügbare Optionen:
    - `loesungen`: Lösungsmodus (`"keine"`, `"sofort"`, `"folgend"`, `"seite"`, `"seiten"`)
    - `materialien`: Materialienmodus (`"keine"`, `"sofort"`, `"folgend"`, `"seite"`, `"seiten"`)
    - `workspaces`: Arbeitsbereiche anzeigen (`true`/`false`)
    - `teilaufgabe-numbering`: Nummerierungsschema (`"a)"`, `"1."`)
    - `punkte`: Punkteanzeige (`"keine"`, `"aufgaben"`, `"teilaufgaben"`, `"alle"`)
  ]

  #sourcecode[```typ
  #set_options((
    loesungen: "seiten",
    materialien: "folgend",
    workspaces: true,
    punkte: "alle"
  ))
  ```]
]

== Aufgabenfunktionen

#command("aufgabe")[
  Erstellt eine Hauptaufgabe mit optionaler Nummerierung, Titel und Methodenangabe.

  #argument("title", types: "content", default: none)[
    Der Titel der Aufgabe, der nach der Nummerierung angezeigt wird.
  ]

  #argument("method", types: "string", default: "")[
    Die Arbeitsform der Aufgabe. Unterstützte Werte:
    - `"EA"`: Einzelarbeit (zeigt Benutzer-Icon)
    - `"PA"`: Partnerarbeit (zeigt Benutzergruppe-Icon)  
    - `"GA"`: Gruppenarbeit (zeigt Benutzer-Icon)
  ]

  #argument("icons", types: "array", default: ())[
    Zusätzliche Icons, die neben der Aufgabe angezeigt werden sollen.
  ]

  #argument("large", types: "boolean", default: false)[
    Wenn `true`, wird eine größere Schriftgröße (14pt) für den Aufgabentitel verwendet.
  ]

  #argument("number", types: "boolean", default: true)[
    Wenn `false`, wird keine Aufgabennummerierung angezeigt.
  ]

  #argument("workspace", types: "content", default: none)[
    Arbeitsbereich, der unterhalb der Aufgabe angezeigt wird, wenn `workspaces: true` gesetzt ist.
  ]

  #argument("label-ref", types: "label", default: none)[
    Ein Label für Querverweise auf diese Aufgabe.
  ]

  #argument("body", types: "content", default: [])[
    Der Inhalt der Aufgabe.
  ]

  #sourcecode[```typ
  #aufgabe(
    title: [Trigonometrie],
    method: "PA",
    icons: (emoji.calculator,),
    large: true
  )[
    Berechnen Sie sin(30°) und cos(60°).
    
    #loesung[
      $sin(30°) = 1/2$, $cos(60°) = 1/2$
    ]
  ]
  ```]
]

#command("teilaufgabe")[
  Erstellt eine Teilaufgabe innerhalb einer Hauptaufgabe.

  #argument("item-label", types: "string", default: "a)")[
    Das Nummerierungsschema für diese spezifische Teilaufgabe (überschreibt globale Einstellung).
  ]

  #argument("label-ref", types: "label", default: none)[
    Ein Label für Querverweise auf diese Teilaufgabe.
  ]

  #argument("workspace", types: "content", default: none)[
    Arbeitsbereich für diese spezifische Teilaufgabe.
  ]

  #argument("body", types: "content", default: [])[
    Der Inhalt der Teilaufgabe.
  ]

  #sourcecode[```typ
  #aufgabe[
    Lösen Sie die folgenden Teilaufgaben:

    #teilaufgabe(label-ref: <teil-a>)[
      Berechnen Sie $x^2 + 2x + 1$.
      #loesung[$(x+1)^2$]
    ]

    #teilaufgabe[
      Vereinfachen Sie das Ergebnis aus @teil-a.
      #loesung[$x^2 + 2x + 1 = (x+1)^2$]
    ]
  ]
  ```]
]

== Inhalts- und Bewertungsfunktionen

#command("loesung")[
  Fügt eine Lösung zur aktuellen Aufgabe oder Teilaufgabe hinzu.

  #argument("body", types: "content", default: [])[
    Der Inhalt der Lösung.
  ]

  Die Anzeige der Lösung wird durch den globalen `loesungen`-Parameter gesteuert.

  #sourcecode[```typ
  #teilaufgabe[
    Berechnen Sie $sqrt(16)$.
    #loesung[$sqrt(16) = 4$]
  ]
  ```]
]

#command("material")[
  Fügt Material zur aktuellen Aufgabe hinzu.

  #argument("body", types: "content", default: [])[
    Der Inhalt des Materials (Text, Tabellen, Abbildungen, etc.).
  ]

  #argument("caption", types: "content", default: none)[
    Eine Beschriftung für das Material.
  ]

  #argument("label", types: "label", default: none)[
    Ein Label für Querverweise auf dieses Material.
  ]

  Das Material wird automatisch nummeriert und je nach `materialien`-Einstellung angezeigt.

  #sourcecode[```typ
  #aufgabe[
    Verwenden Sie die Werte aus @messwerte.

    #material(
      caption: [Messwerte Experiment 1],
      label: <messwerte>
    )[
      #table(
        columns: 3,
        [Zeit], [Temperatur], [Druck],
        [0s], [20°C], [1013 hPa],
        [30s], [25°C], [1015 hPa],
        [60s], [30°C], [1018 hPa]
      )
    ]
  ]
  ```]
]

#command("erwartung")[
  Definiert Bewertungskriterien mit Punkteverteilung für die aktuelle Aufgabe oder Teilaufgabe.

  #argument("text", types: "content", default: [])[
    Beschreibung des Bewertungskriteriums.
  ]

  #argument("punkte", types: "integer", default: 0)[
    Anzahl der Punkte für dieses Kriterium.
  ]

  Die Erwartungen werden zur Berechnung der Gesamtpunktzahl verwendet und in Bewertungsbögen angezeigt.

  #sourcecode[```typ
  #teilaufgabe[
    Beschreiben Sie den Vorgang der Photosynthese.
    
    #erwartung([Lichtreaktion korrekt erklärt], 2)
    #erwartung([Dunkelreaktion korrekt erklärt], 3)
    #erwartung([Gesamtgleichung angegeben], 1)
    
    #loesung[
      Photosynthese umfasst Licht- und Dunkelreaktion...
    ]
  ]
  ```]
]

= Erweiterte Funktionen <sec:advanced>

== State-Management

Das Paket verwendet ein internes State-Management-System zur Verwaltung von:

- Aufgabenliste (`_state_aufgaben`)
- Aktueller Material-Aufgabe (`_state_current_material_aufgabe`)
- Material-Index (`_state_current_material_index`)
- Globale Optionen (`_state_options`)

== Automatische Nummerierung

- Aufgaben werden automatisch durchnummeriert (Aufgabe 1, 2, 3, ...)
- Teilaufgaben verwenden konfigurierbare Nummerierung (`"a)"` oder `"1."`)
- Materialien erhalten automatische Nummerierung basierend auf Aufgabe und Index

== Flexible Anzeigemodi

Das Paket unterstützt verschiedene Anzeigemodi für optimale Flexibilität:

==== Lösungen
- *Sofort*: Lösungen direkt nach jeder Teilaufgabe
- *Folgend*: Lösungen nach der kompletten Aufgabe
- *Seite/Seiten*: Lösungen am Dokumentende

==== Materialien  
- *Sofort/Folgend*: Materialien direkt bei der Aufgabe
- *Seite/Seiten*: Materialien am Dokumentende

==== Punktesystem

Das integrierte Punktesystem ermöglicht:

- Definition von Bewertungskriterien mit `erwartung()`
- Flexible Punkteanzeige (keine, nur Aufgaben, nur Teilaufgaben, alle)

= Beispiele <sec:examples>

==== Einfache Aufgabe mit Teilaufgaben

```typ
#import "@schule/aufgaben:0.1.2": *

#set_options((
  loesungen: "folgend",
  punkte: "alle"
))

#aufgabe(title: [Geometrie Grundlagen])[
  Berechnen Sie für ein Rechteck mit den Seitenlängen a = 5 cm und b = 8 cm:

  #teilaufgabe[
    Den Flächeninhalt A.
    #erwartung([Formel korrekt angewendet], 1)
    #erwartung([Ergebnis mit Einheit], 1)
    #loesung[$A = a times b = 5 "cm" times 8 "cm" = 40 "cm"^2$]
  ]

  #teilaufgabe[
    Den Umfang U.
    #erwartung([Formel korrekt angewendet], 1)
    #erwartung([Ergebnis mit Einheit], 1)
    #loesung[$U = 2(a + b) = 2(5 + 8) "cm" = 26 "cm"$]
  ]
]
```

====== Aufgabe mit Material

```typ
#aufgabe(title: [Datenauswertung], method: "GA")[
  Werten Sie die Messdaten aus @messdaten aus.

  #material(
    caption: [Experimentelle Messdaten],
    label: <messdaten>
  )[
    #table(
      columns: 4,
      [Nr.], [Zeit (s)], [Temperatur (°C)], [Volumen (ml)],
      [1], [0], [20], [100],
      [2], [30], [40], [110],
      [3], [60], [60], [120],
      [4], [90], [80], [130]
    )
  ]

  #teilaufgabe[
    Erstellen Sie ein Diagramm der Temperatur über die Zeit.
    #erwartung([Achsenbeschriftung korrekt], 1)
    #erwartung([Skalierung angemessen], 1)
    #erwartung([Datenpunkte korrekt eingetragen], 2)
  ]

  #teilaufgabe[
    Berechnen Sie die durchschnittliche Temperaturänderung pro Minute.
    #loesung[
      $Delta T = 80°C - 20°C = 60°C$ in 90s\
      $overline((Delta T)/(Delta t)) = 60°C / 1.5 "min" = 40°C/"min"$
    ]
  ]
]
```

==== Komplexe Aufgabe mit verschiedenen Modi

```typ
#set_options((
  loesungen: "seiten",
  materialien: "seite",
  teilaufgabe-numbering: "1.",
  punkte: "alle"
))

#aufgabe(
  title: [Physik: Mechanik],
  method: "EA",
  large: true
)[
  Ein Auto fährt mit konstanter Geschwindigkeit.

  #material(caption: [Formelsammlung Mechanik])[
    - $s = v times t$ (Weg bei konstanter Geschwindigkeit)
    - $v = s / t$ (Geschwindigkeit)
    - $a = (v_2 - v_1) / t$ (Beschleunigung)
  ]

  #teilaufgabe[
    Das Auto legt in 2 Stunden eine Strecke von 120 km zurück.
    Berechnen Sie die Geschwindigkeit.
    
    #erwartung([Gegebene Werte identifiziert], 1)
    #erwartung([Formel korrekt angewendet], 2)
    #erwartung([Einheitenumrechnung], 1)
    #erwartung([Endergebnis korrekt], 1)
    
    #loesung[
      Gegeben: $s = 120 "km"$, $t = 2 "h"$\
      Gesucht: $v$\
      $v = s / t = 120 "km" / 2 "h" = 60 "km/h"$
    ]
  ]

  #teilaufgabe[
    Wie weit fährt das Auto in 45 Minuten?
    
    #erwartung([Zeitumrechnung korrekt], 1)
    #erwartung([Berechnung korrekt], 2)
    
    #loesung[
      $t = 45 "min" = 0.75 "h"$\
      $s = v times t = 60 "km/h" times 0.75 "h" = 45 "km"$
    ]
  ]
]

```

= Integration mit anderen Paketen <sec:integration>

Das `aufgaben` Paket ist als eigenständiges Modul konzipiert, kann aber nahtlos in andere Schul-Pakete integriert werden:

==== Arbeitsblatt-Integration

```typ
#import "@schule/arbeitsblatt:0.2.4": *
#import "@schule/aufgaben:0.1.2": *

#show: arbeitsblatt(
  title: "Mathematik Übungen",
  class: "10a",
  loesungen: "seiten",  // wird an aufgaben weitergegeben
  punkte: "alle"        // wird an aufgaben weitergegeben
)

// Aufgaben verwenden automatisch die arbeitsblatt-Konfiguration
#aufgabe(title: [Quadratische Funktionen])[
  // Aufgabeninhalt...
]
```

==== Klassenarbeit-Integration

Das Paket eignet sich auch für Klassenarbeiten mit Bewertungsbögen:

```typ
#import "@schule/klassenarbeit:0.1.1": *
#import "@schule/aufgaben:0.1.2": *

// Erwartungen werden für Bewertungsbogen verwendet
#aufgabe[
  #erwartung([Ansatz korrekt], 2)
  #erwartung([Rechnung fehlerfrei], 3)
  #erwartung([Antwort vollständig], 1)
]
```

= Changelog

==== Version 0.1.2 (September 2025)
- *Material-System*: Vollständige Überarbeitung des Material-Management-Systems
- *Erweiterte State-Verwaltung*: Verbesserte Verwaltung von Aufgaben, Lösungen und Materialien
- *Material-Nummerierung*: Neue automatische Nummerierung für Materialien
- *FontAwesome Integration*: Aktualisierung auf FontAwesome 0.2.1
- *Gentle-Clues Integration*: Verbesserte Lösungsdarstellung mit gentle-clues 1.1.0

==== Version 0.1.1 (2024)
- *Punktesystem*: Einführung des Erwartungs- und Punktesystems
- *Erweiterte Nummerierung*: Flexible Nummerierungsschemata für Teilaufgaben
- *Performance-Optimierungen*: Verbesserte State-Management-Performance

==== Version 0.1.0 (2024)
- *Initial Release*: Erste stabile Version des aufgaben-Pakets
- *Grundfunktionen*: Aufgaben, Teilaufgaben, Lösungen und Materialien
- *State-Management*: Grundlegendes State-System für Aufgabenverwaltung
- *Flexible Anzeigemodi*: Verschiedene Modi für Lösungen und Materialien