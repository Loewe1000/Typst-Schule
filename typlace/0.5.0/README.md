# typlace

Erstellt **Sitzpläne für Klassenräume** aus einem einfachen mehrzeiligen String –
und sucht auf Wunsch die Sitzordnung, die am besten zu den Wünschen der Klasse passt.

Bausteine heißen deutsch (`typlace`, `sitzordnung`, `wunschliste`), alles in den
Klammern (Parameter, Schlüssel, Werte) ist englisch. Der Layout-String und die
Wunschliste samt ihren Positionsangaben (`vorne`, `v`, `!mitte` …) sind Daten und
bleiben deutsch.

## Layout-Zeichen

| Zeichen | Bedeutung |
|---------|-----------|
| `X` `x` `.` `_` | Freier Platz (unsichtbar) |
| `T` | Ein Sitzplatz; über Kanten zusammenhängende `T` bilden automatisch einen Gruppentisch |
| `1`–`9`, `a`–`z`, `A`–`Z` | Ein Sitzplatz mit ausdrücklicher Tischzugehörigkeit: gleiches Zeichen = gleicher Gruppentisch |
| `o` `O` `#` | Tischfläche ohne Sitzplatz |
| `P` | Teil des Lehrerpults – alle `P` werden zu **einem** Block zusammengefasst |

Leerraum am Zeilenanfang und -ende wird ignoriert, eingerückte Strings sind also erlaubt.
Zwischen den Sitzplätzen eines Gruppentisches wird die Tischfläche automatisch gezeichnet.

## Sitzplan zeichnen

```typst
#import "@schule/typlace:0.5.0": typlace

#let layout = "
  .11..22.
  .11..22.
  .11..22.
  ........
  33.44.55
  33.44.55
  33.44.55
  ........
  ...PP..."

#typlace(layout, names: ("Anna", "Ben", "Clara", ...), number: true)
```

## Sitzordnung nach Schülerwünschen

### 1. Wunschliste als CSV

Spalten mit `|` getrennt:

```
Name|Position|Wunsch|Wunsch|Wunsch
Anna Meier|v|Ben Schulz|Clara Weiß|!Max Klein
Ben Schulz||Anna Meier
Clara Weiß|!m|Anna Meier|Ben Schulz
David Kern|hinten rechts|
```

- **Spalte 1** – Name (Pflicht, muss eindeutig sein)
- **Spalte 2** – Sitzwunsch im Raum, darf leer bleiben. Zwei unabhängige Achsen:
  Tiefe `vorne` | `mitte` | `hinten` (`v` | `m` | `h`) und Seite `links` | `rechts` (`l` | `r`),
  Quermitte `mitte-quer`. Beide Achsen lassen sich **kombinieren** – `vorne-rechts`,
  `vorne rechts`, `vorne, rechts`, `vorne/rechts` und `v-r` bedeuten dasselbe.
  Verneinbar mit `!` oder „nicht": `!m`, `nicht vorne`, `vorne-!mitte`.
- **ab Spalte 3** – beliebig viele Namen. Ein führendes `!` heißt „möchte **nicht**
  neben dieser Person sitzen“.

Wunschnamen müssen nicht exakt geschrieben sein: Groß-/Kleinschreibung, eindeutige
Vornamen und Abkürzungen wie `Clara W.` werden aufgelöst. Unbekannte Namen brechen
mit einer Meldung ab (`strict: false` warnt stattdessen nur).

### 2. Plan berechnen

```typst
#import "@schule/typlace:0.5.0": seating-report, sitzordnung, typlace

#let plan = sitzordnung(layout, read("wuensche.csv"), seed: 42)

#typlace(layout, names: plan.names)
#seating-report(plan)
```

`read()` verträgt ungleich lange Zeilen; Typsts `csv(..., delimiter: "|")` verlangt
in jeder Zeile gleich viele Spalten.

### 3. Feste Vorgaben der Lehrkraft

```typst
#let plan = sitzordnung(layout, read("wuensche.csv"), constraints: (
  fixed: ("Ben Schulz": 3),                   // feste Platznummer
  must-front: ("Eva Lang",),                  // auch must-middle/-back/-left/-right
  apart: (("Max Klein", "Moritz Groß"),),     // nie am selben Gruppentisch
  together: (("Ida Berg", "Jonas Kern"),),    // immer am selben Gruppentisch
))
```

