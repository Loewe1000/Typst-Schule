#import "@preview/mantys:1.0.2": *
#import "../aufgaben.typ" as auf

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
    imports: (aufgaben: "*"),
  ),
)

#set text(lang: "de")

= Über dieses Paket

Das #package[aufgaben] Paket ist das Fundament des Schule-Paket-Ökosystems. Es bietet alle grundlegenden Funktionen zur Strukturierung und Verwaltung von Aufgaben in Bildungsdokumenten.

Dieses Manual gliedert sich wie folgt:
1. *Installation und Import* -- Erste Schritte
2. *Aufgabenverwaltung* -- Erstellen von Aufgaben und Teilaufgaben
3. *Lösungen* -- Verwaltung von Musterlösungen
4. *Material* -- Einbinden von Zusatzmaterialien
5. *Bewertung* -- Punkte und Erwartungshorizonte
6. *Konfiguration* -- Anpassung des Verhaltens
7. *Funktionsreferenz* -- Vollständige API-Dokumentation

= Installation und Import

== Paket importieren

Das Paket kann einfach importiert werden:

#sourcecode[```typ
#import "@schule/aufgaben:0.1.2": *
```]

== Abhängigkeiten

Das Paket importiert automatisch:
- #package[fontawesome] (Icons)
- #package[gentle-clues] (Info-Boxen für Lösungen)

= Aufgabenverwaltung

== Grundlagen

=== Einfache Aufgabe

Die `aufgabe()` Funktion erstellt eine nummerierte Aufgabe:

#example[```typ
#import "@schule/aufgaben:0.1.2": *

#aufgabe[
  Berechne die Summe von 15 und 27.
]
```]

Aufgaben werden automatisch nummeriert (1, 2, 3, ...).

=== Aufgabe mit Titel

Aufgaben können einen Titel erhalten:

#example[```typ
#aufgabe(title: [Addition])[
  Berechne die Summe von 15 und 27.
]

// Alternativ als Positionsargument:
#aufgabe[Addition][
  Berechne die Summe von 15 und 27.
]
```]

Die Nummer und der Titel werden in Fettschrift angezeigt.

#pagebreak(weak: true)

=== Aufgabengröße

Mit dem `large` Parameter kann die Größe der Überschrift gesteuert werden:

#example[```typ
#aufgabe(title: "Hauptaufgabe", large: true)[
  Große Überschrift (1.25em)
]

#aufgabe(title: "Unteraufgabe", large: false)[
  Normale Überschrift (1em)
]
```]

Standard ist `large: true`.

=== Nummerierung

Die Nummerierung kann deaktiviert werden:

#example[```typ
#aufgabe(title: "Bonusaufgabe", number: false)[
  Diese Aufgabe hat keine Nummer.
]
```]
#pagebreak(weak: true)
== Methodenangabe und Icons

=== Sozialformen

Mit dem `method` Parameter können Sozialformen angegeben werden:

#example[```typ
#aufgabe(method: "EA")[
  Einzelarbeit - Bearbeite diese Aufgabe alleine.
]

#aufgabe(method: "PA")[
  Partnerarbeit - Arbeite mit einem Partner.
]

