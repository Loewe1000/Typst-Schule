# Inventar: Nutzung und Dokumentation der API im Repo

Stand: 2026-11-14, Branch `main` (197ea96). Nur gelesen und in ein Scratchpad kompiliert, im Repo nichts geändert.
Repo: `/Users/alexander/Library/Application Support/typst/packages/schule`

Untersuchte (jeweils neueste) Versionen: arbeitsblatt 0.4.0, aufgaben 0.3.1, klassenarbeit 0.4.0, klausurboegen 0.0.5, mathematik 0.0.2, physik 0.0.2, informatik 0.0.2, patterns 0.0.2, operatoren 0.0.1.

Werkzeuge vorhanden: `typst 0.15.1` (CI nagelt 0.15.0 fest), `pdftotext` (poppler).

---

## 0. Das Wichtigste in Kürze

1. **Die arbeitsblatt-0.4.0-Doku wird gar nicht gebaut.** `arbeitsblatt/0.4.0/docs/` hat nur `web.typ`/`manual.typ` (schuldocs 0.1.0 + mantys), kein `docs.typ`. `build.sh` überspringt solche Versionen; `manual.typ` scheitert unter Typst 0.15 (`unknown symbol modifier` in mantys 1.0.2). Die neueste arbeitsblatt-Doku auf der Website ist deshalb **0.3.0** (0.3.1, 0.3.2, 0.4.0 fehlen). Die 0.4.0-Doku nennt im Text durchgehend `@schule/arbeitsblatt:0.3.2` und erwähnt Themes (`theme`, `akzent`), `lsg`, `loesungsmodus`, die Kästen und die Metadaten-Parameter nirgends.
2. **Die API-Referenz entsteht automatisch** (schuldocs `show-module` → `tidy.parse-module` über `read("../quelle.typ")`): Namen, Signaturen, Vorgabewerte kommen aus dem Quelltext. **Von Hand** gepflegt sind: die Docstring-Zeilen `/// - name (typ): Text`, der gesamte Fließtext, alle Beispiele (in `show-example` je zweimal: `rendered:` und `source:`), Options-Tabellen, READMEs, Templates.
3. **Die Doku enthält Beispiele, die nicht kompilieren**, weil `show-code` nichts ausführt: `klausurboegen: (stufe: "I")` (5 Stellen, klassenarbeit-Doku) → `unexpected argument: stufe`; `materialien: "reingequetscht"` (aufgaben-Doku) → vom Assert in arbeitsblatt abgelehnt (richtig: `"reinquetschen"`); der Schnellstart der arbeitsblatt-Doku → `label <graph> does not exist`; Template-Kommentar `punkte: aufgabe, teilaufgabe` → richtig `aufgaben`, `teilaufgaben`.
4. **Tests: 19/19 bestanden.** Alle Tests pinnen eine exakte Paketversion; `neue-version.sh` zieht `tests/` nicht nach. Nach dem Anlegen einer 0.4.x prüfen die Tests weiter die alte Version. Es gibt keine Signatur-/Snapshot-Tests, keinen Test, der Doku-Beispiele kompiliert, und keine Tests für klausurboegen, physik, informatik, operatoren.
5. **`build.sh` bricht bei einer nicht baubaren Doku nicht ab** (nur `WARNUNG … überspringe`, Exit 0): eine Umbenennung, die ein `rendered:`-Beispiel bricht, lässt die Version still von der Website verschwinden.

---

## 1. Häufigkeit: Funktionen, Parameter, Optionswerte

### Methode

grep-basiert (Python-`re`, Skript: `/private/tmp/claude-501/-Users-alexander--claude-spares-spare-T3hcxg/d64ba95e-5a74-47f7-8977-d9b919f98567/scratchpad/freq.py`).

- **Namensliste**: alle `#let name` auf oberster Ebene der Quelldateien der neun Pakete ohne führenden Unterstrich (138 Namen), Parameter aus deren Signaturen.
- **Korpus** (drei Spalten):
  - *Doku* = `docs/*.typ` der neun neuesten Versionen
  - *Vorl.* = `template/*.typ`, `showcase/*.typ`, `README.md` dieser Versionen
  - *Tests* = `tests/*.typ`
- **Funktionen**: Treffer für `name(`, `name[`, `name.with(` (auch in Fließtext wie `` `aufgabe()` `` und in Docstring-Beispielen der Doku).
- **Parameter**: Treffer für `name:` als ganzes Wort.
- Ein `examples/`-Verzeichnis hat keines der neun Pakete (nur blockst, typstage). `template/` haben nur arbeitsblatt und klassenarbeit, `showcase/` nur arbeitsblatt.

Einschränkungen: (a) `show-example` führt jedes Beispiel doppelt (gesetzter Teil + Quelltext), Doku-Zahlen sind dadurch teils verdoppelt. (b) Gleichnamige Parameter verschiedener Funktionen (`title`, `width`, `class`, `columns`, `label` …) lassen sich per grep nicht trennen; `width`, `height`, `columns`, `stroke`, `text`, `align`, `inset` enthalten auch Typst-eigene Aufrufe (`rect(width: …)`). (c) Die Spalte „Vorl." ist bei informatik durch die 383 Zeilen lange README geprägt.

### 1a. Funktionen (Aufrufe)

