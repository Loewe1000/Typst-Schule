# Umbenennungstabelle typlace 0.0.2 → 0.5.0

Stand 2026-11-15. Grundlage: `UMSETZUNG-0.5.0.md` (Vorrang), `konvention.md`, `inventar-hilfspakete.md` Abschnitt 6 und der Quelltext `typlace/0.0.2/`. Die Zeile „typlace 0.0.2: unverändert lassen" in `tabelle-fachpakete.md` Abschnitt 8 ist durch `UMSETZUNG-0.5.0.md` (Umfang: 17 Pakete, darunter typlace) überholt.

Lesart:

- **Art**: unverändert / umbenannt / Typ geändert / intern (wandert in das Modul `internal`, Konvention 7.2) / entfernt / neu.
- **Begründung**: G-Nr. = Glossarzeile (Konvention 3), § = Abschnitt der Konvention, L-Nr. = Lint-Regel.
- Der Layout-String (`X`, `T`, `1`–`9`, `o`, `P` …) und die Wunschliste (Spalten, Positionsangaben `vorne`, `v`, `!mitte`, `hinten rechts`, Kopfzeile „Name") sind Daten (§ 2.1) und bleiben unverändert. Texte im PDF („Pult", der Bericht, die Hinweise) bleiben deutsch.
- WASM-Plugin (`optimierer.wasm`, Rust-Quelltext, exportierte Funktion `optimiere`) und Suchverfahren sind unverändert; umbenannt sind nur Bezeichner und Schlüssel.

## 0. Entscheidungen

