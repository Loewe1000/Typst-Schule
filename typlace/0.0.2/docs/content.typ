#import "@schule/schuldocs:0.2.0": show-example, show-module, show-code

= Über dieses Paket

Das `typlace`-Paket erstellt *Sitzpläne für Klassenräume* aus einem einfachen Layout-String.
Tische, freie Plätze und das Lehrerpult werden als Rastergrafik dargestellt;
Schülernamen können automatisch auf die Sitzplätze verteilt werden.

Das Paket eignet sich für:

- Gedruckte Sitzpläne (A4, quer oder hoch)
- Projektion auf dem Beamer am Anfang der Stunde
- Sitzordnungen, die zu den Wünschen der Klasse passen (`sitzordnung()`)

= Layout-Syntax

Der Layout-String beschreibt den Raum *zeilenweise*. Jedes Zeichen entspricht einem Platz:

#show-code[```
X x . _    – freier Platz (unsichtbar, kein Tisch)
T          – Sitzplatz; zusammenhängende T bilden automatisch einen Gruppentisch
1-9 a-z    – Sitzplatz mit ausdrücklicher Tischzugehörigkeit (gleiches Zeichen = ein Tisch)
o O #      – Tischfläche ohne Sitzplatz
P          – Teil des Lehrerpults (alle P-Felder werden zu einem großen Block zusammengefasst)
```]

Zeilen werden durch `\n` getrennt. Unterschiedlich lange Zeilen werden automatisch
mit `X` aufgefüllt. Das Lehrerpult (`P`) kann beliebig groß und an beliebiger Stelle
im Layout stehen.

= Schnellstart

#show-example(
  rendered: {
    import "../typlace.typ": typlace
    typlace(
      "XXXXXX\nTTXXTT\nTTXXTT\nXXXXXX\nXXPPXX",
      namen: ("Anna", "Ben", "Clara", "David", "Eva", "Felix", "Greta", "Hans"),
      tisch-breite: 2cm,
      tisch-hoehe: 1.2cm,
    )
  },
  source: ```typ
#import "@schule/typlace:0.0.2": typlace

#typlace(
  "XXXXXX
   TTXXTT
   TTXXTT
   XXXXXX
   XXPPXX",
  namen: ("Anna", "Ben", "Clara", "David",
          "Eva", "Felix", "Greta", "Hans"),
  tisch-breite: 2cm,
  tisch-hoehe: 1.2cm,
)
  ```,
)

Namen werden *vor* der Rotation zeilenweise von links nach rechts, oben nach unten
auf die `T`-Felder verteilt.

= Gruppentische

Sitzplätze, die im Raster aneinandergrenzen, gehören automatisch zu einem
Gruppentisch. Wo das nicht reicht -- etwa bei Kopfplätzen, die die Längsseiten nur
diagonal berühren --, bindet ein eigenes Zeichen je Tisch die Plätze ausdrücklich
zusammen. Die Tischfläche zwischen den Plätzen zeichnet `typlace` von selbst.

#show-example(
  rendered: {
    import "../typlace.typ": typlace
    typlace(
      ".11..22.\n.11..22.\n.11..22.\n........\n33.44.55\n33.44.55\n33.44.55\n........\n...PP...",
      namen: range(30).map(i => str(i + 1)),
      tisch-breite: 1.1cm,
      tisch-hoehe: 0.7cm,
      nummern: true,
    )
  },
  source: ```typ