#aufgabe(method: "GA")[
  Gruppenarbeit - Bildet Gruppen von 3-4 Personen.
]
```]

Verfügbare Werte:
- `"EA"` -- Einzelarbeit (zeigt #emoji.person Icon)
- `"PA"` -- Partnerarbeit (zeigt Personen-Gruppe Icon)
- `"GA"` -- Gruppenarbeit (zeigt größere Gruppe Icon)
#pagebreak(weak: true)
=== Benutzerdefinierte Icons

Zusätzliche Icons können mit dem `icons` Parameter hinzugefügt werden:

#example[```typ
#aufgabe(
  title: "Expertenaufgabe",
  icons: (emoji.lightbulb,)
)[
  Diese Aufgabe erfordert kreatives Denken!
]
```]

== Teilaufgaben

Aufgaben können in Teilaufgaben untergliedert werden:

#example[```typ
#aufgabe("Quadratische Gleichungen")[
  Löse die folgenden quadratischen Gleichungen:

  #teilaufgabe[
    $x^2 - 5x + 6 = 0$
  ]

  #teilaufgabe[
    $2x^2 + 7x - 4 = 0$
  ]

  #teilaufgabe[
    $x^2 - 9 = 0$
  ]
]
```]
#pagebreak(weak: true)
=== Nummerierung von Teilaufgaben

Die Nummerierung kann auf zwei Arten erfolgen:

#example[```typ
// Buchstaben: a), b), c)... (Standard)
#set-options((teilaufgabe-numbering: "a)"))

// Dezimal: 1.1, 1.2, 1.3...
#set-options((teilaufgabe-numbering: "1."))
```]

=== Benutzerdefinierte Beschriftung

Für einzelne Teilaufgaben kann eine eigene Beschriftung vergeben werden:

#example[```typ
#teilaufgabe(item-label: "i)")[
  Erste spezielle Teilaufgabe
]

#teilaufgabe(item-label: "ii)")[
  Zweite spezielle Teilaufgabe
]
```]

=== Labels für Referenzen

Teilaufgaben können mit Labels versehen werden:

#example[```typ
#aufgabe[
  #teilaufgabe(label: <teilaufg-a>)[
    Berechne den Wert von x.
  ]
]

Siehe @teilaufg-a für die erste Teilaufgabe.
```]
#pagebreak(weak: true)
== Arbeitsbereich (Workspace)

Aufgaben und Teilaufgaben können Arbeitsbereiche für Schülerantworten enthalten:

#example[```typ
#aufgabe(workspace: v(3cm))[
  Löse die Gleichung: $3x + 7 = 22$
]

#teilaufgabe(workspace: rect(width: 100%, height: 4cm))[
  Zeichne ein Koordinatensystem.
]
```]

Arbeitsbereiche werden nur angezeigt, wenn die Option `workspaces: true` gesetzt ist:

#example[```typ
#set-options((workspaces: true))  // Aktivieren
#set-options((workspaces: false)) // Deaktivieren
```]

Standard ist `workspaces: true`.

= Lösungen

== Lösungen hinzufügen

Lösungen werden mit der `loesung()` Funktion erstellt:

#example[```typ
#aufgabe[
  Berechne $7 times 8$.
]

#loesung[
  $7 times 8 = 56$
]
```]

Die Lösung wird automatisch der zuletzt definierten Aufgabe zugeordnet.

== Lösungen zu Teilaufgaben

Lösungen können auch Teilaufgaben zugeordnet werden:

#example[```typ
#aufgabe("Berechnungen")[
  #teilaufgabe[
    Berechne $50 - 17$.
  ]
  #loesung[
    $50 - 17 = 33$
  ]
]
```]

Die `loesung()` Funktion erkennt automatisch, ob sie zu einer Aufgabe oder Teilaufgabe gehört.

== Mehrere Lösungen

Eine Aufgabe kann mehrere Lösungsblöcke haben:

#example[```typ
#aufgabe[
  Erkläre den Wasserkreislauf.
]

#loesung[
  *Verdunstung:* Wasser verdunstet durch Sonneneinstrahlung.
]

#loesung[
  *Kondensation:* Wasserdampf steigt auf und kondensiert zu Wolken.
]

