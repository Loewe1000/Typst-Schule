# cutter – Silhouette-Schneideplotter mit Passermarken

`cutter` schneidet gedruckte Bögen auf einem Silhouette-Plotter (getestet
für Cameo 4; Cameo 3 und Portrait sollten ebenso gehen). Der Plotter sucht
zuerst die Passermarken auf dem Blatt und schneidet dann genau an den Linien.

Die Schnittlinien kommen aus

- **Typst-Dokumenten** mit `<cut-data>`-Metadaten, zum Beispiel
  `@schule/trimino` mit `cut-marks: true`;
- **JSON-Dateien** im selben Format (etwa aus `trimino-cut-file("….json")`
  im Bündelexport oder aus `typst query`);
- **SVG-Dateien**: geschnitten werden alle Linien einer oder mehrerer
  Strichfarben (Standard: Rot `#ff0000`). So lässt sich jede Vorlage
  schneiden, auch aus Inkscape, Affinity oder Typst (`typst compile --format svg`).

## Einrichten (einmal)

```bash
brew install libusb
```

```bash
cd ~/"Library/Application Support/typst/packages/schule/tools/cutter"
python3 -m venv .venv && .venv/bin/pip install -e .
```

Danach steht `.venv/bin/cutter` bereit. Silhouette Studio muss geschlossen
sein, solange `cutter` den Plotter benutzt.

## Ablauf

1. **Trockenlauf ohne Gerät.** Er zeigt die Schnittfolge und schreibt die
   Befehle mit, die an den Plotter gingen:

   ```bash
   .venv/bin/cutter plan "Trimino.typ"
   ```

   Das ergibt `Trimino-schnitt.svg` (Vorschau: Blatt, Marken, Schnittfolge
   von Blau nach Rot, Leerfahrten gestrichelt) und `Trimino-befehle.txt`.

2. **Drucken.** Den Schnittbogen in *tatsächlicher Größe* drucken (nicht
   „an Seite anpassen“), auf die Schneidematte legen, links oben an die
   Ecke, und mit „Laden“ einziehen.

3. **Plotter prüfen.** Diese Abfrage bewegt nichts:

   ```bash
   .venv/bin/cutter info --query
   ```

4. **Marken suchen und abfahren.** Der Plotter sucht die Marken und fährt
   den Umriss mit angehobenem Messer ab. So sieht man, ob alles passt:

   ```bash
   .venv/bin/cutter cut "Trimino.typ" --trace
   ```

5. **Schneiden.** `cutter` fragt vor jedem Bogen nach, sucht die Marken
   und fährt dann über das Prüfkreuz (rechts unten auf dem Bogen). Erst wenn
   man bestätigt, dass die Messerspitze genau auf der Kreuzmitte steht, wird
   geschnitten; sonst fährt der Kopf zurück und nichts ist geschnitten:

   ```bash
   .venv/bin/cutter cut "Trimino.typ" --material papier
   ```

   Mit `--trace` fährt er vorher mit angehobenem Messer langsam (Tempo 1)
   einmal den äußeren Umriss aller Teile ab und fragt danach, ob geschnitten
   wird – ohne die Marken neu zu suchen.

Schritt 4 entfällt damit meist: `cut --trace` fährt ab und schneidet nach
Rückfrage im selben Durchgang.

Das Fenster bietet dieselben Schritte:

```bash
.venv/bin/cutter gui "Trimino.typ"
```

## Einstellungen

