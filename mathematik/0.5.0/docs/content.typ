#import "@schule/schuldocs:0.3.1": info, show-code, show-example, show-module, tip, warning
#import "../src/lib.typ" as mathematik

// Jedes Beispiel wird aus genau dem Quelltext gesetzt, der daneben steht:
// kompiliert das Handbuch, kompiliert auch jedes Beispiel.
#let scope = dictionary(mathematik)
#let example(source, width: 14cm) = show-example(
  rendered: eval(source.text, mode: "markup", scope: scope),
  source: source,
  width: width,
)

= Über dieses Paket

Das `mathematik`-Paket stellt Werkzeuge für den Mathematikunterricht bereit: Funktionsgraphen im Koordinatensystem, Steckbriefaufgaben, Kreisdiagramme und die nachgebildete Algebra-Ansicht von GeoGebra.

Die Bausteine tragen deutsche Namen (`graphen`, `steckbrief`, `kreisdiagramm`), alles in den Klammern ist englisch (`domain:`, `step:`, `areas:`).

Dieses Handbuch gliedert sich wie folgt:

+ *Schnellstart* -- erste Schritte
+ *Graphen* -- Funktionsgraphen, Beschriftungen, Flächen, Punkte
+ *Koordinatensystem* -- Achsen, Gitter, Größe
+ *Messreihen* -- Datenpunkte aus physik oder aus Zahlenreihen
+ *Steckbrief* -- Polynomfunktion aus Bedingungen
+ *Kreisdiagramm* -- Anteile darstellen
+ *GeoGebra* -- die Algebra-Ansicht nachbilden
+ *Fehlermeldungen* -- was das Paket bei falschen Angaben meldet
+ *Umstieg auf 0.5.0* -- alte und neue Namen
+ *Referenz* -- alle Funktionen mit ihren Parametern

= Schnellstart

#show-code(```typ
#import "@schule/mathematik:0.5.0": *

#graphen($x^2 - 2$, $0,5 x + 1$, domain: (x: (-3, 3), y: (-3, 5)))

#let sb = steckbrief("f(0)=2", "f'(0)=0", "f(2)=0", "f'(2)=0")
Gesucht ist #sb.ansatz, gefunden: #sb.math

