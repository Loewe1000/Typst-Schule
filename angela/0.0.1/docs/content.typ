#import "../../../schuldocs/0.1.0/lib.typ": show-example, show-module, show-code

= Über dieses Paket

Das `angela`-Paket ist ein *schulspezifisches Brief-Template* für die Angelaschule Osnabrück.
Es richtet automatisch den Schulkopf mit Logo, Schulname und blauer Trennlinie ein und
formatiert den Brieftext nach DIN 5008 (11 pt Calibri, 2,5 cm Ränder, 5 cm oberer Rand
für den Briefkopf).

Das Paket stellt folgende Elemente bereit:

- `brief` — Show-Rule, die die Seite als Angelaschule-Brief formatiert.
- `angela-dark` — Dunkelblauer Farbwert (`rgb(40, 80, 155)`), z. B. für eigene Linien.
- `angela-light` — Hellblauer Farbwert (`rgb(150, 180, 221)`).

*Hinweis:* Das Template benötigt `logo.svg` im selben Verzeichnis wie die Quelldatei
sowie die Schriftarten *Lucida Grande* (Schulname) und *Calibri* (Fließtext).
Eine Vorschau ohne diese Ressourcen ist daher nur lokal möglich.

= Schnellstart

Ein minimaler Brief:

#show-code[```typ
#import "@schule/angela:0.0.1": brief

#show: brief

Sehr geehrte Damen und Herren,

hiermit möchten wir Sie über die bevorstehenden Veranstaltungen informieren.

Mit freundlichen Grüßen

Die Schulleitung
```]

= Briefstruktur

Ein vollständiger Schulbrief nach DIN 5008 enthält Anschrift, Datum, Betreff und Grußformel.
In Typst werden Überschriften für Abschnitte des Briefes genutzt:

#show-code[```typ
#import "@schule/angela:0.0.1": brief

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
#import "@schule/angela:0.0.1": brief, angela-dark

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

Das Template verwendet folgende gestalterische Festlegungen:

#show-code[```typ
// Verfügbare Farbkonstanten des angela-Pakets:
angela-dark   // rgb(40, 80, 155)  — Dunkelblau (Kopfzeile, Linien, Akzente)
angela-light  // rgb(150, 180, 221) — Hellblau (z. B. Hintergrundfarben)
```]

Seiteneinstellungen des Templates (zur Information, nicht veränderbar):

- Papierformat: A4
- Schriftgröße: 11 pt, Schriftart: Calibri
- Zeilenabstand: 0,75 em, Blocksatz
- Ränder: 2,5 cm links/rechts, 2 cm unten
- Oberer Rand: 5 cm (für den Briefkopf mit Logo)
- Sprache: Deutsch (automatische Silbentrennung aktiv)

Das Logo wird automatisch rechtsbündig im Briefkopf platziert (Höhe: 4 cm).
Die dunkelblaue Trennlinie unter dem Briefkopf ist Teil des Templates und
orientiert sich am Corporate Design der Angelaschule.

= API-Referenz

#show-module(read("../angela.typ"), name: "angela")
