# Inventar `@schule/mathematik:0.0.2`

Quelle: `mathematik/0.0.2/mathematik.typ` (1927 Zeilen, vollständig gelesen). Entrypoint laut `typst.toml` ist genau diese eine Datei. Zeilenangaben `L…` beziehen sich darauf.
Geprüft mit typst 0.15.1 (Probe-Kompilate im Scratchpad, am Repo nichts geändert). Mit "bestätigt" markierte Fehler wurden so reproduziert.

Umfeld des Pakets:

| Datei | Zustand |
|---|---|
| `mathematik/0.0.2/typst.toml` | name `mathematik`, version `0.0.2`, entrypoint `mathematik.typ`; `description` nennt nur Graphen/Koordinatensysteme/Füllbereiche/Datensatz-Plots, nicht `steckbrief`, `kreisdiagramm`, `geogebra-*`, `teilaufgaben` |
| `mathematik/0.0.2/README.md` | leer (0 Bytes) |
| `mathematik/0.0.2/docs/content.typ`, `docs.typ` | 472 + 11 Zeilen Doku (nicht Teil dieses Auftrags) |
| `mathematik/0.0.1/` | Vorversion mit völlig anderer API (`fkt-plot`, `nbx`, `nbr`, `m-rand`, `colors`, `fkt-graph-card`, `fkt-term-card`, `tasks`, `ti-btn`, `ti-ctrl-btn`, `ti-mnu`); wird noch von `arbeitsblatt` 0.1.0 bis 0.1.9 per `import … : *` benutzt |

---

## 1. Öffentliche Namen (Übersicht)

`dictionary(module).keys()` liefert exakt diese 23 Namen (bestätigt):

| Name | Zeile | Art | Herkunft | Sprache / Schreibweise |
|---|---|---|---|---|
| `default_seed` | L1 | Variable (`42`) | Re-Export aus `@schule/random:0.0.1` | en, snake_case |
| `m` | L1 | Variable (`2^32 - 1`) | Re-Export random | Ein-Buchstaben-Name |
| `a` | L1 | Variable (`48271`) | Re-Export random | Ein-Buchstaben-Name |
| `lcg` | L1 | Funktion | Re-Export random | en, Abkürzung |
| `low_cminstd_rand` | L1 | Funktion | Re-Export random | en, snake_case |
| `low_cminstd_randint` | L1 | Funktion | Re-Export random | en, snake_case |
| `step_seed` | L1 | Funktion | Re-Export random | en, snake_case |
| `fisher_yates_shuffle` | L1 | Funktion | Re-Export random | en, snake_case |
| `rand` | L1 | Funktion | Re-Export random | en |
| `randint` | L1 | Funktion | Re-Export random | en |
| `shuffle` | L1 | Funktion | Re-Export random | en |
| `umrechnungseinheit` | L2 | Funktion | Re-Export aus `@schule/physik:0.0.2` | de, ein Wort |
| `teilaufgaben` | L23 | Funktion | eigen | de |
| `tasks` | L61 | Alias auf `teilaufgaben` | eigen | en |
| `graphen` | L97 | Funktion | eigen | de |
| `steckbrief` | L1019 | Funktion | eigen | de |
| `kreisdiagramm` | L1638 | Funktion | eigen | de |
| `geogebra-colors` | L1799 | Dictionary | eigen | en, kebab-case |
| `geogebra-button` | L1809 | Funktion | eigen | en, kebab-case |
| `geogebra-approx-button` | L1820 | Funktion | eigen | en, kebab-case |
| `geogebra-style` | L1848 | Funktion | eigen | en, kebab-case |
| `geogebra-cell` | L1864 | Funktion | eigen | en, kebab-case |
| `geogebra-algebra` | L1903 | Funktion | eigen | en, kebab-case |

Keine States, keine Counter, keine Labels, keine `query`-Aufrufe, keine Top-Level-`show`/`set`-Regeln, keine privaten (`_…`) Top-Level-Namen in 0.0.2. Alle Hilfsfunktionen sind lokale `let` innerhalb der Funktionskörper.

Muster der Namensgebung: Funktionsnamen der Fachfunktionen deutsch (`teilaufgaben`, `graphen`, `steckbrief`, `kreisdiagramm`), die GeoGebra-Familie englisch (`geogebra-colors/-button/-style/-cell/-algebra`), Parameter fast durchgehend englisch mit zwei deutschen Ausnahmen (`loesungen`, `datensätze`).

---

## 2. Signaturen und Parameter

### 2.1 `teilaufgaben` (L23-58)