| Option | Bedeutung |
|---|---|
| `--material papier\|karton\|fotopapier\|folie` | Startwerte für Tempo, Druck, Tiefe (Standard `karton`: 5 / 27 / 4; `papier` 5 / 10 / 2 für 80 g; `folie` 3 / 33 / 10, vier Durchgänge, Suche 4 mm vor der Marke) |
| `--track-enhancing` | Spurverstärkung: Rollen prägen vor dem Schnitt Spuren, damit glattes oder dickes Material nicht rutscht. Am Cameo 4 fand die Markensuche danach die Marken nicht mehr – nur ohne Passermarken verwenden |
| `--speed 1–30`, `--force 1–33`, `--depth 0–10` | einzeln überschreiben; die Tiefe gilt nur für die AutoBlade |
| `--passes N` | mehrere Durchgänge, für dicken Karton |
| `--mat cameo-12x12\|cameo-12x24\|none` | Schneidematte |
| `--tool 1\|2` | Werkzeughalter |
| `--corner 30` | größter Knick in Grad, um den das Messer weiterschneidet; an spitzeren Ecken setzt es neu an |
| `--overcut 1` | Überschnitt in mm an Schnittenden, nur wo er in den Abfall läuft (`0` schaltet ihn ab) |
| `--page N` | nur diese Seite des Dokuments |
| `--color '#0000ff'` | SVG: Strichfarbe der Schnittlinien, mehrfach möglich |
| `--mark-search 10` | so viele mm vor der ersten Marke beginnt die Suche; bei laminierten Bögen `4`, sonst liest der Sensor durch die Folie das Mattenraster |
| `--mark-inset 10`, `--no-marks` | SVG: Lage der Passermarken bzw. ohne Marken |
| `--check x,y` | SVG: Mitte eines mitgedruckten Prüfkreuzes in mm ab Blattecke |

Die Materialwerte sind Startwerte. Vor dem ersten Bogen eines neuen Papiers
lohnt ein Testschnitt.

Mit `cutter test` lassen sich Tiefe, Druck oder Durchgänge an kleinen
Dreiecken im freien Streifen unter den Teilen ausprobieren, ohne einen Bogen
zu opfern (`--depths 5,6,7`, `--forces 20,26,33`, `--repeats 3,4`,
`--row 2`, `--start-x`).

Laminierte Bögen haften schlecht auf der Matte und verrutschen unter dem
Messer. Sie am Rand mit Malerkrepp festkleben (nicht über die Marken) oder
eine stark haftende Matte nehmen.

## SVG-Vorlagen mit Passermarken

Die Marken folgen Silhouette Studio: links oben ein gefülltes Quadrat
(5 mm), rechts oben und links unten ein Winkel (Schenkel 20 mm, Strich
0,5 mm), alle 10 mm vom Blattrand. Um die Marken herum bleiben etwa 20 mm
frei. Die Koordinaten im SVG gelten in mm ab der linken oberen Blattecke.

## Format `cut-data`

```json
{
  "format": "cut-data", "version": 1, "source": "trimino",
  "page": 2, "unit": "mm", "page-size": [210, 297],
  "marks": {"style": "silhouette", "left": 10, "top": 10, "width": 190, "length": 277,
            "square": 5, "line": 20, "thickness": 0.5},
  "paths": [[[20.0, 81.12], [80.0, 81.12]], …],
  "pieces": [[[20.0, 81.12], [80.0, 81.12], [50.0, 29.16]], …],
  "check": [180.0, 267.0]
}
```

`paths` sind Linienzüge in mm, gemessen von der linken oberen Ecke der
Passermarken (ohne `marks`: von der Blattecke). `pieces` (Umrisse der Teile)
und `check` (Prüfkreuz) sind freiwillig. Jedes andere Typst-Paket kann
dieselben Daten mit `metadata(…) <cut-data>` hinterlegen.

## Wie es funktioniert

- `cutter/job.py` liest die Quellen.
- `cutter/geometry.py` entfernt doppelte Kanten und verbindet Strecken zu
  geraden Schnitten. An spitzen Ecken biegt das Messer nicht ab, sondern
  setzt neu an. Schnittenden verlängert es um den Überschnitt, wenn die
  Verlängerung außerhalb aller Teile liegt. SVG: geschlossene Formen gelten
  als Teile. Zuerst kommen alle waagerechten Schnitte (quer zum Vorschub)
  von oben nach unten, dann die übrigen nach kurzen Leerfahrten. So sitzen
  die waagerechten, bevor die Matte unter hoher Last rutschen kann.
- `cutter/device.py` spricht den Plotter über USB (pyusb/libusb) mit
  GPGL-Befehlen an. Die Befehlsfolgen für Matte, Messer, Markensuche (`TB123`)
  und Bewegung (`M`/`D`, 20 Einheiten je mm, y vor x) stammen aus der
  Dokumentation des Projekts
  [inkscape-silhouette](https://github.com/fablabnbg/inkscape-silhouette).
  Der Trockenlauf läuft durch denselben Code, nur ohne USB.

Tests ohne Gerät:

```bash
.venv/bin/python -m unittest discover tests
```