#typlace(
  ".11..22.
   .11..22.
   .11..22.
   ........
   33.44.55
   33.44.55
   33.44.55
   ........
   ...PP...",
  namen: range(30).map(i => str(i + 1)),
  nummern: true,
)
  ```,
)

Fünf Gruppentische zu je sechs Plätzen. `nummern: true` blendet die Platznummern
ein -- sie werden für feste Platzvorgaben gebraucht.

== Zonen im Raum

Für Sitzwünsche wie „vorne" oder „links" teilt das Paket den Raum in zwei
unabhängige Achsen: *Tiefe* (`vorne`, `mitte`, `hinten`) und *Seite* (`links`,
`mitte`, `rechts`). Beide gelten für den *Gruppentisch als Ganzes* -- ein Tisch
liegt vorne oder hinten, nicht seine einzelnen Sitzreihen.

Wo „vorne" ist, ergibt sich aus der Lage des Pults; mit `vorne: "oben"` lässt es
sich festlegen. Links und rechts sind aus *Schülersicht* gemeint: steht das Pult
unten im Layout, blickt die Klasse nach unten, und die linke Seite des Ausdrucks
ist für die Schüler rechts. Mit `perspektive: "plan"` gilt stattdessen die
Zeichenrichtung.

= Sitzordnung nach Schülerwünschen

`sitzordnung()` sucht die Verteilung, die möglichst viele Wünsche möglichst vieler
Schüler erfüllt, und liefert die fertige Namensliste für `typlace()`.

== Die Wunschliste

Eine Zeile je Schüler, Spalten mit `|` getrennt:

#show-code[```
Name|Position|Wunsch|Wunsch|Wunsch
Anna Meier|v|Ben Schulz|Clara Weiß|!Max Klein
Ben Schulz||Anna Meier
Clara Weiß|!m|Anna Meier|Ben Schulz
David Kern|hinten rechts|
```]

Spalte 2 nimmt den Sitzwunsch auf: `vorne`/`mitte`/`hinten` (`v`/`m`/`h`) für die
Tiefe und `links`/`rechts` (`l`/`r`) für die Seite, dazu `mitte-quer` für die
Quermitte. Beide Achsen sind unabhängig und lassen sich frei kombinieren --
`vorne-rechts`, `vorne rechts`, `vorne, rechts`, `vorne/rechts` und `v-r` meinen
alle dasselbe. Verneint wird mit `!` oder „nicht": `!m`, `nicht vorne`,
`vorne-!mitte`. Ab Spalte 3 stehen beliebig viele Namen; ein führendes `!` heißt
„möchte *nicht* neben dieser Person sitzen".

Die Namen müssen nicht exakt geschrieben sein -- Groß-/Kleinschreibung, eindeutige
Vornamen und Abkürzungen wie `Clara W.` werden aufgelöst. Unbekannte Namen brechen
mit einer Meldung ab.

== Plan berechnen

#show-example(
  rendered: {
    import "../typlace.typ": sitzordnung, typlace
    let layout = "11..22\n11..22\n11..22\n......\n..PP.."
    let wuensche = "Anna|l|Ben|Clara
Ben||Anna|Clara
Clara||Anna|Ben
David||Emil|Felix
Emil||David|Felix
Felix||David|Emil
Greta|r|Hanna
Hanna||Greta|!Anna"
    let plan = sitzordnung(layout, wuensche, seed: 7, qualitaet: "schnell")
    typlace(layout, namen: plan.namen, tisch-breite: 1.5cm, tisch-hoehe: 0.9cm)
  },
  source: ```typ
#let plan = sitzordnung(layout, read("wuensche.csv"), seed: 7)

