#import "@schule/schuldocs:0.2.0": show-example, show-module, show-code

= Über dieses Paket

Das `patterns`-Paket stellt vorformatierte Schreibflächen für Arbeitsblätter bereit:
*kariertes Papier* (`kariert`) und *liniertes Papier* (`liniert`).
Beide Funktionen lassen sich nahtlos in Arbeitsbereiche, Tabellen und zweispaltige Layouts
einbetten und bieten umfangreiche Konfigurationsmöglichkeiten für Rastergröße, Höhe,
Breite, Beschriftungen und Linienfarben.

Typische Einsatzgebiete:

- Freiraum für Berechnungen auf Arbeitsblättern
- Tabellarische Messwerttabellen mit vorgedruckten Zeilenbeschriftungen
- Schreibübungsblätter mit liniertem Papier

= Kariertes Papier

== Einfaches Beispiel

Der erste positionale Parameter gibt die Zeilenanzahl an (bei Standardrastergröße 0,5 cm):

#show-example(
  rendered: {
    import "../patterns.typ": kariert
    kariert(5)
  },
  source: ```typ
#import "@schule/patterns:0.0.2": kariert

#kariert(5)
  ```,
)

== Feste Höhe

Anstelle einer Zeilenanzahl kann auch eine absolute Höhe angegeben werden:

#show-example(
  rendered: {
    import "../patterns.typ": kariert
    kariert(height: 4cm)
  },
  source: ```typ
#kariert(height: 4cm)
  ```,
)

== Größeres Raster

Mit `grid-size` wird die Kantenlänge einer Rasterzelle festgelegt (Standard: 0,5 cm):

#show-example(
  rendered: {
    import "../patterns.typ": kariert
    kariert(4, grid-size: 1cm)
  },
  source: ```typ
#kariert(4, grid-size: 1cm)
  ```,
)

== Zeilen mit Beschriftungen (items)

Mit dem `items`-Parameter können Zeilenbeschriftungen angegeben werden.
`items-spacing` legt den Abstand zwischen zwei Beschriftungen in Rastereinheiten fest:

#show-example(
  rendered: {
    import "../patterns.typ": kariert
    kariert(
      items: ("Messung 1", "Messung 2", "Messung 3"),
      items-spacing: 3,
      grid-size: 0.75cm,
    )
  },
  source: ```typ
#kariert(
  items: ("Messung 1", "Messung 2", "Messung 3"),
  items-spacing: 3,
  grid-size: 0.75cm,
)
  ```,
)

= Liniertes Papier

== Einfaches Beispiel

Vier linierte Zeilen (Standard-Zeilenhöhe: 1 cm):

#show-example(
  rendered: {
    import "../patterns.typ": liniert
    liniert(4)
  },
  source: ```typ
#import "@schule/patterns:0.0.2": liniert

#liniert(4)
  ```,
)

== Angepasste Zeilenhöhe

#show-example(
  rendered: {
    import "../patterns.typ": liniert
    liniert(3, line-height: 1.5cm)
  },
  source: ```typ
#liniert(3, line-height: 1.5cm)
  ```,
)

== Liniertes Papier mit Beschriftungen

Analog zu `kariert` können mit `items` Zeilenbezeichner angegeben werden:

#show-example(
  rendered: {
    import "../patterns.typ": liniert
    liniert(
      items: ("Name:", "Klasse:", "Datum:"),
      items-spacing: 1,
    )
  },
  source: ```typ
#liniert(
  items: ("Name:", "Klasse:", "Datum:"),
  items-spacing: 1,
)
  ```,
)

= Parameter

== `kariert`

#show-code[```typ
#kariert(
  rows: 1,              // Zeilenanzahl (alternativ: erster positiver Arg.)
  width: auto,          // Breite; auto = volle Textbreite; zweiter pos. Arg.
  items: (),            // Array von Zeilenbeschriftungen (string oder content)
  items-spacing: 2,     // Abstand zwischen Beschriftungen in Rastereinheiten
  grid-size: 0.5cm,     // Kantenlänge einer Rasterzelle
  height: none,         // Feste Gesamthöhe (überschreibt rows)
  annotations: (),      // Anmerkungen (intern genutzt)
  line-stroke: (        // Linienstil
    paint: rgb("#AAAAAA").lighten(10%),
    dash: "solid",
    thickness: 0.5pt,
  ),
  fill-color: white,    // Hintergrundfarbe des Rasters
  content: [],          // Überlagernder Inhalt (z. B. Aufgabentext)
)
```]

== `liniert`

#show-code[```typ
#liniert(
  rows: 1,              // Zeilenanzahl (alternativ: erster pos. Arg.)
  width: auto,          // Breite; auto = volle Textbreite; zweiter pos. Arg.
  items: (),            // Array von Zeilenbeschriftungen
  items-spacing: 1,     // Abstand zwischen Beschriftungen in Zeileneinheiten
  line-height: 1cm,     // Höhe einer Zeile
  line-stroke: (        // Linienstil
    paint: black.lighten(50%),
    thickness: 0.5pt,
  ),
)
```]

= API-Referenz

#show-module(read("../patterns.typ"), name: "patterns")