```typ
#let teilaufgaben(
  tasks: (),
  columns: auto,
  numbering: "a)",
  gutter: 1.25em,
  loesungen: (),
  ..args,
) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `tasks` | named | `()` | array von content | en | Aufgaben; wenn leer, wird das erste positionale Argument (Enum-Body, `+ …`) zerlegt (L31-34) |
| `columns` | named | `auto` | `auto` \| int | en | Spaltenzahl; `auto` = Anzahl der Aufgaben (L35-38, intern irreführend `row-amount`) |
| `numbering` | named | `"a)"` | str | en | Laut Doku Nummerierungsschema; wird im Körper NIRGENDS verwendet (toter Parameter) |
| `gutter` | named | `1.25em` | length | en | Spalten- und Zeilenabstand (`column-gutter` und `row-gutter` der Tabelle) |
| `loesungen` | named | `()` | array von content | de, Umschrift `oe` | Lösungen in Aufgabenreihenfolge; jeweils in `loesung[…]` aus `@schule/aufgaben:0.1.2` gewickelt |
| `..args` | sink | - | pos: 1 Enum-Body; named: beliebig | en | positional `.at(0)` = Enum-Body; named gehen ungeprüft an `table()` (L56) |

Intern: `import "@schule/aufgaben:0.1.2": loesung, teilaufgabe` (L39, lokal im Funktionskörper). `teilaufgabe()` wird ohne Argumente außer dem Body aufgerufen (dort: `item-label: none, label: none, workspace: none, body`).
Rückgabe: `table(stroke: none, inset: 0mm, columns: (1fr,) * n, column-gutter, row-gutter, …)`.

### 2.2 `tasks` (L61)

```typ
#let tasks = teilaufgaben
```

Englischer Alias, identische Signatur. Derselbe Name `tasks` ist zugleich Parametername von `teilaufgaben` (`tasks(tasks: …)`).

### 2.3 `graphen` (L97-997)

```typ
#let graphen(
  size: none,
  scale: 1,
  x: (-5, 5),
  y: (-5, 5),
  step: 1,
  x-step: none,
  y-step: none,
  x-label: [$x$],
  y-label: [$y$],
  grid: "both",
  x-grid: none,
  y-grid: none,
  line-width: 1.5pt,
  samples: 200,
  fills: (),
  datensätze: (),
  marks: (),
  ..args,
  annotations: {},
) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `size` | named | `none` | `none` \| int/float \| array `(b, h)` | en | Größe in Canvas-Einheiten (keine length, entgegen Doku L73); `none` = aus den Achsenbereichen (1 Einheit je Achseneinheit, bei `auto` 10) (L719-729) |
| `scale` | named | `1` | int/float | en | `canvas(length: scale * 1cm)` (L777) |
| `x` | named | `(-5, 5)` | array `(min, max)` \| `auto` | Ein-Buchstabe | x-Bereich; `auto` oder unveränderter Default wird bei Datensätzen durch deren Bereich ersetzt (L687) |
| `y` | named | `(-5, 5)` | array `(min, max)` \| `auto` | Ein-Buchstabe | y-Bereich, analog (L691) |
| `step` | named | `1` | int/float \| array `(major, minor)` \| `none` \| (`auto` intern) | en | Tick-/Gitterschritt beider Achsen; Skalar → minor = major/2 (L763); `none` = keine Ticks |
| `x-step` | named | `none` | `none` (= erbt `step`) \| int/float \| array | en, kebab | Schritt nur x |
| `y-step` | named | `none` | wie `x-step` | en, kebab | Schritt nur y |
| `x-label` | named | `[$x$]` | content | en, kebab | Achsenbeschriftung; unveränderter Default wird bei Datensätzen durch "Name in Einheit" ersetzt (L695) |
| `y-label` | named | `[$y$]` | content | en, kebab | analog (L699) |
| `grid` | named | `"both"` | `"both"` \| `"major"` \| `"minor"` \| `"none"` (laut Doku); wird 1:1 an cetz-plot `x-grid`/`y-grid` gereicht | en | Gittermodus beider Achsen |
| `x-grid` | named | `none` | `none` (= erbt `grid`) \| wie `grid` | en, kebab | Gitter nur x |
| `y-grid` | named | `none` | wie `x-grid` | en, kebab | Gitter nur y |
| `line-width` | named | `1.5pt` | length | en, kebab | Strichstärke der Funktionsgraphen (nur Default für `stroke.thickness`, L292) |
| `samples` | named | `200` | int | en | Stützstellen für Graphen, Füllflächen UND Schnittpunktsuche bei `domain: "auto"` (L383) |
| `fills` | named | `()` | dictionary \| array von dictionaries \| `(f, g)` \| einzelne Funktion/content | en, Plural | Füllflächen, Formen siehe 3.2 |
| `datensätze` | named | `()` | dictionary \| array \| `(x-werte, y-werte)` \| `(x-ds, y-ds)` | de, Plural, MIT Umlaut im Bezeichner | diskrete Datenpunkte, Formen siehe 3.4 |
| `marks` | named | `()` | array (oder einzelnes dictionary) | en, Plural | beschriftete Punkte, Formen siehe 3.3 |
| `..args` | sink | - | pos: Funktionen (content `$…$`, function, dictionary); named: beliebig | en | positional = Plots (siehe 3.1); named gehen ungeprüft an `plot.plot()` (L812) und können dort alles oben Gesetzte überschreiben |
| `annotations` | named (steht NACH dem Sink) | `{}` (= `none`) | cetz-draw-Inhalt | en, Plural | wird in `plot.annotate({…})` gesetzt (L831-835), vor den Graphen gezeichnet |

Lokale Importe (L118-120, L593): `@preview/cetz:0.4.2: *`, `@preview/cetz-plot:0.1.3: *`, `@preview/eqalc:0.1.3: math-to-str, get-variable`, `@preview/fancy-units:0.1.1: unit`.
Lokale Hilfsfunktionen (nicht öffentlich): `resolve-color(clr)` L142, `to-func(term)` L158, `polstellen-segmente(f, domain, bereich, n: 400)` L184, `find-intersection(f, g, x-min, x-max, tolerance: 0.0001, max-iterations: 50)` L213, `find-all-intersections(f, g, x-min, x-max, samples: 100)` L259. Sprachmischung auch hier: `polstellen-segmente`/`bereich`/`schritt`/`segmente` deutsch, der Rest englisch.
Feste Stilwerte: Farbpalette `colors` mit 10 Farben (L128-139), `axis-style: "school-book"` (L799), Gitterfarbe `#AAAAAA` aufgehellt 0.5pt (L783-788), Dezimalkomma per Show-Regel auf `\d+\.\d+` in Formeln (L122-125).

### 2.4 `steckbrief` (L1019-1616)

```typ
#let steckbrief(..bedingungen, notation: "dec", precision: 1e-10) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `..bedingungen` | sink (nur positional ausgewertet) | - | Strings wie `"f(2)=3"`, `"f'(-1)=0"`, `"f(1/2)=3"` | de | Bedingungen; Anzahl der Apostrophe = Ableitungsgrad; Grad = Anzahl - 1; benannte Argumente werden stillschweigend verschluckt |
| `notation` | named | `"dec"` | `"dec"` \| `"sci"` \| `"frac"`; jeder andere Wert verhält sich wie `"dec"` | en; Werte englische Abkürzungen | Zahlenformat der Koeffizienten |
| `precision` | named | `1e-10` | float | en | Schwelle, unter der ein Koeffizient als 0 gilt (nur in `format-polynom`, L1471) |

Rückgabe: Dictionary, Schlüssel siehe 3.6. Lokaler Import: `@preview/zero:0.5.0: num as znum` (L1020).
Lokale Hilfsfunktionen: `rat-gcd`, `rat-simp`, `rat-add`, `rat-sub`, `rat-mul`, `rat-div`, `rat-is-zero`, `rat-is-neg`, `rat-abs`, `rat-is-one`, `rat-abs-gt` (L1023-1049), `str-to-rat` L1052, `float-to-rat` L1073, `format-number-rat` L1079, `format-number(value, digits: 2)` L1086, `parse-bedingung` L1118, `parse-bedingung-rat` L1160, `format-ansatz()` L1442, `format-polynom(koeff, digits: 2)` L1467, `format-polynom-rat` L1522, `f(x)` L1560.

### 2.5 `kreisdiagramm` (L1638-1787)

```typ
#let kreisdiagramm(
  data,
  // Legende
  legend: "r",
  // Labels
  show-percentage: true,
  label-color: black,
  // Modus: "percent" (relativ mit %) oder "absolute" (absolute Werte)
  mode: "percent",
  // Weitere Argumente werden direkt an piechart weitergegeben
  ..args,
) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `data` | positional | - | array von `(label, wert)`-Paaren | en | Daten |
| `legend` | named | `"r"` | `"r"` \| `"l"` \| `"t"` \| `"b"` \| `false` \| dictionary (cetz-plot-Legendenkonfiguration); alles andere (`true`, `none`, unbekannter String) → rechts | en; Werte Ein-Buchstaben-Kürzel | Legendenposition |
| `show-percentage` | named | `true` | bool | en, kebab | Wert auf dem Segment anzeigen; gilt auch im Modus `"absolute"` (Name passt dann nicht) |
| `label-color` | named | `black` | color | en, kebab | Textfarbe der Segmentbeschriftung (nur wirksam, wenn kein eigenes `inner-label`) |
| `mode` | named | `"percent"` | `"percent"` \| `"absolute"`; jeder andere Wert wie `"absolute"` | en | `"percent"` hängt nur `%` an den Rohwert an (L1719), es wird nichts in Prozent umgerechnet |
| `..args` | sink | - | ausgewertet werden NUR die named Keys `value-key`, `label-key`, `stroke`, `radius`, `gap`, `slice-style`, `colors`, `inner-label`, `outer-label` | en | Pseudo-Durchreichung an `chart.piechart()`; alle anderen Keys und alle positionalen Extras werden stillschweigend verworfen |