| Funktion | Paket | gesamt | Doku | Vorl. | Tests |
|---|---|---:|---:|---:|---:|
| `aufgabe` | aufgaben | 77 | 43 | 7 | 27 |
| `erwartung` | aufgaben | 56 | 34 | 1 | 21 |
| `teilaufgabe` | aufgaben | 48 | 26 | 1 | 21 |
| `klassenarbeit` | klassenarbeit | 40 | 25 | 2 | 13 |
| `graphen` | mathematik | 32 | 20 | 0 | 12 |
| `set-options` | aufgaben | 28 | 24 | 0 | 4 |
| `loesung` | aufgaben | 27 | 17 | 6 | 4 |
| `arbeitsblatt` | arbeitsblatt | 22 | 13 | 4 | 5 |
| `datensatz` | physik | 21 | 21 | 0 | 0 |
| `caesar` | informatik | 20 | 8 | 12 | 0 |
| `kariert` | patterns | 18 | 11 | 1 | 6 |
| `häufigkeitsanalyse` | informatik | 16 | 3 | 13 | 0 |
| `bin2dec` | informatik | 14 | 6 | 8 | 0 |
| `dec2bin` | informatik | 14 | 6 | 8 | 0 |
| `operator` | operatoren | 14 | 14 | 0 | 0 |
| `text-to-blocks` | informatik | 13 | 4 | 9 | 0 |
| `ascii-table` | informatik | 12 | 2 | 10 | 0 |
| `dec2hex` | informatik | 12 | 6 | 6 | 0 |
| `hex2dec` | informatik | 12 | 6 | 6 | 0 |
| `lücke` | arbeitsblatt | 11 | 5 | 6 | 0 |
| `messwerttabelle` | physik | 10 | 10 | 0 | 0 |
| `liniert` | patterns | 9 | 7 | 0 | 2 |
| `material` | aufgaben | 9 | 6 | 0 | 3 |
| `show-erwartungen` | aufgaben | 9 | 7 | 1 | 1 |
| `tip` | arbeitsblatt | 9 | 8 | 1 | 0 |
| `vigenere` | informatik | 8 | 2 | 6 | 0 |
| `info` | arbeitsblatt | 7 | 6 | 1 | 0 |
| `klausurbögen` | klausurboegen | 7 | 7 | 0 | 0 |
| `messdaten` | physik | 6 | 6 | 0 | 0 |
| `mono` | arbeitsblatt,informatik | 6 | 2 | 4 | 0 |
| `operatoren-liste` | operatoren | 6 | 6 | 0 | 0 |
| `rot13` | informatik | 6 | 6 | 0 | 0 |
| `teilaufgaben` | arbeitsblatt,mathematik | 5 | 4 | 1 | 0 |
| `warning` | arbeitsblatt | 5 | 4 | 1 | 0 |
| `berechnung` | physik | 4 | 4 | 0 | 0 |
| `kreisdiagramm` | mathematik | 4 | 4 | 0 | 0 |
| `minipage` | arbeitsblatt | 4 | 4 | 0 | 0 |
| `show-bewertung` | aufgaben | 4 | 3 | 0 | 1 |
| `get-points` | aufgaben | 3 | 2 | 0 | 1 |
| `icon-link` | arbeitsblatt | 3 | 3 | 0 | 0 |
| `lineare_regression` | physik | 3 | 3 | 0 | 0 |
| `reset-aufgaben` | aufgaben | 3 | 3 | 0 | 0 |
| `steckbrief` | mathematik | 3 | 3 | 0 | 0 |
| `workspace` | arbeitsblatt | 3 | 2 | 1 | 0 |
| `atbash` | informatik | 2 | 2 | 0 | 0 |
| `canvas` | arbeitsblatt | 2 | 2 | 0 | 0 |
| `geogebra-algebra` | mathematik | 2 | 2 | 0 | 0 |
| `qrbox` | arbeitsblatt | 2 | 2 | 0 | 0 |
| `qty` | arbeitsblatt | 2 | 2 | 0 | 0 |
| `show-loesungen` | aufgaben | 2 | 2 | 0 | 0 |
| `show-materialien` | aufgaben | 2 | 2 | 0 | 0 |
| `amperemeter` | physik | 1 | 1 | 0 | 0 |
| `exponentielle_regression` | physik | 1 | 1 | 0 | 0 |
| `geogebra-cell` | mathematik | 1 | 1 | 0 | 0 |
| `geogebra-style` | mathematik | 1 | 1 | 0 | 0 |
| `lamp` | physik | 1 | 1 | 0 | 0 |
| `lsg` | arbeitsblatt | 1 | 0 | 0 | 1 |
| `memo` | arbeitsblatt | 1 | 0 | 1 | 0 |
| `non-print-pagebreak` | arbeitsblatt | 1 | 1 | 0 | 0 |
| `num` | arbeitsblatt | 1 | 1 | 0 | 0 |
| `polynom_regression` | physik | 1 | 1 | 0 | 0 |
| `potenz_regression` | physik | 1 | 1 | 0 | 0 |
| `print-pagebreak` | arbeitsblatt | 1 | 1 | 0 | 0 |
| `quadratische_regression` | physik | 1 | 1 | 0 | 0 |
| `schaltkreis` | physik | 1 | 1 | 0 | 0 |
| `show-offene-loesungen` | aufgaben | 1 | 0 | 0 | 1 |
| `source` | physik | 1 | 1 | 0 | 0 |
| `unit` | arbeitsblatt | 1 | 1 | 0 | 0 |
| `wurzel_regression` | physik | 1 | 1 | 0 | 0 |

**Öffentlich, aber in Doku/Vorlagen/Tests nie aufgerufen (0 Treffer):** `abstract` (arbeitsblatt), `arbeitsblatt-einzeln` (arbeitsblatt), `atlas` (arbeitsblatt), `auto_einheit_anwenden` (physik), `bauhaus` (arbeitsblatt), `build-equation` (physik), `c_canvas` (arbeitsblatt), `combine-units` (physik), `conclusion` (arbeitsblatt), `count_decimal_places` (physik), `danger` (arbeitsblatt), `error` (arbeitsblatt), `example` (arbeitsblatt), `experiment` (arbeitsblatt), `fachfarbe` (arbeitsblatt), `fachfarben` (arbeitsblatt), `fachnamen` (arbeitsblatt), `flex-feld` (patterns), `format-equation-term` (physik), `format-number` (physik), `format-punkte` (aufgaben), `format-simple-equation` (physik), `format-unit` (physik), `generator` (physik), `geogebra-approx-button` (mathematik), `geogebra-button` (mathematik), `geogebra-colors` (mathematik), `get-punkte-anzeige` (aufgaben), `get-punkte-position` (aufgaben), `goal` (arbeitsblatt), `häufigkeitsanalyse-alt` (informatik), `idea` (arbeitsblatt), `ist-flex-feld` (patterns), `kasten-stil` (arbeitsblatt), `kicker` (arbeitsblatt), `klar` (arbeitsblatt), `konstante` (physik), `kontur` (arbeitsblatt), `kuerzel` (arbeitsblatt), `labor` (arbeitsblatt), `leiste` (arbeitsblatt), `loesungsmodus` (arbeitsblatt), `logos` (klassenarbeit), `motor` (physik), `multimeter` (physik), `multiplikatoren` (physik), `notify` (arbeitsblatt), `operatoren-config-state` (operatoren), `operatoren-state` (operatoren), `p_messwerttabelle` (physik), `pk` (physik), `print-state` (arbeitsblatt), `qr-code` (arbeitsblatt), `question` (arbeitsblatt), `regression` (physik), `riso` (arbeitsblatt), `show-loesung` (aufgaben), `show-loesung-inline` (aufgaben), `show-material` (aufgaben), `simple-source` (physik), `skizze` (arbeitsblatt), `success` (arbeitsblatt), `tasks` (arbeitsblatt,mathematik), `themes` (arbeitsblatt), `umrechnungseinheit` (physik), `voltmeter` (physik)

### 1b. Benannte Parameter (`name:`)

