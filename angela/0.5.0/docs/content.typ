#import "@schule/schuldocs:0.3.1": show-code, show-module

= Über dieses Paket

Das `angela`-Paket ist die *Briefvorlage der Angelaschule Osnabrück*.
Es setzt den Schulkopf mit Schulname, Logo und blauer Trennlinie und
richtet den Brieftext ein (11 pt Calibri, 2,5 cm Ränder, 5 cm oberer Rand
für den Briefkopf).

Das Paket stellt drei Namen bereit:

- `brief` — die Vorlage; mit `#show: brief` wird das Dokument zum Brief der Angelaschule.
- `angela-dark` — das Dunkelblau der Schule (`rgb(40, 80, 155)`), zum Beispiel für eigene Linien.
- `angela-light` — das Hellblau der Schule (`rgb(150, 180, 221)`), zum Beispiel für Flächen.

*Hinweis:* Das Logo bringt das Paket selbst mit. Auf dem Rechner müssen die
Schriften *Lucida Grande* (Schulname), *Arial* (Unterzeile) und *Calibri*
(Brieftext) installiert sein; fehlt eine, warnt Typst und nimmt eine
Ersatzschrift.

= Schnellstart

Ein minimaler Brief:

#show-code[```typ
#import "@schule/angela:0.5.0": brief

#show: brief

Sehr geehrte Damen und Herren,

hiermit möchten wir Sie über die bevorstehenden Veranstaltungen informieren.

Mit freundlichen Grüßen

Die Schulleitung
```]

`brief` kennt keine Einstellungen. Ein benanntes Argument bricht mit einer
Meldung ab, zum Beispiel:

#show-code[```
angela.brief: unbekannter Parameter `titel` – weglassen, `brief` kennt keine benannten Argumente
```]

= Briefstruktur

Ein vollständiger Schulbrief enthält Anschrift, Datum, Betreff und Grußformel.
Abschnitte des Briefes bekommen gewöhnliche Überschriften:

#show-code[```typ
#import "@schule/angela:0.5.0": brief

#show: brief

// Empfängeranschrift (oben links, unterhalb des Briefkopfes)
Eltern der Klasse 8a \
Musterstraße 1 \
49074 Osnabrück

#v(1cm)

// Datum rechts ausrichten
#align(right)[Osnabrück, den #datetime.today().display("[day].[month].[year]")]

#v(0.5cm)

// Betreff (fett)
*Betreff: Elternbrief zur Klassenfahrt*

#v(0.5cm)

Sehr geehrte Eltern,

wir freuen uns, Ihnen mitteilen zu können, dass die Klassenfahrt vom
*14. bis 18. Oktober* stattfinden wird.

// Unterabschnitte mit Überschriften
== Ablauf

Der Bus fährt um 8:00 Uhr vom Schulhof ab. …

== Kosten und Zahlungsmodalitäten

Der Gesamtbetrag von *120 €* ist bis zum *30. September* zu überweisen. …

Mit freundlichen Grüßen

// Unterschriftenzeile
#v(2cm)
_Klassenleitung_ #h(3cm) _Schulleitung_
```]

= Absender und Empfänger

Für formale Briefe mit vollständigem Absender-Block:

#show-code[```typ
#import "@schule/angela:0.5.0": brief, angela-dark

#show: brief

// Absenderzeile (klein, über Empfängeranschrift)
#text(8pt, fill: angela-dark)[Angelaschule Osnabrück · Große Domsfreiheit 33 · 49074 Osnabrück]
#v(2mm)

// Empfänger
Max Mustermann \
Musterstraße 1 \
49074 Osnabrück

#v(1cm)
#align(right)[Osnabrück, den 01.09.2025]
#v(0.5cm)

*Betreff: Einladung zum Elternsprechtag*

Sehr geehrter Herr Mustermann, …
```]

= Gestaltungshinweise

Die beiden Schulfarben sind gewöhnliche Farbwerte und lassen sich überall
einsetzen, wo Typst eine Farbe erwartet:

#show-code[```typ
#import "@schule/angela:0.5.0": brief, angela-dark, angela-light

#show: brief

// angela-dark:  rgb(40, 80, 155)   — Dunkelblau (Kopfzeile, Linien, Akzente)
// angela-light: rgb(150, 180, 221) — Hellblau (zum Beispiel Flächen)
#line(length: 100%, stroke: 1pt + angela-dark)

#block(width: 100%, inset: 8pt, radius: 2pt, fill: angela-light.lighten(60%))[
  *Termin:* Elternsprechtag am 12. November, 15 bis 19 Uhr.
]
```]

Feste Einstellungen der Vorlage (zur Information, nicht veränderbar):

- Papierformat: A4
- Schriftgröße: 11 pt, Schriftart: Calibri
- Zeilenabstand: 0,75 em, Blocksatz
- Ränder: 2,5 cm links/rechts, 2 cm unten
- Oberer Rand: 5 cm (für den Briefkopf mit Logo)
- Sprache: Deutsch (automatische Silbentrennung aktiv)

Das Logo steht rechtsbündig im Briefkopf (Höhe: 4 cm).
Die dunkelblaue Trennlinie unter dem Briefkopf gehört zur Vorlage und
folgt dem Erscheinungsbild der Angelaschule.

= Umstieg auf 0.5.0

Version 0.5.0 ändert an diesem Paket keinen Namen; ein Brief sieht nach dem
Umstieg genauso aus wie vorher. Im Dokument ändert sich nur die
Versionsnummer in der Importzeile.

#table(
  columns: (1fr, 1fr),
  table.header([*alt (0.0.1)*], [*neu (0.5.0)*]),
  [`#import "@schule/angela:0.0.1": …`], [`#import "@schule/angela:0.5.0": …`],
  [`brief`], [`brief` (unverändert)],
  [`angela-dark`], [`angela-dark` (unverändert)],
  [`angela-light`], [`angela-light` (unverändert)],
)

Neu ist die Prüfung der Argumente: `brief` lehnt jedes benannte und jedes
überzählige Argument mit einer deutschen Meldung ab
(`angela.brief: unbekannter Parameter …`). Bisher meldete Typst an dieser
Stelle selbst einen Fehler; kein Brief, der bisher kompilierte, ist betroffen.

= API-Referenz

#show-module(read("../src/brief.typ"), name: "angela")
