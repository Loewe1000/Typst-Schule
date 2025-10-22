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
#import "@schule/klassenarbeit:0.1.1": *
```

## Schnellstart

```typ
#import "@schule/klassenarbeit:0.1.1": *

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

## Dokumentation

Die vollständige Dokumentation finden Sie im [Manual](docs/klassenarbeit-manual.pdf).

## Abhängigkeiten

- `@schule/arbeitsblatt:0.2.4`: Basis-Funktionalität für Aufgaben und Layout
- `@schule/aufgaben:0.1.2`: Aufgabenverwaltung und -strukturierung
- `@schule/klausurboegen:0.0.3`: Klausurbögen-Generierung

## Lizenz

MIT

## Autoren

- Lukas Köhl
- Alexander Schulz
