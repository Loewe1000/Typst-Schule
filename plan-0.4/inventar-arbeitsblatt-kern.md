# Inventar: `@schule/arbeitsblatt:0.4.0` – Kern (Entrypoint, Template, Showcase, Manifest)

Gelesene Dateien (vollständig), relativ zu `/Users/alexander/Library/Application Support/typst/packages/schule`:

| Datei | Zeilen | Rolle |
|---|---|---|
| `arbeitsblatt/0.4.0/src/arbeitsblatt.typ` | 1553 | Entrypoint (`typst.toml: entrypoint = "src/arbeitsblatt.typ"`) |
| `arbeitsblatt/0.4.0/template/ab.typ` | 19 | Template für `typst init` |
| `arbeitsblatt/0.4.0/showcase/beispiel.typ` | 80 | Beispielblatt für den Theme-Showcase |
| `arbeitsblatt/0.4.0/typst.toml` | 20 | Manifest |
| `arbeitsblatt/0.3.2/src/arbeitsblatt.typ` | 1409 | nur Vergleich (diff) |

Nicht Teil dieses Inventars (nur für Kopplungen angelesen): `src/themes.typ` (1164 Z., im Arbeitsbaum **uncommitted geändert**), `@schule/aufgaben:0.3.1`, `patterns`, `klassenarbeit:0.4.0`.

Sprach-Kürzel in den Tabellen: **de** = deutsch, **en** = englisch, **mix** = gemischt (de+en in einem Namen), **abk** = Abkürzung. Schreibweise: alle benannten Parameter sind kebab-case, sofern nicht anders vermerkt.

---

## 0. Kurzbefund

- Der Entrypoint definiert selbst **35 öffentliche Namen** (20 Funktionen/Werte + 15 Kasten-Wrapper) und reicht per `import ...: *` den kompletten Namensraum von **13 Fremdmodulen** durch (u. a. ganz `cetz`, `cetz-plot`, `codly`, `colorful-boxes`, `fontawesome`, `zero`, `eqalc`, `gentle-clues` via aufgaben).
- Typst kennt keine privaten Namen: auch alle `_`-Namen (`_state_ab_scope`, `_papier-masse`, `_kasten`, …) sind über `import "@schule/arbeitsblatt:0.4.0": *` sichtbar. `klassenarbeit/0.4.0/src/klassenarbeit.typ:319` nutzt `_state_ab_scope` tatsächlich paketübergreifend.
- Hauptsignatur `arbeitsblatt(...)`: **16 englische** Parameter (`title`, `class`, `paper`, `print`, `duplex`, `workspaces`, `theme`, `font-size`, `font`, `math-font`, `title-font-size`, `figure-font-size`, `landscape`, `custom-header`, `page-settings`, `copyright`), **17 deutsche** (`akzent`, `loesungen`, `materialien`, `punkte`, `zweifach`, `varianten`, `dateiname`, `fach`, `thema`, `jahrgang`, `stufe`, `niveau`, `typ`, `stichworte`, `kerncurriculum`, `stand`, + `scope` nur in `-einzeln` ist en) und **3 gemischte** (`teilaufgabe-numbering`, `aufgaben-shortcodes`, `vorschau-alle`).
- 0.4.0 hat gegenüber 0.3.2 **nichts umbenannt**. Es kamen nur dazu: `theme`, `akzent`, `auto`-Defaults für die vier Schriftparameter, Optionsprüfung, themefähige Kästen. Alle Altnamen/Aliase sind unverändert vorhanden.

---

## 1. Manifest `typst.toml`

| Schlüssel | Wert | Anmerkung |
|---|---|---|
| `name` | `"arbeitsblatt"` | de |
| `version` | `"0.4.0"` | |
| `entrypoint` | `"src/arbeitsblatt.typ"` | |
| `authors` | `["Lukas Köhl", "Alexander Schulz"]` | |
| `description` | deutsch | |
| `license` | `"MIT"` | |
| `repository` | `https://github.com/Loewe1000/Typst-Schule` | |
| `exclude` | `["docs", "showcase"]` | |
| `keywords` | `["ab", "arbeitsblatt", "lehrer"]` | |
| `categories` | `["office", "layout", "components"]` | |
| `disciplines` | `["education", "mathematics", "physics", "computer-science"]` | |
| `[template] path` | `"template"` | |
| `[template] entrypoint` | `"ab.typ"` | Dateiname ist eine Abkürzung; klassenarbeit nutzt analog `ka.typ` |
| `[template] thumbnail` | `"thumbnail.png"` | |
| `compiler` | **fehlt** | Paket nutzt `target() == "bundle"` / `document(pfad, …)` (Typst 0.15+, `--features bundle`); keine Mindestversion deklariert |

---

## 2. Importe des Entrypoints (Zeilen 1–46)

| Z. | Import | Art | Was landet im öffentlichen Namensraum | Version aktuell? |
|---|---|---|---|---|
| 1 | `@schule/aufgaben:0.3.1` | `*` | `aufgabe`, `teilaufgabe`, `loesung`, `erwartung`, `material`, `set-options`, `reset-aufgaben`, `show-loesung`, `show-loesung-inline`, `show-offene-loesungen`, `show-loesungen`, `show-erwartungen`, `show-bewertung`, `show-material`, `show-materialien`, `get-points`, `get-punkte-anzeige`, `get-punkte-position`, `format-punkte`, alle `_state_*`, `_counter_aufgaben`, `_theme-hook`, `_zusammen`, `_loesung-kasten`, `_be-runden`, `_be-anzeige`; zusätzlich **ganz `gentle-clues:1.2.0`** und **`fontawesome:0.6.0`** (aufgaben importiert beide mit `*`) | neueste (0.3.1) |
| 2 | `@schule/random:0.0.1` | `*` | `default_seed`, `m`, `a`, `lcg`, `low_cminstd_rand`, `low_cminstd_randint`, `step_seed`, `fisher_yates_shuffle`, `rand`, `randint`, `shuffle` (alles snake_case; `m` und `a` als Ein-Buchstaben-Globals!) | einzige |
| 3 | `@schule/insert-a-word:0.0.3` | `*` | `iaword-list`, `iaword-solution`, `iaword-counter`, `iaword-uniform`, `iaword-start`, `iaword-show`, `iaword-neu`, `iaword`, `insert-a-word` | neueste |
| 4 | `@schule/energy-sketch:0.0.2` | `*` | `energy-sketch`, **`canvas`, `draw` aus cetz 0.3.1** (werden durch Z. 40 überschrieben) | **veraltet – 0.0.3 existiert** (nutzt cetz 0.5.2) |
| 5 | `@schule/patterns:0.0.2` | `*` | `flex-feld`, `ist-flex-feld`, `kariert`, `liniert` | neueste |
| 6 | `@preview/eqalc:0.1.3` | `*` | gesamtes eqalc | |
| 7 | `@preview/zero:0.5.0` | `*` | gesamtes zero inkl. `num` (wird in Z. 145 überschrieben) | |
| 8 | `@schule/mathematik:0.0.2` | selektiv | `geogebra-algebra`, `geogebra-cell`, `graphen`, `kreisdiagramm`, `steckbrief` (bewusst **ohne** `teilaufgaben`/`tasks`, siehe Z. 1208–1214) | neueste |
| 9 | `@schule/informatik:0.0.2` | `*` | `bin2dec`, `dec2bin`, `häufigkeitsanalyse`, `häufigkeitsanalyse-alt`, `caesar`, `mono`, `vigenere`, `rot13`, `text-to-blocks`, `atbash`, `hex2dec`, `dec2hex`, `ascii-table`, `blockst`, `scratch`, `set-blockst`, `blockst-run-options`, `set-scratch-run`, `scratch-run` | neueste |
| 10–36 | `@schule/physik:0.0.2` | selektiv | `berechnung`, `datensatz`, `messdaten`, `messwerttabelle`, `pk`, `lineare_regression`, `quadratische_regression`, `wurzel_regression`, `exponentielle_regression`, `polynom_regression`, `potenz_regression` (snake_case!), `schaltkreis`, `zap`, `source`, `simple-source`, `multimeter`, `lamp`, `amperemeter`, `voltmeter`, `motor`, `generator` | neueste |
| 37 | `@schule/operatoren:0.0.1` | selektiv | `operator`, `operatoren-liste` | einzige |
| 38 | `@preview/fontawesome:0.6.0` | `*` | alle `fa-*` | |
| 39 | `@preview/zebra:0.1.0` | `qrcode as qr-code-zebra` | `qr-code-zebra` (öffentlich sichtbar) | |
| 40 | `@preview/cetz:0.4.2` | `*` | `canvas`, `draw`, `matrix`, `vector`, … (`canvas` wird in Z. 1266 überschrieben) | |
| 41 | `@preview/cetz-plot:0.1.3` | `*` | `plot`, `chart`, … | |
| 42 | `@preview/codly:1.3.0` | `*` | `codly`, `codly-init`, `local`, … | |
| 43 | `@preview/colorful-boxes:1.4.3` | `*` | `stickybox`, `colorbox`, `outlinebox`, `slantedColorbox` (camelCase aus Fremdpaket) | |
| 44 | `@preview/gentle-clues:1.2.0` | `as _gc` | Modul `_gc` (sichtbar) | |
| 45 | `themes.typ` | selektiv | `themes`, `_theme-aufloesen` | lokal |
| 46 | `@preview/unify:0.8.1` | selektiv | `add-unit`, `unify-num`, `unify-qty`, `unify-unit` | |

