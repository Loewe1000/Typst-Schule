#import "@schule/schuldocs:0.2.0": show-example, show-module, show-code

= Über dieses Paket

Das `abbozza`-Paket visualisiert *Hathi-Spielfelder* als Hex-Kachel-Diagramme mit CeTZ.
Hathi ist ein Lernspiel für den Informatikunterricht, bei dem Schülerinnen und Schüler
eine Elefantin namens Hathi durch ein hexagonales Labyrinth navigieren, indem sie
Scratch-ähnliche Programmierblöcke anordnen.

Das Paket liest das Level-Format des Hathi-Editors (XML als Typst-Daten) und rendert
es als farbige Hex-Grafik — ideal für Aufgabenblätter, bei denen das Level abgedruckt wird.

Folgende Kacheltypen werden unterstützt:

- `grass` — Grasfeld (Standard-Weg)
- `flag` — Startfeld (Hathi beginnt hier)
- `water` — Wasserfeld (nicht begehbar)
- `ice` — Eisfeld
- `rock` — Fels (nicht begehbar)
- `tree` — Baum (nicht begehbar)
- `bananas` — Ziel/Sammelfeld
- `crate` — Kiste
- `lion` — Löwe (Hindernis)
- `hathi` — Hathi-Figur
- `hartmut` — Hartmut-Figur
- `_` — leeres Feld (keine Kachel)

= Schnellstart

Das Level wird aus der Hathi-XML-Datei geladen (als Typst `xml()`-Aufruf):

#show-code[```typ
#import "@schule/abbozza:0.0.1": render-hathi-level

// Level aus XML-Datei laden:
#let level = xml("mein-level.xml")

// Level rendern:
#render-hathi-level(level)
```]

Die XML-Datei wird aus dem Hathi-Web-Editor exportiert und enthält eine
`<world>`-Struktur mit `<tile>`- und `<item>`-Einträgen.

= Skalierung und Druckmodus

Mit `scale` wird die Gesamtgröße der Grafik angepasst. Der `print`-Modus
schaltet auf schwarzweiß-kompatible Farben um:

#show-code[```typ
// Verkleinert (z. B. für zweispaltiges Layout)
#render-hathi-level(level, scale: 0.7)

// Druckmodus: Kontrastreichere, druckbare Farben
#render-hathi-level(level, scale: 1, print: true)

// Große Darstellung für Beamer oder Folie
#render-hathi-level(level, scale: 2.0)
```]

= Kachel-Ersetzungen

Mit dem `replace`-Parameter können Kacheltypen durch andere ersetzt werden.
Das ist nützlich, um z. B. Lösung und Aufgabe aus demselben Level zu erzeugen:

#show-code[```typ
// Alle Bananen-Felder durch leere Gras-Felder ersetzen (Aufgaben-Variante):
#render-hathi-level(
  level,
  replace: ("bananas": "grass"),
)

// Mehrere Ersetzungen:
#render-hathi-level(
  level,
  replace: (
    "lion":  "grass",   // Löwen entfernen
    "crate": "grass",   // Kisten entfernen
  ),
)
```]

= Zusätzliche Kacheln

Mit `extra-tiles` können programmatisch Kacheln hinzugefügt werden,
die im Level selbst nicht vorhanden sind. Jede Kachel ist ein Dictionary
mit `type` und `pos` (Hex-Koordinaten `(col, row)`) sowie optionalen
Feldern `capacity`, `hue` und `direction`:

#show-code[```typ
#render-hathi-level(
  level,
  extra-tiles: (
    (type: "flag",    pos: ("2", "3")),
    (type: "bananas", pos: ("5", "1"), capacity: "3"),
  ),
)
```]

= Parameter

#show-code[```typ
#render-hathi-level(
  level,              // content: XML-Daten des Levels (aus xml("…"))
  extra-tiles: (),    // array: Zusätzliche Kacheln als Dictionary-Array
                      //   (type: str, pos: (col, row), capacity?, hue?, direction?)
  scale: 1,           // float: Skalierungsfaktor der Gesamtgrafik
  print: false,       // bool: Druckmodus (schwarzweiß-kompatible Farben)
  replace: (:),       // dict: Kachel-Ersetzungen (Kacheltyp → neuer Typ)
)
```]

= Integration in Arbeitsblätter

Typischer Workflow für ein Informatik-Aufgabenblatt:

#show-code[```typ
#import "@schule/arbeitsblatt:0.2.4": *
#import "@schule/abbozza:0.0.1": render-hathi-level

#show: arbeitsblatt.with(title: "Hathi – Level 3", class: "5a")

= Aufgabe

Schreibe ein Programm, das Hathi zum Ziel führt.

#let level = xml("level3.xml")

#align(center)[
  #render-hathi-level(level, scale: 0.9)
]

+ Wie viele Schritte braucht Hathi mindestens?
+ Nutze eine Schleife, um den Weg zu kürzen.
```]

= API-Referenz

#show-module(read("../hathi-render.typ"), name: "abbozza")
