#import "../../../schuldocs/0.1.0/lib.typ": show-example, show-module, show-code
#import "@preview/gentle-clues:1.2.0": tip

= Über dieses Paket

Das `aufgaben`-Paket ist das Fundament des Schule-Paket-Ökosystems. Es bietet alle grundlegenden Funktionen zur Strukturierung und Verwaltung von Aufgaben in Bildungsdokumenten.

Dieses Manual gliedert sich wie folgt:

+ *Schnellstart* -- Erste Schritte
+ *Aufgabenverwaltung* -- Erstellen von Aufgaben und Teilaufgaben
+ *Lösungen* -- Verwaltung von Musterlösungen
+ *Material* -- Einbinden von Zusatzmaterialien
+ *Bewertung* -- Punkte und Erwartungshorizonte
+ *Konfiguration* -- Anpassung des Verhaltens
+ *API-Referenz* -- Vollständige Funktionsdokumentation

= Schnellstart

== Paket importieren

```typ
#import "@schule/aufgaben:0.3.0": *
```

== Abhängigkeiten

Das Paket importiert automatisch:
- `fontawesome` (Icons)
- `gentle-clues` (Info-Boxen für Lösungen)

== Minimales Beispiel

```typ
#import "@schule/aufgaben:0.3.0": *

#aufgabe[
  Berechne die Summe von 15 und 27.
]
#loesung[$15 + 27 = 42$]

#aufgabe("Bruchrechnung")[
  Berechne $3/4 + 1/2$.

  #teilaufgabe[Hauptnenner bestimmen.]
  #teilaufgabe[Brüche addieren.]
]
#erwartung(1)[Hauptnenner 4 erkannt]
#erwartung(1)[Ergebnis $5/4$ korrekt]
```

= Aufgabenverwaltung

== Einfache Aufgabe

Die `aufgabe()`-Funktion erstellt eine nummerierte Aufgabe:

#show-example(
  rendered: {
    import "../aufgaben.typ": aufgabe
    aufgabe[
      Berechne die Summe von 15 und 27.
    ]
  },
  source: ```typ
  #aufgabe[
    Berechne die Summe von 15 und 27.
  ]
  ```,
  width: 14cm,
)

Aufgaben werden automatisch nummeriert (1, 2, 3, ...).

== Aufgabe mit Titel

Aufgaben können einen Titel erhalten -- entweder als benannter Parameter oder als erstes Positionsargument:

```typ
#aufgabe(title: [Addition])[
  Berechne die Summe von 15 und 27.
]

// Alternativ als Positionsargument:
#aufgabe[Addition][
  Berechne die Summe von 15 und 27.
]
```

== Aufgabengröße

Mit dem `large`-Parameter wird die Überschriftengröße gesteuert:

```typ
#aufgabe(title: "Hauptaufgabe", large: true)[
  Große Überschrift (1.25em)
]

#aufgabe(title: "Unteraufgabe", large: false)[
  Normale Überschrift (1em)
]
```

Standard ist `large: true`.

== Nummerierung deaktivieren

```typ
#aufgabe(title: "Bonusaufgabe", number: false)[
  Diese Aufgabe hat keine Nummer.
]
```

== Sozialformen und Icons

Mit dem `method`-Parameter können Sozialformen angegeben werden:

```typ
#aufgabe(method: "EA")[Einzelarbeit]
#aufgabe(method: "PA")[Partnerarbeit]
#aufgabe(method: "GA")[Gruppenarbeit]
```

#tip[
  Verfügbare Werte: `"EA"` (Einzelarbeit), `"PA"` (Partnerarbeit), `"GA"` (Gruppenarbeit).
]

Zusätzliche Icons lassen sich über den `icons`-Parameter einbinden:

```typ
#aufgabe(
  title: "Expertenaufgabe",
  icons: (emoji.lightbulb,)
)[
  Diese Aufgabe erfordert kreatives Denken!
]
```

== Teilaufgaben

Aufgaben können in Teilaufgaben untergliedert werden:

#show-example(
  rendered: {
    import "../aufgaben.typ": aufgabe, teilaufgabe
    aufgabe("Quadratische Gleichungen")[
      Löse die folgenden Gleichungen:

      #teilaufgabe[$x^2 - 5x + 6 = 0$]
      #teilaufgabe[$2x^2 + 7x - 4 = 0$]
      #teilaufgabe[$x^2 - 9 = 0$]
    ]
  },
  source: ```typ
  #aufgabe("Quadratische Gleichungen")[
    Löse die folgenden Gleichungen:

    #teilaufgabe[$x^2 - 5x + 6 = 0$]
    #teilaufgabe[$2x^2 + 7x - 4 = 0$]
    #teilaufgabe[$x^2 - 9 = 0$]
  ]
  ```,
  width: 14cm,
)

=== Nummerierung von Teilaufgaben

```typ
// Buchstaben: a), b), c)... (Standard)
#set-options((teilaufgabe-numbering: "a)"))

// Dezimal: 1.1, 1.2, 1.3...
#set-options((teilaufgabe-numbering: "1."))
```

