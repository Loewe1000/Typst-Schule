#import "@schule/schuldocs:0.3.1": show-example, show-module, show-code
#import "../src/lib.typ": hathi-level

// Das Beispiel-Level aller Abschnitte.
#let level = xml("../examples/level.abz")
// Ein Level ohne Kacheln, um einzelne Kachelarten zu zeigen.
#let empty-level = xml(bytes("<abbozza><world><field/></world></abbozza>"))

// Zeigt den Quelltext und setzt genau diesen Quelltext. `hathi-level` und
// `level` sind darin bekannt; so kann kein Beispiel vom Paket abweichen.
#let example(source, ..args) = show-example(
  rendered: eval(source.text, mode: "markup", scope: (hathi-level: hathi-level, level: level)),
  source: source,
  ..args,
)

// Zeigt eine Datei aus examples/ als Quelltext und setzt sie.
#let example-file(name) = show-example(
  rendered: include "../examples/" + name,
  source: raw(read("../examples/" + name).trim(), lang: "typ", block: true),
)

= Über dieses Paket

Hathi ist ein Lernspiel aus _Abbozza! Worlds_ für den Anfangsunterricht in
Informatik: Die Elefantin Hathi wird mit Programmierblöcken über ein Spielfeld
aus Kacheln gesteuert, sammelt Bananen, schiebt Kisten und hisst Flaggen.

Das Paket `abbozza` setzt ein solches Level als Bild. Es liest die Level-Datei
(`.abz`, ein XML-Format) und zeichnet das Spielfeld in Schrägansicht, in der
Größe und Fassung, die das Blatt braucht. So steht auf dem Arbeitsblatt oder in
der Klassenarbeit genau das Level, das die Klasse am Rechner sieht.

Das Paket hat eine Funktion: `hathi-level`.

= Schnellstart

Die Level-Datei wird in Abbozza! Worlds gespeichert, neben das Dokument gelegt
und mit `xml(…)` geladen:

#example-file("schnellstart.typ")

In den folgenden Beispielen ist `level` immer dieses geladene Level.

= Kachelarten

Die Arten heißen wie in der Level-Datei. Das Paket kennt diese:

#{
  let kinds = (
    ("grass", (:), [Gras, begehbar]),
    ("water", (:), [Wasser]),
    ("ice", (:), [Eis]),
    ("rock", (:), [Fels]),
    ("tree", (:), [Baum]),
    ("flag", (:), [Flagge; mit `hue` in anderer Farbe]),
    ("bananas", (capacity: 3), [Bananen; `capacity` ist die Anzahl]),
    ("crate", (capacity: 2), [Kiste; `capacity` ist die Anzahl, die hineinpasst]),
    ("lion", (:), [Löwe]),
    ("hathi", (direction: "0"), [Hathi; `direction` ist die Blickrichtung]),
    ("hartmut", (direction: "0"), [Hartmut; `direction` ist die Blickrichtung]),
  )
  // Als gesetztes Beispiel, damit die Bilder auch auf der Website erscheinen.
  show-example(rendered: table(
    columns: (auto, auto, 1fr),
    align: (left + horizon, center + horizon, left + horizon),
    table.header([*Art*], [*Bild*], [*Bedeutung*]),
    ..kinds
      .map(((kind, extra, meaning)) => (
        raw("\"" + kind + "\""),
        hathi-level(empty-level, tile-size: 12mm, extra-tiles: ((kind: kind, at: (0, 0), ..extra),)),
        meaning,
      ))
      .flatten(),
  ))
}

Eine Art, die das Paket nicht kennt, wird ausgelassen; an ihrer Stelle bleibt
das Feld leer.

= Größe und Druckfassung

`tile-size` ist die Höhe einer Kachel. Die ganze Zeichnung wächst mit; die
Vorgabe ist `25mm`.