Feste Defaults (L1767-1771): `stroke: black`, `radius: 2.5`, `gap: 0`, `value-key: 1`, `label-key: 0`; eigene Palette `default-colors` mit 10 Farben (L1744-1755), andere Farben als in `graphen`. Lokale Importe: `@preview/cetz:0.4.2: canvas`, `@preview/cetz-plot:0.1.3: chart`.

### 2.6 `geogebra-colors` (L1799-1803)

```typ
#let geogebra-colors = (
  primary: rgb("#6557D2"),
  stroke: rgb("#DCDCDC"),
  button: rgb("#808080"),
)
```

Dictionary, Schlüssel englisch: `primary`, `stroke`, `button`.

### 2.7 `geogebra-button` (L1809-1814)

```typ
#let geogebra-button(size: 1.2em) = image(
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `size` | named | `1.2em` | length | en | Breite des Drei-Punkte-Icons (SVG aus `bytes(...)`) |

### 2.8 `geogebra-approx-button` (L1820-1833)

```typ
#let geogebra-approx-button(size: 1.2em) = box(
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `size` | named | `1.2em` | length | en | Breite und Höhe des lila "≈"-Buttons |

### 2.9 `geogebra-style` (L1848-1856)

```typ
#let geogebra-style(body) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `body` | positional | - | content | en | Inhalt; Formeln darin aufrecht, Display, Schrift "New Computer Modern Sans Math"; `set align(left)` |

### 2.10 `geogebra-cell` (L1864-1881)

```typ
#let geogebra-cell(
  content,
  menu: true,
  approx: false,
) = [
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `content` | positional | - | content | en | Zellinhalt (heißt hier `content`, in `geogebra-style` `body`) |
| `menu` | named | `true` | bool | en | Drei-Punkte-Button rechts |
| `approx` | named | `false` | bool | en, Abkürzung | "≈"-Button unten rechts |

### 2.11 `geogebra-algebra` (L1903-1926)

```typ
#let geogebra-algebra(
  ..cells,
  stroke: geogebra-colors.stroke + 0.5pt,
  columns: 1,
  inset: (left: 0.8em, top: 0.8em, bottom: 0.8em, right: 1.2em),
  last-has-approx: false,
) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `..cells` | sink (nur positional) | - | content | en | Zellinhalte; benannte Extras werden verschluckt |
| `stroke` | named | `geogebra-colors.stroke + 0.5pt` | stroke | en | Tabellenrahmen |
| `columns` | named | `1` | int \| array | en | Spalten |
| `inset` | named | `(left: 0.8em, top: 0.8em, bottom: 0.8em, right: 1.2em)` | dictionary \| length | en | Zellinnenabstand |
| `last-has-approx` | named | `false` | bool | en, kebab | letzte Zelle bekommt den "≈"-Button; alle Zellen bekommen fest `menu: true` (L1915) |

### 2.12 Re-exportierte Fremdfunktionen (über L1 und L2)

| Signatur | definiert in | Bemerkung |
|---|---|---|
| `default_seed = 42` | `random/0.0.1` L3 | |
| `m = calc.pow(2, 32) - 1` | random L8 | |
| `a = 48271` | random L9 | |
| `lcg(seed, steps: 100)` | random L11 | |
| `low_cminstd_rand(seed: default_seed)` | random L24 | |
| `low_cminstd_randint(start, end, seed: default_seed)` | random L32 | |
| `step_seed(cur_seed)` | random L40 | |
| `fisher_yates_shuffle(arr, seed)` | random L45 | |
| `rand(seed)` | random L57 | |
| `randint(start, end, seed)` | random L58 | |
| `shuffle(arr, seed)` | random L59 | |
| `umrechnungseinheit(wert, einheit)` | `physik/0.0.2/messwerttabellen.typ` L78 | einzige davon, die mathematik selbst benutzt (L636-646) |

---

## 3. Options- und Konfigurationsschlüssel

### 3.1 `graphen`: Plot-Definition (positional, L285-315)

Erlaubt: function, content (`$…$`), dictionary. Alles andere → `panic` (L308).

| Key | Default | Werte | Sprache | Bedeutung |
|---|---|---|---|---|
| `term` | - | content \| function | en/lat. | Funktionsterm; ohne `term` wird der Eintrag stillschweigend übersprungen (L311) |
| `domain` | `none` → x-Bereich | array `(a, b)` | en | Definitionsbereich |
| `stroke` | `(thickness: line-width, paint: Palettenfarbe)` | stroke/dictionary | en | ersetzt den Strich komplett |
| `clr` | - | color \| int (1-basierter Palettenindex) | Abkürzung | Farbe; Alias von `color` |
| `color` | - | color \| int | en | Farbe; gewinnt gegen `clr` (L304-305) |
| `label` | `none` | dictionary (siehe unten); jeder andere Typ wird ignoriert (L851) | en | Beschriftung am Graphen |

`label`-Dictionary des Plots (L851-866):

| Key | Default | Werte | Bedeutung |
|---|---|---|---|
| `x` | Pflicht (assert L853) | Zahl | x-Stelle, an der das Label sitzt |
| `content` | Pflicht (assert L854) | content | Text |
| `position` | `"tr"` | `"tl"` \| `"tr"` \| `"bl"` \| `"br"`; unbekannt → wie `"br"` (L880) | Lage relativ zum Punkt |
| `fill` | `white` | color | Hintergrund |
| `size` | `none` | length | Schriftgröße |
| `color` | Strichfarbe des Plots | color (KEIN int-Index, bestätigt: Absturz L902) | Textfarbe |
| `padding` | `1mm` | length | Abstand |
| `angle` | `0deg` | angle | Drehung |

Der Doku-Kommentar L852 nennt nur `x, content, fill, position, size, color`; `padding` und `angle` sind undokumentiert.

### 3.2 `graphen`: `fills` (L321-406)

Eingabeformen: einzelnes dictionary; Array aus genau zwei Funktionen `(f, g)` → `(between: (f, g), domain: "auto")`; einzelne Funktion → `(term: f, domain: "auto")`; Array von dictionaries; sonst `()`. Nicht-Dictionary-Einträge im Array → `panic` (L378).

| Key | Default | Werte | Sprache | Bedeutung |
|---|---|---|---|---|
| `term` | - | content \| function | en | Fläche zwischen Graph und x-Achse |
| `between` | - | Array aus genau 2 Funktionen (sonst `panic` L364) | en | Fläche zwischen zwei Graphen |
| `domain` | x-Bereich bzw. `(-5, 5)` | array `(a, b)` \| String `"auto"` | en | Grenzen; `"auto"` (String, nicht das Typst-`auto`) = äußerste Schnittpunkte |
| `auto-domain` | `false` | bool | en, kebab | undokumentierter zweiter Weg zu `domain: "auto"` (L376) |
| `clr` | Palettenfarbe, gesättigt, 60 % aufgehellt, 50 % transparent | color \| int | Abkürzung | Alias |
| `color` | wie oben | color \| int | en | gewinnt gegen `clr` (L374-375) |

### 3.3 `graphen`: `marks` (L411-490)

Eingabeformen je Eintrag: `((x, y), [label])`; `(x, y)`; dictionary. Unbekannte Formen werden stillschweigend ignoriert (kein `panic`).

| Key | Default | Werte | Sprache | Bedeutung |
|---|---|---|---|---|
| `position` | - | `(x, y)` | en | Punkt; gewinnt gegen `pos` |
| `pos` | - | `(x, y)` | Abkürzung | Alias |
| `content` | `none` | content | en | Beschriftung; gewinnt gegen `label` |
| `label` | `none` | content | en | Alias von `content` (im Plot-Dictionary ist `label` dagegen ein Dictionary mit Key `content`) |
| `anchor` | `"south-west"` | cetz-Anker oder Kürzel, siehe unten | en | Ankerpunkt der Beschriftung |
| `padding` | `2mm` | length | en | Abstand (Plot-Label: `1mm`) |
| `symbol` | `"x"` | cetz-Mark-Symbol | en | Punktsymbol |
| `stroke` | `black` | stroke | en | |
| `fill` | `none` → Strichfarbe | color | en | |
| `color` | - | color \| int | en | setzt stroke und (falls leer) fill |
| `clr` | - | color \| int | Abkürzung | wie `color`; gewinnt hier GEGEN `color` (L470 läuft nach L464) |

Anker-Kürzel (L969-987): `"tl"`/`"top-left"` → `north-east`, `"tr"`/`"top-right"` → `north-west`, `"bl"`/`"bottom-left"` → `south-east`, `"br"`/`"bottom-right"` → `south-west`, `"t"`/`"top"` → `north`, `"b"`/`"bottom"` → `south`, `"l"`/`"left"` → `east`, `"r"`/`"right"` → `west`, sonst unverändert an cetz.

### 3.4 `graphen`: `datensätze` (L499-684)

Eingabeformen: dictionary; `(zahlen-array, zahlen-array)`; `(physik-ds, physik-ds)`; Array von dictionaries. Fehlen `x`/`y` → `panic` (L547); Nicht-Dictionary → `panic` (L550).

| Key | Default | Werte | Sprache | Bedeutung |
|---|---|---|---|---|
| `x` | Pflicht | Physik-Datensatz | - | x-Werte |
| `y` | Pflicht | Physik-Datensatz | - | y-Werte |
| `marker` | `"x"` | str \| dictionary mit `symbol` plus weiteren mark-style-Keys | en | Punktsymbol (bei `marks` heißt dasselbe `symbol`) |
| `mark-style` | `none` | dictionary | en, kebab | cetz-`mark-style`, wird über `(fill: clr, stroke: clr + 1.25pt)` gelegt |
| `color` | `index + 1` | color \| int | en | gewinnt gegen `clr` (L544) |
| `clr` | - | color \| int | Abkürzung | Alias |

Erwartete Struktur eines Physik-Datensatzes (aus `@schule/physik`, deutsche Keys plus ein englischer):

| Key | Bedeutung |
|---|---|
| `name` | Größenname (content), wird Achsenbeschriftung |
| `einheit` | Einheit (str \| none); alle x- bzw. y-Datensätze müssen dieselbe haben (`panic` L576, L584) |
| `werte` | Array; `none`- und content-Einträge werden übersprungen |
| `prefix` | Einheitenvorsatz als String, `"1"` = keiner (englischer Key zwischen deutschen) |

### 3.5 String-Enums im Überblick

| Stelle | Werte | Sprache |
|---|---|---|
| `graphen.grid`, `x-grid`, `y-grid` | `"both"`, `"major"`, `"minor"`, `"none"` | en (cetz-plot) |
| `fills[].domain` | `"auto"` (String) | en |
| Plot-`label.position` | `"tl"`, `"tr"`, `"bl"`, `"br"` | en, Kürzel |
| `marks[].anchor` | cetz-Anker (`"south-west"` …) plus `"tl"`, `"tr"`, `"bl"`, `"br"`, `"t"`, `"b"`, `"l"`, `"r"`, `"top-left"`, `"top-right"`, `"bottom-left"`, `"bottom-right"`, `"top"`, `"bottom"`, `"left"`, `"right"` | en |
| `marks[].symbol`, `datensätze[].marker` | cetz-Mark-Symbole, Default `"x"` | en |
| `steckbrief.notation` | `"dec"`, `"sci"`, `"frac"` | en, Abkürzungen |
| `kreisdiagramm.legend` | `"r"`, `"l"`, `"t"`, `"b"` (plus `false`, dictionary) | en, Kürzel |
| `kreisdiagramm.mode` | `"percent"`, `"absolute"` | en |
| `teilaufgaben.numbering` | Typst-Numbering-Muster, Default `"a)"` (wirkungslos) | - |

Deutsche String-Enum-Werte (wie `"kariert"` in anderen Paketen) gibt es in mathematik nicht.

### 3.6 Rückgabe-Dictionary von `steckbrief`

Erfolgsfall (L1595-1613):

| Key | Typ | Sprache | Inhalt |
|---|---|---|---|
| `ansatz` | content | de | `f(x) = a x^n + …` |
| `math` | content | en | Funktionsgleichung mit Zahlen |
| `math-digits` | function `digits => content` | en, kebab | wie `math` mit wählbarer Stellenzahl (bei `"frac"` wirkungslos) |
| `function` | function `x => float` | en | auswertbare Funktion |
| `gleichungssystem` | content \| none | de | LGS als `mat(delim: "|", …)` |
| `bedingungen` | array von content | de | Bedingungen per `eval("$…$")` gesetzt |
| `bedingungen-raw` | array von str | de + en | Eingabestrings |
| `bedingungen-system` | content \| none | de + en | Bedingungen als Matrix |
| `gleichungssystem-raw` | array von content | de + en | einzelne Gleichungen |
| `bedingungen-system-raw` | array von Tripeln | de + en | |
| `a` … `h` | float | - | Koeffizienten, höchster Grad zuerst |

Fehlerfall, singuläre Matrix (L1249-1256): `error` (deutscher Text), `math: none`, `function: none`, `gleichungssystem: none`, `grad`, `bedingungen` (hier die Rohstrings, im Erfolgsfall gesetzter Content). Der Key `grad` existiert nur im Fehlerfall, `error` nur im Fehlerfall, `ansatz` und alle `-raw`-Keys nur im Erfolgsfall.
Die Doku (L1005-1006) nennt nur `math`, `math-digits`, `function`, `gleichungssystem` und die Koeffizienten.

---

## 4. Validierung und Fehlermeldungen

Eine systematische Optionsprüfung (wie `_pruefe` in arbeitsblatt 0.4.0) gibt es nicht. Unbekannte benannte Argumente werden nirgends zurückgewiesen: sie laufen in `teilaufgaben` an `table()`, in `graphen` an `plot.plot()` (dort ggf. englische cetz-Fehler), und werden in `kreisdiagramm`, `steckbrief`, `geogebra-algebra` verschluckt. Unbekannte String-Enum-Werte fallen überall still auf einen Default zurück.

Alle eigenen Meldungen sind deutsch:

| Zeile | Art | Meldung |
|---|---|---|
| L308 | panic | `Plot muss entweder eine Funktion/Content ($x^2$) oder ein Dictionary (term: $x^2$, color: ...) sein` |
| L364 | panic | `'between' muss ein Array mit zwei Funktionen sein: between: ($f$, $g$)` |
| L378 | panic | `Fill muss ein Dictionary sein: (between: ($f$, $g$), domain: ..., color: ...) oder (term: $f$, domain: ..., color: ...)` |
| L547 | panic | `Datensatz-Dictionary muss 'x' und 'y' Keys haben` |
| L550 | panic | `Datensatz muss entweder ein Tupel (x, y) oder ein Dictionary (x: x, y: y, marker: ...) sein` |
| L576 | panic | `Alle x-Datensätze müssen die gleiche Einheit haben!` |
| L584 | panic | `Alle y-Datensätze müssen die gleiche Einheit haben!` |
| L853 | assert | `Label benötigt 'x' Key` |
| L854 | assert | `Label benötigt 'content' Key` |
| L1132, L1167 | assert | `Ungültiges Format: ` + Bedingung |
| L1145, L1170 | assert | `Kein '=' gefunden in: ` + Bedingung |
| L1250 | Rückgabewert `error` (kein Abbruch) | `Matrix ist singulär - keine eindeutige Lösung. Bitte überprüfe die Bedingungen.` |

Uneinheitlich ist der Mechanismus: `panic`, `assert` und ein `error`-Feld im Rückgabewert nebeneinander. Die Meldungen nennen nie den Funktionsnamen (`graphen: …`), und sie mischen deutsche Sätze mit englischen Fachwörtern ("Keys", "Fill", "Plot", "Label").

---

## 5. Inkonsistenzen (mit Zeile)

### 5.1 Sprache und Schreibweise

1. L23-29 `teilaufgaben(tasks:, columns:, numbering:, gutter:, loesungen:)`: vier englische Parameter und ein deutscher in einer Signatur. Aufgaben heißen `tasks`, Lösungen `loesungen`.
2. L28 `loesungen` (Umschrift `oe`) gegen L113 `datensätze` (echter Umlaut im Bezeichner): zwei Umlaut-Konventionen im selben Paket.
3. L97-117 `graphen`: 18 englische Parameter (`size`, `scale`, `step`, `grid`, `fills`, `marks`, `samples`, `annotations` …) und genau ein deutscher (`datensätze`). Funktionsname deutsch.
4. L1019 `steckbrief(..bedingungen, notation:, precision:)`: Sink deutsch, Optionen englisch, Enum-Werte englische Kürzel (`"dec"`, `"sci"`, `"frac"`).
5. L1595-1606 Rückgabe-Keys gemischt: `ansatz`, `gleichungssystem`, `bedingungen` (de) neben `math`, `math-digits`, `function` (en) und Zwittern `bedingungen-raw`, `gleichungssystem-raw`, `bedingungen-system-raw`.
6. L1638 `kreisdiagramm(data, legend:, show-percentage:, label-color:, mode:)`: deutscher Funktionsname, rein englische Parameter.
7. L1799-1903 GeoGebra-Familie komplett englisch (`geogebra-colors`, `-button`, `-approx-button`, `-style`, `-cell`, `-algebra`) neben deutsch benannten Fachfunktionen.
8. L61 `tasks` als englischer Alias für `teilaufgaben`; weitere englische Aliase für `graphen`, `steckbrief`, `kreisdiagramm` gibt es nicht.
9. Dictionary-Keys: `clr` (Abkürzung) und `color` als Doppelnamen an vier Stellen (L304/305, L374/375, L464/470, L544), `pos`/`position` (L447/449), `content`/`label` (L453/455).
10. Datensatz-Keys `name`, `einheit`, `werte` (de) plus `prefix` (en) (L511-512, L640-646).
11. snake_case-Ausreißer in sonst kebab-case-Code: `x_ds`, `y_ds` (L511-513), `mantissa_formatted` (L1099); dazu die re-exportierten `default_seed`, `low_cminstd_rand`, `low_cminstd_randint`, `step_seed`, `fisher_yates_shuffle` (L1).
12. Lokale Bezeichner gemischt: `polstellen-segmente`, `bereich`, `schritt`, `segmente` (L184-208) neben `find-intersection`, `processed-plots`, `effective-x-step`; in `steckbrief` `koeffizienten`, `grad`, `bedingung`, `ableitung` neben `matrix`, `pivot`, `factor`, `parsed`.

### 5.2 Dieselbe Sache verschieden benannt

13. Punktsymbol: `symbol` bei `marks` (L461), `marker` bei `datensätze` (L542), und im `marker`-Dictionary wieder `symbol` (L925).
14. Lage einer Beschriftung: `position` mit `"tl|tr|bl|br"` beim Plot-Label (L861), `anchor` mit cetz-Ankern oder Kürzeln bei `marks` (L459, L969-987), `legend: "r|l|t|b"` in `kreisdiagramm` (L1658-1689).
15. Die Kürzel bedeuten nicht dasselbe: beim Plot-Label ist `"tr"` = Beschriftung rechts oberhalb (L874-886). Bei `marks` wird `"t"`/`"top"` auf den cetz-Anker `north` abgebildet (L977), d. h. die Oberkante des Textes liegt am Punkt und der Text steht darunter, während `"l"`/`"left"` → `east` (L981) den Text links vom Punkt setzt. Horizontal ist das Kürzel also eine Lageangabe, vertikal eine Ankerangabe. Aus dem Code abgeleitet, nicht gerendert.
16. Beschriftungstext: `content` im Plot-Label (L854), `content` oder `label` bei `marks` (L453-456); `label` ist beim Plot dagegen der Container (L306).
17. Abstand der Beschriftung: Default `1mm` beim Plot-Label (L865), `2mm` bei `marks` (L423).
18. Inhaltsparameter: `body` in `geogebra-style` (L1848), `content` in `geogebra-cell` (L1865), `..cells` in `geogebra-algebra` (L1904), `data` in `kreisdiagramm` (L1639), `tasks:` (benannt!) oder positionaler Enum-Body in `teilaufgaben` (L24, L31).
19. Spalten und Abstände: `columns`/`gutter` in `teilaufgaben` (L25, L27), `columns`/`inset` in `geogebra-algebra` (L1906-1907); kein `gutter` dort, kein `inset` hier.
20. Größe: `size` als einheitenlose Zahl/Array in `graphen` (L98), `size` als length in `geogebra-button` (L1809), `radius` (cetz-Einheiten, nur über `..args`) in `kreisdiagramm` (L1780). `scale` gibt es nur in `graphen`.
21. Strich: `line-width` als eigener Parameter (L110), daneben `stroke` in Plot-/Mark-Dictionaries (L303, L462) und `stroke` als Parameter in `geogebra-algebra` (L1905).
22. Drei unabhängige Farbpaletten: `colors` in `graphen` (L128-139), `default-colors` in `kreisdiagramm` (L1744-1755), `geogebra-colors` (L1799). Int-Farbindex (`color: 2`) funktioniert nur in Plot-, Fill-, Mark- und Datensatz-Dictionaries, nicht im Plot-Label (L864, bestätigt) und nicht in `kreisdiagramm`.
23. Stellenzahl/Genauigkeit: `precision` (Nullschwelle, L1019), `digits` (Nachkommastellen, nur über `math-digits`, L1598), fest verdrahtete `1e-10` als Pivot-Schwelle (L1247) statt `precision`.

### 5.3 bool / String / `auto` / `none` für gleichartige Schalter

24. "Automatisch" hat vier Schreibweisen: `size: none` (L98), `x: auto` (L100), `fills[].domain: "auto"` als String (L350), `columns: auto` (L25).
25. "Erbt vom allgemeinen Wert": `x-step: none`, `x-grid: none` (L103, L108). Folge: `none` kann für eine einzelne Achse nicht "aus" bedeuten; für das Gitter braucht man den String `"none"`, während `step: none` (beide Achsen) "keine Ticks" heißt (L758-759).
26. Legende: `legend: false` schaltet ab, `legend: none` zeigt die Legende rechts (L1654, L1703-1711, bestätigt: kein Fehler). Gitter dagegen `"none"` als String.
27. `kreisdiagramm`: bool `show-percentage` plus String `mode` für eine einzige Entscheidung (nichts / Prozent / absolut) (L1643, L1646).
28. `geogebra-cell(menu: true, approx: false)` als Positiv-Schalter; `geogebra-algebra` hat nur `last-has-approx`, kein `menu` (L1866-1867, L1908, L1915). Negativ-Schalter (`no-…`) kommen im Paket nicht vor.
29. Sentinel-Vergleiche mit dem Default statt `auto`: `x == (-5, 5)` (L687), `y == (-5, 5)` (L691), `x-label == [$x$]` (L695), `y-label == [$y$]` (L699), `step == 1` (L708, L712). Wer bei Datensätzen bewusst `x: (-5, 5)` oder `step: 1` setzt, wird überschrieben.

### 5.4 Singular / Plural, positional / named

30. Plural-Parameter `fills`, `marks`, `datensätze`, `annotations`, `loesungen`, `tasks`, `..bedingungen`, `..cells`; Singular-Parameter `data` (L1639) für eine Liste. `fills`, `marks`, `datensätze` akzeptieren zusätzlich das Einzelobjekt (L321, L413, L501), `tasks`/`loesungen` nicht.
31. Hauptinhalt positional: `graphen(..funktionen)`, `steckbrief(..bedingungen)`, `geogebra-algebra(..cells)`, `kreisdiagramm(data)`. In `teilaufgaben` dagegen benannt (`tasks:`) ODER positional als Enum-Body.
32. Sink mit Doppelfunktion: in `teilaufgaben` und `graphen` trägt `..args` positional Inhalt und named Durchreichung (L29, L115); in `kreisdiagramm` nur named, gefiltert (L1648); in `steckbrief`/`geogebra-algebra` ist der Sink nach dem Inhalt benannt und verschluckt named.
33. L115-116: `annotations` steht hinter dem Sink `..args`, alle anderen benannten Parameter davor.
34. `color` gewinnt gegen `clr` bei Plots (L304-305), Fills (L374-375) und Datensätzen (L544), bei `marks` gewinnt `clr` (L464-475).
35. Fehlerverhalten uneinheitlich: unbekannte Plot-/Fill-/Datensatz-Formen → `panic`, unbekannte `marks`-Formen → still ignoriert (L428-476, bestätigt mit `marks: (1, 2)`), Plot-`label` mit falschem Typ → still ignoriert (L851).

### 5.5 Doku gegen Code

36. L18 dokumentiert `numbering`, der Parameter wird nicht verwendet.
37. L73 nennt für `size` den Typ length; verwendet werden einheitenlose Zahlen (L797).
38. L77-79 nennen `none` nicht als zulässigen Wert für `step`; der Test `tests/mathe-graphen-terme.typ` nutzt `step: none`.
39. L94 nennt `annotations` als content, Default ist `{}`.
40. L1005-1006 unvollständige Liste der Rückgabe-Keys.
41. L1631, L1633: `mode: "percent"` "zeigt relative Prozentwerte", gerechnet wird nicht (L1719).
42. L1634-1635: "werden direkt an `chart.piechart()` weitergegeben", tatsächlich Whitelist (L1776-1784); `colors` wird ausgewertet, steht aber weder in der Signatur noch in der Doku.
43. L1018 und L1637: ein normaler `//`-Kommentar steht zwischen Doc-Kommentar (`///`) und `#let`.

---

## 6. Kopplungen

### 6.1 Importe in `mathematik.typ`

| Zeile | Import | Zweck | Stand |
|---|---|---|---|
| L1 | `@schule/random:0.0.1: *` | keiner, im ganzen File wird kein Name daraus benutzt | einzige vorhandene Version; reiner Re-Export-Ballast |
| L2 | `@schule/physik:0.0.2: umrechnungseinheit` | Einheiten-Multiplikator für `datensätze` (L636-646) | aktuell (physik hat 0.0.1, 0.0.2) |
| L39 | `@schule/aufgaben:0.1.2: loesung, teilaufgabe` (lokal in `teilaufgaben`) | Teilaufgaben und Lösungen setzen | VERALTET: vorhanden sind 0.0.1-0.0.4, 0.1.0-0.1.2, 0.3.0, 0.3.1 |
| L118 | `@preview/cetz:0.4.2: *` | Zeichnen | |
| L119 | `@preview/cetz-plot:0.1.3: *` | Plot | |
| L120 | `@preview/eqalc:0.1.3: math-to-str, get-variable` | Formel → Funktion | |
| L593 | `@preview/fancy-units:0.1.1: unit` | Einheiten in Achsenbeschriftung | |
| L1020 | `@preview/zero:0.5.0: num as znum` | Zahlformat | |
| L1650-1651 | `@preview/cetz:0.4.2: canvas`, `@preview/cetz-plot:0.1.3: chart` | Kreisdiagramm | |

### 6.2 Durchreichungen

| Von | Nach | Name hier → Name dort |
|---|---|---|
| `teilaufgaben` | `aufgaben:0.1.2.teilaufgabe(item-label: none, label: none, workspace: none, body)` | nur Body; `numbering` wird nicht nach `item-label` durchgereicht |
| `teilaufgaben` | `aufgaben:0.1.2.loesung(body)` | `loesungen.at(i)` → Body |
| `teilaufgaben` | `table()` | `gutter` → `column-gutter` und `row-gutter`; `columns` (int) → `(1fr,) * n`; `..args.named()` 1:1 |
| `graphen` | `physik:0.0.2.umrechnungseinheit(wert, einheit)` | `ds.einheit`, `ds.prefix` |
| `graphen` | `cetz-plot plot.plot()` | `x`/`y` → `x-min`/`x-max`/`y-min`/`y-max`; `step`/`x-step` → `x-tick-step` + `x-minor-tick-step`; `grid`/`x-grid` → `x-grid`; `x-label` → `x-label`; `size` → `size`; `..named` 1:1 |
| `graphen` | `cetz canvas()` | `scale` → `length: scale * 1cm` |
| `kreisdiagramm` | `cetz-plot chart.piechart()` | `legend` (Kürzel → Dictionary), `colors`/`slice-style` → `slice-style`, `show-percentage` + `mode` + `label-color` → `inner-label`, Whitelist-Keys 1:1 |
| `geogebra-algebra` | `table()` | `stroke`, `columns`, `inset` 1:1 |

### 6.3 Wer benutzt `mathematik`

| Paket/Datei | Import |
|---|---|
| `arbeitsblatt/0.1.0` bis `0.1.9` | `@schule/mathematik:0.0.1: *` (alte API) |
| `arbeitsblatt/0.2.0` | `@schule/mathematik:0.0.2: *` (bekommt damit auch `m`, `a`, `rand`, … ) |
| `arbeitsblatt/0.2.1`, `0.2.2`, `0.2.3` | `@schule/mathematik:0.0.2: tasks` |
| `arbeitsblatt/0.2.4`, `0.3.0`, `0.3.1` | `…: geogebra-algebra, geogebra-cell, graphen, kreisdiagramm, steckbrief, teilaufgaben` |
| `arbeitsblatt/0.3.2`, `0.4.0` | `…: geogebra-algebra, geogebra-cell, graphen, kreisdiagramm, steckbrief` (ohne `teilaufgaben`) |
| `tests/mathe-graphen-terme.typ` | `@schule/mathematik:0.0.2: *` |
| `mathematik/0.0.2/docs/content.typ` | `@schule/mathematik:0.0.2: *` |

Doppelung: `arbeitsblatt/0.4.0/src/arbeitsblatt.typ` L1228-1263 (ebenso 0.3.2 L1120 ff.) enthält eine eigene, korrigierte Kopie von `teilaufgaben` samt Alias `tasks` mit identischer Signatur, aber `loesung`/`teilaufgabe` aus `aufgaben:0.3.1`, wirksamem `numbering` und repariertem Leerfall. Begründung im dortigen Kommentar L1210-1214: die mathematik-Fassung bindet `aufgaben:0.1.2`, deren `loesung` die Lösung immer sofort zeigt. Die mathematik-Fassung ist damit für aktuelle Arbeitsblätter überholt.

Nicht weitergereicht von arbeitsblatt 0.4.0: `geogebra-colors`, `geogebra-button`, `geogebra-approx-button`, `geogebra-style`.

Im Repo liegt außerdem das unversionierte Verzeichnis `typstage-geogebra/0.1.0/` (laut git status untracked; `src/applet.typ`, `src/lib.typ`, `src/boot.js`): ein zweites GeoGebra-Paket neben den `geogebra-*`-Funktionen hier. Inhalt nicht geprüft.

---

## 7. Fehler und Altlasten

### 7.1 Fehler (reproduziert, wo angegeben)

| Nr. | Zeile | Befund |
|---|---|---|
| F1 | L1 | `import "@schule/random:0.0.1": *` re-exportiert 11 Namen, darunter `m` und `a`. Jedes `#import "@schule/mathematik:0.0.2": *` überschreibt damit `m` und `a` im Dokument (bestätigt). Kein einziger dieser Namen wird in der Datei benutzt. |
| F2 | L2 | `umrechnungseinheit` wird ungewollt öffentlich (bestätigt). |
| F3 | L31 | `args.pos() != none` ist immer wahr; `#teilaufgaben()` ohne Inhalt bricht mit "array index out of bounds" in L32 ab (bestätigt). In arbeitsblatt 0.4.0 behoben (`args.pos().len() > 0`). |
| F4 | L26 | `numbering` ohne Wirkung. |
| F5 | L39 | feste Bindung an `aufgaben:0.1.2`: eigener Zähler-/Lösungs-State, unabhängig von dem `aufgaben`-Stand, den das Dokument sonst lädt. |
| F6 | L383 | `x: auto` zusammen mit `fills` und `domain: "auto"` (auch über die Kurzformen): "type auto has no method `at`" (bestätigt). L339 fängt `auto` ab, L383-396 nicht. |
| F7 | L303-305 | `stroke: red + 2pt` zusammen mit `color`/`clr`: "fields on stroke are not yet mutable" (bestätigt). |
| F8 | L864, L902 | `label: (color: 2)`: Int-Index wird nicht aufgelöst, Absturz (bestätigt). |
| F9 | L413-417 | Ein einzelner Punkt `marks: (1, 2)` wird als Array zweier Einträge gelesen und still verworfen (bestätigt: kein Fehler, kein Punkt); nötig ist `((1, 2),)`. |
| F10 | L687-715 | Sentinel-Vergleiche mit Defaults, siehe 5.3 Nr. 29. |
| F11 | L814-818 | Unsichtbarer Dummy-Plot `x => x` auf `(0, 5)` in jedem Diagramm; bei `x: auto`/`y: auto` zieht er den Bereich 0 bis 5 in die Auto-Skalierung. |
| F12 | L969-987 | `marks`-Kürzel vertikal vermutlich verdreht, siehe 5.2 Nr. 15 (nicht gerendert). |
| F13 | L1136-1154 | `steckbrief("f(0)=0,5", …)`: "invalid float: 0,5" (bestätigt). `graphen` versteht das Dezimalkomma (L163), `steckbrief` nicht. |
| F14 | L1374, L1445, L1609 | Koeffizientennamen nur `a` bis `h`: ab 9 Bedingungen "array index out of bounds" (bestätigt). Der sechste Koeffizient heißt `f` wie die Funktion. |
| F15 | L1247 | Pivot-Schwelle fest `1e-10`, Parameter `precision` wird dafür nicht benutzt. |
| F16 | L1249-1256 | Fehlerfall liefert ein Dictionary mit anderer Schlüsselmenge statt abzubrechen; `sb.ansatz` o. ä. scheitert dann mit einer Typst-Meldung ohne Bezug zur Ursache. |
| F17 | L1485/L1493 gegen L1533/L1535 | Dezimal-/Sci-Ausgabe setzt `k dot x`, Bruch-Ausgabe `k x` ohne Malpunkt. |
| F18 | L1109-1113 | `format-number` gibt je nach Wert `str` oder content zurück. |
| F19 | L1719 | `mode: "percent"` rechnet nicht in Prozent um. |
| F20 | L1776-1784 | Unbekannte benannte Argumente an `kreisdiagramm` werden verschluckt (bestätigt mit `foo: 1`). |
| F21 | L1811 | `geogebra-button` hat `#808080` fest im SVG; `geogebra-colors.button` (L1802) wird nirgends verwendet. |
| F22 | L1850-1851 | Schrift "New Computer Modern Sans Math" wird vorausgesetzt, ohne Fallback. |

### 7.2 Toter und doppelter Code

| Zeile | Befund |
|---|---|
| L290 | `clr` wird nur einmal in L292 gelesen; eigene Variable überflüssig |
| L292 | Kommentar "Label-Definition (position, content)" per Copy-and-paste an der `strk`-Zeile |
| L441-443 | unerreichbarer Zweig (Bedingung von L428 fängt denselben Fall bereits ab) |
| L869-870 | `label-side`, `anchor-side` berechnet, nie benutzt |
| L376 | `auto-domain`-Key doppelt zu `domain: "auto"` |
| L544 und L627-628 | `color`/`clr` der Datensätze zweimal aufgelöst |
| L621-623 | Defaults, die wegen L541-545 immer überschrieben werden |
| L1041 | `rat-add` unbenutzt |
| L1351 | `koeff-idx` unbenutzt |
| L1118-1157 und L1160-1173 | `parse-bedingung` und `parse-bedingung-rat` fast identisch |
| L1187-1273 und L1279-1337 | Gauß-Elimination doppelt (float und rational); im `"frac"`-Fall laufen beide |
| L1467-1519 und L1522-1557 | `format-polynom` und `format-polynom-rat` doppelt |
| L1374, L1445, L1609 | Liste `("a", …, "h")` dreimal |
| L1569-1581 | Schleife kopiert `row.cells` elementweise in `cells` |
| L1658-1711 | sechs Legenden-Dictionaries, drei davon identisch (rechts) |
| L1767-1771 | `default-*`-Variablen jeweils genau einmal benutzt |
| L1018, L1637 | Restkommentare zwischen Doc-Kommentar und Definition |
| L1 | Import ohne Nutzung (siehe F1) |

### 7.3 Sonstiges

- Keine `.orig`-Datei im Paket mathematik (die im git status genannte liegt in `aufgaben/0.3.1/`).
- Kein auskommentierter Code in der Datei.
- `README.md` leer; `typst.toml`-Beschreibung unvollständig.
- Die Versionsnummer `0.0.2` passt nicht zum Zielschema 0.4.x; `0.0.1` hat eine komplett andere API und hängt noch an `arbeitsblatt` 0.1.x und an `aufgaben:0.0.4`.
- Das Paket bündelt fünf fachlich getrennte Dinge: Aufgabenlayout (`teilaufgaben`, gehört inhaltlich zu aufgaben/arbeitsblatt und ist dort schon dupliziert), Funktionsplotter (`graphen`), Rechenhelfer (`steckbrief`), Statistikdiagramm (`kreisdiagramm`), GeoGebra-Nachbildung (`geogebra-*`).