#loesung[
  *Niederschlag:* Wasser fällt als Regen zurück zur Erde.
]
```]

Alle Lösungsblöcke werden in der Lösungsanzeige zusammengefasst.

== Anzeigemodi für Lösungen

Lösungen können auf verschiedene Arten angezeigt werden:

#example[```typ
#set-options((loesungen: "keine"))   // Keine Lösungen anzeigen
#set-options((loesungen: "sofort"))  // Direkt nach der Aufgabe
#set-options((loesungen: "folgend")) // Alle Lösungen gesammelt
#set-options((loesungen: "seiten"))  // Jede Lösung auf neuer Seite
```]

Verfügbare Modi:
- `"keine"` -- Lösungen werden nicht angezeigt (Standard)
- `"sofort"` -- Lösungen erscheinen direkt nach jeder Teilaufgabe
- `"folgend"` -- Alle Lösungen werden am Ende jeder Aufgabe angezeigt
- `"seite"` -- Alle Lösungen werden auf einer separaten Seite angezeigt
- `"seiten"` -- Jede Lösung wird auf einer separaten Seite angezeigt
#pagebreak(weak: true)
== Lösungen manuell anzeigen

Lösungen können auch manuell ausgegeben werden:

#sourcecode[```typ
// Alle Lösungen anzeigen
#show-loesungen()
```]

Die Funktion `show-loesungen()` wird automatisch aufgerufen, wenn `loesungen` auf `"folgend"`, `"seite"` oder `"seiten"` gesetzt ist.

= Material

== Material hinzufügen

Materialien werden Aufgaben mit der `material()` Funktion zugeordnet:

#example[```typ
#aufgabe("Textanalyse")[
  Analysiere den folgenden Text.
]

#material[
  "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
]
```]

Material wird automatisch der aktuellen Aufgabe zugeordnet.

== Material mit Beschriftung

#example[```typ
#material(
  caption: "Auszug aus 'Faust I' von Goethe"
)[
  "Habe nun, ach! Philosophie,
  Juristerei und Medizin,
  Und leider auch Theologie
]
```]
Die Beschriftung wird unter dem Material angezeigt.

== Material mit Label

Materialien können mit Labels versehen und referenziert werden:

#sourcecode[```typ
#material(
  caption: "Wichtige Formel",
  label: "material-energie"
)[
  $E = m c^2$
]

Die Einstein'sche Energieformel (siehe @material-energie) zeigt...
```]

Materialien werden automatisch mit "M" + Aufgabennummer + "-" + Buchstabe bezeichnet (z.B. M1-A, M1-B, M2-A).

== Anzeigemodi für Materialien

#sourcecode[```typ
#set-options((materialien: "keine"))   // Keine Materialien
#set-options((materialien: "sofort"))  // Direkt nach Aufgabe
#set-options((materialien: "folgend")) // Gesammelt am Ende
#set-options((materialien: "seiten"))  // Separate Seiten (Standard)
```]

Verfügbare Modi:
- `"keine"` -- Materialien werden nicht angezeigt
- `"sofort"` -- Materialien erscheinen direkt nach der Aufgabe
- `"reingequetscht"` -- Alle Materialien werden am Ende direkt nach den Aufgaben ohne Seitenumbruch gesammelt
- `"seiten"` -- Das Material jeder Aufgabe auf einer separaten Seite (Standard)

== Materialien manuell anzeigen

#sourcecode[```typ
// Alle Materialien anzeigen
#show-materialien()

// Nur Material der letzten Aufgabe
#show-materialien(curr: true)
```]

= Bewertung

== Erwartungen

Erwartungen definieren, was von Schülern erwartet wird, und ordnen diesen Erwartungen Punkte zu.

=== Erwartung erstellen

#example[```typ
#aufgabe("Bruchrechnung")[
  Berechne $3/4 + 1/2$.
]

#erwartung(1)[
  Hauptnenner ermittelt (4)
]

#erwartung(1)[
  Brüche erweitert: $3/4 + 2/4$
]

#erwartung(1)[
  Summe berechnet: $5/4$
]
```]

Die Syntax ist: `#erwartung(punkte)[beschreibung]`

#pagebreak(weak: true)
=== Erwartungen zu Teilaufgaben

Erwartungen werden automatisch der aktuellen Teilaufgabe zugeordnet:

