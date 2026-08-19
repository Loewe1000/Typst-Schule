# typlace

Erstellt **Sitzpläne für Klassenräume** aus einem einfachen mehrzeiligen String –
und sucht auf Wunsch die Sitzordnung, die am besten zu den Wünschen der Klasse passt.

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
#import "@schule/typlace:0.0.2": typlace

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

#typlace(layout, namen: ("Anna", "Ben", "Clara", ...), nummern: true)
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
mit einer Meldung ab (`streng: false` warnt stattdessen nur).

### 2. Plan berechnen

```typst
#import "@schule/typlace:0.0.2": typlace, sitzordnung, sitzplan-bericht

#let plan = sitzordnung(layout, read("wuensche.csv"), seed: 42)

#typlace(layout, namen: plan.namen)
#sitzplan-bericht(plan)
```

`read()` verträgt ungleich lange Zeilen; Typsts `csv(..., delimiter: "|")` verlangt
in jeder Zeile gleich viele Spalten.

### 3. Feste Vorgaben der Lehrkraft

```typst
#let plan = sitzordnung(layout, read("wuensche.csv"), vorgaben: (
  fest: ("Ben Schulz": 3),                    // feste Platznummer
  muss-vorne: ("Eva Lang",),                  // auch muss-mitte/-hinten/-links/-rechts
  getrennt: (("Max Klein", "Moritz Groß"),),  // nie am selben Gruppentisch
  zusammen: (("Ida Berg", "Jonas Kern"),),    // immer am selben Gruppentisch
))
```

Vorgaben sind **hart**: der zurückgegebene Plan verletzt sie nie. Lassen sie sich
nicht alle einhalten, bricht die Funktion mit einer Erklärung ab. Die Platznummern
für `fest` zeigt `typlace(..., nummern: true)` an.

## Wie bewertet wird

| Kriterium | Standardgewicht |
|---|---|
| Wunschperson sitzt unmittelbar daneben, gegenüber oder über Eck | `direkt: 1.0` |
| Wunschperson am selben Gruppentisch, aber weiter weg | `tisch: 0.9` |
| 1., 2. und 3. Wunsch | `raenge: (1.0, 1.0, 1.0)` – gleichwertig |
| 1., 2. und 3. *erfüllter* Wunsch eines Schülers | `stufen: (1.0, 0.7, 0.45)` – fallend |
| Faktor nach Anzahl der *genannten* Namen | `wunschzahl: (1.0, 1.0, 1.0)` – aus |
| Bonus dafür, überhaupt einen Wunsch erfüllt zu bekommen | `fairness: 2.0` |
| Abgelehnte Person am selben Tisch | `ablehnung: -2.0` |
| Erfüllter Positionswunsch je Achse | `position: 0.5` |
| Gemiedene Zone doch zugeteilt | `position-meidet: -0.5` |

Zwei Werte sorgen für eine gleichmäßige Verteilung. Der **Fairness-Bonus** greift
an der Schwelle „mindestens ein Wunsch": ohne ihn bekämen wenige Schüler alle
Wünsche und andere gar keinen. Die **Stufen** wirken oberhalb davon: weil der
zweite erfüllte Wunsch weniger zählt als der erste und der dritte noch weniger,
ist eine Sitzordnung, in der alle zwei von drei Wünschen bekommen, mehr wert als
eine, in der die einen drei und die anderen einen bekommen.

`stufen: (1.0, 1.0, 1.0)` schaltet das ab und zählt nur die Gesamtzahl erfüllter
Wünsche; kleinere Werte wie `(1.0, 0.5, 0.25)` verteilen noch strenger gleich.

