# Historie und Versionslage der @schule-Pakete

Stand: 2026-11-14, Repo `/Users/alexander/Library/Application Support/typst/packages/schule`, Branch `main` (= `origin/main`), 629 Commits (2023-08-18 bis 2026-11-05). Nichts geändert, nichts committet. Regressionstests laufen lokal grün (`bash tests/run.sh`: 19 bestanden, 0 fehlgeschlagen, Typst 0.15.1).

Arbeitsverzeichnis ist nicht sauber:

- `M arbeitsblatt/0.4.0/src/themes.typ` (uncommittet: Theme `atlas`, `reiter(..., rand:)` für bündige Reiter-Kante bei `memo`)
- `?? aufgaben/0.3.1/aufgaben.typ.orig` (1226 Zeilen, Sicherungskopie vor den Commits vom 2026-11-02; würde von `neue-version.sh` mitkopiert)
- `?? typstage-geogebra/` (lokaler Rest; im Repo am 2026-09-12 entfernt, importiert `@schule/typstage:0.1.0`, das es nicht mehr gibt)

---

## 1. Historie: bisherige Umbenennungen und ihre Richtung

### 1.1 Phasen

| Zeitraum | Was |
|---|---|
| 2023-08 bis 2024-12 | Einzeldateien je Paket (`arbeitsblatt.typ` usw.), Autoren lkoehl + Loewe1000. Parameter von Anfang an gemischt: `title`, `class`, `paper`, `print`, `landscape` (en) neben `loesungen` (de). |
| 2024-12-27 `3861eb3` „Reworked aufgaben.typ" | aufgaben 0.1.0: Positions-/Kurzparameter aufgeräumt (`numb`, `lbl`, `use`, `aufg`, `teil` entfallen), `label-ref`, `item-label` eingeführt. |
| 2025-09/10 | arbeitsblatt 0.2.4, aufgaben 0.1.2, klassenarbeit 0.1.2: große API-Runde (kebab-case, Passthrough, Shortcodes, Materialien). |
| 2026-06-10 `f6e58af` | Sprung auf 0.3.0 für arbeitsblatt/aufgaben/klassenarbeit (Bundle-Export, Typst 0.15). Nummern 0.2.x (aufgaben, klassenarbeit) wurden übersprungen, um die drei Pakete auf eine gemeinsame Minor-Linie zu bringen. |
| 2026-09-12 `4746285` | Versionsregel + Skripte + README („Veröffentlichtes ist eingefroren"). |
| 2026-10-22 `76a9e28`, `d5722e5` | arbeitsblatt 0.4.0 + aufgaben 0.3.1 + klassenarbeit 0.4.0: Themes. |
| 2026-11-02/03 | Fehlerkorrekturen, Optionsprüfung, `tests/` (in 0.4.0/0.3.1 und teils rückwirkend in 0.3.0/0.0.2). |

### 1.2 Commits mit Namensentscheidungen (wörtlich)

| Commit | Botschaft | Richtung |
|---|---|---|
| `8cd16b9` 2024-01-14 | „changed "amount" to "columns" in tasks" | en → en (Angleichung an Typst-Vokabular) |
| `362f410` 2024-03-18 | „move liniert and kariert into patterns package" | Auslagerung, deutsche Funktionsnamen bleiben |
| `766e4e8` 2025-10-20 | „Rename tasks function to teilaufgaben" | **en → de** (Funktionsname) |
| `86acf8e` 2025-10-22 | „Add alias for 'teilaufgaben' as 'tasks'" | alter englischer Name bleibt als Alias |
| `9973943` 2025-10-20 | „Renamed functions to kebab-case for consistency and refactored argument parsing for 'aufgabe' and 'erwartung' …" | **snake_case → kebab-case**: `set_options`→`set-options`, `show_loesung`→`show-loesung`, `show_loesungen`→`show-loesungen`, `get_points`→`get-points`, `show_material(ien)`→`show-material(ien)` |
| `33971d6` 2025-10-23 | „Update function calls to kebab-case in arbeitsblatt.typ … (show_materialien, show_loesungen) to kebab-case … for consistency with naming conventions" | snake → kebab |
| `f04847c` 2025-10-23 | „Refactor klassenarbeit API and update to v0.1.2 … removing duplicate parameters and enabling passthrough of all arbeitsblatt parameters. Changed 'klausurboegen' to accept a dictionary for settings, refactored 'info-table' …" | Entdoppelung, `klausurboegen-settings` + `ergebnisse` → ein Dictionary `klausurboegen:` |
| `8223810` 2025-10-28 | „Rename 'schueler' to 'student' and add 'name-field' option" | **de → en** (Parameter) |
| `b6ece89` 2026-05-15 | „Add name-repeat option to repeat name in header" | neu, en |
| `24a1457`/`505b7fb` 2025-12-23 | „Add 'keine-summe' option …", „Add 'erreicht' option to show-erwartungen function" | neu, de |
| `8a7affc` 2025-10-26 | „Add new-page option to show-erwartungen function" | neu, en (im selben Aufruf wie `erreicht`) |
| `f65b753` 2026-04-17 | „Support 'loesungen: "nur"' and inline solutions … loesungen-only parameter" | neu, **denglisch** (`loesungen-only`) |
| patterns 0.0.1 → 0.0.2 (ohne eigene Botschaft) | `lineheight` → `line-height` | Zusammenschreibung → kebab |
| `3cd178c` 2026-10-07 | „klausurboegen 0.0.5: muster: "kariert" \| "liniert" (mit linienabstand), korrekturrand: "innen" …" | neu, **de** (neben `line-stroke`, `result-table`, `weißer-rand`) |
| `bd495d5` 2026-10-07 | „erreicht-spalte wieder entfernt; erreicht: true genügt" | Rückbau einer Doppelung |
| `76a9e28` 2026-10-22 | „Neuer Parameter theme: in arbeitsblatt() … Optional akzent: für eine eigene Farbe. Alle Befehle bleiben gleich …" | neu, **en + de im selben Feature** (`theme`, `akzent`) |
| `f0f0026` 2026-05-15 | „Migrate fancy-units to unify and update wrappers … preserving the short two-argument legacy syntax" | Rückwärtskompatibilität per Wrapper |
| `f0367ce` 2026-09-26 | „qr-code nimmt den alten Parameter background: an" | Alt-Parameter bleibt als Alias |
| `f26d44c` 2026-08-19 | „typstage + geogebra: Stufe 4 — weniger Namen, richtigere Vorgaben" | (Universe-Paket) Reduktion |
| `0187554` 2026-08-23, `4b085fe` 2026-09-12 | „typstage: Kommentare und Vorgaben englisch", „blockst/0.4.0 …: Kataloge englisch" | (Universe-Pakete) **de → en** |

### 1.3 Befund zur Richtung

- **Schreibweise ist entschieden:** kebab-case (seit 2025-10). Reste in snake_case stehen nur noch in physik/messwerttabellen (`lineare_regression`, `p_messwerttabelle`, `count_decimal_places`, `auto_einheit_anwenden`, Parameter `x_param`, `max_wert_pro_tabelle`) und intern (`_state_aufgaben`). camelCase-Reste in klausurboegen 0.0.4 (`maxPoints`, `achievedPoints`).
- **Sprache ist NICHT entschieden** – es gibt Umbenennungen in beide Richtungen (`tasks`→`teilaufgaben` de, `schueler`→`student` en). Faktisches Muster im Kern:
  - Funktionsnamen des Fachvokabulars deutsch: `arbeitsblatt`, `klassenarbeit`, `aufgabe`, `teilaufgabe`, `loesung`, `erwartung`, `material`, `kariert`, `liniert`, `lsg`, `lücke`, `klausurbögen`.
  - Hilfs-/Anzeigefunktionen englisches Verb + deutsches Objekt: `show-loesungen`, `show-erwartungen`, `show-bewertung`, `get-points` (!), `get-punkte-anzeige`, `set-options`, `reset-aufgaben`, `format-punkte`.
  - Layout-/Typst-nahe Parameter englisch: `title`, `class`, `paper`, `print`, `duplex`, `font`, `page-settings`, `custom-header`, `workspaces`, `teacher`, `student`, `date`, `logo`, `info-table`, `page-numbering`.
  - Inhaltliche/didaktische Parameter deutsch: `loesungen`, `materialien`, `punkte`, `erwartungen`, `varianten`, `dateiname`, `zweifach`, `fach`, `thema`, `jahrgang`, `stichworte`, `akzent`, `muster`, `korrekturrand`.
  - Mischformen in einem Namen: `teilaufgabe-numbering`, `aufgaben-shortcodes`, `punkte-template`, `loesungen-only`, `vorschau-alle`, `name-field`, `weißer-rand`, `result-table`.
  - Optionswerte deutsch, teils als Text statt bool: `loesungen: "false" | "sofort" | "folgend" | "seiten" | "nur"`, `punkte: "keine" | "aufgaben" | "alle"`, aber `page-numbering: true | false | "reset" | "continuous"`.
- **Umlaute/ß in Bezeichnern:** `lücke`, `klausurbögen`, `weißer-rand` gegenüber `loesung`, `loesungen`, `klausurboegen` (Paket- und Parametername), `korrekturrand: "aussen"`.
- **Universe-Pakete (typstage, blockst) sind bewusst englisch** geworden; die @schule-internen Pakete nicht.

---

## 2. Diffs der öffentlichen Signaturen

(Ermittelt mit einem Signatur-Extraktor über alle `#let`; `_`-Namen sind privat, werden aber wegen `import … : *` und Fremdzugriffen mit genannt.)

### 2.1 arbeitsblatt 0.3.2 → 0.4.0

- `arbeitsblatt(...)` und `arbeitsblatt-einzeln(...)`: neu `theme: none`, `akzent: auto`; Vorgaben geändert `font-size: 12pt → auto`, `font: "Myriad Pro" → auto`, `math-font: "Fira Math" → auto`, `title-font-size: 16pt → auto`.
- Neu: 15 Kasten-Wrapper, die die Namen aus gentle-clues überdecken und ans Theme leiten: `abstract, info, question, memo, conclusion, tip, success, warning, error, example, goal, idea, experiment, notify, danger` (alle `(..args)`), dazu privat `_kasten`, `_kasten-titel`, `_kasten-original`.
- Neu: Datei `src/themes.typ` (1164 Zeilen; `themes`, `_theme-aufloesen`), Ordner `showcase/`.
- Neu (Commits `56e9eb3`, `4e49bf7`): Prüfung der Optionswerte (`loesungen`, `materialien`, `punkte`, `aufgaben-shortcodes`, `teilaufgabe-numbering`) und Abbruch bei unbekannten benannten Optionen; `loesungsmodus()` prüft positiv.
- Import geändert: `@schule/aufgaben:0.3.0 → 0.3.1`.
- Keine Umbenennung, keine Entfernung. Botschaft: „Alle Befehle bleiben gleich, ohne theme ist die Ausgabe pixelgleich zu 0.3.2."

Vollständige Signatur 0.4.0 (`arbeitsblatt/0.4.0/src/arbeitsblatt.typ:1030`):
`arbeitsblatt(title: "", class: "", paper: "a4", print: false, duplex: true, workspaces: true, theme: none, akzent: auto, font-size: auto, font: auto, math-font: auto, title-font-size: auto, figure-font-size: 9pt, landscape: false, custom-header: none, teilaufgabe-numbering: "a)", page-settings: (:), loesungen: "false", materialien: "seiten", punkte: "keine", aufgaben-shortcodes: "teilaufgaben", copyright: none, zweifach: false, varianten: auto, vorschau-alle: true, dateiname: none, fach: none, thema: none, jahrgang: (), stufe: none, niveau: none, typ: none, stichworte: (), kerncurriculum: (), stand: none, ..args, body)`

Zum Vergleich die Vorgeschichte: 0.3.0→0.3.1 `vorschau-alle: true`; 0.3.1→0.3.2 `zweifach: false`, `loesungsmodus()`, `lsg(body, platz:, sonst:)`, `teilaufgaben(tasks:, columns:, numbering:, gutter:, loesungen:, ..args)` + Alias `tasks`, `qr-code(background:)`.

### 2.2 klassenarbeit 0.3.2 → 0.4.0

- **Signatur unverändert** (`klassenarbeit/0.4.0/src/klassenarbeit.typ:384`):
  `klassenarbeit(subtitle: "", date: "", logo: "angela", teacher: "", student: "", name-field: "Name", name-repeat: false, info-table: false, page-numbering: true, klausurboegen: false, erwartungen: true, punkte-template: none, varianten: auto, variante: auto, dateiname: none, ..args, body)`
- `theme:`/`akzent:` kommen nur über `..args` (aus `args.named()` gelesen, Zeile 86) – tauchen also in der Signatur nicht auf.
- Import `@schule/arbeitsblatt:0.3.0 → 0.4.0` (0.3.2 hing noch an arbeitsblatt 0.3.0, nicht an 0.3.2!).
- Verhalten: Assertions für `page-numbering` und `erwartungen`; `punkte-template` wird je KA neu gesetzt; Seitenzähler-Reset nach dem Seitenwechsel; Erwartungshorizont zählt nicht mit; `page-settings` des Aufrufers überschreibt die KA-Ränder nicht mehr.
- Seitenast: klassenarbeit **0.3.1** hat zusätzlich `bogen: false` – dieser Parameter fehlt in 0.3.2 und 0.4.0 (siehe 2.4).

### 2.3 aufgaben 0.3.0 → 0.3.1

- `show-erwartungen(grouped: false, new-page: false, erreicht: false)` + **neu** `alle: false`, `teile: ()`.
- `show-material(aufg)` + **neu** `start: 0`.
- Neu privat: `_state_theme`, `_theme-hook(name)`, `_zusammen`, `_loesung-kasten`, `_be-runden`, `_be-anzeige`, `_aufgaben-final`, `_rechter-textrand`, `_erwartungen-zeilen`, `_state_ta_material_vorher`, `_ist-flex-workspace`, `_flex-fest`.
- Keine Umbenennung. `typst.toml` unterscheidet sich nur in der Versionsnummer; README beider Versionen ist leer (0 Byte); `docs/content.typ` von 0.3.1 importiert weiter `@schule/aufgaben:0.3.0`.
- Achtung: Ein Teil der 0.3.1-Arbeit wurde auch nach 0.3.0 zurückgetragen (`d1af5b0` 2026-11-03, `f0367ce`, `5f6f8d7`, `3cd178c`/`bd495d5`) – 0.3.0 ist also nach Erscheinen 9-mal geändert worden.

Öffentliche Namen 0.3.1: `get-punkte-anzeige(opts)`, `get-punkte-position(opts)`, `format-punkte(teil: false, points)`, `set-options(options)`, `reset-aufgaben()`, `show-loesung(aufg, teil: false)`, `show-loesung-inline(aufg)`, `show-offene-loesungen()`, `show-loesungen(curr: false, teil: false, inline: false)`, `get-points(aufg, teil: none, idx: none)`, `show-erwartungen(...)`, `show-bewertung(..args, compact: false, full: false)`, `show-material(aufg, start: 0)`, `show-materialien(curr: false)`, `material(body, caption: none, label: none)`, `aufgabe(title: none, method: "", icons: (), large: true, number: true, workspace: none, label: none, ..args)`, `teilaufgabe(item-label: none, label: none, workspace: none, body)`, `loesung(body)`, `erwartung(..args)`.

### 2.4 klausurboegen 0.0.4 → 0.0.5 (zwei auseinandergelaufene Äste!)

- 0.0.5 ist **aus 0.0.3 entstanden, nicht aus 0.0.4**. 0.0.3→0.0.5: nur `muster: "kariert"`, `linienabstand: 8mm`, `korrekturrand: "aussen"` neu.
- 0.0.4 (896 Zeilen, laut `0cdcf95` „lagen nur lokal, werden aber von echten Dokumenten genutzt") enthält gegenüber 0.0.3: `klausurbögen(vordruck: false, namen: false)`, öffentliche `bogen-seiten(exam:, subexam:, teacher:, class:, date:, sek1:, sub:, result-table:, vorschlag:, numbering:, mv:, aufgaben:, tabelle:, rueckseite:, rand:, unten:, abstand:)`, `klausurbogen-arbeit(..args, body)` und private `_bogen-kopf`, `_bogen-namenszeile`, `_bogen-kopfbox`, `_bogen-kopfhoehe`, `_notentabelle`, `_note-anzeige`, `_punktetabelle`.
- Formal also 0.0.4→0.0.5: **entfernt** `bogen-seiten`, `klausurbogen-arbeit`, `vordruck`, `namen` und alle `_bogen-*`; **neu** `muster`, `linienabstand`, `korrekturrand`.
- Dazu passend: klassenarbeit 0.3.1 (`bogen: false`, importiert klausurboegen 0.0.4) ↔ klassenarbeit 0.3.2/0.4.0 (kein `bogen`, importiert 0.0.5). Die Funktionen „Klassenarbeit auf Bogen drucken" und „liniert/Korrekturrand" existieren nie in derselben Version.
- Vorgabe von `korrekturrand` wurde innerhalb von 0.0.5 gedreht (`3cd178c` „innen (Standard)" → `197ea96` „standardmäßig wieder außen").
- Signatur 0.0.5 (`klausurboegen/0.0.5/klausurboegen.typ:37`): `klausurbögen(exam: "", subexam: "", teacher: "SLZ", class: "PH1", date: "09.10.2023", students: (), sek1: false, result: false, rand: 5cm, scale: 1, sub: false, numbering: "a)", mv: (dx: 0cm, dy: 0cm), weißer-rand: true, result-table: true, vorschlag: false, line-stroke: 1pt + rgb("FF0613"), muster: "kariert", linienabstand: 8mm, korrekturrand: "aussen")` – persönliche Vorgabewerte (`"SLZ"`, `"PH1"`, `"09.10.2023"`), `exam`/`subexam` hier vs. `title`/`subtitle` in klassenarbeit.

### 2.5 patterns 0.0.1 → 0.0.2

- `kariert(...)` + `content: []`.
- `liniert(...)`: **umbenannt** `lineheight: 1cm → line-height: 1cm`; neu `items: ()`, `items-spacing: 1`.
- Neu öffentlich: `flex-feld(hoehe, zeichne)`, `ist-flex-feld(inhalt)` (für `rows: 1fr`, Commit `d1af5b0`; deutsche Parameternamen neben `rows`, `width`, `grid-size`, `line-stroke`, `fill-color`).
- Signaturen 0.0.2: `kariert(rows: 1, width: auto, items: (), items-spacing: 2, grid-size: 0.5cm, height: none, annotations: (), line-stroke: …, fill-color: white, content: [], ..args)`, `liniert(rows: 1, width: auto, items: (), items-spacing: 1, line-height: 1cm, line-stroke: …, ..args)`.
- klausurboegen 0.0.5 nutzt weiterhin patterns **0.0.1**.

### 2.6 Ist 0.4.0 „fertig" oder Baustelle?

**Funktional lauffähig, als Release aber Baustelle:**

- Tests grün; 17 der 19 Tests pinnen arbeitsblatt 0.4.0 / klassenarbeit 0.4.0 / aufgaben 0.3.1 (12 davon arbeitsblatt/klassenarbeit 0.4.0).
- 0.4.0 ist eine reine Feature-Version (Themes) – **keinerlei Namensvereinheitlichung** begonnen; sie führt im Gegenteil ein neues Mischpaar ein (`theme` en / `akzent` de; Theme-Namen und Theme-Schlüssel deutsch: `klar, atlas, skizze, labor, kontur, leiste, riso, bauhaus`, `kopf, fuss, hintergrund, rand, schrift`).
- Wird seit dem 2026-10-22 weiter in place verändert (arbeitsblatt 0.4.0: 4 Commits, klassenarbeit 0.4.0: 5 Commits, zuletzt 2026-11-05) plus uncommittete Änderung in `themes.typ`.
- Handbuch nicht nachgezogen: `arbeitsblatt/0.4.0/docs/content.typ` ist byte-gleich zu 0.3.2, erwähnt `theme`/`akzent` nicht, importiert `@schule/arbeitsblatt:0.3.2`; `docs/manual.typ` hängt an `schuldocs/0.1.0` und `@schule/aufgaben:0.3.0`. Es gibt **kein `docs/docs.typ`** → `build.sh` überspringt arbeitsblatt 0.3.1, 0.3.2 und 0.4.0; die Website zeigt für arbeitsblatt als neueste Version 0.3.0. Themes sind nur in `arbeitsblatt/0.4.0/README.md` beschrieben.
- `klassenarbeit/0.4.0/README.md` hat keinen Abschnitt „Neu in 0.4.0" (endet bei „Neu in 0.3.2"), nennt als Abhängigkeit `@schule/aufgaben:0.3.0` (tatsächlich 0.3.1 über arbeitsblatt) und verweist auf ein nicht vorhandenes `docs/klassenarbeit-manual.pdf`. `docs/content.typ` erwähnt `theme` nicht.
- Kein CHANGELOG in irgendeinem Kernpaket (nur typstage hat `CHANGELOG.md`). READMEs von aufgaben 0.3.0/0.3.1, klausurboegen 0.0.5, patterns 0.0.2, arbeitsblatt 0.3.2 sind leer. „Neu in …"-Hinweise stehen verstreut in Handbuchtexten (`arbeitsblatt/0.4.0/docs/content.typ:54`, `:114`) und Doc-Kommentaren (`klassenarbeit.typ:381`).
- aufgaben steht auf 0.3.1, obwohl es zusammen mit 0.4.0 ausgeliefert wurde (Theme-Hooks) – die 2026-06 hergestellte gemeinsame Minor-Linie ist damit wieder gebrochen.

---

## 3. Abhängigkeitsgraph der jeweils neuesten Versionen

Nur Quellcode (ohne docs/, template/, examples/, showcase/).

```
klassenarbeit 0.4.0
 ├─ @schule/arbeitsblatt:0.4.0   (import *)
 └─ @schule/klausurboegen:0.0.5  (lokal in Funktion: klausurbögen)

arbeitsblatt 0.4.0   (alles per `import *` weitergereicht, außer wo vermerkt)
 ├─ @schule/aufgaben:0.3.1
 ├─ @schule/random:0.0.1
 ├─ @schule/insert-a-word:0.0.3      → random 0.0.1
 ├─ @schule/energy-sketch:0.0.2      (neueste: 0.0.3)   → @preview/cetz:0.3.1
 ├─ @schule/patterns:0.0.2           → @preview/cetz:0.4.2
 ├─ @schule/mathematik:0.0.2         (nur geogebra-algebra, geogebra-cell, graphen, kreisdiagramm, steckbrief)
 ├─ @schule/informatik:0.0.2         → @preview/blockst:0.1.0, cetz 0.4.2, cetz-plot 0.1.3
 ├─ @schule/physik:0.0.2             (Auswahlliste)
 ├─ @schule/operatoren:0.0.1         (operator, operatoren-liste) → @preview/tablex:0.0.9
 └─ @preview: eqalc 0.1.3, zero 0.5.0, fontawesome 0.6.0, zebra 0.1.0, cetz 0.4.2,
              cetz-plot 0.1.3, codly 1.3.0, colorful-boxes 1.4.3, gentle-clues 1.2.0 (as _gc), unify 0.8.1

aufgaben 0.3.1        → @preview/fontawesome:0.6.0, gentle-clues:1.2.0   (kein @schule-Import)
klausurboegen 0.0.5   → @schule/patterns:0.0.1, @preview/tablex:0.0.9
mathematik 0.0.2      → @schule/random:0.0.1, @schule/physik:0.0.2 (umrechnungseinheit),
                        @schule/aufgaben:0.1.2 (lokal in teilaufgaben(), Z. 39),
                        @preview: cetz 0.4.2, cetz-plot 0.1.3, eqalc 0.1.3, zero 0.5.0, fancy-units 0.1.1
physik 0.0.2          → @schule/random:0.0.1, @preview: zap 0.4.0, fancy-units 0.1.1, zero 0.5.0, tablex 0.0.9
informatik 0.0.2      → @preview/blockst:0.1.0 (Doc-Kommentar nennt „@schule/blockst:0.0.1")
gutachten 0.0.2       → @schule/klausurboegen:0.0.2, @preview/tablex:0.0.5, unify 0.7.0
messwerttabellen 0.0.1→ @schule/random:0.0.1, @preview: unify 0.7.0, zero 0.5.0, tablex 0.0.9
insert-a-word 0.0.3   → @schule/random:0.0.1
energy-sketch 0.0.3   → @preview/cetz:0.5.2
abbozza 0.0.1         → @preview/cetz:0.3.4
eduki 0.1.0           → @preview/shadowed:0.2.0
schuldocs 0.3.0       → @preview/tidy:0.4.2
ohne Importe: angela, flashcards, options, random, summify, typlace, typopst
```

### 3.1 Veraltete Pins

| Wer | Pin | Neueste | Folge |
|---|---|---|---|
| mathematik 0.0.2 (`mathematik.typ:39`) | aufgaben **0.1.2** | 0.3.1 | Zweite aufgaben-Instanz mit eigenem State; deshalb definiert arbeitsblatt seit 0.3.2 `teilaufgaben`/`tasks` selbst noch einmal (`arbeitsblatt.typ:1228`, `:1263`) |
| klausurboegen 0.0.5 (`klausurboegen.typ:1`) | patterns **0.0.1** | 0.0.2 | zwei patterns-Versionen in einer Klassenarbeit; `liniert` dort noch mit `lineheight` |
| gutachten 0.0.2 (`bewertung.typ:2`) | klausurboegen **0.0.2** | 0.0.5 | dazu tablex 0.0.5, unify 0.7.0 |
| arbeitsblatt 0.4.0 (`arbeitsblatt.typ:4`) | energy-sketch **0.0.2** | 0.0.3 | 0.0.3 (cetz 0.5.2) wird von niemandem genutzt |
| informatik 0.0.2 (`lib.typ:5`) | @preview/blockst **0.1.0** | 0.4.1 (Universe und lokal) | |
| klassenarbeit 0.3.2 | arbeitsblatt **0.3.0** | (damals 0.3.2) | 0.3.2-KAs haben nie `lsg`, `zweifach` usw. bekommen |
| arbeitsblatt 0.4.0 Doku | arbeitsblatt 0.3.2, aufgaben 0.3.0, schuldocs 0.1.0 | | Handbuch baut nicht |
| aufgaben 0.3.1 Doku, klassenarbeit 0.4.0 Doku/README | aufgaben 0.3.0 | 0.3.1 | |
| tests/ | 1× arbeitsblatt 0.3.2 | | `tests/patterns-fr.typ` (wohl absichtlich: prüft den Rückport nach 0.3.x) |

Externe Pakete, bei denen Universe weiter ist (Index vom 2026-11-14): cetz 0.4.2 → 0.5.3, cetz-plot 0.1.3 → 0.1.4, codly 1.3.0 → 2.0.0, eqalc 0.1.3 → 0.1.4, fontawesome 0.6.0 → 0.6.2, gentle-clues 1.2.0 → 1.3.1, zero 0.5.0 → 0.7.1, zap 0.4.0 → 0.6.0, shadowed 0.2.0 → 0.4.0. tablex 0.0.9 ist die letzte Version (abgelöst durch die eingebaute `table`), wird noch in klausurboegen, physik, operatoren, messwerttabellen, gutachten verwendet.

Uneinheitliche Doppel-Bibliotheken: Einheiten über **unify 0.8.1** (arbeitsblatt, mit Wrappern `qty/num/unit` „mit Rückwärtskompatibilität zu fancy-units") **und fancy-units 0.1.1** (physik, mathematik) **und unify 0.7.0** (gutachten, messwerttabellen). cetz in vier Versionen (0.3.1, 0.3.4, 0.4.2, 0.5.2).

### 3.2 Zyklen

Im Graph der neuesten Versionen **kein Zyklus**. Die Treffer `@schule/arbeitsblatt:0.4.0` in arbeitsblatt selbst, `@schule/aufgaben:0.3.0` in schuldocs und `@schule/schuldocs:0.3.0` in schuldocs stehen in Doc-Kommentaren bzw. Bündel-Vorlagen. Heikel ist nur die Raute: klassenarbeit → arbeitsblatt → {aufgaben 0.3.1, mathematik → aufgaben 0.1.2} und klassenarbeit → {arbeitsblatt → patterns 0.0.2, klausurboegen → patterns 0.0.1}.

Wichtig für die Umbenennung: `klassenarbeit` reicht per `#import "@schule/arbeitsblatt:0.4.0": *` und `..args` **alles** aus arbeitsblatt und aufgaben durch; `arbeitsblatt` reicht per `import *` aufgaben, random, insert-a-word, energy-sketch, patterns, informatik, eqalc, zero, fontawesome, cetz, cetz-plot, codly, colorful-boxes durch. Jeder öffentliche Name dieser Pakete ist damit faktisch Teil der arbeitsblatt-API; Namenskollisionen werden still überdeckt (z. B. die 15 Kasten-Wrapper über gentle-clues, `canvas` über cetz, `qty/num/unit`).

### 3.3 Doppelte / tote Pakete

- **messwerttabellen 0.0.1 vs. physik 0.0.2**: gleiche öffentliche Namen `datensatz`, `messdaten`, `multiplikatoren`, `umrechnungseinheit`, `count_decimal_places`, `berechnung`, `p_messwerttabelle`, `messwerttabelle`, `lineare_regression` – physik ist die Weiterentwicklung (Commit `1bea707` „Updates existing modules to import from physik instead of messwerttabellen"). messwerttabellen wird nur noch von arbeitsblatt 0.1.7–0.2.2 importiert, hat keine Doku → Altlast. Signaturen sind auseinandergelaufen (`messwerttabelle(datensatze, max_wert_pro_tabelle, …)` vs. `messwerttabelle(..args, amount: auto, …)`; `berechnung(…, datensatz, …)` vs. `(…, datensaetze, …, max-digits:)`).
- **options 0.0.5 / typopst 0.0.1**: nur von arbeitsblatt ≤ 0.1.9 bzw. aufgaben ≤ 0.0.4 genutzt → tot.
- **teilaufgaben/tasks** doppelt in mathematik 0.0.2 und arbeitsblatt ≥ 0.3.2 (gleiche Signatur).
- **blockst**: lokal `@schule/blockst` 0.0.1–0.4.1 (ab 0.3.0 Submodule) und Universe `@preview/blockst`; informatik nutzt Universe 0.1.0.
- **typstage-geogebra**: am 2026-09-12 entfernt („in typstage aufgegangen"), liegt lokal noch untracked herum.
- **klausurboegen 0.0.4 / klassenarbeit 0.3.1**: Seitenast (siehe 2.4), in 0.0.5/0.3.2/0.4.0 nicht eingeflossen.
- Remote-Zweige ohne Bezug zu main: `origin/Typst-sync`, `origin/arbeitsblatt-0.3.1`, `origin/docs/schuldocs-0.2.0`, `origin/struktur/submodule`.

---

## 4. Regeln für neue Versionen, Universe-Status

### 4.1 Regeln (README.md „Versionen", `.github/scripts/versionen-pruefen.py`, `.github/workflows/versionen.yml`)

1. Aufbau `<paket>/<version>/typst.toml`; **Ordnername = Version in typst.toml** (Regel 1, wird immer geprüft).
2. **„Eine veröffentlichte Version ist eingefroren."** Was auf Typst Universe steht (maßgeblich `https://packages.typst.org/preview/index.json`), darf nicht mehr geändert werden, auch kein Submodul-Zeiger (Regel 2, geprüft bei PR/Push gegen den Basis-Stand; ist der Index nicht erreichbar, schlägt die Prüfung fehl).
3. README wörtlich: „Pakete, die nur hier im Namensraum `@schule` leben, sind nie auf Universe; für sie gilt Regel 2 nicht, und eine neue Version ist dort eine Frage der Ordnung, nicht der Pflicht."
4. Website: gebaut wird jeder Versionsordner mit `docs/docs.typ` (schuldocs 0.3.0, Typst 0.15.0 festgenagelt); `<paket>/` leitet auf die neueste Version mit Doku weiter; Ordner mit nur `docs/web.typ` werden übersprungen.
5. Tests: `bash tests/run.sh` bei jedem PR/Push (`tests.yml`), Kopfkommentare `// erwartet:`, `// nicht:`, `// fehler:`.

### 4.2 `neue-version.sh <paket> <version>`

- Verlangt `x.y.z`, Paketordner vorhanden, Zielordner nicht vorhanden, **neue Version > bisher höchste** (`sort -V`).
- Vorlage ist immer die **höchste** vorhandene Version (also klausurboegen 0.0.5, nicht 0.0.4).
- Kopiert den Ordner komplett (inkl. Streudateien wie `aufgaben.typ.orig`, `.DS_Store`), setzt die Version in `typst.toml`, stellt **nur Importe des eigenen Pakets** (`@schule/<paket>:<alt>`) in allen `.typ` um, löscht `docs/build` und `docs/web.html`.
- Stellt **nicht** um: Pins auf andere @schule-Pakete (arbeitsblatt→aufgaben, klassenarbeit→arbeitsblatt …), Versionsnummern in README.md, `.py`/`.sh` (z. B. `showcase/showcase.py`), relative Pfade (`../../../schuldocs/0.1.0/lib.typ`), Tests.
- Für Submodule (typstage, blockst): neues Submodul unter neuer Nummer.
- Es gibt kein Skript, das mehrere Pakete gemeinsam anhebt und die Querverweise nachzieht – für eine gemeinsame Linie fehlt genau das.

### 4.3 Was steht auf Universe (Index abgerufen 2026-11-14, 5217 Einträge)

| Paket | Universe-Versionen | lokal |
|---|---|---|
| **blockst** | 0.1.0, 0.2.0, 0.2.1, 0.3.0, 0.4.0, 0.4.1 | 0.0.1, 0.0.2, 0.3.0, 0.4.0, 0.4.1 (ab 0.3.0 Submodule; 0.3.0/0.4.0/0.4.1 eingefroren) |
| **typstage** | 0.1.0, 0.1.1, 0.1.2, 0.2.0 | 0.1.1, 0.1.2, 0.2.0 (alle Submodule, alle eingefroren) |
| alle anderen (abbozza, angela, arbeitsblatt, aufgaben, eduki, energy-sketch, flashcards, gutachten, informatik, insert-a-word, klassenarbeit, klausurboegen, mathematik, messwerttabellen, operatoren, options, patterns, physik, random, schuldocs, summify, typlace, typopst, typstage-geogebra, brainroot) | **nicht auf Universe**; die Namen sind dort alle noch frei | |

Folge: Für arbeitsblatt, klassenarbeit, aufgaben, klausurboegen, patterns, mathematik, physik, informatik gilt Regel 2 formal nicht – und sie wird auch nicht gelebt: aufgaben 0.1.2 hat 49 Commits, mathematik 0.0.2 hat 48, klassenarbeit 0.1.2 hat 29, physik 0.0.2 hat 28; aufgaben 0.3.0 wurde zuletzt am 2026-11-03 geändert, klausurboegen 0.0.5 hat am 2026-11-05 eine andere Vorgabe bekommen. Gleichzeitig pinnen echte Unterrichtsdokumente diese Nummern (`0cdcf95`: „die Klassenarbeiten der 5a importieren klassenarbeit:0.3.1"). Eine Umbenennung in einer bestehenden Nummer würde also alte Dokumente brechen; sie gehört zwingend in neue Ordner.

`compiler`-Angabe in typst.toml: arbeitsblatt/klassenarbeit/aufgaben-Neuversionen tragen keine einheitliche Angabe (im Repo 9× „0.15.0", 8× „0.12"/„0.12.0", 1× „0.13.1"; die drei Kernmanifeste haben gar kein `compiler`-Feld), obwohl Bundle-Export und Tests Typst ≥ 0.15 voraussetzen.

---

## 5. Versionsnummern-Lage und freie Nummern

| Paket | vorhandene Versionen | höchste | nächste freie Patch / Minor |
|---|---|---|---|
| arbeitsblatt | 0.0.1–0.0.7, 0.1.0, 0.1.1, 0.1.3–0.1.9, 0.2.0–0.2.4, 0.3.0–0.3.2, **0.4.0** | 0.4.0 | 0.4.1 / 0.5.0 |
| klassenarbeit | 0.0.1–0.0.8, 0.1.0–0.1.2, 0.3.0–0.3.2, **0.4.0** | 0.4.0 | 0.4.1 / 0.5.0 |
| aufgaben | 0.0.1–0.0.4, 0.1.0–0.1.2, 0.3.0, **0.3.1** | 0.3.1 | 0.3.2 / **0.4.0 frei** |
| klausurboegen | 0.0.1–0.0.5 | 0.0.5 | 0.0.6 / 0.1.0 … 0.4.x frei |
| patterns | 0.0.1, 0.0.2 | 0.0.2 | alles ab 0.0.3 frei |
| mathematik, physik, informatik, gutachten | 0.0.1, 0.0.2 | 0.0.2 | alles ab 0.0.3 frei |
| insert-a-word, energy-sketch | 0.0.1–0.0.3 | 0.0.3 | alles ab 0.0.4 frei |
| operatoren, random, angela, flashcards, messwerttabellen, abbozza, typopst | 0.0.1 | 0.0.1 | frei |
| options | 0.0.5 | 0.0.5 | tot |
| typlace | 0.0.1, 0.0.2 | 0.0.2 | frei |
| summify | 0.0.1–0.0.3, 0.1.0 | 0.1.0 | frei |
| eduki | 0.1.0 | 0.1.0 | frei |
| schuldocs | 0.1.0, 0.2.0, 0.3.0 | 0.3.0 | 0.3.1 / 0.4.0 (Werkzeug, eigene Linie) |
| blockst (Universe) | bis 0.4.1 | 0.4.1 | eigene Linie, **nicht einbeziehen** |
| typstage (Universe) | bis 0.2.0 | 0.2.0 | eigene Linie, **nicht einbeziehen** |

Einschränkungen:

- **0.4.0 ist für arbeitsblatt und klassenarbeit verbrannt**: existiert seit 2026-10-22, ist auf GitHub/Website, wird von 12 Tests und vermutlich schon von Dokumenten gepinnt, und verspricht ausdrücklich „Alle Befehle bleiben gleich". Die Vereinheitlichung kann dort nicht „0.4.0" heißen.
- `neue-version.sh` lässt nur Nummern oberhalb der höchsten zu → für arbeitsblatt/klassenarbeit frühestens 0.4.1.
- Wegen `sort -V` als „neueste" (Website-Weiterleitung, Skriptvorlage) muss die vereinheitlichte Version in jedem Paket die höchste sein.

Sinnvolle gemeinsame Linien (beide in allen @schule-eigenen Paketen frei):

- **0.4.1 als gemeinsame Nummer** für das Kernbündel arbeitsblatt, klassenarbeit, aufgaben, klausurboegen, patterns (und mitgezogen mathematik, physik, informatik, operatoren, insert-a-word, energy-sketch, random, sofern sie umbenannt werden). Entspricht dem Wunsch „0.4.X"; 0.4.0 bleibt als „Themes mit alten Namen" stehen, 0.4.1 ist „Themes + einheitliche Namen". Nachteile: aufgaben, klausurboegen, patterns usw. überspringen 0.4.0 (bei aufgaben/klassenarbeit wurde 0.2.x schon einmal übersprungen, Präzedenz vorhanden); ein Bruch in der Patch-Stelle ist unüblich, in 0.x aber zulässig.
- Variante: aufgaben/klausurboegen/patterns/… bekommen **0.4.0**, arbeitsblatt/klassenarbeit **0.4.1** – jede Nummer formal „die nächste", aber dann stimmen die Nummern im Bündel wieder nicht überein (genau das heutige Problem aufgaben 0.3.1 ↔ arbeitsblatt 0.4.0).
- **0.5.0 als gemeinsame Nummer** wäre die saubere Semver-Lösung für einen Bruch und ebenfalls überall frei; widerspricht aber der Vorgabe „0.4.X".

Empfehlung aus Versionssicht: **eine gemeinsame Nummer für das ganze Bündel, nämlich 0.4.1** (Patch-Stellen danach gemeinsam hochzählen: 0.4.2, …), alte Ordner unverändert lassen, und die Regel „eingefroren" ab dieser Linie auch für @schule-eigene Pakete anwenden. Für die gemeinsame Anhebung wird ein Bündel-Skript gebraucht (oder eine Erweiterung von `neue-version.sh`), das die Querverweise zwischen den Paketen, READMEs, Doku-Einstiege (`docs/docs.typ` für arbeitsblatt fehlt) und Tests mit umstellt.

Vor dem Kopieren zu klären/aufzuräumen:

1. uncommittete Änderung in `arbeitsblatt/0.4.0/src/themes.typ` committen oder verwerfen; `aufgaben/0.3.1/aufgaben.typ.orig` und lokales `typstage-geogebra/` entfernen.
2. Entscheidung, ob der Ast klausurboegen 0.0.4 / klassenarbeit 0.3.1 (`bogen:`, `bogen-seiten`, `klausurbogen-arbeit`, `vordruck`, `namen`) in die neue Linie übernommen wird.
3. mathematik → aufgaben 0.1.2 und klausurboegen → patterns 0.0.1 auf die neue Linie heben (beseitigt die doppelten Instanzen und die doppelte `teilaufgaben`).
4. messwerttabellen, options, typopst als Altlast kennzeichnen (nicht mit anheben).
5. Sprachentscheidung treffen – die Historie liefert keine (siehe 1.3).