#typlace(layout, namen: plan.namen)
#sitzplan-bericht(plan)
  ```,
)

`read()` verträgt ungleich lange Zeilen; Typsts `csv(..., delimiter: "|")` besteht
dagegen darauf, dass jede Zeile gleich viele Spalten hat.

Gleicher `seed` ergibt immer denselben Plan. Für Alternativvorschläge probiert man
zwei, drei Seeds durch und vergleicht die Punktzahlen aus dem Bericht.

== Feste Vorgaben

Vorgaben der Lehrkraft stehen bewusst getrennt von den Schülerwünschen -- sie
werden *hart* eingehalten:

#show-code[```typ
#sitzordnung(layout, read("wuensche.csv"), vorgaben: (
  fest: ("Ben Schulz": 3),                    // feste Platznummer
  muss-vorne: ("Eva Lang",),                  // auch muss-mitte/-hinten/-links/-rechts
  getrennt: (("Max Klein", "Moritz Groß"),),  // nie am selben Gruppentisch
  zusammen: (("Ida Berg", "Jonas Kern"),),    // immer am selben Gruppentisch
))
```]

Lassen sich die Vorgaben nicht alle gleichzeitig einhalten, bricht die Funktion mit
einer Erklärung ab, statt still eine davon zu opfern.

== Bewertung

#table(
  columns: (1fr, auto),
  inset: 5pt,
  table.header([*Kriterium*], [*Standardgewicht*]),
  [Wunschperson daneben, gegenüber oder über Eck], [`direkt: 1.0`],
  [Wunschperson am selben Tisch, aber weiter weg], [`tisch: 0.9`],
  [1., 2. und 3. Wunsch], [`raenge: (1.0, 1.0, 1.0)`],
  [1., 2. und 3. _erfüllter_ Wunsch eines Schülers], [`stufen: (1.0, 0.7, 0.45)`],
  [Bonus für „überhaupt einen Wunsch erfüllt"], [`fairness: 2.0`],
  [Abgelehnte Person am selben Tisch], [`ablehnung: -2.0`],
  [Erfüllter Positionswunsch je Achse], [`position: 0.5`],
  [Gemiedene Zone doch zugeteilt], [`position-meidet: -0.5`],
)

Zwei Werte sorgen für eine gleichmäßige Verteilung. Der Fairness-Bonus greift an
der Schwelle „mindestens ein Wunsch": ohne ihn maximiert das Verfahren die reine
Wunschsumme und setzt lieber wenige Cliquen vollständig zusammen, während andere
leer ausgehen. Die Stufen wirken oberhalb dieser Schwelle: weil der zweite
erfüllte Wunsch eines Kindes weniger zählt als sein erster, ist „alle bekommen
zwei von drei" mehr wert als „die einen drei, die anderen einen".

Eine Streuungs- oder Minimum-Formel wäre der naheliegende Alternativweg, koppelt
aber alle Schüler miteinander -- ein Platztausch ließe sich dann nicht mehr
örtlich bewerten, und genau das macht die Suche schnell. Fallende Stufen bleiben
pro Schüler rechenbar. `stufen: (1.0, 1.0, 1.0)` schaltet sie ab.

Wie es ausgegangen ist, zeigt `sitzplan-bericht` als Kreuztabelle -- eine Reihe je
Anzahl *genannter* Wünsche, darin die Kinder nach Anzahl *erfüllter*, damit sich
„drei von drei" und „einer von einem" nicht vermischen:

#show-code[```
        davon erfüllt:  0   1   2   3
 1 Wunsch genannt       ·   1