#kreisdiagramm((("Äpfel", 35), ("Birnen", 45), ("Kirschen", 20)))
```)

Wer `arbeitsblatt` oder `klassenarbeit` ab 0.5.0 benutzt, bekommt `graphen`, `steckbrief`, `kreisdiagramm`, `geogebra-algebra` und `geogebra-cell` von dort; nur `geogebra-style` braucht die eigene Importzeile.

Das Paket benutzt `cetz` 0.4.2, `cetz-plot` 0.1.3, `eqalc` 0.1.3, `fancy-units` 0.1.1, `zero` 0.5.0 und `@schule/physik:0.5.0`.

= Graphen

`graphen` zeichnet Funktionsgraphen in ein Koordinatensystem. Die Graphen sind die Positionsargumente, alles andere ist benannt.

== Terme und Funktionen

Ein Graph ist ein Term im Formelsatz oder eine Funktion. Terme dürfen so geschrieben werden wie an der Tafel: mit Dezimalkomma, ohne Malpunkt, mit Betragsstrichen.

#example(```typ
#graphen(
  $f(x) = 0,5 x^2 - 2$,
  $|x| - 1$,
  x => calc.sin(x),
  domain: (x: (-4, 4), y: (-3, 4)),
)
```)

Polstellen werden erkannt; dort entsteht keine senkrechte Verbindungslinie.

#example(```typ
#graphen($1/x$, domain: (-3, 3))
```)

== Graph mit Einstellungen

Für Farbe, Bereich, Strich und Beschriftung wird der Graph als Dictionary geschrieben.

#example(```typ
#graphen(
  (
    term: $x^2$,
    accent: blue,
    domain: (0, 3),
    labels: ((x: 2, body: $f(x) = x^2$, position: "bottom-right"),),
  ),
  (term: $-x + 6$, stroke: (thickness: 1pt, dash: "dashed"), accent: red),
  domain: (x: (-1, 4), y: (-1, 10)),
)
```)

Schlüssel eines Graphen:

- `term`: Term im Formelsatz oder Funktion (Pflicht)
- `domain`: Bereich `(von, bis)`, in dem der Graph gezeichnet wird; ohne Angabe der ganze x-Bereich
- `accent`: Farbe der Linie und Vorgabe für die Farbe der Beschriftung; ohne Angabe die Palettenfarbe nach Position
- `stroke`: Strich nur dieses Graphen; seine Farbe gilt, solange `accent` fehlt
- `labels`: Array aus Beschriftungen

Schlüssel einer Beschriftung in `labels`:

- `x`: Stelle auf der x-Achse, an der die Beschriftung am Graphen sitzt (Pflicht)
- `body`: Text (Pflicht)
- `position`: Lage zum Punkt: `"top-right"` (Vorgabe), `"top-left"`, `"bottom-right"`, `"bottom-left"`
- `distance`: Abstand vom Punkt, Vorgabe `1mm`
- `fill`: Hintergrund, Vorgabe `white`
- `text-fill`: Textfarbe, Vorgabe die Farbe des Graphen
- `font-size`: Schriftgröße, Vorgabe die des Dokuments
- `rotation`: Drehung, Vorgabe `0deg`

== Flächen

`areas` färbt Flächen: mit `term` die Fläche zwischen Graph und x-Achse, mit `between` die Fläche zwischen zwei Graphen.

#example(```typ
#graphen(
  x => calc.sin(x),
  domain: (x: (-1, 4), y: (-1.5, 1.5)),
  areas: (
    (term: x => calc.sin(x), domain: (0, calc.pi), fill: blue.transparentize(60%)),
  ),
)
```)

Mit `domain: "intersections"` reicht die Fläche von der kleinsten bis zur größten Schnittstelle im x-Bereich.

#example(```typ
#graphen(
  $x^2$,
  $x + 2$,
  domain: (x: (-3, 3), y: (-1, 6)),
  areas: ((between: ($x^2$, $x + 2$), domain: "intersections"),),
)
```)

Schlüssel einer Fläche: `term` oder `between` (genau eines), `domain` (`(von, bis)`, `"intersections"` oder ohne Angabe der x-Bereich) und `fill`. Der x-Bereich einer Fläche ist der in `domain` von `graphen` angegebene, sonst −5 bis 5; nach Messreihen richtet er sich nicht.

== Punkte

`marks` setzt Punkte, auf Wunsch mit Beschriftung.

#example(```typ
#graphen(
  $x^2 - 2$,
  domain: (x: (-3, 3), y: (-3, 4)),
  marks: (
    (at: (0, -2), body: [$S$], position: "bottom-right"),
    (at: (2, 2), body: [$P$], position: "top-left", symbol: "o", accent: red),
    (at: (-2, 2)),
  ),
)
```)

Schlüssel eines Punkts:

- `at`: der Punkt `(x, y)` (Pflicht)
- `body`: Beschriftung
- `position`: Lage der Beschriftung zum Punkt: `"top-right"` (Vorgabe), `"top-left"`, `"bottom-right"`, `"bottom-left"`, `"top"`, `"bottom"`, `"left"`, `"right"`
- `distance`: Abstand der Beschriftung, Vorgabe `2mm`
- `symbol`: Punktsymbol von CeTZ, Vorgabe `"x"`; auch `"o"`, `"square"`, `"triangle"` …
- `accent`: eine Farbe für den Rand und, wenn `fill` fehlt, die Füllung des Symbols
- `stroke`, `fill`: Rand und Füllung einzeln

== Eigene Zeichnungen

`annotations` nimmt Zeichenbefehle von CeTZ auf. Die Koordinaten sind die des Diagramms.

#example(```typ
#import "@preview/cetz:0.4.2": draw

