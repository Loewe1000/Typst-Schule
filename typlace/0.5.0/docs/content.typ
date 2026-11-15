#import "@schule/schuldocs:0.3.1": show-code, show-example, show-module

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
    import "../src/lib.typ": typlace
    typlace(
      "XXXXXX\nTTXXTT\nTTXXTT\nXXXXXX\nXXPPXX",
      names: ("Anna", "Ben", "Clara", "David", "Eva", "Felix", "Greta", "Hans"),
      cell-width: 2cm,
      cell-height: 1.2cm,
    )
  },
  source: ```typ
#import "@schule/typlace:0.5.0": typlace

#typlace(
  "XXXXXX
   TTXXTT
   TTXXTT
   XXXXXX
   XXPPXX",
  names: ("Anna", "Ben", "Clara", "David",
          "Eva", "Felix", "Greta", "Hans"),
  cell-width: 2cm,
  cell-height: 1.2cm,
)
  ```,
)

Namen werden *vor* der Drehung zeilenweise von links nach rechts, oben nach unten
auf die `T`-Felder verteilt.

= Gruppentische

Sitzplätze, die im Raster aneinandergrenzen, gehören automatisch zu einem
Gruppentisch. Wo das nicht reicht -- etwa bei Kopfplätzen, die die Längsseiten nur
diagonal berühren --, bindet ein eigenes Zeichen je Tisch die Plätze ausdrücklich
zusammen. Die Tischfläche zwischen den Plätzen zeichnet `typlace` von selbst.

#show-example(
  rendered: {
    import "../src/lib.typ": typlace
    typlace(
      ".11..22.\n.11..22.\n.11..22.\n........\n33.44.55\n33.44.55\n33.44.55\n........\n...PP...",
      names: range(30).map(i => str(i + 1)),
      cell-width: 1.1cm,
      cell-height: 0.7cm,
      number: true,
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
  names: range(30).map(i => str(i + 1)),
  number: true,
)
  ```,
)

Fünf Gruppentische zu je sechs Plätzen. `number: true` blendet die Platznummern
ein -- sie werden für feste Platzvorgaben gebraucht.

== Zonen im Raum

Für Sitzwünsche wie „vorne" oder „links" teilt das Paket den Raum in zwei
unabhängige Achsen: *Tiefe* (`vorne`, `mitte`, `hinten`) und *Seite* (`links`,
`mitte`, `rechts`). Beide gelten für den *Gruppentisch als Ganzes* -- ein Tisch
liegt vorne oder hinten, nicht seine einzelnen Sitzreihen.

Wo „vorne" ist, ergibt sich aus der Lage des Pults; mit `front: "top"` lässt es
sich festlegen. Links und rechts sind aus *Schülersicht* gemeint: steht das Pult
unten im Layout, blickt die Klasse nach unten, und die linke Seite des Ausdrucks
ist für die Schüler rechts. Mit `perspective: "plan"` gilt stattdessen die
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
    import "../src/lib.typ": sitzordnung, typlace
    let layout = "11..22\n11..22\n11..22\n......\n..PP.."
    let wuensche = "Anna|l|Ben|Clara
Ben||Anna|Clara
Clara||Anna|Ben
David||Emil|Felix
Emil||David|Felix
Felix||David|Emil
Greta|r|Hanna
Hanna||Greta|!Anna"
    let plan = sitzordnung(layout, wuensche, seed: 7, quality: "fast")
    typlace(layout, names: plan.names, cell-width: 1.5cm, cell-height: 0.9cm)
  },
  source: ```typ
#let plan = sitzordnung(layout, read("wuensche.csv"), seed: 7)

#typlace(layout, names: plan.names)
#seating-report(plan)
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
#let plan = sitzordnung(layout, read("wuensche.csv"), constraints: (
  fixed: ("Ben Schulz": 3),                   // feste Platznummer
  must-front: ("Eva Lang",),                  // auch must-middle/-back/-left/-right
  apart: (("Max Klein", "Moritz Groß"),),     // nie am selben Gruppentisch
  together: (("Ida Berg", "Jonas Kern"),),    // immer am selben Gruppentisch
))
```]

Lassen sich die Vorgaben nicht alle gleichzeitig einhalten, bricht die Funktion mit
einer Erklärung ab, statt still eine davon zu opfern.

== Bewertung

#table(
  columns: (1fr, auto),
  inset: 5pt,
  table.header([*Kriterium*], [*Standardgewicht*]),
  [Wunschperson daneben, gegenüber oder über Eck], [`adjacent: 1.0`],
  [Wunschperson am selben Tisch, aber weiter weg], [`table: 0.9`],
  [1., 2. und 3. Wunsch], [`ranks: (1.0, 1.0, 1.0)`],
  [1., 2. und 3. _erfüllter_ Wunsch eines Schülers], [`tiers: (1.0, 0.7, 0.45)`],
  [Bonus für „überhaupt einen Wunsch erfüllt"], [`fairness: 2.0`],
  [Abgelehnte Person am selben Tisch], [`rejection: -2.0`],
  [Erfüllter Positionswunsch je Achse], [`position: 0.5`],
  [Gemiedene Zone doch zugeteilt], [`position-avoided: -0.5`],
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
pro Schüler rechenbar. `weights: (tiers: (1.0, 1.0, 1.0))` schaltet sie ab.

Wie es ausgegangen ist, zeigt `seating-report` als Kreuztabelle -- eine Reihe je
Anzahl *genannter* Wünsche, darin die Kinder nach Anzahl *erfüllter*, damit sich
„drei von drei" und „einer von einem" nicht vermischen:

#show-code[```
        davon erfüllt:  0   1   2   3
 1 Wunsch genannt       ·   1