=== Benutzerdefinierte Beschriftung

```typ
#teilaufgabe(item-label: "i)")[Erste spezielle Teilaufgabe]
#teilaufgabe(item-label: "ii)")[Zweite spezielle Teilaufgabe]
```

=== Labels für Referenzen

```typ
#aufgabe[
  #teilaufgabe(label: <teilaufg-a>)[
    Berechne den Wert von x.
  ]
]

Siehe @teilaufg-a für die erste Teilaufgabe.
```

== Arbeitsbereich (Workspace)

Aufgaben und Teilaufgaben können Arbeitsbereiche für Schülerantworten enthalten:

```typ
#aufgabe(workspace: v(3cm))[
  Löse die Gleichung: $3x + 7 = 22$
]

#teilaufgabe(workspace: rect(width: 100%, height: 4cm))[
  Zeichne ein Koordinatensystem.
]
```

Die Option `workspaces` steuert, ob Arbeitsbereiche angezeigt werden:

```typ
#set-options((workspaces: true))   // Aktivieren (Standard)
#set-options((workspaces: false))  // Deaktivieren
```

= Lösungen

== Lösung hinzufügen

Lösungen werden mit `loesung()` erstellt und automatisch der letzten Aufgabe zugeordnet:

```typ
#aufgabe[Berechne $7 times 8$.]
#loesung[$7 times 8 = 56$]
```

#show-example(
  rendered: {
    import "../aufgaben.typ": aufgabe, loesung, set-options
    set-options((loesungen: "sofort"))
    aufgabe[Berechne $7 times 8$.]
    loesung[$7 times 8 = 56$]
  },
  source: ```typ
  #set-options((loesungen: "sofort"))
  #aufgabe[Berechne $7 times 8$.]
  #loesung[$7 times 8 = 56$]
  ```,
  width: 14cm,
)

== Lösungen zu Teilaufgaben

```typ
#aufgabe("Berechnungen")[
  #teilaufgabe[Berechne $50 - 17$.]
  #loesung[$50 - 17 = 33$]
]
```

== Mehrere Lösungen

Eine Aufgabe kann mehrere `loesung()`-Blöcke haben -- sie werden in der Anzeige zusammengefasst.

== Anzeigemodi

```typ
#set-options((loesungen: "keine"))   // Keine Lösungen anzeigen (Standard)
#set-options((loesungen: "sofort"))  // Direkt nach der Aufgabe
#set-options((loesungen: "folgend")) // Gesammelt am Ende der Aufgabe
#set-options((loesungen: "seite"))   // Auf separater Seite (gemeinsam)
#set-options((loesungen: "seiten"))  // Jede Lösung auf eigener Seite
```

== Lösungen manuell ausgeben

```typ
#show-loesungen()
```

`show-loesungen()` wird automatisch aufgerufen, wenn `loesungen` auf `"folgend"`, `"seite"` oder `"seiten"` gesetzt ist.

= Material

== Material hinzufügen

Materialien werden mit `material()` einer Aufgabe zugeordnet:

```typ
#aufgabe("Textanalyse")[
  Analysiere den folgenden Text.
]

#material[
  "Lorem ipsum dolor sit amet..."
]
```

== Material mit Beschriftung

```typ
#material(caption: "Auszug aus 'Faust I' von Goethe")[
  "Habe nun, ach! Philosophie..."
]
```

== Material mit Label und Referenz

```typ
#material(
  caption: "Wichtige Formel",
  label: "material-energie"
)[$E = m c^2$]

Die Einstein'sche Energieformel (siehe @material-energie) zeigt...
```

Materialien erhalten automatisch die Bezeichnung M{Aufgabennr}-{Buchstabe} (z. B. M1-A, M1-B, M2-A).

== Anzeigemodi für Materialien

```typ
#set-options((materialien: "keine"))          // Keine Materialien
#set-options((materialien: "sofort"))         // Direkt nach Aufgabe
#set-options((materialien: "reingequetscht")) // Gesammelt am Ende, kein Seitenumbruch
#set-options((materialien: "seiten"))         // Separate Seiten (Standard)
```

== Materialien manuell ausgeben

```typ
#show-materialien()           // Alle Materialien
#show-materialien(curr: true) // Nur Material der letzten Aufgabe
```

= Bewertung

== Erwartungen

Erwartungen definieren, was von Schülern erwartet wird, und weisen ihnen Punkte zu.

```typ
#aufgabe("Bruchrechnung")[
  Berechne $3/4 + 1/2$.
]

#erwartung(1)[Hauptnenner ermittelt (4)]
#erwartung(1)[Brüche erweitert: $3/4 + 2/4$]
#erwartung(1)[Summe berechnet: $5/4$]
```