| Parameter | definiert in | gesamt | Doku | Vorl. | Tests |
|---|---|---:|---:|---:|---:|
| `title` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln, aufgaben.aufgabe | 52 | 18 | 12 | 22 |
| `width` | arbeitsblatt.qrbox, patterns.kariert, patterns.liniert, physik.messwerttabelle | 46 | 44 | 2 | 0 |
| `x` | mathematik.graphen | 37 | 27 | 2 | 8 |
| `y` | mathematik.graphen | 31 | 24 | 2 | 5 |
| `class` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln, klausurboegen.klausurbögen | 23 | 16 | 5 | 2 |
| `columns` | arbeitsblatt.minipage, arbeitsblatt.teilaufgaben, mathematik.geogebra-algebra, mathematik.teilaufgaben | 22 | 18 | 3 | 1 |
| `loesungen` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln, arbeitsblatt.teilaufgaben, mathematik.teilaufgaben | 21 | 15 | 3 | 3 |
| `punkte` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 21 | 12 | 2 | 7 |
| `height` | arbeitsblatt.workspace, informatik.ascii-table, patterns.kariert | 20 | 10 | 10 | 0 |
| `erwartungen` | klassenarbeit.klassenarbeit | 17 | 3 | 3 | 11 |
| `key` | informatik.caesar | 16 | 8 | 8 | 0 |
| `date` | klassenarbeit.klassenarbeit, klausurboegen.klausurbögen | 13 | 11 | 2 | 0 |
| `klausurboegen` | klassenarbeit.klassenarbeit | 13 | 8 | 5 | 0 |
| `print` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 13 | 7 | 3 | 3 |
| `ranges` | informatik.ascii-table | 12 | 2 | 10 | 0 |
| `teacher` | klassenarbeit.klassenarbeit, klausurboegen.klausurbögen | 12 | 10 | 2 | 0 |
| `cetz` | informatik.häufigkeitsanalyse-alt | 11 | 0 | 11 | 0 |
| `rel` | informatik.häufigkeitsanalyse-alt | 11 | 0 | 11 | 0 |
| `rows` | patterns.kariert, patterns.liniert | 11 | 2 | 0 | 9 |
| `stroke` | mathematik.geogebra-algebra | 10 | 8 | 2 | 0 |
| `workspace` | aufgaben.aufgabe, aufgaben.teilaufgabe | 10 | 2 | 0 | 8 |
| `label` | aufgaben.aufgabe, aufgaben.material, aufgaben.teilaufgabe | 9 | 5 | 0 | 4 |
| `block-size` | informatik.text-to-blocks | 8 | 2 | 6 | 0 |
| `color` | arbeitsblatt.icon-link | 8 | 8 | 0 | 0 |
| `keyword` | informatik.caesar | 8 | 2 | 6 | 0 |
| `exam` | klausurboegen.klausurbögen | 7 | 7 | 0 | 0 |
| `materialien` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 7 | 6 | 0 | 1 |
| `muster` | klausurboegen.klausurbögen | 7 | 5 | 2 | 0 |
| `subexam` | klausurboegen.klausurbögen | 7 | 7 | 0 | 0 |
| `varianten` | arbeitsblatt.arbeitsblatt, klassenarbeit.klassenarbeit | 7 | 6 | 1 | 0 |
| `workspaces` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 7 | 5 | 0 | 2 |
| `fach` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln, operatoren.operatoren-liste | 6 | 6 | 0 | 0 |
| `items` | patterns.kariert, patterns.liniert | 6 | 6 | 0 | 0 |
| `items-spacing` | patterns.kariert, patterns.liniert | 6 | 6 | 0 | 0 |
| `korrekturrand` | klausurboegen.klausurbögen | 6 | 4 | 2 | 0 |
| `students` | klausurboegen.klausurbögen | 6 | 6 | 0 | 0 |
| `teilaufgabe-numbering` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 6 | 5 | 0 | 1 |
| `erreicht` | aufgaben.show-erwartungen | 5 | 2 | 3 | 0 |
| `grid-size` | patterns.kariert | 5 | 5 | 0 | 0 |
| `stufe` | (alle 5 Treffer: Schlüssel im `klausurboegen`-Dictionary der klassenarbeit-Doku, den es im Code NICHT gibt; namensgleich mit dem Metadaten-Parameter arbeitsblatt.stufe) | 5 | 5 | 0 | 0 |
| `subtitle` | klassenarbeit.klassenarbeit | 5 | 3 | 2 | 0 |
| `text` | operatoren.operator | 5 | 5 | 0 | 0 |
| `aufgaben-shortcodes` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 4 | 1 | 0 | 3 |
| `caption` | aufgaben.material | 4 | 4 | 0 | 0 |
| `datensätze` | mathematik.graphen | 4 | 4 | 0 | 0 |
| `fills` | mathematik.graphen | 4 | 4 | 0 | 0 |
| `line-stroke` | klausurboegen.klausurbögen, patterns.kariert, patterns.liniert | 4 | 4 | 0 | 0 |
| `method` | aufgaben.aufgabe | 4 | 3 | 1 | 0 |
| `page-numbering` | klassenarbeit.klassenarbeit | 4 | 2 | 0 | 2 |
| `scale` | klausurboegen.klausurbögen, mathematik.graphen | 4 | 4 | 0 | 0 |
| `advanced` | informatik.atbash, informatik.caesar, informatik.vigenere | 3 | 3 | 0 | 0 |
| `content` | patterns.kariert | 3 | 2 | 0 | 1 |
| `info-table` | klassenarbeit.klassenarbeit | 3 | 3 | 0 | 0 |
| `large` | aufgaben.aufgabe | 3 | 3 | 0 | 0 |
| `legend` | mathematik.kreisdiagramm | 3 | 3 | 0 | 0 |
| `line-height` | patterns.liniert | 3 | 3 | 0 | 0 |
| `linienabstand` | klausurboegen.klausurbögen | 3 | 3 | 0 | 0 |
| `logo` | klassenarbeit.klassenarbeit | 3 | 3 | 0 | 0 |
| `name-field` | klassenarbeit.klassenarbeit | 3 | 3 | 0 | 0 |
| `page-settings` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 3 | 2 | 0 | 1 |
| `rand` | klausurboegen.klausurbögen | 3 | 3 | 0 | 0 |
| `result-table` | klausurboegen.klausurbögen | 3 | 3 | 0 | 0 |
| `sek1` | klausurboegen.klausurbögen | 3 | 3 | 0 | 0 |
| `size` | mathematik.geogebra-approx-button, mathematik.geogebra-button, mathematik.graphen | 3 | 3 | 0 | 0 |
| `step` | mathematik.graphen | 3 | 1 | 0 | 2 |
| `theme` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 3 | 0 | 3 | 0 |
| `align` | arbeitsblatt.minipage | 2 | 0 | 2 | 0 |
| `dateiname` | arbeitsblatt.arbeitsblatt, klassenarbeit.klassenarbeit | 2 | 1 | 1 | 0 |
| `font` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 2 | 2 | 0 | 0 |
| `font-size` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 2 | 2 | 0 | 0 |
| `grouped` | aufgaben.show-erwartungen | 2 | 2 | 0 | 0 |
| `inset` | mathematik.geogebra-algebra | 2 | 0 | 2 | 0 |
| `item-label` | aufgaben.teilaufgabe | 2 | 2 | 0 | 0 |
| `math-font` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 2 | 2 | 0 | 0 |
| `numbering` | arbeitsblatt.teilaufgaben, klausurboegen.klausurbögen, mathematik.teilaufgaben | 2 | 2 | 0 | 0 |
| `spacing` | arbeitsblatt.minipage | 2 | 2 | 0 | 0 |
| `sub` | klausurboegen.klausurbögen | 2 | 2 | 0 | 0 |
| `tasks` | arbeitsblatt.teilaufgaben, mathematik.teilaufgaben | 2 | 1 | 1 | 0 |
| `tight` | arbeitsblatt.lücke | 2 | 2 | 0 | 0 |
| `variante` | klassenarbeit.klassenarbeit | 2 | 0 | 2 | 0 |
| `variants` | informatik.ascii-table | 2 | 2 | 0 | 0 |
| `akzent` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 1 | 0 | 1 | 0 |
| `alle` | aufgaben.show-erwartungen | 1 | 0 | 0 | 1 |
| `annotations` | mathematik.graphen, patterns.kariert | 1 | 1 | 0 | 0 |
| `approx` | mathematik.geogebra-cell | 1 | 1 | 0 | 0 |
| `colored` | informatik.ascii-table | 1 | 1 | 0 | 0 |
| `copyright` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 1 | 1 | 0 | 0 |
| `curr` | aufgaben.show-loesungen, aufgaben.show-materialien | 1 | 1 | 0 | 0 |
| `current` | physik.source | 1 | 1 | 0 | 0 |
| `custom-header` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 1 | 1 | 0 | 0 |
| `duplex` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 1 | 1 | 0 | 0 |
| `figure-font-size` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 1 | 1 | 0 | 0 |
| `fill-color` | patterns.kariert | 1 | 1 | 0 | 0 |
| `grid` | mathematik.graphen | 1 | 1 | 0 | 0 |
| `icon` | arbeitsblatt.icon-link | 1 | 1 | 0 | 0 |
| `icons` | aufgaben.aufgabe | 1 | 1 | 0 | 0 |
| `label-color` | mathematik.kreisdiagramm | 1 | 1 | 0 | 0 |
| `landscape` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 1 | 1 | 0 | 0 |
| `line-width` | mathematik.graphen | 1 | 1 | 0 | 0 |
| `marks` | mathematik.graphen | 1 | 0 | 0 | 1 |
| `menu` | mathematik.geogebra-cell | 1 | 1 | 0 | 0 |
| `mode` | mathematik.kreisdiagramm | 1 | 1 | 0 | 0 |
| `mv` | klausurboegen.klausurbögen | 1 | 1 | 0 | 0 |
| `name-repeat` | klassenarbeit.klassenarbeit | 1 | 1 | 0 | 0 |
| `new-page` | aufgaben.show-erwartungen | 1 | 1 | 0 | 0 |
| `number` | aufgaben.aufgabe | 1 | 1 | 0 | 0 |
| `paper` | arbeitsblatt.arbeitsblatt, arbeitsblatt.arbeitsblatt-einzeln | 1 | 1 | 0 | 0 |
| `punkte-template` | klassenarbeit.klassenarbeit | 1 | 0 | 0 | 1 |
| `result` | klausurboegen.klausurbögen | 1 | 1 | 0 | 0 |
| `samples` | mathematik.graphen | 1 | 1 | 0 | 0 |
| `scope` | arbeitsblatt.arbeitsblatt-einzeln | 1 | 1 | 0 | 0 |
| `show-percentage` | mathematik.kreisdiagramm | 1 | 1 | 0 | 0 |
| `student` | klassenarbeit.klassenarbeit | 1 | 1 | 0 | 0 |
| `teil` | aufgaben.format-punkte, aufgaben.get-points, aufgaben.show-loesung, aufgaben.show-loesungen | 1 | 1 | 0 | 0 |
| `teile` | aufgaben.show-erwartungen | 1 | 0 | 0 | 1 |
| `vorschau-alle` | arbeitsblatt.arbeitsblatt | 1 | 1 | 0 | 0 |
| `vorschlag` | klausurboegen.klausurbögen | 1 | 1 | 0 | 0 |
| `weißer-rand` | klausurboegen.klausurbögen | 1 | 1 | 0 | 0 |
| `x-grid` | mathematik.graphen | 1 | 1 | 0 | 0 |
| `x-label` | mathematik.graphen | 1 | 1 | 0 | 0 |
| `x-step` | mathematik.graphen | 1 | 1 | 0 | 0 |
| `y-label` | mathematik.graphen | 1 | 1 | 0 | 0 |
| `y-step` | mathematik.graphen | 1 | 1 | 0 | 0 |