Vorgaben sind **hart**: der zurückgegebene Plan verletzt sie nie. Lassen sie sich
nicht alle einhalten, bricht die Funktion mit einer Erklärung ab. Die Platznummern
für `fixed` zeigt `typlace(..., number: true)` an.

## Wie bewertet wird

| Kriterium | Standardgewicht |
|---|---|
| Wunschperson sitzt unmittelbar daneben, gegenüber oder über Eck | `adjacent: 1.0` |
| Wunschperson am selben Gruppentisch, aber weiter weg | `table: 0.9` |
| 1., 2. und 3. Wunsch | `ranks: (1.0, 1.0, 1.0)` – gleichwertig |
| 1., 2. und 3. *erfüllter* Wunsch eines Schülers | `tiers: (1.0, 0.7, 0.45)` – fallend |
| Faktor nach Anzahl der *genannten* Namen | `wish-count: (1.0, 1.0, 1.0)` – aus |
| Bonus dafür, überhaupt einen Wunsch erfüllt zu bekommen | `fairness: 2.0` |
| Abgelehnte Person am selben Tisch | `rejection: -2.0` |
| Erfüllter Positionswunsch je Achse | `position: 0.5` |
| Gemiedene Zone doch zugeteilt | `position-avoided: -0.5` |

Zwei Werte sorgen für eine gleichmäßige Verteilung. Der **Fairness-Bonus** greift
an der Schwelle „mindestens ein Wunsch": ohne ihn bekämen wenige Schüler alle
Wünsche und andere gar keinen. Die **Stufen** wirken oberhalb davon: weil der
zweite erfüllte Wunsch weniger zählt als der erste und der dritte noch weniger,
ist eine Sitzordnung, in der alle zwei von drei Wünschen bekommen, mehr wert als
eine, in der die einen drei und die anderen einen bekommen.

`tiers: (1.0, 1.0, 1.0)` schaltet das ab und zählt nur die Gesamtzahl erfüllter
Wünsche; kleinere Werte wie `(1.0, 0.5, 0.25)` verteilen noch strenger gleich.

Naheliegend wäre, zusätzlich Schüler zu bevorzugen, die **wenige Namen genannt**
haben – wer nur einen nennt, hat schließlich keine zweite Chance. Dafür gibt es
`wish-count`, standardmäßig aber ausgeschaltet: der Fairness-Bonus leistet das
bereits, weil er je Schüler einmal gilt, unabhängig von der Länge seiner Liste.
An einer echten Klasse gemessen bekam das einzige Kind mit nur einem Wunsch
diesen in jeder Einstellung und bei jedem Seed, während `(1.3, 1.15, 1.0)` im
Mittel anderthalb erfüllte Wünsche anderswo kostete. Einschalten mit
`weights: (wish-count: (1.3, 1.15, 1.0))`.
`seating-report` zeigt das Ergebnis als Kreuztabelle: eine Reihe je Anzahl
*genannter* Wünsche, darin die Kinder nach Anzahl *erfüllter* Wünsche. So
vermischen sich „drei von drei" und „einer von einem" nicht.

```
        davon erfüllt:  0   1   2   3
 1 Wunsch genannt       ·   1
2 Wünsche genannt       ·   2   ·
3 Wünsche genannt       ·   3  11  10
```

Dieselben Zahlen stehen in `statistics.distribution` als Dictionary: Schlüssel ist
die Anzahl genannter Wünsche, Wert ein Array, dessen Index die Anzahl erfüllter
Wünsche ist — `distribution.at("3").at(2)` sind also die Kinder, die zwei ihrer
drei Wünsche bekommen haben. Alle Gewichte lassen sich über
`weights: (...)` ändern.

### Position gegen Mitschülerwünsche abwägen

Statt am Gewicht `position` zu drehen, lässt sich direkt angeben, welchen Anteil
die Sitzwünsche im Raum an den insgesamt erreichbaren Punkten haben sollen:

```typst
#sitzordnung(layout, read("wuensche.csv"), position-share: 15%)
```

`0%` ignoriert vorne/hinten/links/rechts vollständig, `50%` stellt beide Seiten
gleich. Das Gewicht wird aus der tatsächlichen Klasse berechnet, der Anteil
stimmt also unabhängig davon, wie viele Positionswünsche überhaupt vorliegen.
Der Bericht weist über `statistics.wish-points` und
`statistics.position-points` aus, wie es tatsächlich ausgegangen ist.