#show-example(
  rendered: {
    import "../aufgaben.typ": aufgabe, erwartung, show-erwartungen
    aufgabe("Bruchrechnung")[
      Berechne $3/4 + 1/2$.
    ]
    erwartung(1)[Hauptnenner ermittelt (4)]
    erwartung(1)[Brüche erweitert: $3/4 + 2/4$]
    erwartung(1)[Summe berechnet: $5/4$]
    show-erwartungen()
  },
  source: ```typ
  #aufgabe("Bruchrechnung")[
    Berechne $3/4 + 1/2$.
  ]
  #erwartung(1)[Hauptnenner ermittelt (4)]
  #erwartung(1)[Brüche erweitert: $3/4 + 2/4$]
  #erwartung(1)[Summe berechnet: $5/4$]
  #show-erwartungen()
  ```,
  width: 14cm,
)

Syntax: `#erwartung(punkte)[beschreibung]`

=== Erwartungen zu Teilaufgaben

```typ
#aufgabe("Geometrie")[
  #teilaufgabe[Berechne den Umfang eines Kreises mit $r = 5$ cm.]
  #erwartung(1)[Formel $U = 2 pi r$ angegeben]
  #erwartung(1)[Ergebnis: $U approx 31.42$ cm]

  #teilaufgabe[Berechne die Fläche.]
  #erwartung(1)[Formel $A = pi r^2$ angegeben]
  #erwartung(2)[Ergebnis: $A approx 78.54$ cm²]
]
```

=== Erwartungen ohne Punkte

```typ
#erwartung[Antwort ist nachvollziehbar begründet]
```

Ohne Punkte-Angabe wird automatisch 0 verwendet.

== Punkte anzeigen

```typ
#set-options((punkte: "keine"))        // Keine Punkte (Standard)
#set-options((punkte: "aufgaben"))     // Nur bei Aufgaben
#set-options((punkte: "teilaufgaben")) // Nur bei Teilaufgaben
#set-options((punkte: "alle"))         // Bei Aufgaben und Teilaufgaben
#set-options((punkte: "keine-summe"))  // Intelligent: bei Aufgaben ohne Teile, sonst bei Teilen
```

=== Die Option `"keine-summe"`

#tip[
  Mit `"keine-summe"` werden Punkte so angezeigt, dass keine doppelten Summen entstehen:
  - Aufgaben *ohne* Teilaufgaben: Punkte bei der Aufgabe
  - Aufgaben *mit* Teilaufgaben: Punkte nur bei den Teilaufgaben
]

== Punkte abrufen

```typ
#context [
  Aufgabe 19 hat #get-points(19) Punkte.
  Teilaufgabe 19.2 hat #get-points(19, teil: 2) Punkte.
]
```

== Erwartungshorizont

```typ
#show-erwartungen()

// Mit Optionen:
#show-erwartungen(
  grouped: false,  // Jede Erwartung einzeln (Standard)
  new-page: true,  // Auf neuer Seite
)
```

Parameter:

#table(
  columns: (auto, auto, 1fr),
  [*Parameter*], [*Standard*], [*Beschreibung*],
  [`grouped`], [`false`], [Gruppiert Erwartungen pro Teilaufgabe],
  [`new-page`], [`false`], [Startet auf einer neuen Seite],
  [`erreicht`], [`false`], [Zeigt `__ / X` statt `X` für eintragbare Punktzahlen],
)

== Bewertungstabelle

```typ
#show-bewertung()      // Mit möglichen Punkten (Standard)
#show-bewertung(false) // Ohne mögliche Punkte
#show-bewertung(none)  // Nur Zeile für erreichte Punkte
```

= Konfiguration

== Optionen setzen

Alle Optionen werden mit `set-options()` gesetzt:

```typ
#set-options((
  loesungen: "seiten",
  materialien: "sofort",
  workspaces: true,
  teilaufgabe-numbering: "a)",
  punkte: "alle",
))
```

Einzelne Optionen können separat gesetzt werden:

```typ
#set-options((loesungen: "sofort"))
#set-options((punkte: "aufgaben"))
```

== Verfügbare Optionen

#table(
  columns: (auto, auto, 1fr),
  [*Option*], [*Standard*], [*Beschreibung*],

  [`loesungen`], [`"keine"`], [Anzeigemodus: `"keine"`, `"sofort"`, `"folgend"`, `"seite"`, `"seiten"`],

  [`materialien`], [`"seiten"`], [Anzeigemodus: `"keine"`, `"sofort"`, `"reingequetscht"`, `"seiten"`],

  [`workspaces`], [`true`], [Ob Arbeitsbereiche angezeigt werden],

  [`teilaufgabe-numbering`], [`"a)"`], [Nummerierungsformat: `"a)"` oder `"1."`],

  [`punkte`], [`"keine"`], [Punkteanzeige: `"keine"`, `"aufgaben"`, `"teilaufgaben"`, `"alle"`, `"keine-summe"`],

  [`punkte-position`], [`"ende"`], [Wo Punkte erscheinen: `"ende"` oder `"rand"` (nur bei Teilaufgaben relevant)],

  [`punkte-template-aufgabe`], [_Funktion_], [Template-Funktion für Aufgabenpunkte (erhält `punkte` als Argument)],

  [`punkte-template-teilaufgabe`], [_Funktion_], [Template-Funktion für Teilaufgabenpunkte],
)

= API-Referenz

#show-module(read("../aufgaben.typ"), name: "aufgaben")