Namenskollisionen durch die `*`-Kaskade (letzte Definition gewinnt):

| Name | Quellen (in Reihenfolge) | Gewinner |
|---|---|---|
| `canvas` | energy-sketch (cetz 0.3.1) → cetz 0.4.2 → eigene Definition Z. 1266 | eigene (`c_canvas` hält das cetz-0.4.2-Original) |
| `draw` | energy-sketch (cetz 0.3.1) → cetz 0.4.2 | cetz 0.4.2 |
| `num` | zero 0.5.0 → eigene Definition Z. 145 (unify-Wrapper) | eigene |
| `mono` | informatik Z. 314 → eigene Definition Z. 1475 (identischer Rumpf) | eigene |
| `info`, `tip`, `memo`, … (15 Stück) | gentle-clues via aufgaben → eigene Wrapper Z. 1539–1553 | eigene |
| `task`, `code` | gentle-clues via aufgaben; **kein** eigener Wrapper | gentle-clues (nicht themefähig, s. Abschnitt 8) |
| `source`, `lamp`, `motor`, `generator`, … | physik (zap-Komponenten), sehr generische englische Namen | nicht geprüft, ob spätere `*`-Importe (cetz, codly, colorful-boxes) sie überdecken – Risiko, da der physik-Import davor steht |
| `a`, `m` | random (`#let a = 48271`, `#let m = …`) | bleiben global sichtbar |

---

## 3. Öffentliche Namen des Entrypoints (eigene Definitionen)

| Z. | Name | Art | Sprache | Schreibweise |
|---|---|---|---|---|
| 102 | `qr-code` | Funktion | en | kebab |
| 121 | `qty` | Funktion | en/abk | – |
| 145 | `num` | Funktion | en/abk | – |
| 169 | `unit` | Funktion | en | – |
| 180 | `print-state` | State `state("print", false)` | en | kebab; Wortfolge `print-state` (alle anderen States: `_state_…`) |
| 268 | `arbeitsblatt-einzeln` | Funktion (Show-Rule-Kern) | de | kebab |
| 1030 | `arbeitsblatt` | Funktion (Show-Rule) | de | – |
| 1145 | `lücke` | Funktion | de | **Umlaut** im Bezeichner |
| 1176 | `loesungsmodus` | Funktion | de | **oe statt ö** |
| 1202 | `lsg` | Funktion | de/abk | – |
| 1228 | `teilaufgaben` | Funktion | de | – |
| 1263 | `tasks` | Alias `= teilaufgaben` | en | Altname bis 0.2.x |
| 1265 | `c_canvas` | Wert (cetz-`canvas`-Original) | en/abk | **snake_case**, als Hilfsname öffentlich |
| 1266 | `canvas` | Funktion (überschreibt cetz) | en | – |
| 1304 | `print-pagebreak` | Funktion | en | kebab |
| 1327 | `non-print-pagebreak` | Funktion | en | kebab, Negativ-Präfix |
| 1361 | `minipage` | Funktion | en (LaTeX-Lehnwort) | – |
| 1399 | `icon-link` | Funktion | en | kebab |
| 1419 | `qrbox` | Funktion | en | **zusammengeschrieben** (vs. `qr-code`) |
| 1475 | `mono` | Funktion | en/abk | Doppelung zu `informatik.mono` |
| 1492 | `workspace` | Funktion | en | Singular (Option heißt `workspaces`) |
| 1539–1553 | `abstract`, `info`, `question`, `memo`, `conclusion`, `tip`, `success`, `warning`, `error`, `example`, `goal`, `idea`, `experiment`, `notify`, `danger` | Funktionen (Kasten-Wrapper) | en | gentle-clues-Namen |
| 45 | `themes` | Dictionary (re-exportiert aus themes.typ) | en | – |

Technisch ebenfalls sichtbare `_`-Namen (als „privat“ gemeint): `_klartext` (50), `_unify-einheit` (61), `_to-unify-str` (65), `_named-with-default-per` (82), `_state_ab_scope` (185), `_papier-masse` (191), `_papier-groesser` (199), `_umbrueche-zaehlen` (209), `_margin-aufloesen` (232), `_varianten-vorlagen` (900), `_varianten-aufloesen` (909), `_vorschau-alle-aktiv` (928), `_kasten-titel` (1507), `_kasten-original` (1514), `_kasten` (1521), `_theme-aufloesen` (45, aus themes.typ), `_gc` (44).

Schreibweisen-Mix bei den privaten Namen: `_state_ab_scope` (snake_case) neben `_papier-masse`, `_varianten-aufloesen` (kebab); Sprache: `_to-unify-str`, `_named-with-default-per` (en) neben `_klartext`, `_unify-einheit` (de/mix).

---

## 4. Signaturen und Parameter

### 4.1 `qr-code` (Z. 102)

```typ
#let qr-code(..args, light-color: white.transparentize(100%), dark-color: black, alt: "", background: none)
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `..args` | sink (pos+named) | – | any | – | an `zebra.qrcode` durchgereicht (URL, `width`, `quiet-zone`, …) |
| `light-color` | named | `white.transparentize(100%)` | color | en | helle Felder → zebra `background-fill` |
| `dark-color` | named | `black` | color | en | dunkle Felder → zebra `fill` |
| `alt` | named | `""` | str | en | Alternativtext – **wird nicht verwendet** (nicht an zebra durchgereicht) |
| `background` | named | `none` | color, none | en | **Alias/Altname für `light-color`**; hat Vorrang, wenn gesetzt (Z. 103) |

### 4.2 `qty` (Z. 121), `num` (Z. 145), `unit` (Z. 169)

```typ
#let qty(..args)
#let num(..args)
#let unit(..args)
```

| Funktion | Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|---|
| `qty` | `..args` | sink | – | 2 Positionsargumente (str/int/float/content) + named | en | Wrapper um `unify.qty`; setzt `per: "fraction"`, wenn `per` fehlt (Z. 82–88) |
| `num` | `..args` | sink | – | 1 Positionsargument + named | en | Wrapper um `unify.num`; **kein** `per`-Default |
| `unit` | `..args` | sink | – | 1 Positionsargument + named | en | Wrapper um `unify.unit`; setzt `per: "fraction"` |

Einheiten-Normalisierung `_unify-einheit` (Z. 61–63): `°C`→`dC`, `Ω`→`Ohm`, `µ`/`μ`→`u`. In `arbeitsblatt-einzeln` wird zusätzlich `add-unit("Watt hours", "Wh", …)` registriert (Z. 343).

### 4.3 `print-state` (Z. 180)

`#let print-state = state("print", false)` – State-Schlüssel `"print"`, bool. Wird in Z. 582 gesetzt und in Z. 1306/1329 gelesen. Dieselbe Information steht zusätzlich in `_state_options` unter `"print"` (Z. 578).