#graphen(
  $0,5 x^2$,
  domain: (x: (-1, 4), y: (-1, 5)),
  annotations: {
    draw.line((2, 0), (2, 2), (0, 2), stroke: (dash: "dashed"))
    draw.circle((2, 2), radius: 0.1, fill: black)
  },
)
```)

= Koordinatensystem

== Achsenbereich

`domain` ist der Bereich beider Achsen oder je Achse ein eigener. Ohne Angabe reichen beide Achsen von −5 bis 5.

#example(```typ
#graphen($x$, domain: (-2, 2))
#graphen($x$, domain: (x: (0, 6), y: (-1, 3)))
```)

== Größe

Ohne Angabe ist eine Einheit auf jeder Achse 1 cm lang. `width` und `height` legen die Größe als Länge fest.

#example(```typ
#graphen($x^3 / 20$, domain: (x: (-5, 5), y: (-6, 6)), width: 8cm, height: 4cm)
```)

== Teilstriche und Gitter

`step` ist die Schrittweite der Teilstriche, `grid-lines` wählt die Gitterlinien. Beide gelten für beide Achsen oder je Achse einzeln.

#example(```typ
#graphen(
  x => calc.sin(x),
  domain: (x: (-6, 6), y: (-2, 2)),
  step: (x: (2, 1), y: 1),
  grid-lines: (x: "major", y: "all"),
  width: 10cm,
  height: 4cm,
)
```)

- `step: 2` -- Hauptschritt 2, Nebenschritt 1 (die Hälfte)
- `step: (2, 0.5)` -- Hauptschritt 2, Nebenschritt 0,5
- `step: none` -- keine Teilstriche
- `step: (x: 2)` -- nur die x-Achse; die andere Achse behält die Vorgabe
- `grid-lines: "all"` (Vorgabe), `"major"`, `"minor"` oder `none`

== Achsenbeschriftung

`labels` ist das Paar `(x-Achse, y-Achse)`. Ein Eintrag `auto` behält die Vorgabe, `none` lässt die Beschriftung weg.

#example(```typ
#graphen(
  x => 2 * x,
  domain: (x: (0, 5), y: (0, 10)),
  labels: ([$t$ in s], [$s$ in m]),
  width: 6cm,
  height: 5cm,
)
```)

== Strich und Stützstellen

`stroke` ist der Strich aller Graphen; jeder Graph behält seine Palettenfarbe, solange der Strich keine Farbe nennt. `sample-count` ist die Zahl der Stützstellen je Graph.

#example(```typ
#graphen(
  x => calc.sin(5 * x),
  x => calc.cos(x),
  domain: (x: (-3, 3), y: (-2, 2)),
  stroke: 2.5pt,
  sample-count: 400,
)
```)

= Messreihen

`datasets` zeichnet Datenpunkte. Eine Messreihe ist ein Dictionary mit `x` und `y`; beide sind ein `datensatz` aus `@schule/physik:0.5.0` oder ein Array aus Zahlen. Achsenbereich, Teilstriche und Achsenbeschriftung richten sich dann nach den Daten, solange `domain`, `step` und `labels` nichts anderes sagen.

#example(```typ
#import "@schule/physik:0.5.0": datensatz

#let t = datensatz((0, 1, 2, 3, 4), name: $t$, unit: "s")
#let s = datensatz((0, 5, 20, 45, 80), name: $s$, unit: "m")

#graphen(x => 5 * x * x, datasets: ((x: t, y: s),), width: 10cm, height: 6cm)
```)

Mehrere Messreihen bekommen der Reihe nach die Palettenfarben. `symbol` wählt das Punktsymbol, `accent` die Farbe, `fill` und `stroke` Füllung und Rand einzeln.

#example(```typ
#graphen(
  datasets: (
    (x: (0, 1, 2, 3, 4), y: (0, 1, 4, 9, 16), symbol: "o"),
    (x: (0, 1, 2, 3, 4), y: (0, 2, 4, 6, 8), symbol: "square", accent: red, fill: white),
  ),
  width: 8cm,
  height: 6cm,
)
```)

Hat ein Datensatz einen Vorsatz (`prefix: "m"` bei `unit: "A"`), rechnet `graphen` die Werte in die Einheit der Achse um: 4 mA stehen bei 0,004 A. Alle Messreihen einer Achse müssen dieselbe Einheit haben.

= Steckbrief

`steckbrief` bestimmt eine Polynomfunktion aus Bedingungen. Der Grad ergibt sich aus der Zahl der Bedingungen (Grad = Anzahl − 1).

#example(```typ
#let sb = steckbrief("f(0)=2", "f'(0)=0", "f(2)=0", "f'(2)=0")

Ansatz: #sb.ansatz

Bedingungen und Gleichungssystem:
#sb.condition-system #h(1cm) #sb.system

Ergebnis: #sb.math