#example[```typ
#aufgabe("Geometrie")[
  #teilaufgabe[
    Berechne den Umfang eines Kreises mit $r = 5 "cm"$.
  ]
  #erwartung(1)[Formel $U = 2 pi r$ angegeben]
  #erwartung(1)[Ergebnis: $U approx 31.42 "cm"$]

  #teilaufgabe[
    Berechne die Fläche.
  ]
  #erwartung(1)[Formel $A = pi r^2$ angegeben]
  #erwartung(2)[Ergebnis: $A approx 78.54 "cm"^2$]
]
```]

=== Erwartungen ohne Punkte

Erwartungen können auch ohne Punkte definiert werden (z.B. für qualitative Bewertungen):

#example[```typ
#erwartung[
  Antwort ist nachvollziehbar begründet
]
```]

Ohne Punkte-Angabe wird automatisch 0 verwendet.

== Punkte anzeigen

Das Anzeigen von Punkten kann konfiguriert werden:

#sourcecode[```typ
#set-options((punkte: "keine"))        // Keine Punkte anzeigen
#set-options((punkte: "aufgaben"))     // Nur bei Aufgaben
#set-options((punkte: "teilaufgaben")) // Nur bei Teilaufgaben
#set-options((punkte: "alle"))         // Bei Aufgaben und Teilaufgaben
```]

Wenn Punkte angezeigt werden, erscheinen sie rechts neben der Aufgabe/Teilaufgabe mit dem Format "X BE" (Bewertungseinheiten).

== Punkte abrufen

Die Funktion `get-points()` ermöglicht das Abrufen von Punktzahlen:

#example[```typ
#context [
  Aufgabe 19 hat #get-points(19) Punkte.

  Teilaufgabe 19.2 hat #get-points(19, teil: 2) Punkte.
]
```]

== Erwartungshorizont

Der Erwartungshorizont ist eine tabellarische Übersicht aller Erwartungen mit Punkten.

=== Erwartungshorizont anzeigen

#sourcecode[```typ
#show-erwartungen()

// Mit Optionen:
#show-erwartungen(
  grouped: false,  // Jede Erwartung einzeln (Standard)
  new-page: true,  // Auf neuer Seite
)
```]

Der Erwartungshorizont zeigt:
- Aufgabennummer
- Teilaufgabennummer (falls vorhanden)
- Erwartungstext
- Punktzahl
- Gesamtsumme aller Punkte
#pagebreak(weak: true)
=== Gruppierter Erwartungshorizont

Mit `grouped: true` werden Erwartungen pro Teilaufgabe zusammengefasst:

#example[```typ
#show-erwartungen(grouped: true)
```]

Dies ist übersichtlicher, wenn viele Erwartungen pro Teilaufgabe vorhanden sind.
#pagebreak(weak: true)
== Bewertungstabelle

Die Bewertungstabelle ist für Schüler gedacht, um erreichte Punkte einzutragen.

#sourcecode[```typ
#show-bewertung()