### 4.4 `arbeitsblatt-einzeln` (Z. 268–305)

```typ
#let arbeitsblatt-einzeln(
  title: "", class: "", paper: "a4", print: false, duplex: true, workspaces: true,
  theme: none, akzent: auto, font-size: auto, font: auto, math-font: auto,
  title-font-size: auto, figure-font-size: 9pt, landscape: false, custom-header: none,
  teilaufgabe-numbering: "a)", page-settings: (:), loesungen: "false",
  materialien: "seiten", punkte: "keine", aufgaben-shortcodes: "teilaufgaben",
  copyright: none, zweifach: false, scope: none,
  fach: none, thema: none, jahrgang: (), stufe: none, niveau: none, typ: none,
  stichworte: (), kerncurriculum: (), stand: none,
  ..args, body,
)
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `title` | named | `""` | str, content | en | Titel in der Kopfzeile; Metadaten-Schlüssel `titel` |
| `class` | named | `""` | str, content | en | Klassen-/Kurskürzel rechts im Kopf; steuert Fachfarbe (`"MA-05"`); Metadaten-Schlüssel `klasse` |
| `paper` | named | `"a4"` | str; für `zweifach` nur `"a3"`,`"a4"`,`"a5"`,`"a6"` | en | Papierformat (an `page(paper:)`) – **nicht validiert** |
| `print` | named | `false` | bool | en | Druckfassung (feste Seitenhöhe, Heftrand) vs. Digitalfassung (endlose Seite) |
| `duplex` | named | `true` | bool | en (Lehnwort) | wechselnde Ränder `inside`/`outside`; nur mit `print: true` und ohne `landscape` |
| `workspaces` | named | `true` | bool | en, Plural | `workspace()`-Blöcke anzeigen |
| `theme` | named | `none` | `none`, `"standard"`, `"klar"`, `"atlas"`, `"skizze"`, `"labor"`, `"kontur"`, `"leiste"`, `"riso"`, `"bauhaus"`, Funktion `(akzent, class) => dict`, Dictionary | en | Gestaltung (neu in 0.4.0) |
| `akzent` | named | `auto` | `auto`, color | de | Akzentfarbe des Themes; `auto` = Fachfarbe aus `class` (neu in 0.4.0) |
| `font-size` | named | `auto` (0.3.2: `12pt`) | `auto`, length | en | Grundschriftgröße; Theme-Schlüssel `schrift.groesse`, sonst 12pt |
| `font` | named | `auto` (0.3.2: `"Myriad Pro"`) | `auto`, str, array | en | Textschrift; Theme `schrift.text`, sonst „Myriad Pro“; Fallbacks „Fira Sans“, „New Computer Modern Sans“, „DejaVu Sans“ werden angehängt |
| `math-font` | named | `auto` (0.3.2: `"Fira Math"`) | `auto`, str, array | en | Formelschrift; Theme `schrift.mathe`, sonst „Fira Math“ |
| `title-font-size` | named | `auto` (0.3.2: `16pt`) | `auto`, length | en | Titelgröße; Theme `schrift.titel`, sonst 16pt |
| `figure-font-size` | named | `9pt` | length | en | Beschriftungsgröße – **kein `auto`, kein Theme-Schlüssel** |
| `landscape` | named | `false` | bool | en | Querformat (→ `page(flipped:)`) |
| `custom-header` | named | `none` | content, none | en | ersetzt Kopfzeile komplett |
| `teilaufgabe-numbering` | named | `"a)"` | `"a)"`, `"1."` | **mix** (de+en), Singular | Nummerierung der Teilaufgaben; an `_state_options` |
| `page-settings` | named | `(:)` | dictionary | en | Zusatzargumente für `set page`; `margin` wird gesondert behandelt |
| `loesungen` | named | **`"false"`** (String!) | `"keine"`, `"false"`, `false`, `none`, `"sofort"`, `"folgend"`, `"seite"`, `"seiten"`, `"nur"`, `"reinquetschen"` | de, **oe statt ö**, Plural | Lösungsmodus |
| `materialien` | named | `"seiten"` | `"keine"`, `"false"`, `false`, `none`, `"sofort"`, `"folgend"`, `"seite"`, `"seiten"`, `"reinquetschen"` | de, Plural | Materialmodus |
| `punkte` | named | `"keine"` | `"keine"`, `"aufgaben"`, `"teilaufgaben"`, `"alle"`, `"keine-summe"` **oder** Dictionary `(anzeige: …, position: "ende"\|"rand")` | de | Punkteanzeige |
| `aufgaben-shortcodes` | named | `"teilaufgaben"` | `"keine"`, `"aufgaben"`, `"teilaufgaben"`, `"alle"` | **mix** (de+en) | `= Überschrift` → `aufgabe`, `+ Punkt` → `teilaufgabe` |
| `copyright` | named | `none` | str (URL), none | en | URL für QR-Code in der Kopfzeile (Name sagt „Copyright“, erwartet wird eine URL) |
| `zweifach` | named | `false` | bool | de | jede Seite doppelt auf Bogen der nächsten Größe; braucht `print: true` (nicht geprüft) |
| `scope` | named | `none` | str, none | en | Bundle-Kennung der Variante; setzt `_state_ab_scope`, Marker-Labels |
| `fach` | named | `none` | str, none | de | Metadatum |
| `thema` | named | `none` | str, none | de | Metadatum (Pfad in Materialbibliothek) |
| `jahrgang` | named | `()` | array of int | de, Singular trotz Liste | Metadatum |
| `stufe` | named | `none` | `"sek-1"`, `"sek-2"`, none | de | Metadatum, nicht validiert |
| `niveau` | named | `none` | `"einfuehrung"`, `"vertiefung"`, `"ea"`, `"ga"`, none | de (ue statt ü im Wert) | Metadatum, nicht validiert |
| `typ` | named | `none` | z. B. `"arbeitsblatt"`, `"uebung"`, `"stationsarbeit"`, `"klausur"` | de | Metadatum, nicht validiert |
| `stichworte` | named | `()` | array of str | de, Plural | Metadatum |
| `kerncurriculum` | named | `()` | array | de, Singular trotz Liste | Metadatum |
| `stand` | named | `none` | str `"JJJJ-MM-TT"`, none | de | Metadatum |
| `..args` | sink | – | nur `header-ascent` (named) erlaubt | en | alles andere → assert (Z. 322–326). **Positionale Überschüsse werden nicht geprüft** |
| `body` | positional | – | content | en | Dokumentinhalt |

Innere Hilfsfunktion `header(title: none, class: none, font-size: 16pt, copyright: none)` (Z. 434) – en.

### 4.5 `arbeitsblatt` (Z. 1030–1069)

Identisch zu `arbeitsblatt-einzeln`, jedoch **ohne `scope`** und **zusätzlich**:

```typ
#let arbeitsblatt(
  title: "", class: "", paper: "a4", print: false, duplex: true, workspaces: true,
  theme: none, akzent: auto, font-size: auto, font: auto, math-font: auto,
  title-font-size: auto, figure-font-size: 9pt, landscape: false, custom-header: none,
  teilaufgabe-numbering: "a)", page-settings: (:), loesungen: "false",
  materialien: "seiten", punkte: "keine", aufgaben-shortcodes: "teilaufgaben",
  copyright: none, zweifach: false,
  varianten: auto, vorschau-alle: true, dateiname: none,
  fach: none, thema: none, jahrgang: (), stufe: none, niveau: none, typ: none,
  stichworte: (), kerncurriculum: (), stand: none,
  ..args, body,
)
```

| Parameter (nur die zusätzlichen) | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `varianten` | named | `auto` | `auto` → `("digital", "loesung")`; str; array of str; dictionary `(name: overrides)` | de | Bundle-Varianten; vordefiniert `druck`, `digital`, `loesung`, `zweifach` |
| `vorschau-alle` | named | `true` | bool | de | bei sys-Input `vorschau=alle` alle Varianten hintereinander |
| `dateiname` | named | `none` | str, none | de | Präfix der Bundle-Ausgabedateien (`<dateiname>-<variante>.pdf`) |

Die doppelte Parameterliste (Z. 268–304 und Z. 1030–1068) plus das `basis`-Dictionary (Z. 1070–1103) ist **dreifach gepflegte Redundanz**: jeder neue Parameter muss an drei Stellen eingetragen werden.

### 4.6 `lücke` (Z. 1145)

```typ
#let lücke(body, tight: false)
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `body` | positional | – | content | en | bestimmt die Breite, wird versteckt |
| `tight` | named | `false` | bool | en | ohne 2em Einzug |

