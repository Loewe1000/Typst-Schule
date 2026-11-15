#import "@schule/schuldocs:0.3.1": info, show-code, show-example, show-module, tip, warning
#import "../src/lib.typ" as patterns

// Jedes Beispiel wird aus seinem eigenen Quelltext gesetzt: Was hier steht,
// kompiliert auch.
#let example(source, ..rest) = show-example(
  rendered: eval(source.text, mode: "markup", scope: dictionary(patterns)),
  source: source,
  ..rest,
)

= Über dieses Paket

Das `patterns`-Paket stellt Schreibflächen für Arbeitsblätter bereit:
*kariertes Papier* (`kariert`) und *liniertes Papier* (`liniert`).
Beide Bausteine lassen sich in Arbeitsbereiche, Tabellen und mehrspaltige Layouts
einbetten. Rastergröße, Höhe, Breite, Beschriftungen und Linienstil sind einstellbar.

Typische Einsatzgebiete:

- Freiraum für Rechnungen auf Arbeitsblättern
- Messwerttabellen mit vorgedruckten Zeilenbeschriftungen
- Schreibzeilen für Antworten, Name und Datum
- Felder, die den Rest der Seite füllen (`1fr`)

Die Bausteine heißen deutsch (`kariert`, `liniert`), alles in den Klammern ist
englisch (`grid-size`, `line-height`, `stroke` …). Wer von einer älteren Version
kommt, findet die Zuordnung im Abschnitt „Umstieg auf 0.5.0".

= Schnellstart

#show-code(```typ
#import "@schule/patterns:0.5.0": kariert, liniert

#kariert(5)
#liniert(3)
```)

Wer mit `@schule/arbeitsblatt` oder `@schule/klassenarbeit` arbeitet, hat beide
Bausteine dort schon zur Hand und braucht keinen eigenen Import.

= Kariertes Papier

== Zeilenzahl

Die Zeilenzahl steht vorn ohne Namen. Ein Kästchen ist 0,5 cm groß; ohne Angabe
entsteht eine Zeile.

#example(```typ
#kariert(5)
```)

== Feste Höhe

Statt der Zeilenzahl kann `height` eine Höhe als Länge geben. Beides zugleich
ist ein Fehler.

#example(```typ
#kariert(height: 3cm)
```)

== Größe der Kästchen

`grid-size` ist die Kantenlänge eines Kästchens:

#example(```typ
#kariert(3, grid-size: 1cm)
```)

== Breite

Ohne Angabe füllt das Feld die verfügbare Breite. `columns` gibt die Breite in
Kästchen an, `width` als Länge. Nur eines von beiden ist erlaubt.

#example(```typ
#kariert(3, columns: 12)

#kariert(3, width: 8cm)
```)

== Beschriftungen

`items` setzt Beschriftungen untereinander in das Raster. `item-rows` legt fest,
wie viele Kästchen jede Beschriftung bekommt. Ohne Zeilenzahl ergibt sich die
Höhe des Felds aus den Beschriftungen.

#example(```typ
#kariert(
  items: ("Messung 1", "Messung 2", "Messung 3"),
  item-rows: 3,
  grid-size: 0.75cm,
)
```)

== Inhalt über dem Raster

`overlay` setzt Inhalt oben links über das Raster, zum Beispiel eine
vorgegebene erste Zeile:

#example(```typ
#kariert(5, overlay: [Gegeben: $a = 3$, $b = 4$. Gesucht: $c$])
```)

== Linienstil und Hintergrund

`stroke` bestimmt die Gitterlinien, `fill` den Hintergrund (`none` für keinen):

#example(```typ
#kariert(
  3,
  stroke: (paint: blue.lighten(40%), thickness: 0.5pt),
  fill: yellow.lighten(85%),
)
```)

== Zeichnungen im Raster

`annotations` nimmt CeTZ-Elemente auf. Die Einheit ist ein Kästchen, der
Ursprung liegt unten links.

#example(```typ
#import "@preview/cetz:0.4.2": draw