Zur Größenordnung, gemessen an einer 28er-Klasse mit 72 Wünschen und 8
Positionswünschen: `0%` → 61 Wünsche und 2 Positionen erfüllt, `20%` → 57 und 3,
`50%` → 58 und 3. Viel mehr als 3 der 8 Positionswünsche sind nicht zu holen,
weil eine Zone dem ganzen Gruppentisch gilt und damit unmittelbar gegen die
Freundesgruppe steht.

## Rechenkern

Die Suche läuft standardmäßig im mitgelieferten WASM-Plugin (`src/optimierer.wasm`,
Rust-Quelltext unter `rust/`). Es ist eine 1:1-Übertragung von `src/optimizer.typ`:
gleicher Zufallsgenerator, gleiche Reihenfolge der Tausche, gleiche Reihenfolge
der Additionen. Bei gleichem `seed` liefern beide Fassungen denselben Plan —
gemessen an einer 30er-Klasse identisch bis zur vierten Nachkommastelle und bis
auf den einzelnen geprüften Tausch.

| | 20 Startpläne | 2000 Startpläne |
|---|---|---|
| `engine: "typst"` | 12,0 s | ~20 min |
| `engine: "wasm"` | 0,22 s | 14,3 s |

Die reine Suche ist damit rund **75-fach schneller**. Nach jedem Plugin-Aufruf
rechnet Typst die gelieferte Sitzordnung selbst nach; weichen die Punktzahlen ab,
bricht das Paket ab, statt still ein falsches Ergebnis zu setzen.

Weil Rechenzeit dadurch billig ist, sind die Voreinstellungen für `quality`
beim WASM-Kern viel großzügiger (50 / 300 / 2000 Startpläne statt 6 / 12 / 30),
und das lohnt sich: an der Testklasse stieg die Punktzahl von 118,5 (20 Versuche)
über 119,4 (100) auf 121,8 (2000).

`engine: "typst"` bleibt als lesbare Referenz erhalten — zum Nachvollziehen des
Verfahrens, zum Ändern ohne Rust-Werkzeuge und als Gegenprobe.

### Plugin neu bauen

```bash
rust/bauen.sh
```

Braucht `rustup` samt Ziel `wasm32-unknown-unknown` (unter macOS
`brew install rustup`). Das Skript stellt den Toolchain-Pfad voran — liegt
daneben ein Rust aus Homebrew im `PATH`, greift `cargo` sonst zu dessen `rustc`,
dem die Standardbibliothek für `wasm32` fehlt.

## Die Funktionen

| Name | Aufgabe |
|---|---|
| `typlace(layout, names: (), …)` | zeichnet den Sitzplan |
| `sitzordnung(layout, students, …)` | sucht die Sitzordnung und liefert den Plan (`plan.names`, `plan.statistics`, …) |
| `wunschliste(source, …)` | liest und prüft eine Wunschliste vorab |
| `seating-report(plan)` | ausführlicher Bericht zu einem Plan |
| `seating-summary(plan)` | eine Zeile Kennzahlen |
| `default-weights` | die Standardgewichte der Bewertung |

## Parameter

### `typlace(layout, ...)`

| Parameter | Typ | Standard | Beschreibung |
|-----------|-----|---------|--------------|
| `names` | `array` | `()` | Namen, zeilenweise auf die Sitzplätze verteilt |
| `cell-width` / `cell-height` | `length` | `2cm` / `1.2cm` | Größe einer Zelle |
| `seat-fill` | `color` | hellblau | Füllfarbe der Sitzplätze |
| `desk-fill` | `color` | braun | Füllfarbe des Pults |
| `table-fill` | `auto`/`color`/`none` | `auto` | Tischfläche; `none` schaltet sie ab |
| `number` | `bool` | `false` | Platznummern anzeigen |
| `rotation` | `angle` | `0deg` | `0deg`, `90deg`, `180deg`, `270deg` im Uhrzeigersinn |

### `sitzordnung(layout, students, ...)`