// Optionen:
#show-bewertung(true)   // Mit möglichen Punkten (Standard)
#show-bewertung(false)  // Ohne mögliche Punkte
#show-bewertung(none)   // Nur erreichte Punkte-Zeile
```]

Die Tabelle zeigt:
- Aufgabennummern
- Teilaufgaben (falls vorhanden)
- Mögliche Punkte (optional)
- Felder zum Eintragen der erreichten Punkte
- Gesamtsumme
#pagebreak(weak: true)
= Konfiguration

== Optionen setzen

Alle Optionen werden mit `set-options()` gesetzt:

#example[```typ
#set-options((
  loesungen: "seiten",
  materialien: "sofort",
  workspaces: true,
  teilaufgabe-numbering: "a)",
  punkte: "alle",
))
```]

Optionen können auch einzeln gesetzt werden:

#example[```typ
#set-options((loesungen: "sofort"))
#set-options((punkte: "aufgaben"))
```]

== Verfügbare Optionen

#table(
  columns: (auto, auto, 1fr),
  align: (left, left, left),
  [*Option*], [*Standard*], [*Beschreibung*],

  [`loesungen`], [`"keine"`], [Anzeigemodus für Lösungen: `"keine"`, `"sofort"`, `"folgend"`, `"seite"`, `"seiten"`],

  [`materialien`], [`"seiten"`], [Anzeigemodus für Materialien: `"keine"`, `"sofort"`, `"reingequetscht"`, `"seiten"`],

  [`workspaces`], [`true`], [Ob Arbeitsbereiche angezeigt werden],

  [`teilaufgabe-numbering`], [`"a)"`], [Nummerierungsformat: `"a)"` oder `"1."`],

  [`punkte`], [`"keine"`], [Punkteanzeige: `"keine"`, `"aufgaben"`, `"teilaufgaben"`, `"alle"`],
)

= Funktionsreferenz

== Hauptfunktionen

#command("aufgabe", arg(title: none), arg(method: ""), arg(icons: ()), arg(large: true), arg(number: true), arg(workspace: none), arg(label: none), arg[body])[

  #argument("title", types: (none, "content"), default: none)[
    Titel der Aufgabe. Kann auch als erstes Positionsargument übergeben werden.
  ]

  #argument("method", types: "string", default: "")[
    Sozialform: `"EA"` (Einzelarbeit), `"PA"` (Partnerarbeit), oder `"GA"` (Gruppenarbeit).
  ]

  #argument("icons", types: "array", default: ())[
    Array mit zusätzlichen Icons (z.B. FontAwesome-Icons).
  ]

  #argument("large", types: "boolean", default: true)[
    Wenn `true`, wird die Überschrift größer dargestellt (1.25em statt 1em).
  ]

  #argument("number", types: "boolean", default: true)[
    Wenn `false`, wird keine Aufgabennummer angezeigt.
  ]

  #argument("workspace", types: (none, "content"), default: none)[
    Arbeitsbereich für Schülerantworten (z.B. `v(3cm)` oder ein Grid).
  ]

  #argument("label", types: (none, "label", "string"), default: none)[
    Label zur Referenzierung der Aufgabe.
  ]

  #argument("body", types: "content")[
    Inhalt der Aufgabe.
  ]
]

#command("teilaufgabe", arg(item-label: none), arg(label: none), arg(workspace: none), arg[body])[
  Erstellt eine Teilaufgabe innerhalb einer Aufgabe.

  #argument("item-label", types: (none, "content"), default: none)[
    Benutzerdefinierte Beschriftung statt automatischer Nummerierung.
  ]

  #argument("label", types: (none, "label", "string"), default: none)[
    Label zur Referenzierung der Teilaufgabe.
  ]

  #argument("workspace", types: (none, "content"), default: none)[
    Arbeitsbereich für diese Teilaufgabe.
  ]

  #argument("body", types: "content")[
    Inhalt der Teilaufgabe.
  ]
]

#command("loesung", arg[body])[
  Fügt eine Lösung zur aktuellen Aufgabe oder Teilaufgabe hinzu.

  #argument("body", types: "content")[
    Inhalt der Lösung.
  ]

  Die Lösung wird automatisch der zuletzt erstellten Aufgabe oder Teilaufgabe zugeordnet.
]

#command("erwartung", arg[punkte], arg[body])[
  Definiert eine Erwartung mit Punktzahl für die aktuelle Aufgabe oder Teilaufgabe.

  #argument("punkte", types: ("integer", none), default: 0)[
    Anzahl der Punkte für diese Erwartung. Kann weggelassen werden für 0 Punkte.
  ]

  #argument("body", types: "content")[
    Beschreibung der Erwartung.
  ]

  Erwartungen werden automatisch der aktuellen Aufgabe oder Teilaufgabe zugeordnet.
]

#command("material", arg[body], arg(caption: none), arg(label: none))[
  Fügt Material zur aktuellen Aufgabe hinzu.

  #argument("body", types: "content")[
    Inhalt des Materials.
  ]

  #argument("caption", types: (none, "content"), default: none)[
    Beschriftung für das Material.
  ]

  #argument("label", types: (none, "label"), default: none)[
    Label zur Referenzierung des Materials.
  ]

  Material wird automatisch mit M{Aufgabennr}-{Buchstabe} bezeichnet.
]
#pagebreak(weak: true)
== Anzeigefunktionen

#command("show-loesungen", arg(curr: false), arg(teil: false))[
  Zeigt Lösungen an.

  #argument("curr", types: "boolean", default: false)[
    Wenn `true`, nur Lösung der letzten Aufgabe anzeigen.
  ]

  #argument("teil", types: ("boolean", "integer"), default: false)[
    Wenn eine Zahl, nur Lösungen dieser Teilaufgabe anzeigen.
  ]
]

#command("show-materialien", arg(curr: false))[
  Zeigt Materialien an.

  #argument("curr", types: "boolean", default: false)[
    Wenn `true`, nur Material der letzten Aufgabe anzeigen.
  ]
]

#command("show-erwartungen", arg(grouped: false), arg(new-page: false))[
  Zeigt den Erwartungshorizont als Tabelle an.

  #argument("grouped", types: "boolean", default: false)[
    Wenn `true`, werden Erwartungen pro Teilaufgabe gruppiert dargestellt.
  ]

  #argument("new-page", types: "boolean", default: false)[
    Wenn `true`, wird der Erwartungshorizont auf einer neuen Seite angezeigt.
  ]
]

#command("show-bewertung", sarg[punkte])[
  Zeigt eine Bewertungstabelle für Schüler an.

  #argument("punkte", types: ("boolean", none), default: true)[
    - `true`: Zeigt mögliche Punkte an
    - `false`: Zeigt leere Felder für mögliche Punkte
    - `none`: Zeigt keine Zeile für mögliche Punkte
  ]

  Die Tabelle enthält Spalten für alle Aufgaben, Teilaufgaben und erreichte Punkte.
]
#pagebreak(weak: true)
== Hilfsfunktionen

#command("set-options", arg[options])[
  Setzt Optionen für die Aufgabenverwaltung.

  #argument("options", types: "dictionary")[
    Dictionary mit Optionen. Verfügbare Schlüssel:
    - `loesungen`: `"keine"`, `"sofort"`, `"folgend"`, `"seiten"`
    - `materialien`: `"keine"`, `"sofort"`, `"folgend"`, `"seiten"`
    - `workspaces`: `true` oder `false`
    - `teilaufgabe-numbering`: `"a)"` oder `"1."`
    - `punkte`: `"keine"`, `"aufgaben"`, `"teilaufgaben"`, `"alle"`
  ]
]

#command("get-points", arg[aufgabe], arg(teil: none))[
  Gibt die Gesamtpunktzahl einer Aufgabe oder Teilaufgabe zurück.

  #argument("aufgabe", types: ("integer", none))[
    Nummer der Aufgabe (1-basiert).
  ]

  #argument("teil", types: (none, "integer"), default: none)[
    Nummer der Teilaufgabe (1-basiert). Wenn `none`, werden alle Punkte der Aufgabe zurückgegeben.
  ]

  Muss in einem `context`-Block verwendet werden, da auf finale Zustände zugegriffen wird.
]
#pagebreak(weak: true)
= Beispiele

== Komplettes Beispiel

#example(breakable: true)[```typ
#import "@schule/aufgaben:0.1.2": *