#example(```typ
#hathi-level(level, tile-size: 15mm)
```)

`print: true` setzt Gras und Wasser in hellen Farben, die auch auf einem
Schwarz-Weiß-Drucker gut zu unterscheiden sind:

#example(```typ
#hathi-level(level, tile-size: 20mm, print: true)
```)

= Kacheln ersetzen

`replacements` tauscht Kachelarten aus, bevor gezeichnet wird. Der Schlüssel
ist die Art in der Datei, der Wert die Art, die stattdessen erscheint. So
entstehen aus einer Datei mehrere Fassungen, etwa ein Level ohne Löwen und
ohne Bananen:

#example(```typ
#hathi-level(
  level,
  tile-size: 20mm,
  replacements: (lion: "grass", bananas: "grass"),
)
```)

Ersetzt wird auch in den zusätzlichen Kacheln des nächsten Abschnitts.

= Zusätzliche Kacheln

`extra-tiles` legt weitere Kacheln über das Level. Jeder Eintrag ist ein
Dictionary mit diesen Schlüsseln:

#table(
  columns: (auto, auto, 1fr),
  table.header([*Schlüssel*], [*Typ*], [*Bedeutung*]),
  [`kind`], [`str`], [Kachelart, siehe oben. Pflicht.],
  [`at`], [`array`], [Feld `(x, y)` in den Koordinaten der Level-Datei, zwei ganze Zahlen. Pflicht.],
  [`capacity`], [`int`, `str`], [Anzahl bei `"bananas"` und `"crate"`; dort Pflicht.],
  [`direction`], [`str`], [Blickrichtung `"0"` bis `"3"` bei `"hathi"` und `"hartmut"`; dort Pflicht.],
  [`hue`], [`int`, `float`], [Farbton der Flagge in Grad (0 bis 360). Ohne Angabe ist sie blau.],
)

Damit kommen eine zweite Figur und ihre Flagge ins Bild, ohne dass die Datei
geändert wird:

#example(```typ
#hathi-level(
  level,
  tile-size: 20mm,
  extra-tiles: (
    (kind: "hartmut", at: (5, 1), direction: "2"),
    (kind: "flag", at: (0, 2), hue: 344),
    (kind: "bananas", at: (1, 0), capacity: 5),
  ),
)
```)

Die vier Blickrichtungen `"0"` bis `"3"` in einer Reihe:

#example(```typ
#hathi-level(
  level,
  tile-size: 20mm,
  extra-tiles: range(4).map(n => (kind: "hartmut", at: (n, 3), direction: str(n))),
)
```)

= Im Arbeitsblatt

`hathi-level` liefert gewöhnlichen Inhalt. Die Zeichnung lässt sich deshalb
ausrichten, in eine Aufgabe setzen oder neben Text stellen wie jedes Bild:

#example-file("klassenarbeit.typ")

In `aufgabe`, `teilaufgabe` und `minipage` der Pakete `arbeitsblatt` und
`klassenarbeit` steht der Aufruf genauso.

= Fehlermeldungen

Das Paket prüft jeden Aufruf und nennt in der Meldung die Abhilfe. Einige
Beispiele:

#table(
  columns: (1fr, 1.3fr),
  table.header([*Aufruf*], [*Meldung*]),
  [`hathi-level(level, tile-sise: 2cm)`],
  [abbozza.hathi-level: unbekannter Parameter `tile-sise` – meintest du `tile-size`?],
  [`hathi-level(level, tile-size: 2)`],
  [abbozza.hathi-level: `tile-size` erwartet eine Länge, bekam `2` (int) – zum Beispiel `25mm`],
  [`hathi-level(level, extra-tiles: ((kind: "crate", at: (1, 1)),))`],
  [abbozza.hathi-level: Kachel `"crate"` ohne `capacity` – die Anzahl angeben, zum Beispiel `capacity: 3`],
  [`hathi-level(level, extra-tiles: ((kind: "hathi", at: (1, 1), direction: 2),))`],
  [abbozza.hathi-level: `direction: 2` – die Blickrichtung ist ein Text: `direction: "2"` schreiben],
  [`hathi-level(level, extra-tiles: ((kind: "flag", at: (1, 1), hue: "rot"),))`],
  [abbozza.hathi-level: `hue` erwartet eine ganze Zahl oder eine Zahl, bekam `"rot"` (str) – zum Beispiel `344`],
)

= Umstieg auf 0.5.0

Mit 0.5.0 folgen die Namen der gemeinsamen Konvention der Schule-Pakete. Alte
Namen brechen mit einer Meldung ab, die den neuen Namen nennt; am Bild ändert
sich nichts.

#table(
  columns: (1fr, 1fr, 1.4fr),
  table.header([*bis 0.0.1*], [*ab 0.5.0*], [*Hinweis*]),
  [`render-hathi-level(…)`], [`hathi-level(…)`], [Funktion umbenannt],
  [`scale: 1`], [`tile-size: 25mm`],
  [Länge statt Faktor: `scale: s` ist `tile-size: s * 25mm`, also `scale: 1.3` → `tile-size: 32.5mm`. Die Meldung rechnet um.],
  [`replace: (…)`], [`replacements: (…)`], [],
  [`extra-tiles: ((type: …, pos: …),)`], [`extra-tiles: ((kind: …, at: …),)`],
  [Schlüssel umbenannt; `capacity`, `hue`, `direction` bleiben],
  [`print`, `extra-tiles`], [unverändert], [],
  [`canvas`, `draw` und weitere CeTZ-Namen über `#import "@schule/abbozza:0.0.1": *`],
  [nicht mehr enthalten],
  [Das Paket reicht CeTZ nicht mehr weiter. Wer die Namen braucht, importiert CeTZ selbst.],
)

Vorher und nachher:

#show-code(```typ
// 0.0.1
#import "@schule/abbozza:0.0.1": *
#render-hathi-level(xml("level.abz"), scale: 0.8, replace: ("lion": "grass"),
  extra-tiles: ((type: "flag", pos: (1, 3), hue: 344),))

// 0.5.0
#import "@schule/abbozza:0.5.0": hathi-level
#hathi-level(xml("level.abz"), tile-size: 20mm, replacements: (lion: "grass"),
  extra-tiles: ((kind: "flag", at: (1, 3), hue: 344),))
```)

= API-Referenz

#show-module(read("../src/hathi-level.typ"), name: "abbozza", only: ("hathi-level",))