2 Wünsche genannt       ·   2   ·
3 Wünsche genannt       ·   3  11  10
```]

Dieselben Zahlen liegen in `plan.statistics.distribution`: Schlüssel ist die Anzahl
genannter Wünsche, Wert ein Array mit der Anzahl erfüllter Wünsche als Index. Einzelne Gewichte lassen sich über `weights: (position: 1.5)`
ändern.

Statt einzelne Gewichte zu verstellen, lässt sich direkt angeben, welchen Anteil
die Sitzwünsche im Raum an den erreichbaren Punkten haben sollen -- das Gewicht
wird dann aus der tatsächlichen Klasse berechnet:

#show-code[```typ
#let plan = sitzordnung(layout, read("wuensche.csv"), position-share: 15%)
```]

`0%` ignoriert vorne/hinten/links/rechts vollständig, `50%` stellt beide Seiten
gleich. Wie es ausgegangen ist, steht im Bericht unter
`plan.statistics.wish-points` und `plan.statistics.position-points`.

Positionswünsche wiegen in der Voreinstellung bewusst leicht. Da eine Zone dem ganzen Gruppentisch gilt,
konkurriert „ich möchte vorne sitzen" direkt mit „ich möchte neben meinen Freunden
sitzen" -- ein höheres Gewicht kostet erfahrungsgemäß mehrere soziale Wünsche und
erfüllt kaum zusätzliche Positionswünsche.

== Rechenkern

Die Suche läuft standardmäßig in einem mitgelieferten WASM-Plugin
(`src/optimierer.wasm`, Rust-Quelltext unter `rust/`, neu bauen mit `rust/bauen.sh`).
Es ist eine 1:1-Übertragung von `src/optimizer.typ` -- gleicher Zufallsgenerator,
gleiche Reihenfolge der Tausche, gleiche Reihenfolge der Additionen. Bei
gleichem `seed` kommt in beiden Fassungen derselbe Plan heraus.

#table(
  columns: 3,
  inset: 5pt,
  table.header([], [*20 Startpläne*], [*2000 Startpläne*]),
  [`engine: "typst"`], [12,0 s], [rund 20 min],
  [`engine: "wasm"`], [0,22 s], [14,3 s],
)

Nach jedem Aufruf rechnet Typst die gelieferte Sitzordnung selbst nach. Weichen
die Punktzahlen ab, bricht das Paket ab, statt still ein falsches Ergebnis zu
setzen -- so kann die Schnittstelle zwischen beiden Fassungen nicht unbemerkt
auseinanderlaufen.

Weil Rechenzeit damit billig ist, sind die Voreinstellungen von `quality` beim
WASM-Kern viel großzügiger (50, 300 und 2000 Startpläne statt 6, 12 und 30).
`engine: "typst"` bleibt als lesbare Referenz erhalten.

== Wie gesucht wird

Das Verfahren erzeugt mehrere zufällige, aber zulässige Startpläne und verbessert
jeden durch Platztausche, solange das Punkte bringt; bewertet wird dabei nur die
Differenz eines Tauschs. Der beste Plan gewinnt. `quality` steuert den Aufwand
(`"fast"`, `"normal"`, `"thorough"`), `attempts` und `max-steps`
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
  names: ("Anna", "Ben", "Clara", "David",
          "Eva", "Felix", "Greta", "Hans"),
  rotation: 180deg,   // Pult unten → Pult oben nach der Drehung
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
  names: ("Anna", "Ben", "Clara", "David", "Eva", "Felix", "Greta"),
  seat-fill: rgb("#d4edda"),    // Hellgrün
  desk-fill: rgb("#856404"),    // Dunkelbraun
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
  names: range(24).map(i => "Schüler " + str(i + 1)),
  cell-width: 1.8cm,
  cell-height: 1cm,
)
```]