Naheliegend wäre, zusätzlich Schüler zu bevorzugen, die **wenige Namen genannt**
haben – wer nur einen nennt, hat schließlich keine zweite Chance. Dafür gibt es
`wunschzahl`, standardmäßig aber ausgeschaltet: der Fairness-Bonus leistet das
bereits, weil er je Schüler einmal gilt, unabhängig von der Länge seiner Liste.
An einer echten Klasse gemessen bekam das einzige Kind mit nur einem Wunsch
diesen in jeder Einstellung und bei jedem Seed, während `(1.3, 1.15, 1.0)` im
Mittel anderthalb erfüllte Wünsche anderswo kostete. Einschalten mit
`gewichte: (wunschzahl: (1.3, 1.15, 1.0))`.
`sitzplan-bericht` zeigt das Ergebnis als Kreuztabelle: eine Reihe je Anzahl
*genannter* Wünsche, darin die Kinder nach Anzahl *erfüllter* Wünsche. So
vermischen sich „drei von drei" und „einer von einem" nicht.

```
        davon erfüllt:  0   1   2   3
 1 Wunsch genannt       ·   1
2 Wünsche genannt       ·   2   ·
3 Wünsche genannt       ·   3  11  10
```

Dieselben Zahlen stehen in `statistik.verteilung` als Dictionary: Schlüssel ist
die Anzahl genannter Wünsche, Wert ein Array, dessen Index die Anzahl erfüllter
Wünsche ist — `verteilung.at("3").at(2)` sind also die Kinder, die zwei ihrer
drei Wünsche bekommen haben. Alle Gewichte lassen sich über
`gewichte: (...)` ändern.

### Position gegen Mitschülerwünsche abwägen

Statt am Gewicht `position` zu drehen, lässt sich direkt angeben, welchen Anteil
die Sitzwünsche im Raum an den insgesamt erreichbaren Punkten haben sollen:

```typst
#sitzordnung(layout, read("wuensche.csv"), position-anteil: 15%)
```

`0%` ignoriert vorne/hinten/links/rechts vollständig, `50%` stellt beide Seiten
gleich. Das Gewicht wird aus der tatsächlichen Klasse berechnet, der Anteil
stimmt also unabhängig davon, wie viele Positionswünsche überhaupt vorliegen.
Der Bericht weist über `statistik.punkte-aus-wuenschen` und
`statistik.punkte-aus-position` aus, wie es tatsächlich ausgegangen ist.

Zur Größenordnung, gemessen an einer 28er-Klasse mit 72 Wünschen und 8
Positionswünschen: `0%` → 61 Wünsche und 2 Positionen erfüllt, `20%` → 57 und 3,
`50%` → 58 und 3. Viel mehr als 3 der 8 Positionswünsche sind nicht zu holen,
weil eine Zone dem ganzen Gruppentisch gilt und damit unmittelbar gegen die
Freundesgruppe steht.

## Rechenkern

Die Suche läuft standardmäßig im mitgelieferten WASM-Plugin (`optimierer.wasm`,
Rust-Quelltext unter `rust/`). Es ist eine 1:1-Übertragung von `optimierer.typ`:
gleicher Zufallsgenerator, gleiche Reihenfolge der Tausche, gleiche Reihenfolge
der Additionen. Bei gleichem `seed` liefern beide Fassungen denselben Plan —
gemessen an einer 30er-Klasse identisch bis zur vierten Nachkommastelle und bis
auf den einzelnen geprüften Tausch.

| | 20 Startpläne | 2000 Startpläne |
|---|---|---|
| `motor: "typst"` | 12,0 s | ~20 min |
| `motor: "wasm"` | 0,22 s | 14,3 s |

Die reine Suche ist damit rund **75-fach schneller**. Nach jedem Plugin-Aufruf
rechnet Typst die gelieferte Sitzordnung selbst nach; weichen die Punktzahlen ab,
bricht das Paket ab, statt still ein falsches Ergebnis zu setzen.

Weil Rechenzeit dadurch billig ist, sind die Voreinstellungen für `qualitaet`
beim WASM-Kern viel großzügiger (50 / 300 / 2000 Startpläne statt 6 / 12 / 30),
und das lohnt sich: an der Testklasse stieg die Punktzahl von 118,5 (20 Versuche)
über 119,4 (100) auf 121,8 (2000).

`motor: "typst"` bleibt als lesbare Referenz erhalten — zum Nachvollziehen des
Verfahrens, zum Ändern ohne Rust-Werkzeuge und als Gegenprobe.

### Plugin neu bauen

```bash
rust/bauen.sh
```