| Parameter | Typ | Standard | Beschreibung |
|-----------|-----|---------|--------------|
| `constraints` | `dictionary` | `(:)` | Harte Vorgaben (siehe oben) |
| `weights` | `dictionary` | `(:)` | Abweichungen von den Standardgewichten |
| `position-share` | `auto`/`ratio` | `auto` | Anteil der Sitzwünsche im Raum an den erreichbaren Punkten |
| `engine` | `str` | `"wasm"` | Rechenkern: `"wasm"` oder `"typst"` |
| `seed` | `int` | `42` | Startwert; anderer Seed = anderer Vorschlag |
| `quality` | `str` | `"normal"` | `"fast"`, `"normal"`, `"thorough"` |
| `attempts` / `max-steps` | `auto`/`int` | `auto` | Überschreiben `quality` |
| `front` | `auto`/`str` | `auto` | Vorderseite (`"top"`, `"bottom"`, `"left"`, `"right"`); sonst aus der Pultlage bestimmt |
| `perspective` | `str` | `"student"` | Links/rechts aus Schüler- (`"student"`) oder Plansicht (`"plan"`) |
| `strict` | `bool` | `true` | Bei unbekannten Namen abbrechen |
| `duration` | `none`/`str` | `none` | Rechenzeit als Text für den Bericht |

Rückgabe u. a.: `names` (direkt an `typlace` weiterreichen), `points`, `statistics`,
`details`, `notes`, `geometry`, `problem`.

### `wunschliste(source, ...)`

| Parameter | Typ | Standard | Beschreibung |
|-----------|-----|---------|--------------|
| `delimiter` | `auto`/`str` | `auto` | Spaltentrenner; `auto` erkennt `\|`, `;`, Tabulator oder `,` |
| `header-row` | `auto`/`bool` | `auto` | Erste Zeile überspringen; `auto` erkennt eine Kopfzeile an „Name" |
| `seat-count` | `none`/`int` | `none` | Anzahl Sitzplätze zur Gegenprüfung |
| `max-wishes` | `int` | `3` | Wünsche je Schüler; überzählige werden verworfen |
| `strict` | `bool` | `true` | Bei unbekannten Namen abbrechen |

Rückgabe: `(students:, notes:)`; je Schüler `name`, `position: (depth:, side:)`,
`position-avoided`, `wishes`, `rejections`. Die Zonen heißen dort `"front"`,
`"middle"`, `"back"`, `"left"`, `"right"`.

## Umstieg von älteren Versionen

Namen siehe Handbuch, Abschnitt „Umstieg auf 0.5.0" (Tabellen alt → neu für
Funktionen, Parameter, Werte und alle Schlüssel). Alte Namen werden nicht still
angenommen; das Paket bricht mit einer Meldung ab, die den neuen Namen nennt
(``typlace.typlace: `namen` heißt jetzt `names` ``). Strenger als früher:
`rotation` ist ein Winkel (`90deg` statt `90`), `names` muss eine Liste sein,
und falsche Typen werden gemeldet statt still übergangen.

## Hinweise

- Gleicher `seed` ergibt immer denselben Plan.

### Seed oder Budget?

Der Seed wirkt nur so stark, wie das Budget klein ist. Das Verfahren liefert das
Beste aus `attempts` Startplänen; wie gut dieses Beste ausfällt, schwankt bei
wenigen Versuchen deutlich und bei vielen kaum noch. An einer 30er-Klasse über
sechs Seeds gemessen (Spanne zwischen bestem und schlechtestem Seed):

| Versuche | Spanne |
|---|---|
| 20 | 7,8 Punkte |
| 200 | 1,9 Punkte |
| 2000 | 0,6 Punkte |

Mehr Versuche sind also der verlässliche Hebel, nicht das Durchprobieren von
Seeds — dafür reicht die Voreinstellung `quality: "thorough"`. Verschiedene
Seeds sind dann noch nützlich, um mehrere *gleich gute* Vorschläge
nebeneinanderzulegen.

Die Versuche einzeln neu zu seeden bringt übrigens nichts: der Zufallsstrom läuft
ohnehin durch alle Versuche hindurch, jeder bekommt also frische Zahlen.
- Die Zonen `vorne`/`mitte`/`hinten` und `links`/`mitte`/`rechts` gelten für den
  **Gruppentisch als Ganzes**, nicht für einzelne Sitzreihen.
- Links und rechts sind aus Schülersicht gemeint (Blick nach vorne).
- Bei nur zwei Tischreihen gibt es kein „mitte“; solche Wünsche weist der Bericht
  als nicht erfüllbar aus.