Zeigt die Lösung **nie** an (auch nicht im Lösungsmodus) – anders als `lsg`.

### 4.7 `loesungsmodus` (Z. 1176)

```typ
#let loesungsmodus()
```

Keine Parameter. Liefert bool; braucht `context`. Positivliste: `"sofort"`, `"folgend"`, `"seite"`, `"seiten"`, `"nur"`, `"reinquetschen"`. Liest `state("options", (:))` direkt statt `_state_options`.

### 4.8 `lsg` (Z. 1202)

```typ
#let lsg(body, platz: true, sonst: none)
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `body` | positional | – | content | en | Lösungsinhalt an Ort und Stelle |
| `platz` | named | `true` | bool | de | Platz im Schülerblatt freihalten (`hide`) |
| `sonst` | named | `none` | content, none | de | Ersatzinhalt im Schülerblatt |

### 4.9 `teilaufgaben` (Z. 1228) / Alias `tasks` (Z. 1263)

```typ
#let teilaufgaben(tasks: (), columns: auto, numbering: "a)", gutter: 1.25em, loesungen: (), ..args)
#let tasks = teilaufgaben
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `tasks` | named | `()` | array of content | en | Aufgaben; **gleicher Name wie der Funktions-Alias `tasks`** |
| `columns` | named | `auto` | `auto`, int | en | Spaltenzahl (`auto` = Anzahl Aufgaben) |
| `numbering` | named | `"a)"` | str; `"a)"` = echte Teilaufgaben, sonst schlichte Nummerierung | en | Schema – hier `numbering`, in `arbeitsblatt` `teilaufgabe-numbering` |
| `gutter` | named | `1.25em` | length | en | Zellabstand (Spalten und Zeilen) |
| `loesungen` | named | `()` | array of content | de | Lösungen in Aufgabenreihenfolge – **gleicher Name wie der Modus-Parameter `loesungen` (String) in `arbeitsblatt`**, anderer Typ |
| `..args` | sink | – | 1. Positionsargument = Enum-Body (wenn `tasks` leer); named → `table()` | – | |

### 4.10 `c_canvas` / `canvas` (Z. 1265–1266)

```typ
#let c_canvas = canvas
#let canvas(..args, body)
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `..args` | sink | – | an cetz `canvas` | – | `length`, `padding`, … |
| `body` | positional | – | cetz-Zeichnung | en | bekommt vorab `set-style(axes: …)` (Ticks, Gitter, Pfeilspitze, Achsenlabels) |

### 4.11 `print-pagebreak` (Z. 1304), `non-print-pagebreak` (Z. 1327)

```typ
#let print-pagebreak(loesungen-only: false)
#let non-print-pagebreak(loesungen-only: false)
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `loesungen-only` | named | `false` | bool | **mix** (de+en) | Umbruch nur bei `loesungen == "nur"` (nicht: „in jeder Lösungsfassung“) |

### 4.12 `minipage` (Z. 1361)

```typ
#let minipage(columns: auto, align: horizon, spacing: 5mm, ..args)
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `columns` | named | `auto` | `auto`, array (Breiten), int | en | Spalten; `auto` = gleichmäßig |
| `align` | named | `horizon` | alignment | en | Ausrichtung |
| `spacing` | named | `5mm` | length | en | Spaltenabstand – heißt in `teilaufgaben` **`gutter`** (dort 1.25em) |
| `..args` | sink | – | positional = Spalteninhalte; named → `table()` | – | |

### 4.13 `icon-link` (Z. 1399)

```typ
#let icon-link(url, name, icon: emoji.chain, color: blue)
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `url` | positional | – | str | en | Ziel |
| `name` | positional | – | str, content | en | Linktext |
| `icon` | named | `emoji.chain` | content | en | Icon |
| `color` | named | `blue` | color | en | Textfarbe (Themes/`akzent` nennen Farben `farbe`/`akzent`) |

### 4.14 `qrbox` (Z. 1419)

```typ
#let qrbox(url, name, width: 3cm, ..args)
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `url` | positional | – | str | en | QR-Inhalt und Link |
| `name` | positional | – | str, content | en | Linktext |
| `width` | named | `3cm` | length | en | Boxbreite |
| `..args` | sink | – | named → `stickybox` (colorful-boxes) | – | |

### 4.15 `mono` (Z. 1475)

```typ
#let mono(body) = text(font: "SF Mono", body)
```

`body` positional, content. Schrift „SF Mono“ fest verdrahtet (nur macOS).

### 4.16 `workspace` (Z. 1492)

```typ
#let workspace(height: 5cm, body)
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `height` | named | `5cm` | length | en | **toter Parameter** – wird im Rumpf nicht verwendet |
| `body` | positional | – | content | en | nur ausgegeben, wenn Option `workspaces` wahr |

### 4.17 Kasten-Wrapper (Z. 1539–1553)