#graphen(sb.function, domain: (-1, 3))
```)

== Bedingungen

#show-code(```typ
"f(2)=3"      // Funktionswert
"f'(-1)=0"    // erste Ableitung
"f''(0)=6"    // zweite Ableitung
"f(1/2)=1"    // Brüche
"f(0)=0,5"    // Dezimalkomma oder Dezimalpunkt
```)

Legen die Bedingungen die Funktion nicht eindeutig fest, bricht `steckbrief` mit einer Meldung ab.

== Ergebnis

Das Ergebnis ist ein Dictionary:

- `ansatz`: allgemeine Funktionsgleichung
- `math`: Funktionsgleichung mit den berechneten Koeffizienten
- `math-digits`: Funktion, die `math` mit gewählter Stellenzahl liefert: `#(sb.math-digits)(4)`
- `function`: Funktion `x => f(x)`, zum Rechnen und für `graphen`
- `conditions`: die Bedingungen im Formelsatz (Array)
- `condition-system`: die Bedingungen untereinander
- `equations`: die Gleichungen des Gleichungssystems (Array)
- `system`: das Gleichungssystem untereinander
- `coefficients`: die Koeffizienten als Dictionary `(a: …, b: …, …)`, höchster Grad zuerst

Die Koeffizienten heißen der Reihe nach $a$, $b$, $c$, …; bei mehr als fünf Bedingungen heißt der sechste $f$ wie die Funktion.

== Zahlenformat

`notation` wählt die Schreibweise der Koeffizienten: `"decimal"` (Vorgabe), `"scientific"` oder `"fraction"` für exakte Brüche. `tolerance` ist der Betrag, unter dem ein Koeffizient als 0 gilt und wegfällt.

#example(```typ
#steckbrief("f(1/2)=3", "f'(-1)=1/2", "f''(0)=6", notation: "fraction").math

#steckbrief("f(100)=3", "f(200)=0.00015", notation: "scientific").math

#let sb = steckbrief("f(0)=1", "f(1)=1.5", "f(3)=0")
#(sb.math-digits)(4), #sb.coefficients.a
```)

= Kreisdiagramm

`kreisdiagramm` setzt ein Kreisdiagramm aus Paaren `(Beschriftung, Wert)`.

#example(```typ
#kreisdiagramm((("Äpfel", 35), ("Birnen", 45), ("Kirschen", 20)))
```)

`percent: true` (Vorgabe) setzt hinter jeden Wert ein Prozentzeichen; umgerechnet wird nichts, die Werte sollten sich also zu 100 ergänzen. Mit `percent: false` stehen die Werte ohne Zeichen da, mit `labeled: false` bleiben die Segmente leer.

#example(```typ
#kreisdiagramm(
  (("Ja", 12), ("Nein", 9), ("Enthaltung", 3)),
  percent: false,
  text-fill: white,
  legend-position: "bottom",
  accents: (green.darken(20%), red.darken(10%), gray),
  stroke: white + 1.5pt,
  width: 4cm,
)
```)

- `legend: false` -- keine Legende
- `legend-position` -- `"right"` (Vorgabe), `"left"`, `"top"`, `"bottom"`
- `accents` -- Farben der Segmente der Reihe nach
- `width` -- Durchmesser des Kreises

= GeoGebra

Drei Funktionen bilden die Algebra-Ansicht von GeoGebra nach, zum Beispiel für Aufgaben, in denen eine Eingabe gelesen oder ergänzt werden soll. Die Formeln brauchen die Schrift „New Computer Modern Sans Math“.

#example(```typ
#geogebra-algebra(
  $v = vec(2, 1, 5)$,
  $u = vec(1, -1, 3)$,
  $P = (3, 1, -3)$,
)
```)

`approximate-last: true` gibt der letzten Zelle die Schaltfläche „≈“, `columns` setzt mehrere Zellen nebeneinander.

#example(```typ
#geogebra-algebra($a = 3$, $b = 4$, $c = sqrt(a^2 + b^2)$, columns: 3, approximate-last: true)
```)

`geogebra-style` setzt nur die Formeln im GeoGebra-Stil, `geogebra-cell` eine einzelne Zelle ohne Rahmen.

#example(```typ
#geogebra-style[$g(t) = v + t u$]