#kariert(6, annotations: {
  draw.line((2, 1), (10, 1), (10, 5), close: true, stroke: black)
  draw.content((6, 0.5), [$a$])
})
```)

= Liniertes Papier

== Zeilenzahl

Auch hier steht die Zeilenzahl vorn. Eine Zeile ist 1 cm hoch.

#example(```typ
#liniert(4)
```)

== Zeilenhöhe und Breite

#example(```typ
#liniert(3, line-height: 1.5cm, width: 8cm)
```)

== Beschriftungen

Mit `items` steht auf den Linien Text. Die Zeilenzahl ergibt sich dann aus den
Beschriftungen; `item-rows` gibt jeder Beschriftung mehrere Zeilen.

#example(```typ
#liniert(items: ("Name:", "Klasse:", "Datum:"))
```)

== Linienstil

#example(```typ
#liniert(2, stroke: (paint: black, thickness: 0.8pt, dash: "dotted"))
```)

= Flexible Felder

Ein Anteil wie `1fr` statt der Zeilenzahl macht das Feld flexibel: Es verhält
sich wie `v(1fr)` und teilt sich den freien Platz der Seite mit den anderen
flexiblen Feldern. Ein Feld mit `2fr` wird doppelt so hoch wie eines mit `1fr`.

#example(```typ
#block(height: 6cm)[
  Rechnung:
  #kariert(2fr)
  Antwort:
  #liniert(1fr)
]
```)

#info[
  In `teilaufgabe(workspace: kariert(1fr))` holt das Aufgabenpaket das Feld aus
  der Teilaufgabe heraus, damit es sich den Platz der Seite mit den anderen
  Feldern teilen kann.
]

== Eigene flexible Felder

`flex-area` baut ein solches Feld aus einer eigenen Zeichenfunktion. Sie
bekommt die tatsächliche Höhe. `is-flex-area` fragt, ob ein Inhalt ein flexibles
Feld ist.

#example(```typ
#block(height: 3cm)[
  #flex-area(1fr, height => rect(
    width: 100%,
    height: height,
    stroke: (dash: "dashed"),
  )[Platz für eine Skizze])
]

#is-flex-area(kariert(1fr)) #is-flex-area(kariert(4))
```)

= Fehlermeldungen

Jede falsche Eingabe bricht mit einer Meldung ab, die sagt, was zu schreiben
ist. Tippfehler bekommen einen Vorschlag, alte Namen ihren Nachfolger:

#show-code(```
patterns.kariert: unbekannter Parameter `grid-sice` – meintest du `grid-size`?
patterns.kariert: `items-spacing` heißt jetzt `item-rows`
patterns.kariert: `rows` steht vorn ohne Namen – `kariert(4)` schreiben
patterns.kariert: `width` erwartet eine Länge, bekam `12` (int) – die Kästchenzahl steht in `columns:`
```)

= Umstieg auf 0.5.0

Die Bausteine `kariert` und `liniert` heißen wie bisher. Geändert haben sich
Parameternamen und zwei Schreibweisen; am Bild ändert sich nichts. Ein alter
Name wird nie still angenommen: Das Paket bricht mit „heißt jetzt" ab.

== `kariert`

#table(
  columns: (1fr, 1fr),
  table.header([*bisher (0.0.2)*], [*jetzt (0.5.0)*]),
  [`kariert(rows: 4)`], [`kariert(4)`],
  [`kariert(rows: 1fr)`], [`kariert(1fr)`],
  [`kariert(4, 12)`, `width: 12` (Kästchen)], [`kariert(4, columns: 12)`],
  [`kariert(4, 5cm)`, `width: 5cm` (Länge)], [`kariert(4, width: 5cm)`],
  [`width: 2.5` (Kommazahl, in Kästchen)], [`width: 1.25cm` (Länge: Zahl mal Kästchengröße)],
  [`items-spacing: 3`], [`item-rows: 3` (ganze Zahl)],
  [`height: none`], [weglassen (Vorgabe ist `auto`)],
  [`line-stroke: …`], [`stroke: …`],
  [`fill-color: …`], [`fill: …`],
  [`content: […]`], [`overlay: […]`; `content: []` und `content: ""` weglassen],
  [`cnt: …`], [weglassen (hatte nie eine Wirkung)],
  [Zeilenzahl und `height` zugleich], [nur eines von beiden],
)

== `liniert`

#table(
  columns: (1fr, 1fr),
  table.header([*bisher (0.0.1, 0.0.2)*], [*jetzt (0.5.0)*]),
  [`liniert(rows: 3)`], [`liniert(3)`],
  [`liniert(3, 5cm)`], [`liniert(3, width: 5cm)`],
  [`liniert(3, 10)`], [`liniert(3)` (die Zahl wurde nie gelesen)],
  [`width: 10` (Zahl, in Zeilenhöhen)], [`width: 10cm` (Länge: Zahl mal Zeilenhöhe)],
  [`items-spacing: 2`], [`item-rows: 2` (ganze Zahl)],
  [`lineheight: 1cm`], [`line-height: 1cm`],
  [`line-stroke: …`], [`stroke: …`],
)

== Flexible Felder

#table(
  columns: (1fr, 1fr),
  table.header([*bisher (0.0.2)*], [*jetzt (0.5.0)*]),
  [`flex-feld(hoehe, zeichne)`], [`flex-area(height, body)`],
  [`ist-flex-feld(inhalt)`], [`is-flex-area(body)`],
)

#tip[
  Der Import `@schule/patterns:0.5.0` bringt neben den vier Funktionen die
  beiden alten Funktionsnamen als abbrechende Hinweise mit, dazu das Modul
  `internal` ohne zugesicherte Schnittstelle. Namen aus CeTZ
  reicht das Paket nicht weiter; wer in `annotations` zeichnet, importiert
  `@preview/cetz` selbst.
]

= API-Referenz

#show-module(read("../src/patterns.typ"), name: "patterns")