2 Wünsche genannt       ·   2   ·
3 Wünsche genannt       ·   3  11  10
```]

Dieselben Zahlen liegen in `statistik.verteilung`: Schlüssel ist die Anzahl
genannter Wünsche, Wert ein Array mit der Anzahl erfüllter Wünsche als Index. Einzelne Gewichte lassen sich über `gewichte: (position: 1.5)`
ändern.

Statt einzelne Gewichte zu verstellen, lässt sich direkt angeben, welchen Anteil
die Sitzwünsche im Raum an den erreichbaren Punkten haben sollen -- das Gewicht
wird dann aus der tatsächlichen Klasse berechnet:

#show-code[```typ
#sitzordnung(layout, read("wuensche.csv"), position-anteil: 15%)
```]

`0%` ignoriert vorne/hinten/links/rechts vollständig, `50%` stellt beide Seiten
gleich. Wie es ausgegangen ist, steht im Bericht unter
`statistik.punkte-aus-wuenschen` und `statistik.punkte-aus-position`.

Positionswünsche wiegen in der Voreinstellung bewusst leicht. Da eine Zone dem ganzen Gruppentisch gilt,
konkurriert „ich möchte vorne sitzen" direkt mit „ich möchte neben meinen Freunden
sitzen" -- ein höheres Gewicht kostet erfahrungsgemäß mehrere soziale Wünsche und
erfüllt kaum zusätzliche Positionswünsche.

== Rechenkern

Die Suche läuft standardmäßig in einem mitgelieferten WASM-Plugin
(`optimierer.wasm`, Rust-Quelltext unter `rust/`, neu bauen mit `rust/bauen.sh`).
Es ist eine 1:1-Übertragung von `optimierer.typ` -- gleicher Zufallsgenerator,
gleiche Reihenfolge der Tausche, gleiche Reihenfolge der Additionen. Bei
gleichem `seed` kommt in beiden Fassungen derselbe Plan heraus.

#table(
  columns: 3,
  inset: 5pt,
  table.header([], [*20 Startpläne*], [*2000 Startpläne*]),
  [`motor: "typst"`], [12,0 s], [rund 20 min],
  [`motor: "wasm"`], [0,22 s], [14,3 s],
)

Nach jedem Aufruf rechnet Typst die gelieferte Sitzordnung selbst nach. Weichen
die Punktzahlen ab, bricht das Paket ab, statt still ein falsches Ergebnis zu
setzen -- so kann die Schnittstelle zwischen beiden Fassungen nicht unbemerkt
auseinanderlaufen.

Weil Rechenzeit damit billig ist, sind die Voreinstellungen von `qualitaet` beim
WASM-Kern viel großzügiger (50, 300 und 2000 Startpläne statt 6, 12 und 30).
`motor: "typst"` bleibt als lesbare Referenz erhalten.

== Wie gesucht wird

Das Verfahren erzeugt mehrere zufällige, aber zulässige Startpläne und verbessert
jeden durch Platztausche, solange das Punkte bringt; bewertet wird dabei nur die
Differenz eines Tauschs. Der beste Plan gewinnt. `qualitaet` steuert den Aufwand
(`"schnell"`, `"normal"`, `"gruendlich"`), `versuche` und `max-schritte`
überschreiben ihn direkt.

= Varianten

== Rotation

Der gesamte Sitzplan kann um 0°, 90°, 180° oder 270° (jeweils im Uhrzeigersinn) gedreht werden.
Das ist nützlich, wenn der Eingang an einer anderen Seite des Raumes liegt:

#show-code[```typ
#typlace(
  "XXXXXX
   TTXXTT
   TTXXTT
   XXXXXX
   XXPPXX",
  namen: ("Anna", "Ben", "Clara", "David",
          "Eva", "Felix", "Greta", "Hans"),
  rotation: 180,   // Pult unten → Pult oben nach Rotation
)
```]

== Farben anpassen

Tisch- und Pultfarbe können frei gewählt werden:

#show-code[```typ
#typlace(
  "TTXTT
   TTXTT
   XXXXX
   XXPXX",
  namen: ("Anna", "Ben", "Clara", "David", "Eva", "Felix", "Greta"),
  tisch-farbe: rgb("#d4edda"),    // Hellgrün
  pult-farbe:  rgb("#856404"),    // Dunkelbraun
)
```]

== Großes Klassenzimmer

Für größere Klassen einfach das Layout erweitern:

#show-code[```typ
#typlace(
  "TTTTTTTT
   TTTTTTTT
   TTTTTTTT
   XXXXXXXX
   XXXPPXXX",
  namen: range(24).map(i => "Schüler " + str(i + 1)),
  tisch-breite: 1.8cm,
  tisch-hoehe: 1cm,
)
```]

= Parameter

#show-code[```typ
#typlace(
  layout,               // str: Layoutstring (X, T, 1-9/a-z, o, P)
  namen: (),            // array: Namen für die Sitzplätze
  tisch-breite: 2cm,    // length: Breite eines Tischfeldes
  tisch-hoehe: 1.2cm,   // length: Höhe eines Tischfeldes
  tisch-farbe: rgb("#cce0f5"),   // color: Füllfarbe der Sitzplätze
  pult-farbe:  rgb("#6b4c2a"),   // color: Füllfarbe des Lehrerpults
  koerper-farbe: auto,  // auto | color | none: Tischfläche
  nummern: false,       // bool: Platznummern anzeigen
  rotation: 0,          // int: 0, 90, 180 oder 270 im Uhrzeigersinn
)

#sitzordnung(
  layout,               // str: Layoutstring
  schueler,             // str | array | dictionary: Wunschliste
  vorgaben: (:),        // dictionary: fest, muss-vorne, muss-mitte,
                        //   muss-hinten, muss-links, muss-rechts,
                        //   getrennt, zusammen
  gewichte: (:),        // dictionary: geänderte Gewichte
  position-anteil: auto,  // auto | ratio: Anteil der Sitzwünsche im Raum
  seed: 42,             // int: Startwert des Zufalls
  qualitaet: "normal",  // str: "schnell" | "normal" | "gruendlich"
  versuche: auto,       // auto | int: Anzahl Startpläne
  max-schritte: auto,   // auto | int: Schritte je Versuch
  vorne: auto,          // auto | "oben" | "unten" | "links" | "rechts"
  motor: "wasm",        // str: "wasm" (Plugin) | "typst" (Referenz)
  perspektive: "schueler",  // str: "schueler" | "plan"
  streng: true,         // bool: unbekannte Namen = Fehler
)
```]

= API-Referenz

#show-module(read("../typlace.typ"), name: "typlace")

#show-module(read("../optimierer.typ"), name: "optimierer")

#show-module(read("../daten.typ"), name: "daten")

#show-module(read("../bewertung.typ"), name: "bewertung")

#show-module(read("../geometrie.typ"), name: "geometrie")

#show-module(read("../bericht.typ"), name: "bericht")