#box(width: 5cm, stroke: 0.5pt + gray, inset: 0.8em, geogebra-cell(approximate: true)[$f(x) = x^2$])
```)

= Fehlermeldungen

Jede Funktion prüft ihre Angaben. Eine Meldung nennt Paket und Funktion, den Befund und die Abhilfe:

#show-code(```
mathematik.graphen: unbekannter Parameter `widht` – meintest du `width`?
mathematik.graphen: `samples` heißt jetzt `sample-count`
mathematik.graphen: `width` erwartet eine Länge oder `auto`, bekam `8` (int) – zum Beispiel `8cm`
mathematik.graphen: `marks: (1, 2)` ist ein nacktes Zahlenpaar – `marks: ((at: (1, 2)),)` schreiben
mathematik.steckbrief: `notation: "frac"` heißt jetzt `"fraction"`
```)

= Umstieg auf 0.5.0 <umstieg>

Mit 0.5.0 haben alle Pakete einheitliche Namen: Die Bausteine bleiben deutsch, alles in den Klammern ist englisch. Alte Namen brechen beim Kompilieren mit einer Meldung ab, die den neuen Namen nennt. Wer die Namen nach den folgenden Tabellen umstellt, bekommt dasselbe Bild wie mit 0.0.2, bis auf die unter „Was sich sonst geändert hat“ genannten Fälle.

== Funktionen

#table(
  columns: (1fr, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*bisher (0.0.2)*], [*jetzt (0.5.0)*]),
  [`graphen`, `steckbrief`, `kreisdiagramm`], [unverändert, neue Parameter],
  [`geogebra-algebra`, `geogebra-cell`, `geogebra-style`], [unverändert, neue Parameter],
  [`teilaufgaben`, `tasks`], [`teilaufgaben` aus `@schule/aufgaben:0.5.0` (auch über `arbeitsblatt` und `klassenarbeit`); mathematik hat keine eigene Fassung mehr],
  [`geogebra-colors`, `geogebra-button`, `geogebra-approx-button`], [nur noch unter `internal`, ohne Zusicherung: `geogebra-palette`, `geogebra-menu-button`, `geogebra-approximate-button`],
  [`rand`, `randint`, `shuffle`, `m`, `a` … (aus random durchgereicht)], [entfallen; wer sie braucht, importiert `@schule/random:0.0.1`],
  [`umrechnungseinheit`], [entfällt],
)

== Parameter von `graphen`

#table(
  columns: (1fr, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*bisher*], [*jetzt*]),
  [`x: (0, 10)`], [`domain: (x: (0, 10))`],
  [`x: (0, 10), y: (-1, 3)`], [`domain: (x: (0, 10), y: (-1, 3))`],
  [`x: (-3, 3), y: (-3, 3)`], [`domain: (-3, 3)`],
  [`x: auto`, `y: auto`, `x: (-5, 5)`], [weglassen (`domain: auto`)],
  [`size: (10, 6)`], [`width: 10cm, height: 6cm`],
  [`size: 8`], [`width: 8cm, height: 8cm`],
  [`size: (10, 6), scale: 0.5`], [`width: 5cm, height: 3cm`],
  [`scale: 0.5` ohne `size`], [`width` und `height` ausrechnen: Achsenbereich mal 0,5 cm],
  [`step: 1`], [weglassen (`step: auto`)],
  [`x-step: 2`], [`step: (x: 2)`],
  [`x-step: (1, 0.5), y-step: 2`], [`step: (x: (1, 0.5), y: 2)`],
  [`x-label: [$t$]`], [`labels: ([$t$], auto)`],
  [`x-label: [$t$], y-label: [$s$]`], [`labels: ([$t$], [$s$])`],
  [`grid: "both"`], [weglassen (`grid-lines: "all"`)],
  [`grid: "major"`, `grid: "minor"`], [`grid-lines: "major"`, `grid-lines: "minor"`],
  [`grid: "none"`], [`grid-lines: none`],
  [`x-grid: "major"`], [`grid-lines: (x: "major")`],
  [`y-grid: "none"`], [`grid-lines: (y: none)`],
  [`line-width: 2pt`], [`stroke: 2pt`],
  [`samples: 400`], [`sample-count: 400`],
  [`fills: (…)`], [`areas: (…)`],
  [`fills: ($f$, $g$)`], [`areas: ((between: ($f$, $g$), domain: "intersections"),)`],
  [`fills: $f$`], [`areas: ((term: $f$, domain: "intersections"),)`],
  [`datensätze: (x: t, y: s)`], [`datasets: ((x: t, y: s),)`],
  [`datensätze: (xs, ys)`], [`datasets: ((x: xs, y: ys),)`],
  [`marks: ((1, 2),)`], [`marks: ((at: (1, 2)),)`],
  [`marks: (((1, 2), [P]),)`], [`marks: ((at: (1, 2), body: [P]),)`],
  [`annotations: {…}`], [unverändert],
  [weitere benannte Argumente (gingen an cetz-plot)], [entfallen, unbekannte Parameter sind ein Fehler],
)

== Schlüssel in `graphen`

#table(
  columns: (auto, 1fr, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*wo*], [*bisher*], [*jetzt*]),
  [Graph], [`color: red`, `clr: red`], [`accent: red`],
  [], [`color: 2` (Palettenindex)], [`accent: rgb("#D62728")`, siehe unten],
  [], [`label: (x: 1, content: $f$)`], [`labels: ((x: 1, body: $f$),)`],
  [Beschriftung eines Graphen], [`content`], [`body`],
  [], [`position: "tl"`, `"tr"`, `"bl"`, `"br"`], [`position: "top-left"`, `"top-right"`, `"bottom-left"`, `"bottom-right"`],
  [], [`size: 14pt`], [`font-size: 14pt`],
  [], [`color: black`], [`text-fill: black`],
  [], [`padding: 2mm`], [`distance: 2mm`],
  [], [`angle: 20deg`], [`rotation: 20deg`],
  [Fläche], [`color`, `clr`], [`fill`],
  [], [`domain: "auto"`, `auto-domain: true`], [`domain: "intersections"`],
  [Punkt], [`position: (1, 2)`, `pos: (1, 2)`], [`at: (1, 2)`],
  [], [`content: [P]`, `label: [P]`], [`body: [P]`],
  [], [`padding: 3mm`], [`distance: 3mm`],
  [], [`color`, `clr`], [`accent`],
  [], [`anchor: …`], [`position: …`, Werte siehe unten],
  [Messreihe], [`marker: "o"`], [`symbol: "o"`],
  [], [`marker: (symbol: "o", fill: white)`], [`symbol: "o", fill: white`],
  [], [`mark-style: (fill: white, stroke: red)`], [`fill: white, stroke: red`],
  [], [`color`, `clr`], [`accent`],
)

Der Palettenindex entfällt. Die Farben der Palette sind der Reihe nach `rgb("#1F77B4")`, `rgb("#D62728")`, `rgb("#2CA02C")`, `rgb("#FF7F0E")`, `rgb("#9467BD")`, `rgb("#8C564B")`, `rgb("#E377C2")`, `rgb("#7F7F7F")`, `rgb("#BCBD22")`, `rgb("#17BECF")`.

Die Lage der Beschriftung eines Punkts hieß `anchor` und nannte den Anker des Textes; `position` nennt jetzt, wo der Text vom Punkt aus steht. Dasselbe Bild ergibt:

#table(
  columns: (1fr, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*bisher `anchor:`*], [*jetzt `position:`*]),
  [`"south-west"` (Vorgabe), `"br"`, `"bottom-right"`], [`"top-right"` (Vorgabe)],
  [`"south-east"`, `"bl"`, `"bottom-left"`], [`"top-left"`],
  [`"north-west"`, `"tr"`, `"top-right"`], [`"bottom-right"`],
  [`"north-east"`, `"tl"`, `"top-left"`], [`"bottom-left"`],
  [`"south"`, `"b"`, `"bottom"`], [`"top"`],
  [`"north"`, `"t"`, `"top"`], [`"bottom"`],
  [`"west"`, `"r"`, `"right"`], [`"right"`],
  [`"east"`, `"l"`, `"left"`], [`"left"`],
)

== `steckbrief`

#table(
  columns: (1fr, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*bisher*], [*jetzt*]),
  [`notation: "dec"`, `"sci"`, `"frac"`], [`notation: "decimal"`, `"scientific"`, `"fraction"`],
  [`precision: 1e-10`], [`tolerance: 1e-10`],
  [`sb.gleichungssystem`], [`sb.system`],
  [`sb.gleichungssystem-raw`], [`sb.equations`],
  [`sb.bedingungen`], [`sb.conditions`],
  [`sb.bedingungen-system`], [`sb.condition-system`],
  [`sb.a`, `sb.b`, `sb.c` …], [`sb.coefficients.a`, `sb.coefficients.b`, `sb.coefficients.c` …],
  [`sb.bedingungen-raw`, `sb.bedingungen-system-raw`], [entfallen],
  [`sb.error`, `sb.grad` (wenn es keine eindeutige Lösung gibt)], [entfallen; die Funktion bricht mit einer Meldung ab],
  [`sb.ansatz`, `sb.math`, `sb.math-digits`, `sb.function`], [unverändert],
)

== `kreisdiagramm`

#table(
  columns: (1fr, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*bisher*], [*jetzt*]),
  [`legend: "r"`, `legend: true`, `legend: none`], [weglassen],
  [`legend: "l"`, `"t"`, `"b"`], [`legend-position: "left"`, `"top"`, `"bottom"`],
  [`legend: false`], [unverändert],
  [`legend: (…)` (Dictionary für cetz-plot)], [entfällt],
  [`show-percentage: false`], [`labeled: false`],
  [`mode: "absolute"`], [`percent: false`],
  [`mode: "percent"`], [weglassen (`percent: true`)],
  [`label-color: white`], [`text-fill: white`],
  [`colors: (…)`, `slice-style: (…)`], [`accents: (…)`],
  [`radius: 3.5`], [`width: 7cm` (Durchmesser als Länge)],
  [`stroke: …`], [unverändert],
  [`gap`, `value-key`, `label-key`, `inner-label`, `outer-label`], [entfallen],
)

== GeoGebra

#table(
  columns: (1fr, 1fr),
  stroke: 0.5pt + luma(180),
  table.header([*bisher*], [*jetzt*]),
  [`geogebra-cell($…$, approx: true)`], [`geogebra-cell($…$, approximate: true)` oder `geogebra-cell(approximate: true)[$…$]`],
  [`geogebra-algebra(…, last-has-approx: true)`], [`geogebra-algebra(…, approximate-last: true)`],
)

== Was sich sonst geändert hat

- Eine ausdrücklich geschriebene Vorgabe gilt jetzt auch zusammen mit Messreihen. Bisher wurden `x: (-5, 5)`, `y: (-5, 5)`, `step: 1`, `x-label: [$x$]` und `y-label: [$y$]` neben `datensätze` als „nicht gesetzt“ behandelt; wer das alte Bild will, lässt diese Angaben weg.
- `domain` ohne Angabe ist immer `(-5, 5)` oder der Bereich der Messreihen. Das frühere `x: auto` ohne Messreihen (der Bereich ergab sich aus den Stützstellen) gibt es nicht mehr.
- Mit `scale` wuchsen auch Symbole und Abstände der Achsenbeschriftung; mit `width` und `height` ändert sich nur die Größe des Koordinatensystems.
- Ein Graph, eine Fläche oder ein Punkt in einer Form, die das Paket nicht kennt, ist ein Fehler. Bisher wurde manches still übergangen: ein Graph ohne `term`, `marks: (1, 2)`, ein `label` falschen Typs.
- `stroke` und `accent` dürfen im selben Graphen stehen; bisher brach das bei `stroke: red + 2pt` ab. Wie bisher `color` gewinnt `accent` gegen eine Farbe, die in `stroke` steht.
- Hat ein Datensatz aus physik einen Vorsatz (`prefix: "m"`), werden seine Werte in die Einheit der Achse umgerechnet: 40 mA stehen bei 0,04 A. Bisher standen sie unverändert an der Achse (40 bei „in A“). Wer die alten Zahlen an der Achse will, schreibt den Vorsatz in die Einheit (`unit: "mA"`) und lässt `prefix` weg.
- Leere Zellen einer Messreihe (`none`, Zellen aus `messdaten`) werden übersprungen.
- `steckbrief` nimmt das Dezimalkomma an (`"f(0)=0,5"`), rechnet mit mehr als acht Bedingungen und benutzt `tolerance` auch beim Lösen des Gleichungssystems.
- `kreisdiagramm(legend: false)` setzt das Diagramm ohne Legende; bisher brach der Aufruf ab.
- Ein Punkt in `marks` mit einem Rand wie `stroke: blue + 2pt` und ohne `fill` wird in der Farbe des Rands gefüllt; bisher brach der Aufruf ab.

= Referenz

== Graphen
#show-module(read("../src/graphs.typ"), name: "graphs", scope: scope)

== Steckbrief
#show-module(read("../src/polynomial.typ"), name: "polynomial", scope: scope)

== Kreisdiagramm
#show-module(read("../src/charts.typ"), name: "charts", scope: scope)

== GeoGebra
#show-module(read("../src/geogebra.typ"), name: "geogebra", scope: scope)