#set-options((
  loesungen: "folgend",
  materialien: "seiten",
  punkte: "alle",
  teilaufgabe-numbering: "a)",
))

#aufgabe("Funktionen untersuchen")[
  Gegeben ist die Funktion $f(x) = x^2 - 4x + 3$.

  #teilaufgabe[
    Bestimme die Nullstellen von $f$.
  ]
  #erwartung(1)[Ansatz mit Mitternachtsformel oder Faktorisierung]
  #erwartung(2)[Berechnung der Nullstellen $x_1 = 1$, $x_2 = 3$]
  #loesung[
    Mit der Mitternachtsformel:
    $x_(1,2) = (4 plus.minus sqrt(16-12))/2 = (4 plus.minus 2)/2$

    Also: $x_1 = 1$ und $x_2 = 3$
  ]

  #teilaufgabe[
    Bestimme den Scheitelpunkt.
  ]
  #erwartung(1)[Formel für x-Koordinate: $x_s = -b/(2a)$]
  #erwartung(1)[Berechnung: $x_s = 2$]
  #erwartung(1)[Berechnung: $y_s = f(2) = -1$]
  #loesung[
    $x_s = -(-4)/(2 dot 1) = 2$

    $y_s = 2^2 - 4 dot 2 + 3 = 4 - 8 + 3 = -1$

    Scheitelpunkt: $S(2|-1)$
  ]
]

