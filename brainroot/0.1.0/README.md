# brainroot

`brainroot` zeichnet zweiseitige Mindmaps: die Wurzel in der Mitte, die Äste
nach rechts und links, jeder Ast in seiner eigenen Farbe bis in die Blätter.
Das Layout entsteht automatisch, die Kästen passen sich dem Text an.

## Verwendung

```typ
#import "@schule/brainroot:0.1.0": brainroot, branch

#brainroot(title: [Energiearten])[
  - Bewegungsenergie
    - Kinetische Energie
    - Windenergie
  - Spannenergie
    - Dehnungsenergie
  - Wärmeenergie
    - Feuerenergie
  - Höhenenergie
    - Schwerkraftenergie
    - Gewichtenergie
]
```

Jeder Listenpunkt wird zu einem Knoten, eingerückte Punkte zu seinen
Kindern, beliebig tief. Wer Farbe oder Seite eines Astes bestimmen will,
schreibt ihn als `branch(...)`:

```typ
#brainroot([Energiearten],
  branch([Bewegungsenergie], [Kinetische Energie], [Windenergie], color: red),
  branch([Spannenergie], [Dehnungsenergie], side: left),
)
```

Beide Formen lassen sich mischen; eine Liste und einzelne `branch`-Aufrufe
dürfen nebeneinander als Argumente stehen.

## Parameter

`branch(label, ..kids, color: none, side: auto)`

- `color`: Farbe des Astes; `none` nimmt die nächste Farbe der Palette.
- `side`: `left` oder `right` erzwingt die Seite. Beides nur auf der ersten Ebene.

`brainroot(..branches, title: none, ...)`

- `title`: Beschriftung der Wurzel. Fehlt sie, ist das erste positionale Argument die Wurzel.

- `palette`: Name einer Palette (siehe unten), ein Array von Farben oder `(colors: ..., root: ...)`. Standard: `"poster"`.
- `root-fill`: Farbe der Wurzel. Standard: `auto`, die der Palette.
- `tint`: Aufhellung der Astfarbe für die Kästen. Standard: `60%`.
- `tint-min`: Mindesthelligkeit getönter Füllungen (0 bis 1), dunkle Farben werden weiter aufgehellt. Standard: `0.8`.
- `scale`: Schriftgröße je Ebene relativ zur Umgebung. Standard: `(1.3, 1.1, 1.0)`.
- `bold-depth`: So viele Ebenen ab der Wurzel werden fett. Standard: `2`.
- `thickness`: Linienstärke je Ebene. Standard: `(3pt, 1.5pt)`.
- `level-gap`, `root-gap`: Abstände in Wachstumsrichtung, Eltern zu Kind und Wurzel zu Ast. Standard: `40pt`, `80pt`.
- `sibling-gap`, `branch-gap`: Abstände quer dazu, zwischen Geschwistern und zwischen den Ästen der ersten Ebene. Standard: `8pt`, `24pt`.
- `max-width`: Ab dieser Breite wird umgebrochen. Standard: `5cm`.
- `inset`: Innenabstand der Kästen.

## Anordnungen

| `layout` | |
| --- | --- |
| `both` | Wurzel mittig, Äste rechts und links (Standard) |
| `right`, `left` | alle Äste auf einer Seite |
| `down`, `up` | Baum von oben nach unten bzw. von unten nach oben |
| `radial` | Äste im Kreis um die Wurzel, Teilbäume wachsen nach außen |

Bei `both` gehen ohne Angabe von `side` die ersten Äste nach rechts, bis die
rechte Seite etwa die Hälfte der Gesamthöhe erreicht hat; der Rest geht nach
links. Die Reihenfolge von oben nach unten bleibt auf beiden Seiten erhalten.
Bei `radial` beginnt der erste Ast bei `start`, die weiteren folgen im
Uhrzeigersinn; der Radius wächst, bis sich keine Teilbäume überschneiden.

## Paletten

| `palette` | |
| --- | --- |
| `poster` | kräftig bunt, wie Filzstifte an der Tafel (Standard) |
| `pastel` | zarte, gedämpfte Töne |
| `grayscale` | nur Graustufen |
| `mono` | ein Blau in wechselnder Helligkeit |
| `plain` | eine dunkle Tinte für alles |
| `earth` | Terrakotta, Ocker, Oliv, Sand |
| `ocean` | Türkis, Petrol, Seegrün |
| `sunset` | Rot, Orange, Rosa, Violett |
| `forest` | Grün mit etwas Braun |
| `neon` | grelle, gesättigte Farben |

Eigene Farben: `palette: (red, blue, green)` oder mit Wurzelfarbe
`palette: (colors: (red, blue), root: black)`.

## Themes

Ein Theme legt fest, wie Kästen und Kanten aussehen. Die Farben kommen
weiterhin aus der Palette.

| Theme | Kästen | Kanten |
| --- | --- | --- |
| `soft` | pastell gefüllt, runde Ecken | weiche S-Kurven |
| `outline` | weiß mit farbigem Rahmen | Kurven |
| `blocks` | vollfarbig, weiße Schrift, eckig | rechte Winkel |
| `lines` | kein Kasten, Text auf farbiger Linie | Kurven, die in die Linie münden |
| `sketch` | dünner Rahmen, keine Füllung | gestrichelte Geraden |
| `bubbles` | Pillen, pastell gefüllt | Geraden |
| `hand` | wie `soft`, handgezeichnet | wackelnde Kurven |
| `scribble` | ohne Füllung, zweimal gezogen | wackelnde Kurven |
| `marker` | vollfarbig, Filzstift | breite wackelnde Geraden |
| `pencil` | dünn, Bleistift | zitternde rechte Winkel |

Die vier handgezeichneten Themes wackeln jede Linie nach dem Muster der
TikZ-Dekoration `sketch`: entlang des Pfades, mit reproduzierbarem Zufall.
Eine Handschrift wie "Patrick Hand" oder "Kalam" passt dazu, entweder per
`set text(font: ...)` oder über das Theme-Feld `font`.

Ein Dictionary überschreibt einzelne Felder eines Themes:

```typ
#brainroot(title: [Energiearten],
  theme: (base: "outline", edge: "elbow", radius: 0pt), karte)
```

Felder: `edge` (`"curve"`, `"elbow"`, `"straight"`), `fill` (`"tint"`,
`"solid"`, `"white"`, `"none"`), `stroke` (Rahmenstärke), `radius`,
`underline`, `dash` (`"solid"`, `"dashed"`, `"dotted"`), `font`, `root` mit
Überschreibungen nur für die Wurzel, und `hand`: `none` oder ein Dictionary
mit `amplitude` (Ausschlag in pt), `wavelength` (Wellenlänge in pt),
`randomness` (Unregelmäßigkeit, 1 = reiner Sinus), `segment` (Schrittweite
in pt) und `passes` (wie oft jede Linie gezogen wird).

```typ
#brainroot(title: [Energiearten], layout: "radial",
  theme: (base: "blocks", hand: (amplitude: 1, wavelength: 60), font: "Kalam"),
  karte)
```