| Nr. | Entscheidung | Begründung |
|---|---|---|
| E1 | `sitzordnung` ist ein **neuer Baustein** (`bausteine-de-zusatz.txt`). Parameterwort: `seating`. | Bausteintest § 2.1: B1 liefert den Datenwert, den `typlace(names: …)` setzt (wie `datensatz`); B2 „Sitzordnung" ist das Wort, das Lehrkräfte und Klasse sagen; B3 kein Verb-Präfix, kein Technikhelfer. |
| E2 | `wunschliste` ist ein **neuer Baustein** (`bausteine-de-zusatz.txt`). Parameterwort: `wishes`. | B1 liefert den Datenwert, den `sitzordnung` nimmt; B2 „Wunschliste" steht so auf dem Zettel, den die Klasse ausfüllt; B3 trifft nicht zu. |
| E3 | `typlace` bleibt. | Funktionsname = Paketname (Eigenname, § 2.1). |
| E4 | `sitzplan-bericht` → `seating-report`, `sitzplan-kennzahlen` → `seating-summary`. | Kein Baustein: Ausgabe zu einem übergebenen Wert, kein Schulbegriff (B2 fehlt). Englischer zusammengesetzter Helfer `<merkmal>-<substantiv>` (§ 4.1) mit dem Parameterwort des Bausteins `sitzordnung` vorn (§ 4.1 „hinter dem Verb steht das Parameterwort"). |
| E5 | Alles, was nur der Optimierer braucht, wandert nach `internal` (17 Namen). | § 7.1, § 7.2; Inventar 6.5 „exportiert viele Interna". Kein Dokument im Repo benutzt sie. |
| E6 | `schueler-lesen` und `schueler-pruefen` sind nicht mehr öffentlich; ihr Stub nennt `wunschliste`. | `wunschliste` ist genau die Hintereinanderschaltung beider; als englische Namen bräuchten sie ein Verb außerhalb der Verbliste (§ 4.1: `show set reset get has is format`). |
| E7 | `rotation` wird ein Winkel (`90deg` statt `90`); eine Drehung, die keine Vierteldrehung ist, ist ein Fehler. | G75 (`rotation`: angle), § 5.5, L6 (gleicher Name, gleicher Typ wie `qr-box(rotation:)`); § 8.1 „keine falsche Eingabe wird still übergangen" (bisher wurde jede andere Zahl still zu 0, Inventar 6.5). Vorgabe gleichwertig: `0` → `0deg`. |
| E8 | Zonen und Kanten sind Enum-Werte und werden englisch: `"front"`, `"middle"`, `"back"`, `"left"`, `"right"`; `front: "top"`, `"bottom"`, `"left"`, `"right"`. Im Bericht erscheinen sie weiter deutsch. | § 5.3. Die gleichlautenden Wörter in der Wunschliste sind Daten und bleiben. |
| E9 | Rückgabe-Schlüssel, Schlüssel der Schüler-Einträge, von `weights` und `constraints` werden englisch, durchgehend bis in den Quelltext (keine Übersetzungsschicht). | § 2.1 „öffentlich ist alles, was ein Dokument schreiben kann", § 5.4. |
| E10 | `kontext` → `problem` (nicht `context`). | `context` ist ein Typst-Schlüsselwort und als Feldname nicht schreibbar. |
| E11 | `geo` → `geometry`. | § 2.2: keine Abkürzung außer den aufgezählten. |
| E12 | **Behobener Fehler:** `sitzordnung(layout, csv(...))` nimmt die Zeilen aus `csv()` an. | In 0.0.2 dokumentiert („das Ergebnis von `csv(..., delimiter: "\|")`"), brach aber mit „cannot access fields on type array" ab. Kein Dokument, das bisher kompilierte, ändert sich. |
| E13 | Private Helfer (`_spielraum`, `_startplan`, `_verbessern`, `_mischen`, `_positionen` …) und lokale Variablen in den Rümpfen behalten ihre deutschen Namen. | Auftrag „Algorithmen nicht anfassen"; sie sind von außen nicht erreichbar und nicht im Lint (L19 prüft nur exportierte Unterstrich-Namen). Abweichung von § 7.2, siehe Abschnitt 9. |

## 1. Öffentliche Namen

| alt | neu | Art | Begründung |
|---|---|---|---|
| `typlace` | `typlace` | unverändert (Parameter geändert) | E3 |
| `sitzordnung` | `sitzordnung` | unverändert (Parameter geändert) | E1 |
| `wunschliste` | `wunschliste` | unverändert (Parameter geändert) | E2 |
| `sitzplan-bericht` | `seating-report` | umbenannt | E4 |
| `sitzplan-kennzahlen` | `seating-summary` | umbenannt | E4 |
| `standard-gewichte` | `default-weights` | umbenannt (Wert, kein Stub möglich) | § 2.1 „Werte und Konstanten" englisch (`default-seed`) |
| `schueler-lesen` | `internal.parse-students` (Stub nennt `wunschliste`) | intern | E6 |
| `schueler-pruefen` | `internal.check-students` (Stub nennt `wunschliste`) | intern | E6 |
| `plaetze-analysieren` | `internal.analyze-layout` | intern | E5 |
| `layout-matrix` | `internal.layout-matrix` | intern (kein Stub: Name gleich) | E5 |
| `koerper-zellen` | `internal.table-cells` | intern | E5 |
| `ist-frei`, `ist-pult`, `ist-koerper`, `ist-platz` | `internal.is-free`, `internal.is-desk`, `internal.is-table`, `internal.is-seat` | intern | E5; § 4.1 `is-<adjektiv>` |
| `tisch-ids` | `internal.table-ids` | intern (Wert, kein Stub möglich) | E5 |
| `wasm-suchen` | `internal.wasm-search` | intern | E5 |
| `kontext-erstellen` | `internal.build-problem` | intern | E5, E10 |
| `normalisiere-vorgaben` | `internal.normalize-constraints` | intern | E5 |
| `bewerte` | `internal.score-plan` | intern | E5 |
| `statistik` | `internal.statistics` | intern | E5 |
| `punkte-schueler` | `internal.student-score` | intern | E5 |
| `punkte-wert` | `internal.student-points` | intern | E5 |
| `platz-von-schueler` | `internal.seat-of-students` | intern | E5 |
| `tausch-delta` | `internal.swap-delta` | intern | E5 |
| – (nur in `wasm.typ`) `kodieren` | `internal.encode` | intern | E5 |
| – (nur in `geometrie.typ`) `zeichen-frei`, `zeichen-pult`, `zeichen-koerper`, `zeichen-auto` | `internal.free-chars`, `internal.desk-chars`, `internal.table-chars`, `internal.auto-chars` | intern | E5 |

Keine States, Counter oder Labels, heute wie künftig.

Dateien: `typlace.typ` → `src/typlace.typ`, `optimierer.typ` → `src/optimizer.typ`, `daten.typ` → `src/data.typ`, `bewertung.typ` → `src/scoring.typ`, `geometrie.typ` → `src/geometry.typ`, `bericht.typ` → `src/report.typ`, `wasm.typ` → `src/wasm.typ`, `optimierer.wasm` → `src/optimierer.wasm` (byte-gleich); neu `src/lib.typ` (Einstieg), `src/internal.typ`, `src/removed.typ`, `src/internal/check.typ`.

## 2. `typlace`

```typ
// alt (typlace.typ Z. 44)
#let typlace(layout, namen: (), tisch-breite: 2cm, tisch-hoehe: 1.2cm, tisch-farbe: rgb("#cce0f5"),
  pult-farbe: rgb("#6b4c2a"), koerper-farbe: auto, nummern: false, rotation: 0) = { }
// neu
#let typlace(layout, names: (), cell-width: 2cm, cell-height: 1.2cm, seat-fill: rgb("#cce0f5"),
  desk-fill: rgb("#6b4c2a"), table-fill: auto, number: false, rotation: 0deg, ..deprecated) = { }
```

| alt | neu | Art | Begründung |
|---|---|---|---|
| `layout` (positional) | `layout` (positional) | unverändert | führendes Hauptargument (§ 4.4) |
| `namen: ()` | `names: ()` | umbenannt | Plural wegen Vorgabe `()` (L9) |
| `tisch-breite: 2cm` | `cell-width: 2cm` | umbenannt | G31; gemeint ist die Rasterzelle (gilt auch für Pult und freie Felder) |
| `tisch-hoehe: 1.2cm` | `cell-height: 1.2cm` | umbenannt | G32 |
| `tisch-farbe: rgb("#cce0f5")` | `seat-fill: rgb("#cce0f5")` | umbenannt | G27 `fill`, Verbot des Suffixes `-color` (L4); gefärbt wird der Sitzplatz |
| `pult-farbe: rgb("#6b4c2a")` | `desk-fill: rgb("#6b4c2a")` | umbenannt | G27 |
| `koerper-farbe: auto` | `table-fill: auto` | umbenannt | G27; W5 mit `none` als Aus |
| `nummern: false` | `number: false` | umbenannt | G40 „Nummer anzeigen" = `number` (bool), Schalter bleibt positiv und wird nicht gewendet (§ 4.3) |
| `rotation: 0` (int, Grad) | `rotation: 0deg` (angle) | Typ geändert | E7 |
| – | `..deprecated` | neu | § 4.4 Nr. 5 c |

Werte: `rotation: 90` → `90deg`, `180` → `180deg`, `270` → `270deg` (Meldung „falscher Typ" mit Beispiel `90deg`; kein „heißt jetzt", weil der Typ wechselt). Erlaubt ist jede Vierteldrehung (`-90deg`, `360deg`), sonst Fehler.

## 3. `sitzordnung`

```typ
// alt (optimierer.typ Z. 266)
#let sitzordnung(layout, schueler, vorgaben: (:), gewichte: (:), position-anteil: auto, seed: 42,
  qualitaet: "normal", versuche: auto, max-schritte: auto, vorne: auto, perspektive: "schueler",
  streng: true, dauer: none, motor: "wasm") = { }
// neu
#let sitzordnung(layout, students, constraints: (:), weights: (:), position-share: auto, seed: 42,
  quality: "normal", attempts: auto, max-steps: auto, front: auto, perspective: "student",
  strict: true, duration: none, engine: "wasm", ..deprecated) = { }
```

| alt | neu | Art | Wertabbildung | Begründung |
|---|---|---|---|---|
| `layout` (positional) | `layout` | unverändert | – | – |
| `schueler` (positional) | `students` (positional) | umbenannt | – | G20, Plural (Sammlung) |
| `vorgaben: (:)` | `constraints: (:)` | umbenannt | Schlüssel siehe 3.1 | Plural wegen `(:)` |
| `gewichte: (:)` | `weights: (:)` | umbenannt | Schlüssel siehe 3.2 | Plural wegen `(:)` |
| `position-anteil: auto` | `position-share: auto` | umbenannt | – | Typ ratio (§ 5.5); float bleibt wie bisher zulässig |
| `seed: 42` | `seed: 42` | unverändert | – | G85 |
| `qualitaet: "normal"` | `quality: "normal"` | umbenannt | `"schnell"` → `"fast"`, `"normal"` bleibt, `"gruendlich"` → `"thorough"` | § 5.3 |
| `versuche: auto` | `attempts: auto` | umbenannt | – | Zählgröße im Plural (§ 4.2) |
| `max-schritte: auto` | `max-steps: auto` | umbenannt | – | G71 `steps`; `max` ist erlaubte Abkürzung (§ 2.2) |
| `vorne: auto` | `front: auto` | umbenannt | `"oben"` → `"top"`, `"unten"` → `"bottom"`, `"links"` → `"left"`, `"rechts"` → `"right"` | E8 |
| `perspektive: "schueler"` | `perspective: "student"` | umbenannt | `"schueler"` → `"student"`, `"plan"` bleibt | G20 |
| `streng: true` | `strict: true` | umbenannt | – | W1, positiv |
| `dauer: none` | `duration: none` | umbenannt | `""` ist ein Fehler („leerer Text", § 5.2); Zahl bleibt wie bisher zulässig | W4 |
| `motor: "wasm"` | `engine: "wasm"` | umbenannt | `"wasm"`, `"typst"` bleiben (Eigennamen, `names-zusatz.txt`) | `motor` wäre in `names.txt` nur als zap-Bauteil erlaubt |
| – | `..deprecated` | neu | – | § 4.4 Nr. 5 c |

### 3.1 Schlüssel von `constraints`

| alt | neu | Art | Begründung |
|---|---|---|---|
| `fest` | `fixed` | umbenannt | Name → Platznummer |
| `muss-vorne`, `muss-mitte`, `muss-hinten` | `must-front`, `must-middle`, `must-back` | umbenannt | wörtlich; das Präfix hält den Schlüssel vom Parameter `front` (anderer Typ, L6) getrennt |
| `muss-links`, `muss-rechts` | `must-left`, `must-right` | umbenannt | wie oben |
| `getrennt` | `apart` | umbenannt | – |
| `zusammen` | `together` | umbenannt | – |

Neu geprüft: unbekannte Schlüssel (bisher still übergangen, Inventar 6.4) und der Typ je Schlüssel (`fixed` Dictionary, sonst Array).

### 3.2 Schlüssel von `weights` und `default-weights`

| alt | neu | Art | Begründung |
|---|---|---|---|
| `direkt: 1.0` | `adjacent: 1.0` | umbenannt | unmittelbar benachbart |
| `tisch: 0.9` | `table: 0.9` | umbenannt | selber Gruppentisch |
| `raenge: (1.0, 1.0, 1.0)` | `ranks: (…)` | umbenannt | Plural (Array) |
| `stufen: (1.0, 0.7, 0.45)` | `tiers: (…)` | umbenannt | `steps` ist G71 (Schrittzahl) und schiede aus |
| `wunschzahl: (1.0, 1.0, 1.0)` | `wish-count: (…)` | umbenannt | G38 `<ding>-count` |
| `fairness: 2.0` | `fairness: 2.0` | unverändert | sprachgleich |
| `ablehnung: -2.0` | `rejection: -2.0` | umbenannt | – |
| `hart: -1000.0` | `constraint: -1000.0` | umbenannt | Abzug je verletzter Vorgabe; nennt die Sache wie `rejection` und `position` |
| `position: 0.5` | `position: 0.5` | unverändert | G72 |
| `position-meidet: -0.5` | `position-avoided: -0.5` | umbenannt | – |

Neu geprüft: unbekannte Schlüssel (bisher still übergangen).

### 3.3 Rückgabe von `sitzordnung` (der „Plan")

| alt | neu | alt | neu |
|---|---|---|---|
| `namen` | `names` | `hinweise` | `notes` |
| `zuordnung` | `assignment` | `kontext` | `problem` |
| `platz-von` | `seat-of` | `geo` | `geometry` |
| `punkte` | `points` | `seed` | `seed` |
| `punkte-gerundet` | `points-rounded` | `dauer` | `duration` |
| `details` | `details` | `versuche` | `attempts` |
| `statistik` | `statistics` | `schritte` | `steps` |
| | | `geprueft` | `checked` |

`statistics`: `punkte` → `points`, `wuensche-gesamt` → `wishes-total`, `wuensche-erfuellt` → `wishes-fulfilled`, `quote` → `rate`, `alle-erfuellt` → `all-fulfilled`, `ohne-wunsch` → `unfulfilled` (Präfix `without-` ist verboten, L4), `position-gesamt` → `position-total`, `position-erfuellt` → `position-fulfilled`, `position-verletzt` → `position-violated`, `position-unerfuellbar` → `position-impossible` (Einträge `(name:, zone:)` unverändert), `ablehnungen-verletzt` → `rejections-violated`, `vorgaben-verletzt` → `constraints-violated`, `verteilung` → `distribution`, `punkte-aus-position` → `position-points`, `punkte-aus-wuenschen` → `wish-points`.

`details` (je Schüler): `punkte` → `points`, `punkte-position` → `position-points`, `erfuellt` → `fulfilled`, `verletzt` → `violated` (Einträge `(schueler:, art:, punkte:)` → `(student:, kind:, points:)`), `position` bleibt, `position-verletzt` → `position-violated`, `hart-verletzt` → `constraints-violated`.

`geometry`: `matrix` bleibt, `zeilen` → `rows`, `spalten` → `columns`, `vorne` → `front`, `plaetze` → `seats`, `tische` → `tables`, `zonen: (tiefe:, seite:)` → `zones: (depth:, side:)`, `beziehung` → `relations`. Je Platz: `index`, `zeile` → `row`, `spalte` → `column`, `zeichen` → `character`, `tisch` → `table`, `abstand` → `distance`, `zone: (tiefe:, seite:)` → `zone: (depth:, side:)`. Werte: Tischnamen `"tisch-1"` → `"table-1"` (`"auto-0"` bleibt); Beziehung `"selbst"`, `"direkt"`, `"tisch"`, `"fern"` → `"self"`, `"adjacent"`, `"table"`, `"far"`; Zonen nach E8.

`problem` (früher `kontext`): `geo` → `geometry`, `schueler` → `students`, `index-von` → `index-of`, `wuensche` → `wishes`, `ablehnungen` → `rejections`, `getrennt` → `apart`, `zusammen` → `together`, `rueckwaerts` → `reverse`, `gewichte` → `weights`, `anzahl-schueler` → `student-count`, `anzahl-plaetze` → `seat-count`.

## 4. `wunschliste`

```typ
// alt (daten.typ Z. 353)
#let wunschliste(quelle, trenner: auto, kopfzeile: auto, plaetze: none, max-wuensche: 3, streng: true) = { }
// neu
#let wunschliste(source, delimiter: auto, header-row: auto, seat-count: none, max-wishes: 3, strict: true, ..deprecated) = { }
```

| alt | neu | Art | Begründung |
|---|---|---|---|
| `quelle` (positional) | `source` (positional) | umbenannt | Positionsargument, im Dokument nicht geschrieben |
| `trenner: auto` | `delimiter: auto` | umbenannt | heißt wie Typsts `csv(delimiter:)` und bedeutet dasselbe (Entscheidungsbaum Schritt 2) |
| `kopfzeile: auto` | `header-row: auto` | umbenannt | bool/auto: „erste Zeile ist eine Kopfzeile"; `header` allein ist G54/G81 (content bzw. array) und schiede wegen L6 aus |
| `plaetze: none` | `seat-count: none` | umbenannt | G38 `<ding>-count` (int) |
| `max-wuensche: 3` | `max-wishes: 3` | umbenannt | Parameterwort von `wunschliste` (E2) |
| `streng: true` | `strict: true` | umbenannt | wie in `sitzordnung` |
| – | `..deprecated` | neu | § 4.4 Nr. 5 c |

Rückgabe: `(schueler:, hinweise:)` → `(students:, notes:)`. Je Eintrag: `name` bleibt, `position: (tiefe:, seite:)` → `position: (depth:, side:)`, `position-meidet` → `position-avoided`, `wuensche` → `wishes`, `ablehnungen` → `rejections`; Zonenwerte nach E8. Wer `sitzordnung` selbst gebaute Einträge übergibt, bekommt für jeden alten Schlüssel und Wert „heißt jetzt".

## 5. `seating-report`, `seating-summary`

```typ
// alt (bericht.typ Z. 72, Z. 7)
#let sitzplan-bericht(plan, details: true) = { }
#let sitzplan-kennzahlen(plan) = { }
// neu
#let seating-report(plan, details: true, ..deprecated) = { }
#let seating-summary(plan) = { }
```

| alt | neu | Art | Begründung |
|---|---|---|---|
| `plan` (positional) | `plan` (positional) | unverändert | – |
| `details: true` | `details: true` | unverändert | W1, positiv |

Die Ausgabe ist wortgleich; Zonen im Satz „… wünscht „mitte"" werden aus den englischen Werten zurück ins Deutsche gesetzt.

## 6. Fehlermeldungen

Alle 21 `panic("typlace: …")` laufen über `fail("typlace", <funktion>, "<Befund> – <Abhilfe>")` (§ 8.2, L21). `<funktion>` ist die öffentliche Funktion, die der Benutzer aufgerufen hat (`typlace`, `sitzordnung`, `wunschliste`); die internen Helfer bekommen sie als `caller:`. Beispiele:

```
typlace.sitzordnung: Platz 9 für Anna gibt es nicht – erlaubt sind 0 bis 7 (`typlace(number: true)` zeigt die Nummern)
typlace.sitzordnung: diese Namen stehen nicht in der Klassenliste: „Zoe“ (Wunsch von Dora) – Schreibweise angleichen oder `strict: false` setzen
typlace.typlace: das Layout enthält keine Sitzplätze – Plätze mit `T` oder einem Tischzeichen (`1`–`9`, `a`–`z`) eintragen
```

Der Hinweistext bei `strict: false` („typlace: Diese Namen stehen nicht in der Klassenliste: … Sie wurden ignoriert.") steht im PDF und bleibt wortgleich.

## 7. Stubs (`src/removed.typ`)

`sitzplan-bericht` → `seating-report`, `sitzplan-kennzahlen` → `seating-summary`, `schueler-lesen` → `wunschliste`, `schueler-pruefen` → `wunschliste`, `plaetze-analysieren` → `internal.analyze-layout`, `koerper-zellen` → `internal.table-cells`, `ist-frei` → `internal.is-free`, `ist-pult` → `internal.is-desk`, `ist-koerper` → `internal.is-table`, `ist-platz` → `internal.is-seat`, `wasm-suchen` → `internal.wasm-search`, `bewerte` → `internal.score-plan`, `kontext-erstellen` → `internal.build-problem`, `normalisiere-vorgaben` → `internal.normalize-constraints`, `platz-von-schueler` → `internal.seat-of-students`, `punkte-schueler` → `internal.student-score`, `punkte-wert` → `internal.student-points`, `tausch-delta` → `internal.swap-delta`, `statistik` → `internal.statistics`.

Kein Stub: `standard-gewichte`, `tisch-ids` (Werte; ein Stub wäre eine Funktion und gäbe beim Feldzugriff keine brauchbare Meldung) und `layout-matrix` (Name unverändert, nur nach `internal` gewandert). Dort meldet Typst „unknown variable".

## 8. Wortlisten

Neue Bausteine in `bausteine-de-zusatz.txt`: `sitzordnung`, `wunschliste`. Die zugehörigen Zeilen `"sitzordnung": ["seating"]` und `"wunschliste": ["wishes"]` fehlen noch in `wortpaare.json` und in `word-pairs` von `check.typ` (beide Dateien durfte die Umsetzung nicht ändern).

Neue Wörter in `words-en-zusatz.txt` – vom Lint verlangt (Funktions- und Parameternamen): `delimiter wishes seat strict attempts constraints duration engine front layout perspective share quality students weights plan seating summary report details desk`; dazu für Schlüssel und Enum-Werte, die das Lint nicht prüft: `fast normal thorough left right must back middle fixed apart together adjacent ranks tiers wish fairness rejection constraint avoided depth rejections notes assignment statistics problem geometry checked fulfilled violated impossible unfulfilled distribution rate rounded seats tables zones relations distance column`.

Eigennamen in `names-zusatz.txt`: `wasm`, `typst` (Werte von `engine`).

## 9. Abweichungen und offene Punkte

1. § 7.2 (interne Namen englisch, kein `_name`): Die über `internal` erreichbaren Namen sind englisch; private Helfer mit Unterstrich und lokale Variablen in den Rümpfen sind deutsch geblieben (E13).
2. § 8.4 „für jede Zeile der Compat-Tabelle ein Test": Es gibt 17 Tests (`tests/v05-typlace-*.typ`), die jede Meldungsart abdecken, aber nicht jede einzelne Zeile.
3. `position-share` nimmt weiter auch `float` (0.2 = 20 %) an; § 5.5 sähe nur `ratio` vor. Unverändert gelassen, weil sich sonst Verhalten änderte.
4. `details` ist zugleich Parameter von `seating-report` (bool) und Schlüssel des Plans (Array). Beide Namen bestehen seit 0.0.2 und sind englisch; nicht angefasst.
5. Typprüfungen (§ 8.1): Gegenüber 0.0.2 bewusst strenger sind `names` (nur Array; ein `str` wurde früher buchstabenweise verteilt, typischer Fehler `("Anna")`), `attempts`, `max-steps`, `seat-count`, `max-wishes` (nur `int`, kein `float`), `strict` (nur `bool`), `weights` (nur Dictionary), `front` und `perspective` (nur die Enum-Werte) sowie der Typ je Schlüssel von `constraints`. Nicht eingeschränkt, weil gültige Eingaben in 0.0.2: `cell-width`/`cell-height` nehmen jedes Rastermaß (`length`, `ratio`, `relative`, `fraction`, `auto`), `table-fill` auch `gradient` und `tiling`, `duration` auch `int` und `float`.
6. „alt und neu zugleich": Der neue Name ist ein deklarierter Parameter und landet nicht im Sink. Die Zugleich-Meldung erscheint deshalb nur, wenn der neue Name einen anderen Wert als die Vorgabe trägt (Vergleich mit der Vorgabe, Helfer `_gesetzt`); sonst die einfache Meldung „heißt jetzt".
7. `sitzordnung` mit einem Dictionary `(students:, notes:)`: Schlüssel und Zonenwerte der Einträge werden geprüft (`internal`-Helfer `check-entries` in `src/data.typ`, nicht über `internal.typ` exportiert), die Namen aber nicht erneut aufgelöst; `notes` darf fehlen (dann `()`).
8. `wunschliste(header: …)`: kein eigener Hinweis auf `header-row` (weder „heißt jetzt" noch „gibt es nicht mehr" träfe zu, den Namen gab es nie); die Meldung zählt die erlaubten Parameter auf.

## 10. Maschinenlesbarer Anhang

Lesart wie in `tabelle-fachpakete.md` Abschnitt 12: Schlüssel in `parameter`, `werte`, `schluessel` und `rueckgabe` sind die alten Namen, mit dem Paket qualifiziert; `funktionen` bildet auf die neuen ab; `stubs` nennt den Text hinter „heißt jetzt"; `"$v"` ist der alte Wert.

```json
{
  "paket": "typlace",
  "von": "0.0.2",
  "nach": "0.5.0",
  "funktionen": {
    "typlace.sitzplan-bericht": "typlace.seating-report",
    "typlace.sitzplan-kennzahlen": "typlace.seating-summary",
    "typlace.standard-gewichte": "typlace.default-weights",
    "typlace.schueler-lesen": "typlace.internal.parse-students",
    "typlace.schueler-pruefen": "typlace.internal.check-students",
    "typlace.plaetze-analysieren": "typlace.internal.analyze-layout",
    "typlace.layout-matrix": "typlace.internal.layout-matrix",
    "typlace.koerper-zellen": "typlace.internal.table-cells",
    "typlace.ist-frei": "typlace.internal.is-free",
    "typlace.ist-pult": "typlace.internal.is-desk",
    "typlace.ist-koerper": "typlace.internal.is-table",
    "typlace.ist-platz": "typlace.internal.is-seat",
    "typlace.tisch-ids": "typlace.internal.table-ids",
    "typlace.wasm-suchen": "typlace.internal.wasm-search",
    "typlace.kontext-erstellen": "typlace.internal.build-problem",
    "typlace.normalisiere-vorgaben": "typlace.internal.normalize-constraints",
    "typlace.bewerte": "typlace.internal.score-plan",
    "typlace.statistik": "typlace.internal.statistics",
    "typlace.punkte-schueler": "typlace.internal.student-score",
    "typlace.punkte-wert": "typlace.internal.student-points",
    "typlace.platz-von-schueler": "typlace.internal.seat-of-students",
    "typlace.tausch-delta": "typlace.internal.swap-delta"
  },
  "stubs": {
    "typlace.sitzplan-bericht": "seating-report",
    "typlace.sitzplan-kennzahlen": "seating-summary",
    "typlace.schueler-lesen": "wunschliste",
    "typlace.schueler-pruefen": "wunschliste",
    "typlace.plaetze-analysieren": "internal.analyze-layout",
    "typlace.koerper-zellen": "internal.table-cells",
    "typlace.ist-frei": "internal.is-free",
    "typlace.ist-pult": "internal.is-desk",
    "typlace.ist-koerper": "internal.is-table",
    "typlace.ist-platz": "internal.is-seat",
    "typlace.wasm-suchen": "internal.wasm-search",
    "typlace.bewerte": "internal.score-plan",
    "typlace.kontext-erstellen": "internal.build-problem",
    "typlace.normalisiere-vorgaben": "internal.normalize-constraints",
    "typlace.platz-von-schueler": "internal.seat-of-students",
    "typlace.punkte-schueler": "internal.student-score",
    "typlace.punkte-wert": "internal.student-points",
    "typlace.tausch-delta": "internal.swap-delta",
    "typlace.statistik": "internal.statistics"
  },
  "ohne-stub": [
    "typlace.standard-gewichte",
    "typlace.tisch-ids",
    "typlace.layout-matrix"
  ],
  "parameter": {
    "typlace.typlace": {
      "namen": "names",
      "tisch-breite": "cell-width",
      "tisch-hoehe": "cell-height",
      "tisch-farbe": "seat-fill",
      "pult-farbe": "desk-fill",
      "koerper-farbe": "table-fill",
      "nummern": "number"
    },
    "typlace.sitzordnung": {
      "vorgaben": "constraints",
      "gewichte": "weights",
      "position-anteil": "position-share",
      "qualitaet": "quality",
      "versuche": "attempts",
      "max-schritte": "max-steps",
      "vorne": "front",
      "perspektive": "perspective",
      "streng": "strict",
      "dauer": "duration",
      "motor": "engine"
    },
    "typlace.wunschliste": {
      "trenner": "delimiter",
      "kopfzeile": "header-row",
      "plaetze": "seat-count",
      "max-wuensche": "max-wishes",
      "streng": "strict"
    }
  },
  "positional": {
    "typlace.sitzordnung": {
      "schueler": "students"
    },
    "typlace.wunschliste": {
      "quelle": "source"
    }
  },
  "werte": {
    "typlace.typlace.rotation": {
      "0": "0deg",
      "90": "90deg",
      "180": "180deg",
      "270": "270deg",
      "*": "Fehler: keine Vierteldrehung"
    },
    "typlace.sitzordnung.qualitaet": {
      "schnell": "fast",
      "normal": "normal",
      "gruendlich": "thorough"
    },
    "typlace.sitzordnung.vorne": {
      "oben": "top",
      "unten": "bottom",
      "links": "left",
      "rechts": "right"
    },
    "typlace.sitzordnung.perspektive": {
      "schueler": "student",
      "plan": "plan"
    },
    "typlace.sitzordnung.motor": {
      "wasm": "wasm",
      "typst": "typst"
    },
    "typlace.sitzordnung.dauer": {
      "": null
    }
  },
  "schluessel": {
    "typlace.sitzordnung.vorgaben[]": {
      "fest": "fixed",
      "muss-vorne": "must-front",
      "muss-mitte": "must-middle",
      "muss-hinten": "must-back",
      "muss-links": "must-left",
      "muss-rechts": "must-right",
      "getrennt": "apart",
      "zusammen": "together"
    },
    "typlace.sitzordnung.gewichte[]": {
      "direkt": "adjacent",
      "tisch": "table",
      "raenge": "ranks",
      "stufen": "tiers",
      "wunschzahl": "wish-count",
      "fairness": "fairness",
      "ablehnung": "rejection",
      "hart": "constraint",
      "position": "position",
      "position-meidet": "position-avoided"
    },
    "typlace.sitzordnung.schueler": {
      "schueler": "students",
      "hinweise": "notes"
    },
    "typlace.sitzordnung.schueler[]": {
      "name": "name",
      "position": "position",
      "position-meidet": "position-avoided",
      "wuensche": "wishes",
      "ablehnungen": "rejections"
    },
    "typlace.sitzordnung.schueler[].position": {
      "tiefe": "depth",
      "seite": "side"
    },
    "typlace.sitzordnung.schueler[].position-meidet": {
      "tiefe": "depth",
      "seite": "side"
    }
  },
  "zonen": {
    "vorne": "front",
    "mitte": "middle",
    "hinten": "back",
    "links": "left",
    "rechts": "right"
  },
  "rueckgabe": {
    "typlace.sitzordnung": {
      "namen": "names",
      "zuordnung": "assignment",
      "platz-von": "seat-of",
      "punkte": "points",
      "punkte-gerundet": "points-rounded",
      "details": "details",
      "statistik": "statistics",
      "hinweise": "notes",
      "kontext": "problem",
      "geo": "geometry",
      "seed": "seed",
      "dauer": "duration",
      "versuche": "attempts",
      "schritte": "steps",
      "geprueft": "checked"
    },
    "typlace.sitzordnung.statistik": {
      "punkte": "points",
      "wuensche-gesamt": "wishes-total",
      "wuensche-erfuellt": "wishes-fulfilled",
      "quote": "rate",
      "alle-erfuellt": "all-fulfilled",
      "ohne-wunsch": "unfulfilled",
      "position-gesamt": "position-total",
      "position-erfuellt": "position-fulfilled",
      "position-verletzt": "position-violated",
      "position-unerfuellbar": "position-impossible",
      "ablehnungen-verletzt": "rejections-violated",
      "vorgaben-verletzt": "constraints-violated",
      "verteilung": "distribution",
      "punkte-aus-position": "position-points",
      "punkte-aus-wuenschen": "wish-points"
    },
    "typlace.sitzordnung.details[]": {
      "punkte": "points",
      "punkte-position": "position-points",
      "erfuellt": "fulfilled",
      "verletzt": "violated",
      "position": "position",
      "position-verletzt": "position-violated",
      "hart-verletzt": "constraints-violated"
    },
    "typlace.sitzordnung.details[].erfuellt[]": {
      "schueler": "student",
      "art": "kind",
      "punkte": "points"
    },
    "typlace.sitzordnung.geo": {
      "matrix": "matrix",
      "zeilen": "rows",
      "spalten": "columns",
      "vorne": "front",
      "plaetze": "seats",
      "tische": "tables",
      "zonen": "zones",
      "beziehung": "relations"
    },
    "typlace.sitzordnung.geo.plaetze[]": {
      "index": "index",
      "zeile": "row",
      "spalte": "column",
      "zeichen": "character",
      "tisch": "table",
      "abstand": "distance",
      "zone": "zone"
    },
    "typlace.sitzordnung.geo.beziehung[][]": {
      "selbst": "self",
      "direkt": "adjacent",
      "tisch": "table",
      "fern": "far"
    },
    "typlace.sitzordnung.kontext": {
      "geo": "geometry",
      "schueler": "students",
      "index-von": "index-of",
      "wuensche": "wishes",
      "ablehnungen": "rejections",
      "getrennt": "apart",
      "zusammen": "together",
      "rueckwaerts": "reverse",
      "gewichte": "weights",
      "anzahl-schueler": "student-count",
      "anzahl-plaetze": "seat-count"
    },
    "typlace.wunschliste": {
      "schueler": "students",
      "hinweise": "notes"
    }
  },
  "neu": {
    "bausteine": [
      "sitzordnung",
      "wunschliste"
    ],
    "wortpaare": {
      "sitzordnung": [
        "seating"
      ],
      "wunschliste": [
        "wishes"
      ]
    },
    "names": [
      "wasm",
      "typst"
    ]
  },
  "unveraendert": [
    "Layout-String",
    "Wunschliste (Spalten, Positionsangaben, Kopfzeile)",
    "optimierer.wasm",
    "Texte im PDF"
  ],
  "states": [],
  "labels": []
}
```