**Definiert, aber nirgends in Doku/Vorlagen/Tests benutzt (0 Treffer):** `alt`, `amount`, `auto-einheit`, `background`, `beschreibung`, `bold`, `compact`, `dark-color`, `digits`, `farbe`, `flipped`, `flipped-side`, `full`, `gutter`, `header`, `idx`, `inline`, `jahrgang`, `kerncurriculum`, `koeffizienten-namen`, `language`, `last-has-approx`, `light-color`, `loesungen-only`, `max-digits`, `min-punkte`, `niveau`, `notation`, `operator-text-bold`, `platz`, `precision`, `prefix`, `row-height`, `sonst`, `stand`, `start`, `stichworte`, `symbol`, `thema`, `title-font-size`, `typ`, `variant`, `x_potenz`, `y-grid`, `zweifach`, `fehler` (physik.berechnung; die 3 grep-Treffer in tests/ sind die Testdirektive `// fehler:`)

Nur als Schlüssel in Options-Dictionaries (kein Funktionsparameter, deshalb nicht in der Tabelle): `show` (in `erwartungen:`/`klausurboegen:`; per grep nicht von `#show:`-Regeln zu trennen), `ergebnisse` (klausurboegen-Dictionary), `anzeige`/`position` (punkte-Dictionary), `punkte-position`, `punkte-template-aufgabe`, `punkte-template-teilaufgabe` (aufgaben-Optionen), `datei` (Varianten-Override), `domain`/`term`/`between`/`marker` (graphen-Dictionaries), `dx`/`dy` (klausurbögen `mv`).

### 1c. Optionswerte (welcher Wert wie oft)