```typ
#let abstract(..args) = _kasten("abstract", ..args)
// ebenso: info, question, memo, conclusion, tip, success, warning, error,
//         example, goal, idea, experiment, notify, danger
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `..args` | sink | – | 1 Positionsargument (Inhalt) + gentle-clues-Named | – | ohne Theme-Hook `kasten` 1:1 an gentle-clues |

Von `_kasten` (Z. 1521–1538) ausgewertete gentle-clues-Argumente, wenn ein Theme zeichnet – alle anderen (z. B. `icon`, `header-color`, `border-color`, `body-color`, `stroke-width`) werden **stillschweigend verworfen**:

| gentle-clues-Argument (en) | Default | → Hook-Argument (Theme) | Sprache dort |
|---|---|---|---|
| `title` | `_kasten-titel.at(art)` | `titel` | de |
| `headless` | `false` | `titel: none` | – |
| `accent-color` | `auto` | `farbe` | de |
| `breakable` | `false` | `breakable` | en |
| `width` | `auto` | `width` | en |
| (Art) | – | `art` | de |
| 1. Positionsargument | `[]` | positional | – |

Deutsche Standardtitel `_kasten-titel` (Z. 1507–1513): `abstract`→„Einführung“, `info`→„Info“, `question`→„Frage“, `memo`→„Merke“, `task`→„Aufgabe“, `conclusion`→„Zusammenfassung“, `tip`→„Tipp“, `success`→„Erledigt“, `warning`→„Achtung“, `error`→„Fehler“, `example`→„Beispiel“, `goal`→„Ziel“, `idea`→„Idee“, `experiment`→„Experiment“, `notify`→„Mitteilung“, `code`→„Code“, `danger`→„Gefahr“.

---

## 5. Options-, State-, Label- und Enum-Schlüssel

### 5.1 An `@schule/aufgaben` übergebene Optionen (`set-options`, Z. 573–580)

| Schlüssel in `_state_options` | Quelle (arbeitsblatt-Parameter) | Anmerkung |
|---|---|---|
| `"loesungen"` | `loesungen` | aufgaben-Default `"keine"`, arbeitsblatt-Default `"false"` |
| `"materialien"` | `materialien` | |
| `"workspaces"` | `workspaces` | |
| `"punkte"` | `punkte` | String oder Dictionary `(anzeige:, position:)` |
| `"print"` | `print` | zusätzlich in `print-state` |
| `"teilaufgabe-numbering"` | `teilaufgabe-numbering` | |

Nicht von `arbeitsblatt` setzbar, aber in `_state_options` vorhanden (aufgaben 0.3.1, Z. 40–52): `punkte-position`, `punkte-template-aufgabe`, `punkte-template-teilaufgabe` (klassenarbeit setzt sie über `punkte-template`). `aufgaben-shortcodes` und `zweifach` landen **nicht** im State (nur Closure).

### 5.2 String-Enums

| Parameter | Werte | Wo ausgewertet |
|---|---|---|
| `loesungen` | `"keine"`, `"false"`, `false`, `none` (aus) · `"sofort"` · `"folgend"` · `"seite"` · `"seiten"` · `"nur"` · `"reinquetschen"` | Z. 312, 706, 715, 1179, 1308, 1331; aufgaben |
| `materialien` | `"keine"`, `"false"`, `false`, `none` · `"sofort"` · `"folgend"` · `"seite"` · `"seiten"` · `"reinquetschen"` | Z. 313, 711; aufgaben |
| `punkte` / `punkte.anzeige` | `"keine"`, `"aufgaben"`, `"teilaufgaben"`, `"alle"`, `"keine-summe"` | Z. 314 |
| `punkte.position` | `"ende"`, `"rand"` | Z. 316 |
| `aufgaben-shortcodes` | `"keine"`, `"aufgaben"`, `"teilaufgaben"`, `"alle"` | Z. 318, 690, 695 |
| `teilaufgabe-numbering` | `"a)"`, `"1."` | Z. 319, 391–398 |
| `theme` | `none`, `"standard"`, `"klar"`, `"atlas"`, `"skizze"`, `"labor"`, `"kontur"`, `"leiste"`, `"riso"`, `"bauhaus"` | themes.typ Z. 1138–1164 |
| `varianten`-Namen | `"druck"`, `"digital"`, `"loesung"`, `"zweifach"` (+ frei wählbare) | Z. 900–905 |
| `paper` (für zweifach) | `"a3"`, `"a4"`, `"a5"`, `"a6"` | Z. 191–199 |
| `stufe` (nur Doku) | `"sek-1"`, `"sek-2"` | nicht geprüft |
| `niveau` (nur Doku) | `"einfuehrung"`, `"vertiefung"`, `"ea"`, `"ga"` | nicht geprüft |
| `typ` (nur Doku) | `"arbeitsblatt"`, `"uebung"`, `"stationsarbeit"`, `"klausur"` | nicht geprüft |

### 5.3 Varianten-Vorlagen `_varianten-vorlagen` (Z. 900–905)

| Variante | Overrides |
|---|---|
| `druck` | `(print: true)` |
| `digital` | `(print: false)` |
| `loesung` | `(print: true, loesungen: "nur", workspaces: false)` |
| `zweifach` | `(print: true, zweifach: true)` |

Sonder-Override-Schlüssel im Varianten-Dictionary: `datei` (kompletter Ausgabepfad, Z. 1109–1110). Daneben existiert der Parameter `dateiname` (Präfix). Ausgabepfad-Schema: `<dateiname>-<variante>.pdf`; Scope-Kennung: `praefix + name` im Bundle (Z. 1114), nur `name` in der Vorschau (Z. 1125).

### 5.4 States

| State-Variable | Schlüssel | Z. | Inhalt |
|---|---|---|---|
| `print-state` | `"print"` | 180 | bool |
| `_state_ab_scope` | `"ab-scope"` | 185 | str/none |
| (anonym) | `"options"` | 1179, 1307, 1330 | direkter Zugriff per `state("options", (:))` statt `_state_options` |
| `_state_options` (aufgaben) | `"options"` | 391, 397, 1494 | Options-Dictionary |
| `_state_theme` (aufgaben) | `"ab-theme"` | 616, 1522 | aufgelöstes Theme-Dictionary |
| `_state_aufgaben`, `_state_in_loesung`, `_state_current_material_aufgabe`, `_state_current_material_index`, `_counter_aufgaben` (aufgaben) | – | 378–383, 656–662, 695, 711, 715 | werden hier gelesen |

### 5.5 Labels, Metadaten, Query-Konventionen

| Label | Z. | Inhalt |
|---|---|---|
| `<ab-meta>` | 590–602 | `metadata((titel:, klasse:, fach:, thema:, jahrgang:, stufe:, niveau:, typ:, stichworte:, kerncurriculum:, stand:))` – Abfrage `typst query '<ab-meta>' --field value` |
| `<_ab-start-{scope}>` | 608 | `metadata("arbeitsblatt-start")` |
| `<_ab-ende-{scope}>` | 894 | `metadata("arbeitsblatt-ende")` |
| `<_zweifach-oben>` | 778 | Messmarke |
| `<_zweifach-ende>` | 781 | Messmarke |

Metadaten-Schlüssel `titel`/`klasse` sind deutsch, die Parameter dazu heißen `title`/`class`.

Figure-Kinds und Referenzkürzel (Z. 376–431, 630–684): `kind: "material"` → „M{aufgabe}-{A,B,…}“; `kind: "teilaufgabe"` → „a)“ bzw. „1.1“; `kind: "aufgabe"`; `image` → Präfix „A“; `table` → Präfix „T“; Fallback-Supplement „M“ (Z. 632).

### 5.6 System-Inputs

| Input | Wert | Z. | Wirkung |
|---|---|---|---|
| `vorschau` | `"alle"` | 928 | alle Varianten in der Editor-Preview |
| `theme`, `class`, `loesungen` | frei | `showcase/beispiel.typ` 10–13 | nur im Showcase |

### 5.7 Theme-Dictionary-Schlüssel, die der Entrypoint liest

| Schlüssel | Z. | Typ / Signatur | Sprache |
|---|---|---|---|
| `schrift.text` | 332 | str/array | de |
| `schrift.mathe` | 333 | str/array | de |
| `schrift.groesse` | 334 | length | de (oe/ss-Umschrift) |
| `schrift.titel` | 335 | length | de |
| `rand.top` | 488 | length | **en** |
| `rand.bottom` | 505 | length | **en** |
| `rand.innen` | 492 | length | de |
| `rand.aussen` | 493 | length | de (ss statt ß) |
| `rand.kopf-oben` | 503 | length | de |
| `header-ascent` | 503, 545 | length | **en** |
| `footer-descent` | 553 | length/ratio | **en** |
| `kopf` | 456–460 | `(title:, class:, copyright:, font-size:) => content` | Schlüssel de, Argumente **en** |
| `fuss` | 552–553 | `(duplex:) => content` | Schlüssel de, Argument en |
| `hintergrund` | 555–557 | `(print:, oben:, rand:) => content` | Schlüssel de, Argumente **mix** |
| `setup` | 617 | Show-Funktion `body => content` | **en** |
| `kasten` | 1523–1536 | `(art:, titel:, farbe:, breakable:, width:, body) => content` | Schlüssel de, Argumente **mix** |
| (aufgaben-Hooks) `aufgabe`, `teilaufgabe`, `loesung`, `loesung-kopf`, `material-kopf` | aufgaben 0.3.1 Z. 19–27 | Signatur `aufgabe(nummer:, titel:, icons:, punkte:, large:, number:)` | mix |

---

## 6. Validierung und Fehlermeldungen

| Z. | Was | Meldung (wörtlich) | Sprache |
|---|---|---|---|
| 308–311 | `_pruefe(name, wert, erlaubt)` | `"arbeitsblatt: ungültiger Wert für `<name>`: <repr> – erlaubt: …"` | de |
| 312 | `loesungen` | s. o. | de |
| 313 | `materialien` | s. o. | de |
| 314 | `punkte` bzw. `punkte.anzeige` | s. o. | de |
| 316 | `punkte.position` | s. o. (Name `"punkte.position"`) | de |
| 318 | `aufgaben-shortcodes` | s. o. | de |
| 319 | `teilaufgabe-numbering` | s. o. | de |
| 322–326 | unbekannte Named-Args (außer `header-ascent`) | `"arbeitsblatt: unbekannte Option(en): `…` – Tippfehler?"` | de |
| 727–732 | `zweifach` mit unbekanntem `paper` | `panic("zweifach unterstützt nur a3, a4, a5, a6 – erhalten: …")` | de |
| 799–805 | zweifach-Sonde zu klein | `panic("zweifach: Der Inhalt passt nicht in die Messsonde von N Seiten …")` | de |
| 919 | `varianten` falscher Typ | `panic("varianten muss auto, ein String, ein Array oder ein Dictionary sein, erhalten: …")` | de |
| themes.typ 1155 | unbekanntes Theme | `"Unbekanntes Theme … Verfügbar: standard, …"` | de |
| themes.typ 1162 | `theme` falscher Typ | `panic("theme muss none, ein Name, eine Funktion oder ein Dictionary sein, erhalten: …")` | de |
| aufgaben 0.3.1 Z. 920 | (Kopplung) | `panic("aufgabe expects 1 or 2 positional arguments")` | **en** |

Präfix-Uneinheitlichkeit: `"arbeitsblatt: …"`, `"zweifach: …"`, `"zweifach unterstützt …"` (ohne Doppelpunkt), `"varianten muss …"`, `"theme muss …"`, `"Unbekanntes Theme …"`. Mechanismus uneinheitlich: `assert` (Optionen) vs. `panic` (Typen).

**Nicht** validiert: `paper` (außer bei `zweifach`), `print`/`duplex`/`workspaces`/`landscape`/`zweifach` (Typ), Variantennamen (ein Tippfehler wie `"lösung"` erzeugt stillschweigend eine Variante ohne Overrides, also **ohne** Lösungen/mit Basisoptionen), `zweifach: true` ohne `print: true`, `stufe`/`niveau`/`typ`, Schlüssel des `punkte`-Dictionarys, Schlüssel in `page-settings`, überzählige Positionsargumente in `..args`, Argumente der Kasten-Wrapper im Theme-Modus.

Die Prüfung sitzt nur in `arbeitsblatt-einzeln`; `arbeitsblatt` reicht `args.named()` durch (Z. 1103), sodass Varianten-Overrides mitgeprüft werden. `varianten`, `vorschau-alle`, `dateiname` als Override-Schlüssel würden als „unbekannte Option“ abgelehnt.

---

## 7. Inkonsistenzen (mit Zeile)

### 7.1 Sprache innerhalb einer Signatur

| Z. | Befund |
|---|---|
| 268–304 / 1030–1068 | `title`, `class`, `paper`, `print`, `duplex`, `workspaces`, `theme`, `font*`, `landscape`, `custom-header`, `page-settings`, `copyright`, `scope` (en) neben `akzent`, `loesungen`, `materialien`, `punkte`, `zweifach`, `varianten`, `dateiname`, `fach` … `stand` (de) |
| 284 / 1046 | `teilaufgabe-numbering` – deutsch-englisches Kompositum |
| 289 / 1051 | `aufgaben-shortcodes` – deutsch-englisches Kompositum |
| 275–276 | `theme` (en) direkt neben `akzent` (de) |
| 1055 | `vorschau-alle` (de) neben `print`, `landscape` (en) |
| 1202 | `lsg(body, platz:, sonst:)` – de-Parameter, aber `body` |
| 1228–1234 | `teilaufgaben(tasks:, columns:, numbering:, gutter:, loesungen:)` – 4× en, 1× de |
| 1304, 1327 | `print-pagebreak(loesungen-only:)` – Funktionsname en, Parameter mix |
| 1145 | `lücke(body, tight:)` – Funktionsname de, Parameter en |
| 590–602 | Metadaten `titel`/`klasse` vs. Parameter `title`/`class` |
| 456–460, 552–557, 1529–1536 | Theme-Hooks: Schlüssel `kopf`/`fuss`/`hintergrund`/`kasten` de, Argumente `title`/`class`/`font-size`/`duplex`/`print`/`breakable`/`width` en neben `oben`/`rand`/`art`/`titel`/`farbe` de |
| 488–505 | `rand.top`/`rand.bottom` (en) neben `rand.innen`/`rand.aussen`/`rand.kopf-oben` (de) im selben Dictionary |

### 7.2 Umlaute vs. Umschrift

| Z. | Befund |
|---|---|
| 1145 | `lücke` mit echtem Umlaut |
| 286, 1176, 1202, 1233, 1304 | `loesungen`, `loesungsmodus`, `loesungen-only`, Variante `loesung` mit `oe` |
| 493, 334 | Theme-Schlüssel `aussen`, `groesse` umschrieben |
| informatik (durchgereicht) | `häufigkeitsanalyse` mit Umlaut |

### 7.3 Dieselbe Sache, verschiedene Namen / derselbe Name, verschiedene Sache

| Z. | Befund |
|---|---|
| 284 vs. 1231 | Nummerierungsschema: `teilaufgabe-numbering` (arbeitsblatt) vs. `numbering` (teilaufgaben) |
| 1232 vs. 1361 | Abstand: `gutter: 1.25em` (teilaufgaben) vs. `spacing: 5mm` (minipage) – beides landet in `table(column-gutter:)`; verschiedene Einheiten und Defaults |
| 286 vs. 1233 | `loesungen` = Modus-String (arbeitsblatt) vs. `loesungen` = Array von Inhalten (teilaufgaben) |
| 1229 vs. 1263 | `tasks` ist zugleich Parametername und Funktions-Alias |
| 274 vs. 1492 | Option `workspaces` (Plural, bool) vs. Funktion `workspace` vs. `aufgabe(workspace:)`/`teilaufgabe(workspace:)` (Inhalt, in aufgaben) |
| 102 | `light-color` und `background` für dasselbe |
| 102 vs. 1419 | `qr-code` (mit Bindestrich) vs. `qrbox` (ohne) vs. Import-Alias `qr-code-zebra` |
| 276 vs. 1399 vs. 1532 | Farbe: `akzent` (arbeitsblatt), `color` (icon-link), `farbe` (Kasten-Hook), `accent-color` (gentle-clues-Argument), `light-color`/`dark-color` (qr-code) |
| 269 vs. aufgaben | `title` überall en (`arbeitsblatt(title:)`, `aufgabe(title:)`, Kasten `title:`), intern/Hooks `titel` |
| 1056 vs. 1109 | `dateiname` (Präfix-Parameter) vs. `datei` (Override-Schlüssel für den ganzen Pfad) |
| 180 vs. 578 | Druckmodus doppelt geführt: `print-state` und `_state_options.print` |
| 180 vs. 185 | State-Benennung: `print-state` vs. `_state_ab_scope` (aufgaben: `_state_options`) |
| 290 | `copyright` erwartet eine URL und erzeugt einen QR-Code |
| 1265 | `c_canvas` (snake_case, Abkürzung) als einziger eigener snake_case-Name |

### 7.4 bool vs. String vs. auto vs. none für gleichartige Schalter

| Z. | Befund |
|---|---|
| 286 / 1048 | `loesungen: "false"` – **String** `"false"` als Default; erlaubt sind zugleich `"keine"`, `"false"`, `false`, `none` (vier Schreibweisen für „aus“) |
| 287 | `materialien`: dieselben vier „aus“-Schreibweisen, Default aber `"seiten"` |
| 288 | `punkte`: „aus“ nur als `"keine"`; `false`/`none` hier **nicht** erlaubt |
| 289 | `aufgaben-shortcodes`: „aus“ nur als `"keine"` |
| 272–274, 282, 291 | `print`, `duplex`, `workspaces`, `landscape`, `zweifach` sind echte bools |
| 275 | `theme`: „aus“ als `none` **oder** `"standard"` |
| 276–280 | `akzent`, `font*`: `auto`; `figure-font-size` (281) dagegen fester Wert ohne `auto` |
| 283, 290, 292 | `custom-header`, `copyright`, `scope`: `none` |
| 288 | `punkte` ist String **oder** Dictionary |
| 1054 | `varianten`: auto / String / Array / Dictionary |

### 7.5 Singular / Plural

| Z. | Befund |
|---|---|
| 284 vs. 289 | `teilaufgabe-numbering` (Singular) vs. `aufgaben-shortcodes` (Plural) |
| 286–288 | `loesungen`, `materialien`, `punkte` (Plural) vs. Variantenname `loesung` (Singular, Z. 903) |
| 286 | Enum-Werte `"seite"` vs. `"seiten"` – zwei verschiedene Modi, die sich nur im Plural-n unterscheiden |
| 296, 301 | `jahrgang` und `kerncurriculum` sind Arrays mit Singular-Namen; `stichworte` Plural |
| 274 vs. 1492 | `workspaces` vs. `workspace` |
| 1228 vs. aufgaben | `teilaufgaben` (Raster) vs. `teilaufgabe` (einzeln) – nur ein Buchstabe Unterschied |

### 7.6 Negativ- vs. Positiv-Schalter, Wortstellung

| Z. | Befund |
|---|---|
| 1304 / 1327 | `print-pagebreak` vs. `non-print-pagebreak` (Negativ-Präfix als eigener Funktionsname statt Parameter) |
| 1304 | `loesungen-only` (nachgestelltes `-only`) |
| 1145 | `tight: false` (Positiv-Schalter) |
| 1202 | `platz: true` (Positiv, Default an) |
| gentle-clues | `headless` (Negativ) wird in `titel: none` übersetzt (Z. 1531) |

### 7.7 Positional vs. named

| Z. | Befund |
|---|---|
| 1145, 1202, 1475 | `body` positional **vorn** (`lücke(body, tight:)`, `lsg(body, …)`) |
| 268, 1030, 1266, 1492 | `body` positional **hinten** (`workspace(height:, body)`, `canvas(..args, body)`) |
| 1228 | Aufgabenliste wahlweise named (`tasks:`) **oder** als Enum-Body positional über den Sink |
| 1361 | `minipage`: Inhalte nur über Sink-Positionals |
| 1399, 1419 | `url`, `name` positional |
| aufgaben | `aufgabe(title:)` named **oder** als 1. von 2 Positionsargumenten |

### 7.8 Verschiedene Defaults für dasselbe

| Z. | Befund |
|---|---|
| 286 vs. aufgaben Z. 44 | `loesungen`-Default `"false"` (arbeitsblatt) vs. `"keine"` (aufgaben-State) vs. `"keine"` (Fallback in 1179/1307/1330) |
| 288 vs. aufgaben Z. 48 | `punkte`-Default `"keine"` (arbeitsblatt) vs. `"aufgaben"` (aufgaben-State und Fallback für `punkte.anzeige`, Z. 314) |
| 284 vs. 391, 397 | `teilaufgabe-numbering`-Default `"a)"` vs. Fallback `"1."` in der Referenzauflösung |
| 274 vs. 1495 | `workspaces`-Default `true` vs. Fallback `false` in `workspace()` |
| 543–549 vs. 743–747 | `header-ascent`: im Normalmodus args → Theme → 20 %; im Zweifach-Modus args → 20 % (**Theme wird ignoriert**) |
| 488 | oberer Rand 2.3cm (print) vs. 2.2cm (digital); Z. 556 Fallback 2.3cm |

---

## 8. Altlasten, toter Code, Fehler

| Z. | Befund |
|---|---|
| 286, 1048 | Default `loesungen: "false"` (String) – Altlast; funktioniert nur, weil `"false"` in jeder Positiv-/Negativliste mitgeführt wird |
| 102–104 | `qr-code(alt:)` wird angenommen, aber nicht an zebra weitergegeben (toter Parameter); `background` ist Altname |
| 1492 | `workspace(height:)` ohne Wirkung; Doku (Z. 1489) behauptet „wird an `body` übergeben“ |
| 1263 | `tasks`-Alias („arbeitsblatt bis 0.2.x“) |
| 1265 | `c_canvas` öffentlich |
| 1475 | `mono` doppelt (identisch in `informatik/0.0.2/lib.typ:314`) |
| 1507–1520 vs. 1539–1553 | `_kasten-titel` und `_kasten-original` enthalten `task` und `code`, es gibt aber **keine Wrapper `task`/`code`** → diese beiden Kästen bleiben auch mit Theme im gentle-clues-Stil |
| 1195 | Doku-Beispiel `#lsg(sonst: linien(2))` – eine Funktion `linien` existiert im Repo nicht (gemeint: `liniert`) |
| 1484–1486 | Doku-Beispiel `#workspace(height: 5cm)[#kariert(2)]` nutzt den toten Parameter; Kommentar „2 mm-Karos“ falsch (`2` = Zeilen) |
| 339–340 | Kommentar „Set document title and authors in metadata“ ohne Code; außerhalb des Bundles wird **kein** `set document(title:)` gesetzt (nur im Bundle, Z. 1113) |
| 429, 710, 714 | englische Restkommentare zwischen deutschen („Other references as usual.“, „To show solutions on a seperate page“ – Tippfehler) |
| 1400 | auskommentiert: `//fa-external-link(fill: blue)` |
| 944 | Doku: „seit 0.3.1“ für die Vorschau; Z. 973 „seit 0.4.0“ – Versionshinweise im Fließtext |
| 990–993 | Parameterdoku unvollständig: `loesungen` ohne `"reinquetschen"`; `materialien` ohne `"keine"`, `"folgend"`, `"seite"`; `punkte` ohne `"keine-summe"` und ohne Dictionary-Form; `varianten` ohne `"zweifach"` (Z. 998–999) |
| 1179, 1307, 1330 | `state("options", (:))` direkt statt `_state_options` (funktioniert nur über den gleichen Schlüssel-String) |
| 1308, 1331 | `loesungen-only` prüft nur `== "nur"`, nicht `loesungsmodus()` |
| 524–531, 743–747 | Zweifach-Modus: `header: none, footer: none`, kein `background` → Theme-Fußzeile und -Hintergrund entfallen; `page-settings` (außer `margin`) werden ignoriert; Theme-`header-ascent` ignoriert |
| 322 | überzählige **Positions**argumente in `..args` werden nicht gemeldet |
| 688 | `set raw(syntaxes: "processing.sublime-syntax")` – fest verdrahtete Processing-Syntax für alle Blätter |
| 343 | `add-unit("Watt hours", "Wh", …)` bei jedem `arbeitsblatt-einzeln`-Aufruf |
| 4 | `energy-sketch:0.0.2` importiert (cetz 0.3.1) obwohl 0.0.3 (cetz 0.5.2) existiert; drei cetz-Versionen im Spiel (0.3.1 via energy-sketch, 0.4.2 direkt, 0.5.2 in energy-sketch 0.0.3) |
| 46 vs. physik | arbeitsblatt nutzt `unify:0.8.1`, physik 0.0.2 intern noch `fancy-units:0.1.1` – zwei Einheiten-Bibliotheken; die Wrapper `qty`/`num`/`unit` (Z. 107–178) existieren nur als Kompatibilitätsschicht |
| 1208–1214 | `teilaufgaben` ist eine **Doppelimplementierung** von `mathematik/0.0.2/mathematik.typ:23` (dort an `aufgaben:0.1.2` gebunden laut Kommentar); mathematik hat ebenfalls `#let tasks = teilaufgaben` (Z. 61) |
| 268–304, 1030–1068, 1070–1103 | Parameterliste dreifach gepflegt |
| Repo | `aufgaben/0.3.1/aufgaben.typ.orig` untracked (Patch-Rest); `arbeitsblatt/0.4.0/src/themes.typ` uncommitted geändert; 25 Altversionen `arbeitsblatt/0.0.1 … 0.3.2` liegen daneben |
| typst.toml | kein `compiler`-Feld trotz Bundle-/`target()`-Nutzung |
| template/ab.typ 4–5 | `title: [Titel]`, `class: [Klasse]` als Content, Doku sagt `string`; Kommentar nennt Varianten ohne `zweifach` |