= Parameter

#show-code[```typ
#typlace(
  layout,               // str: Layoutstring (X, T, 1-9/a-z, o, P)
  names: (),            // array: Namen für die Sitzplätze
  cell-width: 2cm,      // length: Breite eines Tischfeldes
  cell-height: 1.2cm,   // length: Höhe eines Tischfeldes
  seat-fill: rgb("#cce0f5"),   // color: Füllfarbe der Sitzplätze
  desk-fill: rgb("#6b4c2a"),   // color: Füllfarbe des Lehrerpults
  table-fill: auto,     // auto | color | gradient | tiling | none: Tischfläche
  number: false,        // bool: Platznummern anzeigen
  rotation: 0deg,       // angle: 0deg, 90deg, 180deg oder 270deg im Uhrzeigersinn
)

#let plan = sitzordnung(
  layout,               // str: Layoutstring
  read("wuensche.csv"), // str | array | dictionary: Wunschliste
  constraints: (:),     // dictionary: fixed, must-front, must-middle,
                        //   must-back, must-left, must-right,
                        //   apart, together
  weights: (:),         // dictionary: geänderte Gewichte
  position-share: auto, // auto | ratio: Anteil der Sitzwünsche im Raum
  seed: 42,             // int: Startwert des Zufalls
  quality: "normal",    // str: "fast" | "normal" | "thorough"
  attempts: auto,       // auto | int: Anzahl Startpläne
  max-steps: auto,      // auto | int: Schritte je Versuch
  front: auto,          // auto | "top" | "bottom" | "left" | "right"
  perspective: "student",  // str: "student" | "plan"
  strict: true,         // bool: unbekannte Namen = Fehler
  duration: none,       // none | str | content | Zahl: Rechenzeit für den Bericht
  engine: "wasm",       // str: "wasm" (Plugin) | "typst" (Referenz)
)
```]

== Was im Plan steht

`sitzordnung()` liefert ein Dictionary. Alle Schlüssel sind englisch:

#table(
  columns: (auto, 1fr),
  inset: 5pt,
  table.header([*Schlüssel*], [*Inhalt*]),
  [`names`], [Namen in Platzreihenfolge, leere Plätze als leerer Text -- direkt an `typlace(names: …)`],
  [`assignment`, `seat-of`], [Platz → Schülerindex und Schüler → Platzindex],
  [`points`, `points-rounded`], [Punktzahl des Plans],
  [`statistics`], [Kennzahlen: `wishes-total`, `wishes-fulfilled`, `rate`, `all-fulfilled`, `unfulfilled`, `position-total`, `position-fulfilled`, `position-violated`, `position-impossible`, `rejections-violated`, `constraints-violated`, `distribution`, `position-points`, `wish-points`],
  [`details`], [je Schüler: `points`, `position-points`, `fulfilled`, `violated`, `position`, `position-violated`, `constraints-violated`],
  [`notes`], [Hinweise zur Wunschliste (deutscher Text)],
  [`geometry`], [das ausgewertete Layout: `rows`, `columns`, `front`, `seats`, `tables`, `zones`, `relations`],
  [`problem`], [die aufbereiteten Daten der Suche: `students`, `wishes`, `rejections`, `weights` …],
  [`seed`, `duration`, `attempts`, `steps`, `checked`], [Aufwand der Suche],
)

Zonen heißen in diesen Daten `"front"`, `"middle"`, `"back"` (Achse `depth`)
und `"left"`, `"middle"`, `"right"` (Achse `side`). In der Wunschliste und im
gedruckten Bericht bleiben sie deutsch.

= Umstieg auf 0.5.0

Mit 0.5.0 gelten in allen `@schule`-Paketen dieselben Regeln: Was man aufruft,
heißt wie das Schulding (`typlace`, `sitzordnung`, `wunschliste`); alles in den
Klammern -- Parameter, Schlüssel, Werte -- ist englisch. Am Verhalten ändert
sich nichts: dasselbe Dokument ergibt mit den neuen Namen dasselbe PDF.

Ein alter Name wird nie still angenommen. Das Paket bricht mit einer Meldung
ab, die den neuen Namen nennt:

#show-code[```
typlace.typlace: `namen` heißt jetzt `names`
typlace.sitzordnung: `quality: "gründlich"` heißt jetzt `"thorough"`
typlace.sitzplan-bericht: `sitzplan-bericht` heißt jetzt `seating-report`
```]

Unverändert bleiben der Layout-String und die Wunschliste samt ihren deutschen
Positionsangaben (`vorne`, `v`, `!mitte`, `hinten rechts` …): das sind Daten.

Einiges ist strenger als früher: `rotation` ist ein Winkel (`90deg` statt
`90`), und eine Drehung, die keine Vierteldrehung ist, wird gemeldet statt
still als 0 gelesen. Falsche Typen werden gemeldet, wo sie bisher still
durchgingen: `names` muss eine Liste sein (ein Text wurde früher buchstabenweise
auf die Plätze verteilt -- `("Anna")` ist ein Text, `("Anna",)` eine Liste),
`attempts`, `max-steps`, `seat-count` und `max-wishes` sind ganze Zahlen,
`strict` ist `true` oder `false`, und unbekannte Schlüssel in `weights` und
`constraints` sind ein Fehler. Neu angenommen werden die Zeilen aus
`csv("wuensche.csv", delimiter: "|")` direkt in `sitzordnung`.

Das Ergebnis von `sitzordnung` (der Plan) ist ein Dictionary. Wer daraus Felder
liest, findet unten alle Schlüssel; bei einem alten Schlüssel im Plan kann das
Paket nicht helfen, dort meldet Typst nur „dictionary does not contain key".

== Funktionen

#table(
  columns: (1fr, 1fr),
  inset: 5pt,
  table.header([*bis 0.0.2*], [*ab 0.5.0*]),
  [`typlace`], [`typlace`],
  [`sitzordnung`], [`sitzordnung`],
  [`wunschliste`], [`wunschliste`],
  [`sitzplan-bericht`], [`seating-report`],
  [`sitzplan-kennzahlen`], [`seating-summary`],
  [`standard-gewichte`], [`default-weights`],
  [`schueler-lesen`, `schueler-pruefen`], [`wunschliste` (liest und prüft in einem Schritt)],
  [`plaetze-analysieren`, `layout-matrix`, `koerper-zellen`, `ist-frei`, `ist-pult`, `ist-koerper`, `ist-platz`, `tisch-ids`, `kontext-erstellen`, `bewerte`, `statistik`, `punkte-schueler`, `punkte-wert`, `platz-von-schueler`, `tausch-delta`, `normalisiere-vorgaben`, `wasm-suchen`],
  [nicht mehr öffentlich; ohne Zusicherung erreichbar als `internal.analyze-layout`, `internal.layout-matrix`, `internal.table-cells`, `internal.is-free`, `internal.is-desk`, `internal.is-table`, `internal.is-seat`, `internal.table-ids`, `internal.build-problem`, `internal.score-plan`, `internal.statistics`, `internal.student-score`, `internal.student-points`, `internal.seat-of-students`, `internal.swap-delta`, `internal.normalize-constraints`, `internal.wasm-search`],
)

== Parameter und Werte

#table(
  columns: (auto, 1fr, 1fr),
  inset: 5pt,
  table.header([*Funktion*], [*bis 0.0.2*], [*ab 0.5.0*]),
  [`typlace`], [`namen`], [`names`],
  [], [`tisch-breite`, `tisch-hoehe`], [`cell-width`, `cell-height`],
  [], [`tisch-farbe`], [`seat-fill`],
  [], [`pult-farbe`], [`desk-fill`],
  [], [`koerper-farbe`], [`table-fill`],
  [], [`nummern`], [`number`],
  [], [`rotation: 90` (Zahl)], [`rotation: 90deg` (Winkel)],
  [`sitzordnung`], [`vorgaben`], [`constraints`],
  [], [`gewichte`], [`weights`],
  [], [`position-anteil`], [`position-share`],
  [], [`qualitaet: "schnell"`, `"normal"`, `"gruendlich"`], [`quality: "fast"`, `"normal"`, `"thorough"`],
  [], [`versuche`, `max-schritte`], [`attempts`, `max-steps`],
  [], [`vorne: "oben"`, `"unten"`, `"links"`, `"rechts"`], [`front: "top"`, `"bottom"`, `"left"`, `"right"`],
  [], [`perspektive: "schueler"`, `"plan"`], [`perspective: "student"`, `"plan"`],
  [], [`streng`], [`strict`],
  [], [`dauer`], [`duration`],
  [], [`motor: "wasm"`, `"typst"`], [`engine: "wasm"`, `"typst"`],
  [`wunschliste`], [`trenner`], [`delimiter`],
  [], [`kopfzeile`], [`header-row`],
  [], [`plaetze`], [`seat-count`],
  [], [`max-wuensche`], [`max-wishes`],
  [], [`streng`], [`strict`],
)

== Schlüssel

#table(
  columns: (auto, 1fr, 1fr),
  inset: 5pt,
  table.header([*Wo*], [*bis 0.0.2*], [*ab 0.5.0*]),
  [`constraints`], [`fest`], [`fixed`],
  [], [`muss-vorne`, `muss-mitte`, `muss-hinten`], [`must-front`, `must-middle`, `must-back`],
  [], [`muss-links`, `muss-rechts`], [`must-left`, `must-right`],
  [], [`getrennt`, `zusammen`], [`apart`, `together`],
  [`weights`], [`direkt`, `tisch`], [`adjacent`, `table`],
  [], [`raenge`, `stufen`], [`ranks`, `tiers`],
  [], [`wunschzahl`], [`wish-count`],
  [], [`fairness`, `position`], [unverändert],
  [], [`ablehnung`], [`rejection`],
  [], [`hart`], [`constraint`],
  [], [`position-meidet`], [`position-avoided`],
  [Plan], [`namen`, `punkte`, `punkte-gerundet`], [`names`, `points`, `points-rounded`],
  [], [`zuordnung`, `platz-von`], [`assignment`, `seat-of`],
  [], [`statistik`, `hinweise`], [`statistics`, `notes`],
  [], [`geo`, `kontext`], [`geometry`, `problem`],
  [], [`dauer`, `versuche`, `schritte`, `geprueft`], [`duration`, `attempts`, `steps`, `checked`],
  [`statistics`], [`wuensche-gesamt`, `wuensche-erfuellt`, `quote`], [`wishes-total`, `wishes-fulfilled`, `rate`],
  [], [`alle-erfuellt`, `ohne-wunsch`], [`all-fulfilled`, `unfulfilled`],
  [], [`position-gesamt`, `position-erfuellt`, `position-verletzt`, `position-unerfuellbar`], [`position-total`, `position-fulfilled`, `position-violated`, `position-impossible`],
  [], [`ablehnungen-verletzt`, `vorgaben-verletzt`], [`rejections-violated`, `constraints-violated`],
  [], [`verteilung`], [`distribution`],
  [], [`punkte-aus-wuenschen`, `punkte-aus-position`], [`wish-points`, `position-points`],
  [`details` (je Schüler)], [`punkte`, `punkte-position`], [`points`, `position-points`],
  [], [`erfuellt`, `verletzt`], [`fulfilled`, `violated`],
  [], [Einträge darin: `schueler`, `art`, `punkte`], [`student`, `kind`, `points`],
  [], [`position`], [unverändert],
  [], [`position-verletzt`, `hart-verletzt`], [`position-violated`, `constraints-violated`],
  [`geometry`], [`matrix`], [unverändert],
  [], [`zeilen`, `spalten`, `vorne`], [`rows`, `columns`, `front`],
  [], [`plaetze`, `tische`], [`seats`, `tables`],
  [], [`zonen: (tiefe:, seite:)`], [`zones: (depth:, side:)`],
  [], [`beziehung`], [`relations`],
  [], [Werte darin: `"selbst"`, `"direkt"`, `"tisch"`, `"fern"`], [`"self"`, `"adjacent"`, `"table"`, `"far"`],
  [je Platz in `seats`], [`index`], [unverändert],
  [], [`zeile`, `spalte`, `zeichen`], [`row`, `column`, `character`],
  [], [`tisch`, `abstand`], [`table`, `distance`],
  [], [`zone: (tiefe:, seite:)`], [`zone: (depth:, side:)`],
  [], [Tischnamen `"tisch-1"`, `"auto-0"`], [`"table-1"`; `"auto-0"` unverändert],
  [`problem`], [`geo`, `schueler`], [`geometry`, `students`],
  [], [`index-von`], [`index-of`],
  [], [`wuensche`, `ablehnungen`], [`wishes`, `rejections`],
  [], [`getrennt`, `zusammen`], [`apart`, `together`],
  [], [`rueckwaerts`, `gewichte`], [`reverse`, `weights`],
  [], [`anzahl-schueler`, `anzahl-plaetze`], [`student-count`, `seat-count`],
  [Wunschliste], [`schueler`, `hinweise`], [`students`, `notes`],
  [], [`wuensche`, `ablehnungen`, `position-meidet`], [`wishes`, `rejections`, `position-avoided`],
  [], [`tiefe`, `seite`], [`depth`, `side`],
  [], [`"vorne"`, `"mitte"`, `"hinten"`, `"links"`, `"rechts"`], [`"front"`, `"middle"`, `"back"`, `"left"`, `"right"`],
)

= API-Referenz

#show-module(read("../src/typlace.typ"), name: "typlace", only: ("typlace",), heading-level: 2)

#show-module(read("../src/optimizer.typ"), name: "optimizer", only: ("sitzordnung",), heading-level: 2)

#show-module(read("../src/data.typ"), name: "data", only: ("wunschliste",), heading-level: 2)

#show-module(read("../src/report.typ"), name: "report", only: ("seating-report", "seating-summary"), heading-level: 2)

#show-module(read("../src/scoring.typ"), name: "scoring", only: ("default-weights",), heading-level: 2)
