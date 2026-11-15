# klassenarbeit

Vorlage für Klassenarbeiten, Klausuren und Tests im Schule-Typst-Ökosystem.
Sie baut auf `arbeitsblatt` auf und ergänzt:

- den Kopf mit Logo, Titel, Datum, Klasse und Lehrkraft, dazu Namensfeld und Info-Tabelle
- „Seite x von y“
- den Erwartungshorizont aus allen `erwartung(…)` der Arbeit
- ein Lösungsdokument und, auf Wunsch, Klausurbögen aus derselben Quelle

Der Baustein heißt deutsch (`klassenarbeit`), alles in den Klammern ist englisch.

## Import

```typ
#import "@schule/klassenarbeit:0.5.0": *
```

Damit stehen auch alle Namen aus `arbeitsblatt` bereit (`aufgabe`,
`teilaufgabe`, `loesung`, `erwartung`, `material`, `luecke`, `kariert` …).

## Beispiel

```typ
#import "@schule/klassenarbeit:0.5.0": *

#show: klassenarbeit.with(
  title: [Klassenarbeit Nr. 2],
  subtitle: [Quadratische Funktionen],
  class: [9a],
  date: [15.03.2026],
  teacher: [MÜ],
  points: "all",
  expectations: (achieved: true),
)

#aufgabe(title: [Nullstellen])[
  #teilaufgabe[
    Bestimme die Nullstellen von $f(x) = x^2 - 5x + 6$.
    #erwartung(3)[beide Nullstellen berechnet]
    #loesung[$x_1 = 2$, $x_2 = 3$]
  ]
]
```

## Mehrere Dateien aus einer Quelle

```bash
typst compile --features bundle --format bundle ka.typ ausgabe/
```

erzeugt `Klassenarbeit Nr. 2.pdf`, `Klassenarbeit Nr. 2 - Lösung.pdf` und, mit
`answer-sheets: true`, `Klassenarbeit Nr. 2 - Klausurbögen.pdf`. Ein
gewöhnliches `typst compile` erzeugt ein Dokument; `preview-variant` wählt,
welches (`"print"`, `"solutions"`, `"answer-sheets"`).

## Umstieg von älteren Versionen

Namen siehe Handbuch, Abschnitt „Umstieg auf 0.5.0“. Jeder alte Name bricht
mit einer Meldung ab, die den neuen nennt, zum Beispiel
``klassenarbeit.klassenarbeit: `erwartungen` heißt jetzt `expectations` ``.

## Abhängigkeiten

- `@schule/arbeitsblatt:0.5.0` (Seite, Schrift, Themes, Kästen, Helfer)
- `@schule/aufgaben:0.5.0` (Aufgaben, Lösungen, Erwartungshorizont)
- `@schule/klausurboegen:0.5.0` (Klausurbögen)

## Lizenz

MIT. Autoren: Lukas Köhl, Alexander Schulz.
