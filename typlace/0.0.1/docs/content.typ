#import "@schule/schuldocs:0.2.0": show-example, show-module, show-code

= Über dieses Paket

Das `typlace`-Paket erstellt *Sitzpläne für Klassenräume* aus einem einfachen Layout-String.
Tische, freie Plätze und das Lehrerpult werden als Rastergrafik dargestellt;
Schülernamen können automatisch auf die Sitzplätze verteilt werden.

Das Paket eignet sich für:

- Gedruckte Sitzpläne (A4, quer oder hoch)
- Projektion auf dem Beamer am Anfang der Stunde
- Zufällig generierte Sitzordnungen (in Kombination mit `@schule/random`)

= Layout-Syntax

Der Layout-String beschreibt den Raum *zeilenweise*. Jedes Zeichen entspricht einem Platz:

#show-code[```
X  – freier Platz (unsichtbar, kein Tisch)
T  – Schülertisch / Sitzplatz (erhält einen Namen)
P  – Teil des Lehrerpults (alle P-Felder werden zu einem großen Block zusammengefasst)
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
#import "@schule/typlace:0.0.1": typlace

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
  layout,               // str: Layoutstring (Zeichen: X, T, P; Zeilenumbruch: \n)
  namen: (),            // array: Namen, die auf T-Plätze verteilt werden
  tisch-breite: 2cm,    // length: Breite eines Tischfeldes
  tisch-hoehe: 1.2cm,   // length: Höhe eines Tischfeldes
  tisch-farbe: rgb("#cce0f5"),   // color: Füllfarbe der Schülertische
  pult-farbe:  rgb("#6b4c2a"),   // color: Füllfarbe des Lehrerpults
  rotation: 0,          // int: Rotation in Grad (0, 90, 180 oder 270, im Uhrzeigersinn)
)
```]

= API-Referenz

#show-module(read("../typlace.typ"), name: "typlace")
