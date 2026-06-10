# Klassenarbeit

Ein Typst-Paket zur Erstellung von Klassenarbeiten und Tests für den Schulunterricht.

## Features

- **Professionelles Layout**: Vorkonfiguriertes Layout mit Header für Titel, Klasse, Datum und Lehrer
- **Aufgabenverwaltung**: Strukturierte Aufgaben und Teilaufgaben mit automatischer Nummerierung
- **Erwartungshorizont**: Automatische Generierung von Erwartungshorizonten mit Punkteverteilung
- **Bewertungsbögen**: Integrierte Bewertungstabellen für die Korrektur
- **Klausurbögen**: Automatische Generierung von Klausurbögen für die Schülerverwaltung
- **Flexibilität**: Anpassbare Layouts, Schriftarten und Seiteneinstellungen

## Installation

```typ
#import "@schule/klassenarbeit:0.3.0": *
```

## Schnellstart

```typ
#import "@schule/klassenarbeit:0.3.0": *

#show: klassenarbeit.with(
  title: [Klassenarbeit],
  subtitle: [Mathematik],
  class: [10a],
  date: [15.03.2025],
  teacher: [Müller],
  punkte: "alle",
  erwartungen: true,
)

#aufgabe(title: [Gleichungen])[
  #teilaufgabe[
    Lösen Sie: $2x + 5 = 13$
    #erwartung(2, [Äquivalenzumformung korrekt])
    #loesung[$x = 4$]
  ]
]
```

## Bundle-Export (neu in 0.3.0)

Mit Typst 0.15+ erzeugt eine Quelldatei im Bundle-Modus automatisch mehrere Dateien:

```bash
typst compile --features bundle --format bundle ka.typ ausgabe/
```

Es entstehen standardmäßig:

- `{Titel}.pdf` – die Klassenarbeit (Druckfassung)
- `{Titel} - Lösung.pdf` – Lösungen inline plus Erwartungshorizont
- `{Titel} - Klausurbögen.pdf` – nur mit `klausurboegen: true` bzw. einem
  Einstellungs-Dictionary: ohne `ergebnisse` ein leerer Bogen, mit
  `ergebnisse` (CSV-Zeilen) ausgefüllte Bögen pro Schüler

Klausurbögen sind ab 0.3.0 **nie mehr Teil der Klassenarbeits-Datei**, sondern
immer eine eigene Datei. Außerhalb des Bundles wählt `variante: "druck" |
"loesung" | "klausurboegen"`, welches Dokument die Einzelkompilation erzeugt
(Standard: `"druck"`). Der Basisname der Dateien lässt sich mit `dateiname:`
überschreiben; bei mehreren Klassenarbeiten in einer Datei muss er eindeutig
sein.

## Dokumentation

Die vollständige Dokumentation finden Sie im [Manual](docs/klassenarbeit-manual.pdf).

## Abhängigkeiten

- `@schule/arbeitsblatt:0.3.0`: Basis-Funktionalität für Aufgaben und Layout
- `@schule/aufgaben:0.3.0`: Aufgabenverwaltung und -strukturierung
- `@schule/klausurboegen:0.0.3`: Klausurbögen-Generierung

## Lizenz

MIT

## Autoren

- Lukas Köhl
- Alexander Schulz