Braucht `rustup` samt Ziel `wasm32-unknown-unknown` (unter macOS
`brew install rustup`). Das Skript stellt den Toolchain-Pfad voran — liegt
daneben ein Rust aus Homebrew im `PATH`, greift `cargo` sonst zu dessen `rustc`,
dem die Standardbibliothek für `wasm32` fehlt.

## Parameter

### `typlace(layout, ...)`

| Parameter | Typ | Standard | Beschreibung |
|-----------|-----|---------|--------------|
| `namen` | `array` | `()` | Namen, zeilenweise auf die Sitzplätze verteilt |
| `tisch-breite` / `tisch-hoehe` | `length` | `2cm` / `1.2cm` | Größe einer Zelle |
| `tisch-farbe` | `color` | hellblau | Füllfarbe der Sitzplätze |
| `pult-farbe` | `color` | braun | Füllfarbe des Pults |
| `koerper-farbe` | `auto`/`color`/`none` | `auto` | Tischfläche; `none` schaltet sie ab |
| `nummern` | `bool` | `false` | Platznummern anzeigen |
| `rotation` | `int` | `0` | `0`, `90`, `180`, `270` im Uhrzeigersinn |

### `sitzordnung(layout, schueler, ...)`

| Parameter | Typ | Standard | Beschreibung |
|-----------|-----|---------|--------------|
| `vorgaben` | `dictionary` | `(:)` | Harte Vorgaben (siehe oben) |
| `gewichte` | `dictionary` | `(:)` | Abweichungen von den Standardgewichten |
| `position-anteil` | `auto`/`ratio` | `auto` | Anteil der Sitzwünsche im Raum an den erreichbaren Punkten |
| `motor` | `str` | `"wasm"` | Rechenkern: `"wasm"` oder `"typst"` |
| `seed` | `int` | `42` | Startwert; anderer Seed = anderer Vorschlag |
| `qualitaet` | `str` | `"normal"` | `"schnell"`, `"normal"`, `"gruendlich"` |
| `versuche` / `max-schritte` | `auto`/`int` | `auto` | Überschreiben `qualitaet` |
| `vorne` | `auto`/`str` | `auto` | Vorderseite; sonst aus der Pultlage bestimmt |
| `perspektive` | `str` | `"schueler"` | Links/rechts aus Schüler- oder Plansicht |
| `streng` | `bool` | `true` | Bei unbekannten Namen abbrechen |

Rückgabe u. a.: `namen` (direkt an `typlace` weiterreichen), `punkte`, `statistik`,
`details`, `hinweise`, `geo`, `kontext`.

## Hinweise

- Gleicher `seed` ergibt immer denselben Plan.

### Seed oder Budget?

Der Seed wirkt nur so stark, wie das Budget klein ist. Das Verfahren liefert das
Beste aus `versuche` Startplänen; wie gut dieses Beste ausfällt, schwankt bei
wenigen Versuchen deutlich und bei vielen kaum noch. An einer 30er-Klasse über
sechs Seeds gemessen (Spanne zwischen bestem und schlechtestem Seed):

| Versuche | Spanne |
|---|---|
| 20 | 7,8 Punkte |
| 200 | 1,9 Punkte |
| 2000 | 0,6 Punkte |

Mehr Versuche sind also der verlässliche Hebel, nicht das Durchprobieren von
Seeds — dafür reicht die Voreinstellung `qualitaet: "gruendlich"`. Verschiedene
Seeds sind dann noch nützlich, um mehrere *gleich gute* Vorschläge
nebeneinanderzulegen.

Die Versuche einzeln neu zu seeden bringt übrigens nichts: der Zufallsstrom läuft
ohnehin durch alle Versuche hindurch, jeder bekommt also frische Zahlen.
- Die Zonen `vorne`/`mitte`/`hinten` und `links`/`mitte`/`rechts` gelten für den
  **Gruppentisch als Ganzes**, nicht für einzelne Sitzreihen.
- Links und rechts sind aus Schülersicht gemeint (Blick nach vorne).
- Bei nur zwei Tischreihen gibt es kein „mitte“; solche Wünsche weist der Bericht
  als nicht erfüllbar aus.