---

## 9. Kopplungen zu anderen `@schule`-Paketen

| Von (arbeitsblatt) | Nach | Name dort | Z. |
|---|---|---|---|
| `loesungen`, `materialien`, `workspaces`, `punkte`, `print`, `teilaufgabe-numbering` | `aufgaben:0.3.1` `set-options` → `_state_options` | gleichnamige Schlüssel | 573–580 |
| aufgelöstes Theme | `aufgaben:0.3.1` `_state_theme` (`"ab-theme"`) | Hooks `aufgabe`, `teilaufgabe`, `loesung`, `loesung-kopf`, `material-kopf` | 616 |
| – | `aufgaben.reset-aufgaben()` | | 615 |
| – | `aufgaben.show-offene-loesungen()`, `show-materialien()`, `show-loesungen()` | | 707, 712, 716 |
| `= Überschrift` (Shortcode) | `aufgaben.aufgabe(title: it.body, large: true)[]` | `title`, `large` (en) | 690–693 |
| `+ Punkt` (Shortcode) | `aufgaben.teilaufgabe(it.body)` | | 694–700 |
| `teilaufgaben` | `aufgaben.teilaufgabe()`, `aufgaben.loesung` | | 1242–1244 |
| – | `insert-a-word.iaword-neu()` | | 619 |
| `theme`, `akzent`, `class` | `themes.typ` `_theme-aufloesen(theme, akzent, class)` | positional | 330 |
| `qrbox(..args)` | `colorful-boxes.stickybox` | | 1420 |
| Kasten-Wrapper | `gentle-clues` (`_gc.*`) | `title`, `headless`, `accent-color`, `breakable`, `width` | 1514–1536 |
| `showcase/beispiel.typ:57` | `aufgabe(title:, method: "PA")` | `method` (en) in aufgaben | – |
| `showcase/beispiel.typ:63` | `workspace(kariert(4))` | `patterns.kariert(rows)` | – |