| Schlüssel | Werte (× Häufigkeit über alle drei Korpusteile) |
|---|---|
| `loesungen` | "sofort" ×5, "seiten" ×4, "keine" ×4, "folgend" ×2, ( ×2, "seite" ×1, sys.inputs.at ×1, "kiene" ×1, "nur" ×1 |
| `materialien` | "sofort" ×4, "keine" ×1, "reingequetscht" ×1, "seiten" ×1 |
| `punkte` | "alle" ×10, "aufgaben" ×4, "teilaufgaben" ×2, "keine-summe" ×2, "keine" ×1, 6 ×1, ( ×1 |
| `aufgaben-shortcodes` | "alle" ×2, "keine" ×2 |
| `teilaufgabe-numbering` | "a)" ×3, "1." ×3 |
| `page-numbering` | "continuous" ×2, true ×1, false ×1 |
| `logo` | "angela" ×1, image ×1, none ×1 |
| `paper` | "a5" ×1 |
| `theme` | sys.inputs.at ×1, "klar" ×1 |
| `anzeige` | "alle" ×1 |
| `position` | "br" ×1, "rand" ×1 |
| `varianten` | ( ×4 |
| `variante` | "druck" ×2 |
| `method` | "PA" ×2, "EA" ×1, "GA" ×1 |
| `erwartungen` | false ×9, ( ×5, true ×2, "true" ×1 |
| `klausurboegen` | ( ×8, 0.0.5 ×2, true ×2, false ×1 |
| `print` | true ×10, false ×3 |
| `duplex` | true ×1 |
| `workspaces` | true ×5, false ×2 |
| `landscape` | true ×1 |
| `zweifach` |  |
| `info-table` | ( ×2, false ×1 |
| `name-repeat` | true ×1 |

Auffällig: `"kiene"` ist ein gewollter Tippfehler-Test; `"reingequetscht"` steht in der aufgaben-Doku und existiert im Code nicht; `erwartungen: "true"` ist ein Fehler-Test; `klausurboegen: 0.0.5` sind Versionsangaben (grep-Artefakt). `loesungen: "false"` (Zeichenkette!) ist der Vorgabewert in arbeitsblatt, kommt aber in keinem Beispiel vor.

### 1d. Sprachmischung in den meistbenutzten Namen (Befund aus den Tabellen)

- Deutsch: `aufgabe`, `teilaufgabe`, `erwartung`, `loesung`, `klassenarbeit`, `arbeitsblatt`, `graphen`, `datensatz`, `kariert`, `liniert`, `lücke`, `klausurbögen`, `häufigkeitsanalyse`; Parameter `loesungen`, `materialien`, `punkte`, `erwartungen`, `klausurboegen`, `varianten`, `dateiname`, `akzent`, `muster`, `linienabstand`, `korrekturrand`, `rand`, `erreicht`, `fach`.
- Englisch: `set-options`, `get-points`, `material`, `workspace`, `minipage`, `icon-link`, `mono`, `caesar`; Parameter `title`, `class`, `print`, `duplex`, `workspaces`, `paper`, `landscape`, `date`, `teacher`, `student`, `subtitle`, `logo`, `method`, `large`, `number`, `label`, `caption`, `exam`, `subexam`, `students`, `result`, `scale`.
- Denglisch: `show-erwartungen`, `show-bewertung`, `show-loesungen`, `show-materialien`, `show-offene-loesungen`, `reset-aufgaben`, `text-to-blocks` neben `häufigkeitsanalyse`, `operatoren-liste`, `print-pagebreak`; Parameter `teilaufgabe-numbering`, `aufgaben-shortcodes`, `punkte-template`, `vorschau-alle`, `auto-einheit`, `weißer-rand` neben `result-table`, `loesungen-only`, `operator-text-bold`, `koeffizienten-namen`, `min-punkte`.
- Schreibweisen: Umlaute in Bezeichnern (`lücke`, `klausurbögen`, `häufigkeitsanalyse`, `datensätze`, `weißer-rand`) neben Umschrift (`loesung`, `klausurboegen`, `kuerzel`); Unterstrich statt Bindestrich in physik (`lineare_regression`, `auto_einheit_anwenden`, `count_decimal_places`, `p_messwerttabelle`, `x_potenz`) und arbeitsblatt (`c_canvas`); gleiches Ding, zwei Namen: Paket `klausurboegen` ↔ Funktion `klausurbögen` ↔ Parameter `klausurboegen`; `exam`/`subexam` (klausurbögen) ↔ `title`/`subtitle` (klassenarbeit); `sek1` (Code) ↔ `stufe` (Doku).

---

## 2. Wie die Doku entsteht

### Ablauf

1. `.github/workflows/build-docs.yml` (Push/PR auf main) → `bash .github/scripts/build.sh`.
2. `build.sh` findet per Auto-Discovery jeden Ordner `{paket}/{version}/docs/docs.typ` und baut ihn mit `typst compile --format bundle --features bundle,html` → `index.html`, `docs.css`, `{paket}.pdf` unter `.docs-site/{paket}/{version}/`. Dazu `versions.json`, eine Weiterleitung auf die neueste Version, Pagefind-Index nur für die neueste Version (`suchbar.py`).
3. `docs.typ` importiert `@schule/schuldocs:0.3.0`, ruft `docs.with(toml: toml("../typst.toml"), …)` und bindet `content.typ` ein. Name, Version, Beschreibung, Autoren kommen aus `typst.toml`; `abstract`, `links`, `notices` stehen von Hand in `docs.typ`.
4. `content.typ` ist handgeschriebener Fließtext mit drei schuldocs-Bausteinen:
   - `show-code(```typ …```)` zeigt Quelltext, **führt ihn nicht aus** (`schuldocs/0.3.0/src/display.typ:147`).
   - `show-example(rendered: {…}, source: ```typ …```)` bekommt das gesetzte Ergebnis fertig übergeben; der Code steht also **zweimal** da und kann auseinanderlaufen (`display.typ:83`). Nur der `rendered:`-Teil wird wirklich kompiliert.
   - `show-module(read("../quelle.typ"), name: "…")` am Ende: `tidy.parse-module()` (tidy 0.4.2) liest Namen, Signatur, Vorgabewerte aus dem Quelltext, Typen und Beschreibungen aus `///`-Kommentaren; die Darstellung macht schuldocs selbst (`api.typ:337`). Parameter werden in der alten Listenform `/// - name (typ): Text` beschrieben; `api.typ:71–100` ordnet diese Zeilen den Signatur-Parametern zu.

Folgen für die Referenz:
- Erscheinen nur Funktionen **mit** Docstring; Namen mit `_` werden ausgeblendet. Von 138 öffentlichen Namen haben 84 einen Docstring (arbeitsblatt 21/51, aufgaben 13/19, klassenarbeit 1/2, klausurboegen 1/1, mathematik 9/11, physik 20/33, informatik 13/13, patterns 4/4, operatoren 2/4). Geprüft am Build: klassenarbeit-Referenz enthält genau 1 Funktion, aufgaben 13.
- Jede Funktion bekommt die Sprungmarke `{modul}-{funktionsname}` (z. B. `aufgaben-get-points`); Umbenennungen ändern also die Anker der Website.
- Über Paketgrenzen hinweg wird nichts dokumentiert: `klassenarbeit` reicht `..args` an `arbeitsblatt` durch, die Referenz zeigt aber nur die eigenen 15 Parameter. `arbeitsblatt` re-exportiert per `import … : *` aufgaben, patterns, informatik, random, insert-a-word, energy-sketch, cetz, cetz-plot, codly, colorful-boxes, fontawesome, eqalc, zero – nichts davon steht in der arbeitsblatt-Referenz.

### Welche Paket-Doku wie gebaut wird

| Paket/Version | Einstieg | schuldocs | `show-module` | baut lokal? |
|---|---|---|---|---|
| arbeitsblatt 0.4.0 | `web.typ` + `manual.typ` (kein `docs.typ`) | 0.1.0 per relativem Pfad `../../../schuldocs/0.1.0/lib.typ` | ja (`content.typ:524`) | **nein** – wird von `build.sh` übersprungen; `manual.typ` scheitert an mantys 1.0.2 |
| arbeitsblatt 0.3.0 | `docs.typ` | 0.3.0 | ja | ja (einzige arbeitsblatt-Version auf der Website) |
| arbeitsblatt 0.3.1, 0.3.2 | `web.typ` + `manual.typ` | 0.1.0 | ja | nein (übersprungen) |
| aufgaben 0.3.1 | `docs.typ` | 0.3.0 | ja | ja |
| klassenarbeit 0.4.0 | `docs.typ` | 0.3.0 | ja | ja |
| klausurboegen 0.0.5 | `docs.typ` | 0.3.0 | ja | ja |
| mathematik 0.0.2 | `docs.typ` | 0.3.0 | ja | ja |
| physik 0.0.2 | `docs.typ` | 0.3.0 | ja (4 Module) | ja |
| informatik 0.0.2 | `docs.typ` | 0.3.0 | ja | ja |
| patterns 0.0.2 | `docs.typ` | 0.3.0 | ja | ja |
| operatoren 0.0.1 | `docs.typ` | 0.3.0 | ja | ja |

(Lokaler Probelauf mit denselben Schaltern wie `build.sh`, Ausgabe ins Scratchpad; Pagefind nicht ausgeführt.)

### Was bei einer Umbenennung nachgezogen werden muss

Automatisch richtig, sobald der Quelltext stimmt: Funktionsname, Signatur und Vorgabewerte in der API-Referenz; Versionsnummer in Kopf, Dropdown und Startseiten-Badge (aus `typst.toml` bzw. Ordnername); Aufnahme der neuen Version in die Website.

Von Hand (je Paket):

1. **Quelltext**: `#let`-Name, Parameter, alle internen Aufrufe; dazu die Meldungstexte der Asserts (`arbeitsblatt.typ:308–325` nennt Optionsnamen und erlaubte Werte als Zeichenketten) und Zustandsschlüssel (`_state_options` in `aufgaben.typ:41–54`, das arbeitsblatt als Dictionary befüllt – die Schlüssel sind die eigentliche Schnittstelle zwischen den Paketen).
2. **Docstrings**: jede Zeile `/// - altername (typ): …` und die ```` ```typ ````-Beispiele im Docstring. Passt der Name nicht mehr zur Signatur, verliert der Parameter still seine Beschreibung.
3. **`docs/content.typ`**: Fließtext, `show-code`-Blöcke (werden nie geprüft), `show-example` an **beiden** Stellen (`rendered:` und `source:`), handgepflegte Options-Tabellen (aufgaben `content.typ:471–488`, arbeitsblatt `content.typ:72–81`, `228–237`, `253–262`), Versionsnummern in den `#import`-Zeilen der Beispiele.
4. **`docs/docs.typ`**: `abstract`; bei aufgaben der Import `reset-aufgaben` (`aufgaben/0.3.1/docs/docs.typ:2`).
5. **`README.md`** des Pakets (klassenarbeit 91 Zeilen, informatik 383 Zeilen mit eigener, abweichender API-Beschreibung; arbeitsblatt 29 Zeilen). `neue-version.sh` fasst nur `*.typ` an, **nicht** die README.
6. **`template/`** (arbeitsblatt `ab.typ`, klassenarbeit `ka.typ`): Parameternamen und die Kommentare mit den erlaubten Werten; wird über `[template]` in `typst.toml` als `typst init`-Vorlage ausgeliefert.
7. **`showcase/`** (nur arbeitsblatt): `beispiel.typ`, `render.sh` (Theme-Namen fest verdrahtet), `showcase.py`.
8. **`typst.toml`**: `version`, `entrypoint`, `exclude`, `[template]`; bei den kleinen Paketen stehen dort noch Platzhalter (`description = "Package for klausurboegen"`, ebenso patterns, operatoren).
9. **Abhängige Pakete** – die Importe tragen feste Versionen und werden von `neue-version.sh` nur für das eigene Paket umgestellt:
   - `klassenarbeit/0.4.0/src/klassenarbeit.typ:1` → `@schule/arbeitsblatt:0.4.0`; `:23` → `@schule/klausurboegen:0.0.5`
   - `arbeitsblatt/0.4.0/src/arbeitsblatt.typ:1–37` → aufgaben 0.3.1, patterns 0.0.2, mathematik 0.0.2, informatik 0.0.2, physik 0.0.2, operatoren 0.0.1, random 0.0.1, insert-a-word 0.0.3, energy-sketch 0.0.2
   - `mathematik/0.0.2/mathematik.typ:39` → `@schule/aufgaben:0.1.2` (!), `:2` → physik 0.0.2
   - `klausurboegen/0.0.5/klausurboegen.typ:1` → `@schule/patterns:0.0.1` (neueste ist 0.0.2)
   - Durchgereichte Namen: klassenarbeit reicht `klausurboegen:`-Dictionary unverändert als benannte Argumente an `klausurbögen()` weiter (`klassenarbeit.typ:30–38`) und übersetzt `title→exam`, `subtitle→subexam`, `ergebnisse→students`/`result`; `erwartungen:`-Dictionary geht an `show-erwartungen()`.
10. **`tests/*.typ`**: 19 Dateien mit festem `@schule/<paket>:<version>`; Aufrufe und Optionsnamen; die `// erwartet:`-Muster hängen an Ausgabetexten („BE", „Lösung", „Seite x von y"), `// fehler:` an Assert-Texten.
11. **Website-Index `.github/scripts/index.html`** (447 Zeilen, von Hand): je Paket eine Karte mit `<h3>paketname</h3>` und Beschreibung; nur die Versions-Badge wird beim Build ersetzt. Betroffen bei Paket-Umbenennung oder geänderter Beschreibung, nicht bei Funktionsnamen.
12. **Root-`README.md`**, Abschnitt „Versionen": Regel „veröffentlichte Version ist eingefroren" – `versionen.yml`/`versionen-pruefen.py` lässt Änderungen an einer auf Typst Universe stehenden Version scheitern. Jede Umbenennung braucht also einen neuen Versionsordner (`bash .github/scripts/neue-version.sh <paket> <version>`).
13. **Außerhalb des Repos**: alle bestehenden Unterrichtsdateien, die `@schule/…` importieren (hier nicht untersucht).

Was `neue-version.sh` tut und nicht tut: kopiert den neuesten Versionsordner komplett (auch Reste wie `aufgaben/0.3.1/aufgaben.typ.orig`, untracked), setzt `version` in `typst.toml`, ersetzt `@schule/<paket>:<alt>` in allen `*.typ` des neuen Ordners. Es ändert **nicht**: Importe anderer Pakete auf dieses Paket, `README.md`, `tests/`, relative Pfade wie `../../../schuldocs/0.1.0/lib.typ`, und es wandelt keine alte `web.typ`/`manual.typ` in `docs.typ` um.

---

## 3. Doku gegen Code (Stichprobe der meistbenutzten Namen)

Geprüft durch Lesen und – wo angegeben – durch Kompilieren kleiner Dateien gegen den Checkout.

### Dokumentiert, aber im Code nicht (mehr) vorhanden oder anders

| # | Stelle | Doku sagt | Code |
|---|---|---|---|
| 1 | `klassenarbeit/0.4.0/docs/content.typ:196, 211, 215, 244, 260` | `klausurboegen: (stufe: "I"/"II")` | `klausurbögen()` kennt `sek1: bool`, kein `stufe`. Kompiliert mit `variante: "klausurboegen"`: `error: unexpected argument: stufe` (`klassenarbeit.typ:38`). Im normalen PDF-Lauf fällt es nicht auf, weil Klausurbögen dort gar nicht erzeugt werden. |
| 2 | `aufgaben/0.3.1/docs/content.typ:315, 477` | `materialien: "reingequetscht"` | Wert heißt `"reinquetschen"` (`arbeitsblatt.typ:313`); arbeitsblatt lehnt `"reingequetscht"` per Assert ab. `aufgaben.typ` selbst wertet nur `"sofort"`, `"seiten"`, `"folgend"`, `"seite"` aus und schluckt den falschen Wert still. |
| 3 | `aufgaben/0.3.1/docs/content.typ:481` | Vorgabe `punkte: "keine"` | `aufgaben.typ:48`: `punkte: "aufgaben"` (arbeitsblatt setzt dann `"keine"`). |
| 4 | `arbeitsblatt/0.4.0/docs/content.typ:225, 233` | `aufgaben-shortcodes: "alle"` sei Standard | `arbeitsblatt.typ:289, 1051`: Vorgabe `"teilaufgaben"`. |
| 5 | `arbeitsblatt/0.4.0/docs/content.typ:253–262` | `loesungen`: `"keine"` (Standard), `"sofort"`, `"folgend"`, `"seiten"` | erlaubt sind zusätzlich `"false"`, `false`, `none`, `"seite"`, `"nur"`, `"reinquetschen"`; Vorgabe in arbeitsblatt ist die Zeichenkette `"false"` (`arbeitsblatt.typ:286`), in aufgaben `"keine"` (`aufgaben.typ:44`). |
| 6 | `arbeitsblatt/0.4.0/docs/content.typ:22–49` (Schnellstart) | vollständiges Beispiel | kompiliert weder mit 0.4.0 noch mit 0.3.2: `label <graph> does not exist` (`#material(label: …)` außerhalb einer Aufgabe). |
| 7 | `arbeitsblatt/0.4.0/docs/content.typ:466, 488–498` | „fancy-units" sei integriert | `arbeitsblatt.typ:46` nutzt `@preview/unify:0.8.1` mit eigenen Hüllen `qty`/`num`/`unit`; fancy-units steckt nur noch in physik. |
| 8 | `arbeitsblatt/0.4.0/docs/content.typ:22, 202, 210` | `@schule/arbeitsblatt:0.3.2` | Paket ist 0.4.0. |
| 9 | `aufgaben/0.3.1/docs/content.typ:23, 35`; `klassenarbeit/0.4.0/docs/content.typ` (2×); `klassenarbeit/0.4.0/README.md` | `@schule/aufgaben:0.3.0` | aktuell 0.3.1. |
| 10 | `klassenarbeit/0.4.0/src/klassenarbeit.typ:355` (Docstring) | Parameter `table (array)` | gibt es nicht; die Tabelle kommt über `info-table`. Dafür fehlt `name-field` im Docstring. Docstring halb englisch, halb deutsch. |
| 11 | `klassenarbeit/0.4.0/template/ka.typ:9` | `punkte: … // aufgabe, teilaufgabe, alle, keine` | gültig sind `"aufgaben"`, `"teilaufgaben"`; `punkte: "aufgabe"` → Assert-Fehler (kompiliert geprüft). |
| 12 | `klassenarbeit/0.4.0/README.md` | Handbuch unter `docs/klassenarbeit-manual.pdf` | Datei gibt es nicht. |
| 13 | `informatik/0.0.2/README.md:21, 31, 41, 217, 227, 355, 379` | Funktion `hf-diagramm(data)` | existiert nicht in `lib.typ`; dort `häufigkeitsanalyse` und `häufigkeitsanalyse-alt(text, rel:, cetz:)`. Die README beschreibt `rel`/`cetz` je 11×. |
| 14 | `informatik/0.0.2/lib.typ:1` (Kommentar) | Re-Export aus `@schule/blockst:0.0.1` | tatsächlich `@preview/blockst:0.1.0` (`lib.typ:5`). |
| 15 | `arbeitsblatt/0.4.0/typst.toml`, `klassenarbeit/0.4.0/typst.toml` | `thumbnail = "thumbnail.png"` | in `template/` liegt jeweils nur die `.typ`-Datei. |
| 16 | `physik/0.0.2/regressionen.typ` Docstring `lineare_regression` | Einträge `math`, `math-digits`, `m`, `b`, `function` | keine Parameter (Rückgabe-Schlüssel, als Parameterliste geschrieben). |

### Im Code vorhanden, aber nicht dokumentiert

- **arbeitsblatt 0.4.0**: `theme`, `akzent` (nur README + Showcase, 0 Treffer in der Doku), `zweifach` als Parameter, Metadaten `fach`, `thema`, `jahrgang`, `stufe`, `niveau`, `typ`, `stichworte`, `kerncurriculum`, `stand`; Funktionen `lsg(platz:, sonst:)`, `loesungsmodus()`, `teilaufgaben`/`tasks`, `qr-code`, die 15 Kästen (`info`, `tip`, `memo`, `warning`, `abstract`, `question`, `conclusion`, `success`, `error`, `example`, `goal`, `idea`, `experiment`, `notify`, `danger` – ohne Docstring), `canvas`/`c_canvas`, `print-state`; aus `themes.typ`: `themes`, `fachfarben`, `fachnamen`, `fachfarbe`, `kuerzel`, `kicker`, `kasten-stil` und die acht Theme-Funktionen `klar`, `atlas`, `skizze`, `labor`, `kontur`, `leiste`, `riso`, `bauhaus`. `arbeitsblatt-einzeln` ist öffentlich, laut Docstring intern, mit 34 unbeschriebenen Parametern.
- **aufgaben 0.3.1**: `get-punkte-anzeige`, `get-punkte-position`, `format-punkte`, `show-loesung`, `show-loesung-inline`, `show-material` (öffentlich, ohne Docstring); `get-points(idx:)`; Theme-Hooks (`_state_theme`, seit 0.3.1) nur als Kommentar.
- **klassenarbeit 0.4.0**: `logos` (öffentlich über `import … : *`, ohne Docstring); die an arbeitsblatt durchgereichten Parameter stehen nur als Aufzählung in einem Satz.
- **klausurboegen 0.0.5**: vollständig beschrieben; in keinem Test benutzt.
- **mathematik 0.0.2**: `steckbrief`, `kreisdiagramm` ohne Docstring (im Fließtext beschrieben); `geogebra-button`, `geogebra-approx-button`, `geogebra-colors` nie benutzt.
- **physik 0.0.2**: 13 von 33 Namen ohne Docstring, darunter offensichtliche Hilfsfunktionen, die öffentlich sind: `umrechnungseinheit`, `auto_einheit_anwenden`, `count_decimal_places`, `p_messwerttabelle`, `multiplikatoren`, `format-number`, `format-unit`, `combine-units`, `format-equation-term`, `build-equation`, `format-simple-equation`, `regression`, `multimeter`.
- **patterns 0.0.2**: `flex-feld`, `ist-flex-feld` öffentlich, Parameter unbeschrieben, nie benutzt.
- **operatoren 0.0.1**: `operatoren-state`, `operatoren-config-state` öffentlich; `operator(bold:)`, `operatoren-liste(language:, operator-text-bold:)` nie in Beispielen.

### Stichprobe: bestätigt stimmig (kompiliert)

`arbeitsblatt.with(title, class, print, duplex, punkte, loesungen, header-ascent, page-settings, copyright, custom-header)`, `workspace(height:)`, `kariert(3)` (positional = `rows`), `qty`/`num`/`unit` in beiden Schreibweisen, `icon-link(icon:, color:)`, `minipage`, `print-pagebreak`, `non-print-pagebreak`, `canvas`, `lücke(tight:)`, `qrbox(width:)`, `mono`; `klassenarbeit.with(title, subtitle, class, date, teacher, logo: none, name-field: none, student, name-repeat, info-table, erwartungen: (erreicht:, grouped:), page-numbering: "continuous")`, `aufgabe("Titel")[…]`, `aufgabe(title:)`, `erwartung(2)[…]` und `erwartung(2, […])`, `teilaufgabe`, `loesung`; `klausurboegen: (sek1: true)`.

### Doppelte oder konkurrierende Definitionen (für die Vereinheitlichung relevant)

- `teilaufgaben`/`tasks` zweimal: `mathematik.typ:23/61` (bindet fest `aufgaben:0.1.2`) und `arbeitsblatt.typ:1228/1263` (eigene Fassung, weil die aus mathematik Lösungen immer sofort zeigt; begründet im Docstring `arbeitsblatt.typ:1210–1214`).
- `mono` zweimal: `arbeitsblatt.typ:1475` und `informatik/lib.typ:314`.
- `info`, `tip`, `warning` … in arbeitsblatt überschreiben die gleichnamigen aus gentle-clues, die aufgaben per `import … : *` weiterreicht.
- `qty`/`num`/`unit` in arbeitsblatt (unify) gegen die aus fancy-units in physik.
- `source`, `lamp`, `motor`, `generator`, `multimeter`, `amperemeter`, `voltmeter` (physik) landen über arbeitsblatt im globalen Namensraum.

---

## 4. Testgerüst

### Funktionsweise

`tests/run.sh [muster]` (61 Zeilen, bash):
1. legt ein temporäres Paketverzeichnis an und verlinkt das Repo als `schule` → `@schule/…` wird aus dem Checkout aufgelöst (wie `build.sh`);
2. kompiliert jede `tests/*<muster>*.typ` mit `typst compile --package-path … --root <repo>` nach PDF;
3. liest Kommentarzeilen der Testdatei:
   - `// erwartet: <regex>` – muss im `pdftotext -layout`-Text vorkommen (Leerzeichen zusammengezogen),
   - `// nicht: <regex>` – darf nicht vorkommen,
   - `// fehler: <text>` – Kompilieren muss mit dieser Meldung scheitern (`grep -F`),
   - ohne Zeilen: muss nur kompilieren;
4. Exit-Code 1, wenn ein Test fehlschlägt.

CI: `.github/workflows/tests.yml` (PR, Push auf main), Typst 0.15.0, poppler-utils.

### Ergebnis des Laufs (lokal, Typst 0.15.1)

```
ok    ab-fehler-loesungen-tippfehler
ok    ab-fehler-unbekannte-option
ok    ab-margin-xy
ok    aufgaben-bewertung-teil0
ok    aufgaben-keine-summe
ok    aufgaben-kommazahlen
ok    aufgaben-nur-label
ok    aufgaben-punkte-rand
ok    aufgaben-shortcode-loesung-material
ok    aufgaben-verweise
ok    ka-be-zwei-bloecke
ok    ka-erwartungen-alle
ok    ka-fehler-erwartungen-text
ok    ka-punkte-template
ok    ka-seitenzahlen-continuous
ok    ka-seitenzahlen-zwischentext
ok    mathe-graphen-terme
ok    patterns-fr-040
ok    patterns-fr

19 bestanden, 0 fehlgeschlagen      (Exit 0)
```

### Welche Tests welche Version pinnen

| Test | Import | Prüfungen | Thema |
|---|---|---|---|
| ab-fehler-loesungen-tippfehler | arbeitsblatt 0.4.0 | 1 fehler | Tippfehler in `loesungen` wird abgelehnt |
| ab-fehler-unbekannte-option | klassenarbeit 0.4.0 | 1 fehler | unbekannte Option wird abgelehnt |
| ab-margin-xy | klassenarbeit 0.4.0 | 1 erwartet | `page-settings: (margin: (x:, y:))` |
| aufgaben-bewertung-teil0 | aufgaben 0.3.1 | 3 erwartet | Bewertungstabelle |
| aufgaben-keine-summe | aufgaben 0.3.1 | 1 erwartet, 1 nicht | `punkte: "keine-summe"` |
| aufgaben-kommazahlen | aufgaben 0.3.1 | 3 erwartet, 1 nicht | BE mit Dezimalkomma |
| aufgaben-nur-label | aufgaben 0.3.1 | 1 erwartet | `loesungen: "nur"` + Label |
| aufgaben-punkte-rand | arbeitsblatt 0.4.0 | 1 erwartet | `punkte: (position: "rand")` |
| aufgaben-shortcode-loesung-material | arbeitsblatt 0.4.0 | 4 erwartet, 1 nicht | Shortcodes, `"folgend"` |
| aufgaben-verweise | aufgaben 0.3.1 | 1 erwartet | `teilaufgabe-numbering: "1."` |
| ka-be-zwei-bloecke | klassenarbeit 0.4.0 | 3 erwartet, 1 nicht | zwei Klassenarbeiten in einer Datei |
| ka-erwartungen-alle | klassenarbeit 0.4.0 | 3 erwartet, 1 nicht | `show-erwartungen(alle:, teile:)` |
| ka-fehler-erwartungen-text | klassenarbeit 0.4.0 | 1 fehler | `erwartungen: "true"` |
| ka-punkte-template | klassenarbeit 0.4.0 | 2 erwartet, 1 nicht | `punkte-template` |
| ka-seitenzahlen-continuous | klassenarbeit 0.4.0 | 2 erwartet, 1 nicht | `page-numbering: "continuous"` |
| ka-seitenzahlen-zwischentext | klassenarbeit 0.4.0 | 1 erwartet, 1 nicht | Seitenzähler |
| mathe-graphen-terme | mathematik 0.0.2 | nur Kompilieren | `graphen` (x, y, marks, step) |
| patterns-fr-040 | arbeitsblatt 0.4.0 | 2 erwartet | `kariert/liniert(rows: 1fr)` |
| patterns-fr | arbeitsblatt **0.3.2** | 2 erwartet | dasselbe mit alter Version |

Verteilung: klassenarbeit 0.4.0 ×8, arbeitsblatt 0.4.0 ×5, aufgaben 0.3.1 ×5, mathematik 0.0.2 ×1, arbeitsblatt 0.3.2 ×1. Alle importieren mit `: *`.

### Was für eine sichere Migration fehlt

1. **Versionsbindung der Tests.** Die Version steht fest in jeder Testdatei; `neue-version.sh` fasst `tests/` nicht an. Für eine 0.4.x müssen die Tests kopiert oder parametrisiert werden (z. B. Version per `--input`/sed in `run.sh`), sonst laufen sie grün gegen die alte Version.
2. **Kein Signatur-Snapshot.** Nichts hält fest, welche Namen und Parameter ein Paket exportiert. Eine eingecheckte Liste je Paket (Name, Parameter, Vorgabewert – aus `tidy.parse-module` oder per `dictionary(module)` in Typst erzeugbar) plus Diff-Test würde jede unbeabsichtigte API-Änderung zeigen und zugleich die Umbenennungstabelle alt→neu liefern.
3. **Keine Prüfung der Doku-Beispiele.** `show-code`-Blöcke und `source:`-Teile werden nie kompiliert; README-Codeblöcke und `template/*.typ` ebenfalls nicht. Die Fehler aus Abschnitt 3 (#1, #2, #6, #11, #13) wären mit einem Test „jeden ```` ```typ ````-Block, der mit `#import "@schule/` beginnt, und jede Template-Datei kompilieren" aufgefallen.
4. **`build.sh` bricht bei Doku-Fehlern nicht ab** (`fehlgeschlagen+=…`, Exit 0; nur das englische Handbuch und leere Submodule sind harte Fehler). Der Doku-Build ist damit kein Sicherheitsnetz.
5. **Lücken in der Abdeckung.** Keine Tests für: klausurboegen (auch nicht die Durchreichung aus klassenarbeit, `variante: "klausurboegen"`), physik, informatik, operatoren; Bundle-Export (`varianten`, `dateiname`, `vorschau=alle`), `zweifach`, Themes (`theme`, `akzent`), `materialien`-Modi, `loesungen: "seite"/"seiten"/"sofort"`, `lsg`, `lücke`, `minipage`, `teilaufgaben`, Kästen, `show-bewertung(compact:, full:)`, `material(caption:, label:)`. `mathe-graphen-terme` prüft nur, dass es kompiliert.
6. **Kein Test für alte Namen.** Falls 0.4.x Aliasse oder sprechende Fehlermeldungen für alte Parameternamen bekommt, gibt es dafür noch kein Muster; das vorhandene `// fehler:`-Schema (wie `ab-fehler-unbekannte-option`) eignet sich dafür.
7. **Nur Textvergleich.** `pdftotext`-Regex erkennt keine Layoutänderungen; für Themes und Klausurbögen gibt es keine visuelle oder strukturelle Absicherung (Seitenzahl, Bildvergleich).
8. **Typst-Version.** CI 0.15.0, lokal 0.15.1 – bisher ohne Unterschied im Ergebnis.

---

## Anhang: Hilfsskripte und Rohdaten (Scratchpad)

- `/private/tmp/claude-501/-Users-alexander--claude-spares-spare-T3hcxg/d64ba95e-5a74-47f7-8977-d9b919f98567/scratchpad/freq.py` – Häufigkeitszählung
- `/private/tmp/claude-501/-Users-alexander--claude-spares-spare-T3hcxg/d64ba95e-5a74-47f7-8977-d9b919f98567/scratchpad/freq.out` – Rohtabellen
- `/private/tmp/claude-501/-Users-alexander--claude-spares-spare-T3hcxg/d64ba95e-5a74-47f7-8977-d9b919f98567/scratchpad/funcs.json` – alle 138 öffentlichen Namen mit Parametern, Vorgabewerten, Datei und Zeile
- `/private/tmp/claude-501/-Users-alexander--claude-spares-spare-T3hcxg/d64ba95e-5a74-47f7-8977-d9b919f98567/scratchpad/nutz/ds.py` – Abgleich Docstring ↔ Signatur
- `/private/tmp/claude-501/-Users-alexander--claude-spares-spare-T3hcxg/d64ba95e-5a74-47f7-8977-d9b919f98567/scratchpad/rev.py` – in der Doku benutzte, im Code unbekannte Namen