#aufgabe("Kurvendiskussion", method: "PA")[
  Untersuche die Funktion aus Aufgabe 1 vollständig.
]

#material(
  caption: "Hilfsmittel: Ableitungsregeln",
  label: <ableitungen>
)[
  - Potenzregel: $(x^n)' = n x^(n-1)$
  - Konstantenregel: $(c)' = 0$
  - Summenregel: $(f+g)' = f' + g'$
]

// Lösungen und Erwartungen werden automatisch am Ende angezeigt
```]

== Arbeiten ohne Arbeitsblatt-Paket

Das aufgaben-Paket kann auch eigenständig verwendet werden:

#sourcecode(breakable: true)[```typ
#import "@schule/aufgaben:0.1.2": *

#set text(font: "Linux Libertine", size: 11pt)

#set-options((
  punkte: "aufgaben",
  teilaufgabe-numbering: "1.",
))

= Übungsblatt Mathematik

#aufgabe("Bruchrechnung")[
  #teilaufgabe[
    Berechne: $1/2 + 1/3$
  ]
  #erwartung(2)[Richtiges Ergebnis: $5/6$]

  #teilaufgabe[
    Berechne: $3/4 - 1/6$
  ]
  #erwartung(2)[Richtiges Ergebnis: $7/12$]
]

#aufgabe("Prozentrechnung")[
  Ein Artikel kostet 80€. Er wird um 15% reduziert.
  Wie viel kostet er jetzt?
]
#erwartung(1)[Berechnung der 15%: 12€]
#erwartung(1)[Neuer Preis: 68€]

#pagebreak()

#show-erwartungen()
```]

#pagebreak(weak: true)

= Kombination mit anderen Paketen

Das aufgaben-Paket wird von anderen Paketen verwendet:
- #package[arbeitsblatt] -- Für Arbeitsblätter mit Formatierung
- #package[klassenarbeit] -- Für Klassenarbeiten mit Deckblatt

Sie können aber auch eigene Templates erstellen, die aufgaben verwenden.

= Zusammenfassung

Das #package[aufgaben] Paket bietet:

- ✓ Strukturierte Aufgabenverwaltung mit Nummerierung
- ✓ Teilaufgaben mit flexibler Nummerierung
- ✓ Lösungsverwaltung mit mehreren Anzeigemodi
- ✓ Materialverwaltung mit Referenzierung
- ✓ Erwartungshorizonte und Punktevergabe
- ✓ Bewertungstabellen
- ✓ Flexible Konfiguration
- ✓ Verwendbar als Basis für eigene Dokumenttypen

Es ist ideal als Grundlage für Bildungsdokumente oder zur direkten Verwendung in einfachen Übungsblättern.