Eingehend: `klassenarbeit/0.4.0/src/klassenarbeit.typ:1` importiert `@schule/arbeitsblatt:0.4.0: *`, ruft `arbeitsblatt-einzeln.with(...)` (Z. 227), liest `_state_ab_scope` (Z. 319), baut `page-settings` um (Z. 79, 193–225) und führt eigene Parameter `varianten`, `variante`, `dateiname` (de) neben `subtitle`, `date`, `logo`, `teacher`, `student`, `name-field`, `name-repeat`, `info-table`, `page-numbering` (en) sowie `klausurboegen`, `erwartungen`, `punkte-template` (de/mix). Jede Umbenennung in `arbeitsblatt` (`title`, `class`, `page-settings`, `scope`, `_state_ab_scope`, `arbeitsblatt-einzeln`) schlägt dorthin durch.

Importierte `@schule`-Versionen: aufgaben 0.3.1 (aktuell), random 0.0.1, insert-a-word 0.0.3 (aktuell), **energy-sketch 0.0.2 (veraltet, 0.0.3 vorhanden)**, patterns 0.0.2 (aktuell), mathematik 0.0.2, informatik 0.0.2, physik 0.0.2, operatoren 0.0.1.

---

## 10. Vergleich 0.3.2 → 0.4.0

| Bereich | 0.3.2 | 0.4.0 |
|---|---|---|
| aufgaben-Import | `@schule/aufgaben:0.3.0` | `@schule/aufgaben:0.3.1` |
| neue Importe | – | `gentle-clues:1.2.0 as _gc`, `themes.typ: themes, _theme-aufloesen` |
| neue Parameter | – | `theme: none`, `akzent: auto` (beide Funktionen) |
| geänderte Defaults | `font-size: 12pt`, `font: "Myriad Pro"`, `math-font: "Fira Math"`, `title-font-size: 16pt` | alle vier `auto` (Theme-Wert, sonst alter Default) |
| `font`/`math-font` | nur String | auch Array (`_liste`) |
| Validierung | keine | `_pruefe` + Prüfung unbekannter Named-Args (Z. 306–326) |
| `loesungsmodus()` | Negativliste `not in ("keine", "false", false, none)` | Positivliste (Z. 1179) |
| Margin aus `page-settings` | nur `top` | auch `y`/`rest`; `values.remove("top")` entfernt |
| Ränder | feste Werte, `x: 1.75cm` | Theme-Schlüssel `rand.*`, `left`/`right` getrennt |
| Kopf/Fuß/Hintergrund | fest | Theme-Hooks `kopf`, `fuss`, `hintergrund`, `setup`, `header-ascent`, `footer-descent` |
| Kästen | gentle-clues direkt (über aufgaben) | Wrapper `abstract` … `danger` mit Theme-Hook `kasten` (Z. 1501–1553) |
| **umbenannt** | – | **nichts** – alle öffentlichen Namen und Parameter aus 0.3.2 sind in 0.4.0 unverändert vorhanden (`qr-code`, `qty`, `num`, `unit`, `print-state`, `arbeitsblatt-einzeln`, `arbeitsblatt`, `lücke`, `loesungsmodus`, `lsg`, `teilaufgaben`, `tasks`, `c_canvas`, `canvas`, `print-pagebreak`, `non-print-pagebreak`, `minipage`, `icon-link`, `qrbox`, `mono`, `workspace`) |

Folgerung für den Umbenennungsplan: 0.4.0 ist bisher eine reine Funktionserweiterung (Themes, Validierung). Die Vereinheitlichung der Namen steht vollständig aus; die neue Optionsprüfung (Z. 306–326) ist der natürliche Ort für Alias-/Deprecation-Meldungen.
