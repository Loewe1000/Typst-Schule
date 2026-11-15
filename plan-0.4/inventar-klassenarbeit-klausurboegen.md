# Inventar: klassenarbeit 0.4.0 und klausurboegen 0.0.5

Gelesen (vollständig): `klassenarbeit/0.4.0/src/klassenarbeit.typ` (523 Z.), `klassenarbeit/0.4.0/src/logos.typ` (6 Z.), `klassenarbeit/0.4.0/template/ka.typ` (19 Z.), `klausurboegen/0.0.5/klausurboegen.typ` (582 Z.). Verglichen mit `klassenarbeit/0.3.2` (diff) und `klausurboegen/0.0.4` (diff, Signaturen). Für die Durchreichungen nachgeschlagen: `arbeitsblatt/0.4.0/src/arbeitsblatt.typ` (Signatur `arbeitsblatt-einzeln` Z. 268-304, Validierung Z. 305-326, `_varianten-vorlagen` Z. 900-905), `arbeitsblatt/0.4.0/src/themes.typ` (`_theme-aufloesen` Z. 1151), `aufgaben/0.3.1/aufgaben.typ` (`set-options` Z. 113, `show-offene-loesungen` Z. 279, `show-erwartungen` Z. 534), `patterns/0.0.1/patterns.typ` (`kariert`, `liniert`).

Geprüft mit `typst 0.15.1` (Testdateien nur im Scratchpad, Repo unverändert). Was unten als "per Kompilieren bestätigt" markiert ist, wurde tatsächlich ausgeführt; alles andere ist aus dem Quelltext gelesen.

Sprach-Kürzel: de = deutsch, en = englisch, gem = gemischt, Abk = Abkürzung.

---

## 1. klassenarbeit 0.4.0

### 1.1 Paketdaten (`typst.toml`)

| Feld | Wert |
|---|---|
| name / version | `klassenarbeit` / `0.4.0` |
| entrypoint | `src/klassenarbeit.typ` |
| template | `template/ka.typ` |
| Importe | `@schule/arbeitsblatt:0.4.0` mit `*` (Z. 1); `@schule/klausurboegen:0.0.5` nur `klausurbögen`, lokal in `_klausurboegen-inhalt` (Z. 23); `logos.typ` lokal in `header` (Z. 140) |

### 1.2 Top-Level-Bindungen

| Zeile | Name | Art | Öffentlich gemeint? | Schreibweise |
|---|---|---|---|---|
| 3 | `_ka-counter` | `counter("klassenarbeit")` | nein (Unterstrich) | kebab, Abk `ka` |
| 8 | `_state_ka_variante` | `state("ka-variante", none)` | nein | snake_case, im State-Key aber kebab |
| 15 | `_klausurboegen-inhalt` | Funktion | nein | kebab, `oe` statt `ö` |
| 48 | `_klassenarbeit-einzeln` | Funktion | nein | kebab |
| 384 | `klassenarbeit` | Funktion (Show-Rule) | **ja, einzige eigene öffentliche Funktion** | de |

Typst kennt keine privaten Namen: `#import "@schule/klassenarbeit:0.4.0": *` liefert auch die vier Unterstrich-Namen. Zusätzlich wird durch `#import "@schule/arbeitsblatt:0.4.0": *` (Z. 1) **die gesamte Oberfläche von arbeitsblatt 0.4.0 re-exportiert**, also u. a. `arbeitsblatt`, `arbeitsblatt-einzeln`, `teilaufgaben`/`tasks`, `lücke`, `lsg`, `loesungsmodus`, `canvas`/`c_canvas`, `print-pagebreak`, `non-print-pagebreak`, `minipage`, `icon-link`, `qrbox`, `qr-code`, `mono`, `workspace`, `qty`/`num`/`unit`, `print-state`, `_state_ab_scope`, `themes`, `_theme-aufloesen`, alle Kästen (`info`, `memo`, `tip`, `warning`, `error`, ...), und transitiv alles aus `aufgaben:0.3.1`, `random`, `insert-a-word`, `energy-sketch`, `patterns:0.0.2`, `informatik`, `physik`, `mathematik` (Auswahl), `operatoren` sowie die Preview-Pakete `cetz`, `cetz-plot`, `codly`, `colorful-boxes`, `zero`, `eqalc`, `fontawesome`. Details dazu stehen im Inventar zu arbeitsblatt/aufgaben.

Von klassenarbeit selbst **benutzte** Namen aus arbeitsblatt/aufgaben: `arbeitsblatt-einzeln` (Z. 227), `_theme-aufloesen` (Z. 86, privat gemeinter Name!), `_state_ab_scope` (Z. 319, privat gemeinter Name!), `set-options` (Z. 217), `show-offene-loesungen` (Z. 305), `show-erwartungen` (Z. 327).

### 1.3 `klassenarbeit` (Z. 384-402)

Wörtliche Signatur:

```typ
#let klassenarbeit(
  subtitle: "",
  date: "",
  logo: "angela",
  teacher: "",
  student: "",
  name-field: "Name",
  name-repeat: false,
  info-table: false,
  page-numbering: true,
  klausurboegen: false,
  erwartungen: true,
  punkte-template: none,
  varianten: auto,
  variante: auto,
  dateiname: none,
  ..args,
  body,
) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `subtitle` | named | `""` | str / content | en | Untertitel im Kopf; an klausurbögen als `subexam` |
| `date` | named | `""` | str / content | en | Datum im Kopf; an klausurbögen als `date` |
| `logo` | named | `"angela"` | Schlüssel aus `logos` (nur `"angela"`), content (z. B. `image(...)`), `none` | en (Wert: Eigenname) | Logo links im Kopf. Docstring Z. 352 sagt "content", Default ist aber ein String-Schlüssel |
| `teacher` | named | `""` | str / content | en | Lehrkraft/Kürzel im Kopf; an klausurbögen als `teacher` |
| `student` | named | `""` | str / content | en | Schülername hinter dem Namensfeld |
| `name-field` | named | `"Name"` | str / content / `none` | en, kebab | Beschriftung des Namensfelds; `none` blendet es aus. Der Doppelpunkt wird automatisch angehängt (Z. 103, 275) |
| `name-repeat` | named | `false` | bool | en, kebab | Namensfeld im Seitenkopf jeder Seite wiederholen |
| `info-table` | named | `false` | `false` \| array (flach, wird in 2er-Gruppen zerlegt, oder Array aus Paaren) \| `true` (wirkungslos) | en, kebab | Infotabelle (Schlüssel/Wert) unter dem Kopf. Docstring Z. 356 sagt nur "boolean" |
| `page-numbering` | named | `true` | `true` \| `false` \| `"reset"` \| `"continuous"` | en, kebab; Werte en | Seitenzahlen "Seite x von y"; `true` = `"reset"` |
| `klausurboegen` | named | `false` | bool \| dictionary | de, `oe` | Klausurbögen aktivieren; Dictionary = Einstellungen (siehe 1.6) |
| `erwartungen` | named | `true` | bool \| dictionary | de | Erwartungshorizont; Dictionary = Einstellungen (siehe 1.7) |
| `punkte-template` | named | `none` | `none` \| function `punkte => content` \| dictionary `(aufgabe:, teilaufgabe:)` | gem (de + en), kebab | Darstellung der BE |
| `varianten` | named | `auto` | `auto` \| str \| array aus `"druck"`, `"loesung"`, `"klausurboegen"` | de | Bundle-Varianten |
| `variante` | named | `auto` | `auto` \| `"druck"` \| `"loesung"` \| `"klausurboegen"` | de | Variante außerhalb des Bundles |
| `dateiname` | named | `none` | str \| `none` | de | Basisname der Bundle-Dateien |
| `..args` | sink | - | nur named werden ausgewertet (`args.named()`); positionale Extras werden stillschweigend verworfen | en | wird an `arbeitsblatt-einzeln` gereicht (siehe 1.8) |
| `body` | positional | - | content | en | Inhalt |

Aus `..args` liest `klassenarbeit` selbst (ohne sie als Parameter zu deklarieren): `title` (Z. 412), `class` (Z. 413). Beide stehen im Docstring (Z. 348, 350) wie eigene Parameter, sind es aber nicht.

Im Docstring dokumentiert, in der Signatur **nicht vorhanden**: `table (array)` (Z. 355).

In der Signatur vorhanden, im Docstring **fehlend**: `name-field`.

### 1.4 `_klassenarbeit-einzeln` (Z. 48-65)

```typ
#let _klassenarbeit-einzeln(
  variante: "druck",
  scope: none,
  ka-id: 1,
  subtitle: "",
  date: "",
  logo: "angela",
  teacher: "",
  student: "",
  name-field: "Name",
  name-repeat: false,
  info-table: false,
  page-numbering: true,
  erwartungen: true,
  punkte-template: none,
  ..args,
  body,
) = context {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `variante` | named | `"druck"` | `"druck"` \| `"loesung"` | de | welche Fassung gerendert wird |
| `scope` | named | `none` | str \| `none`; gesetzt als `"ka-<id>-druck"` / `"ka-<id>-loesung"` (Z. 463, 474) | en | Bundle-Kennung, an `arbeitsblatt-einzeln(scope:)` |
| `ka-id` | named | `1` | int | Abk + en, kebab | laufende Nummer aus `_ka-counter` |
| `subtitle` ... `punkte-template` | named | wie 1.3 | wie 1.3 | wie 1.3 | wie 1.3 |
| `..args` | sink | - | named | en | aus `args.named()` gelesen: `page-settings` (Z. 79), `title` (Z. 80), `class` (Z. 81), `theme` (Z. 86), `akzent` (Z. 86), `font` (Z. 94), `math-font` (Z. 95); Rest an `arbeitsblatt-einzeln` |
| `body` | positional | - | content | en | Inhalt |

Lokale Hilfsfunktion `header(title: "", subtitle: "", class: "", date: "", teacher: "", logo: none)` (Z. 139): alle Namen en.

Lokale Variablen (Sprachmix in einer Funktion): `ka-label`, `table`, `page-settings`, `title`, `class`, `th`, `schrift`, `font`, `math-font`, `name-field-block`, `current-page`, `end-page`, `last-page`, `total-ka`, `last-ka-label`, `kopf-abstand`, `klassenarbeit-margin`, `final-page-settings`, `tpl-aufgabe`, `tpl-teilaufgabe`, `weitere-args`, `table-cells`, `erwartungen-einstellungen`, `erwartungen-aktiv`, `einstellungen`. Die lokale Variable `table` (Z. 76) verdeckt die eingebaute Funktion `table`; deshalb steht überall `std.table`.

### 1.5 `_klausurboegen-inhalt` (Z. 15-22)

```typ
#let _klausurboegen-inhalt(
  title: "",
  subtitle: "",
  teacher: "",
  class: "",
  date: "",
  einstellungen: (:),
) = {
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `title` | named | `""` | str / content | en | wird zu `exam` |
| `subtitle` | named | `""` | str / content | en | wird zu `subexam` |
| `teacher` | named | `""` | str / content | en | gleichnamig weiter |
| `class` | named | `""` | str / content | en | gleichnamig weiter |
| `date` | named | `""` | str / content | en | gleichnamig weiter |
| `einstellungen` | named | `(:)` | dictionary (alles andere wird zu `(:)`) | de | Rest-Einstellungen für `klausurbögen` |

### 1.6 Schlüssel im Dictionary `klausurboegen: (...)`

| Schlüssel | Verarbeitet in | Werte | Sprache | Wirkung |
|---|---|---|---|---|
| `show` | Z. 433 (Auswertung), Z. 28 (entfernt) | bool, Default `true` | en | `false` schaltet die Bögen trotz Dictionary ab |
| `ergebnisse` | Z. 26-27, 36-37 | Array aus CSV-Zeilen inkl. Kopfzeile, oder fehlend | de | wird zu `students: ergebnisse` **und** `result: true` |
| alle weiteren | Z. 38 `..parameter` | siehe `klausurbögen` (2.3) | gem | unverändert an `klausurbögen`; unbekannte Schlüssel erzeugen den Typst-Fehler "unexpected argument" (per Kompilieren bestätigt mit `weisser-rand`) |

Da `..parameter` **nach** den festen Argumenten steht, kann der Nutzer im Dictionary auch `exam`, `subexam`, `teacher`, `class`, `date`, `students`, `result` direkt setzen und damit die abgeleiteten Werte überschreiben (per Kompilieren bestätigt mit `students`). Es gibt also zwei Wege für dieselbe Sache: `ergebnisse` (de) und `students` + `result` (en).

### 1.7 Schlüssel im Dictionary `erwartungen: (...)`

| Schlüssel | Verarbeitet in | Werte | Sprache | Wirkung |
|---|---|---|---|---|
| `show` | Z. 317 | bool, Default `true` | en | `false` blendet den Horizont aus |
| `new-page` | Z. 321 | beliebig | en, kebab | wird entfernt und ignoriert (Horizont steht immer auf eigener Seite via `page({...})`, Z. 326) |
| `grouped` | an `show-erwartungen` | bool, Default `false` | en | gruppierte Darstellung |
| `erreicht` | an `show-erwartungen` | bool, Default `false` | de | Spalte "__ / X" zum Eintragen |
| `alle` | an `show-erwartungen` | bool, Default `false` | de | alle Blöcke (Reset-Marken) getrennt ausweisen |
| `teile` | an `show-erwartungen` | array, Default `()` | de | Titel der Blöcke |

Ziel-Signatur in aufgaben 0.3.1 (Z. 534): `show-erwartungen(grouped: false, new-page: false, erreicht: false, alle: false, teile: ())` - en und de gemischt in einer Signatur.

### 1.8 Was `klassenarbeit` an `arbeitsblatt-einzeln` reicht (Z. 227-246)

Fest gesetzt:

| Argument dort | Wert | Herkunft in klassenarbeit |
|---|---|---|
| `title` | `title` | aus `..args` |
| `print` | `true` | fest (Klassenarbeit ist immer Druckfassung) |
| `header-ascent` | `14pt` (`kopf-abstand`) | fest; ist in arbeitsblatt **kein deklarierter Parameter**, sondern die einzige erlaubte Ausnahme in der Prüfung unbekannter Optionen (arbeitsblatt.typ Z. 322) |
| `custom-header` | `header(...)` | aus `subtitle`, `date`, `class`, `teacher`, `logo`, `name-repeat`, `name-field`, `student` gebaut |
| `page-settings` | `final-page-settings` | `page-settings` aus `..args`, plus Standard-`margin` `(top: 1cm, bottom: 1cm, left: 1.5cm, right: 1.5cm)` und `+14pt` oben |
| `scope` | `scope` | intern |
| `loesungen` | `"nur"` | nur bei `variante == "loesung"` (überschreibt Nutzerwert) |
| `theme` | aufgelöstes Theme-Dictionary ohne `kopf`, `fuss`, `hintergrund`, `rand`, `header-ascent` | nur wenn Theme gesetzt |

Über `..weitere-args` (alle benannten Extras außer `page-settings`) gleichnamig durchgereicht - der Name in klassenarbeit **ist** der Name in arbeitsblatt, weil klassenarbeit sie gar nicht deklariert:

`title`, `class`, `paper`, `print`, `duplex`, `workspaces`, `theme`, `akzent`, `font-size`, `font`, `math-font`, `title-font-size`, `figure-font-size`, `landscape`, `custom-header`, `teilaufgabe-numbering`, `loesungen`, `materialien`, `punkte`, `aufgaben-shortcodes`, `copyright`, `zweifach`, `scope`, `fach`, `thema`, `jahrgang`, `stufe`, `niveau`, `typ`, `stichworte`, `kerncurriculum`, `stand`, `header-ascent`.

Folgen der Reihenfolge (Spread steht nach den festen Argumenten, später gewinnt):

- `print: false`, `custom-header: ...`, `header-ascent: ...`, `scope: ...` vom Nutzer **überschreiben** die festen Werte von klassenarbeit. Ein `custom-header` vom Nutzer ersetzt also still den gesamten KA-Kopf.
- Parameter, die nur `arbeitsblatt()` kennt, nicht aber `arbeitsblatt-einzeln()`, scheitern: `vorschau-alle` ergibt `arbeitsblatt: unbekannte Option(en): \`vorschau-alle\` – Tippfehler?` (per Kompilieren bestätigt). `varianten` und `dateiname` fängt klassenarbeit selbst ab.
- Die Fehlermeldung bei Tippfehlern nennt `arbeitsblatt:`, nicht `klassenarbeit:`.

Über `set-options` (aufgaben 0.3.1, Z. 113) gesetzt: `punkte-template-aufgabe`, `punkte-template-teilaufgabe` (Z. 217-220). Der Parameter in klassenarbeit heißt `punkte-template` mit Unterschlüsseln `aufgabe` / `teilaufgabe`; die Options-Schlüssel in aufgaben heißen `punkte-template-aufgabe` / `punkte-template-teilaufgabe`. Die Standard-Templates sind in klassenarbeit (Z. 208-209) und in aufgaben (Z. 50-51) **doppelt** definiert (`[*#punkte BE*]`, `[*[#punkte BE]*]`).

### 1.9 Was `klassenarbeit` an `klausurbögen` reicht (Z. 30-39)

| klassenarbeit | klausurbögen | gleich benannt? |
|---|---|---|
| `title` (aus `..args`) | `exam` | **nein** |
| `subtitle` | `subexam` | **nein** |
| `teacher` | `teacher` | ja (Default dort aber `"SLZ"` statt `""`) |
| `class` (aus `..args`) | `class` | ja (Default dort `"PH1"` statt `""`) |
| `date` | `date` | ja (Default dort `"09.10.2023"` statt `""`) |
| `klausurboegen.ergebnisse` | `students` | **nein** (de vs. en, und anderer Begriff: Ergebnisse vs. Schüler) |
| `klausurboegen.ergebnisse != none` | `result` | **nein** (abgeleitet) |
| `klausurboegen.<rest>` | gleichnamig | ja |
| `logo` | - | nicht durchgereicht; klausurbögen nutzt fest `image("logo.svg")` (Z. 163, 165) |
| `font`, `math-font`, `theme`, `akzent` | - | nicht durchgereicht; klausurbögen nutzt fest `"Myriad Pro"` (Z. 64, 75) |
| `teilaufgabe-numbering` (`"a)"` \| `"1."`) | `numbering` (`"a)"` \| alles andere = Ziffern) | **nein**, wird auch nicht automatisch gekoppelt |
| `student` | - | nicht durchgereicht (Namen kommen aus `ergebnisse`) |

### 1.10 String-Enums, States, Labels, Dateinamen

| Sache | Werte / Name | Zeile | Anmerkung |
|---|---|---|---|
| Variante | `"druck"`, `"loesung"`, `"klausurboegen"` | 445-494, 507-520 | `oe`/`ue` statt Umlaut. arbeitsblatt kennt `"druck"`, `"digital"`, `"loesung"`, `"zweifach"` (arbeitsblatt.typ Z. 900); klassenarbeit kennt `"digital"` und `"zweifach"` **nicht** und akzeptiert anders als arbeitsblatt **kein Dictionary** für `varianten` |
| `varianten: auto` | klassenarbeit: `("druck", "loesung")`; arbeitsblatt: `("digital", "loesung")` | 446 | gleicher Parameter, verschiedener Auto-Wert (fachlich begründet, aber zu dokumentieren) |
| `page-numbering` | `true`, `false`, `"reset"`, `"continuous"` | 68 | bool und String für denselben Schalter; `true` und `"reset"` sind Aliase |
| `logo` | `"angela"` | 54, logos.typ Z. 2 | einziger Schlüssel im Dictionary `logos` |
| State | `state("ka-variante", none)` als `_state_ka_variante` | 8 | Bindung snake_case, Key kebab |
| Counter | `counter("klassenarbeit")` als `_ka-counter` | 3 | Bindung kebab |
| State aus arbeitsblatt | `_state_ab_scope` (`state("ab-scope")`) | 319 | Zugriff auf privaten Namen des Nachbarpakets |
| Ende-Label | `label("ende-arbeitsblatt-id-" + str(ka-id) + "-" + variante)` | 74, 117 | heißt "arbeitsblatt", obwohl es die Klassenarbeit markiert |
| Metadaten | `metadata("ende-des-dokuments")` | 309 | |
| Scope | `"ka-<id>-druck"`, `"ka-<id>-loesung"` | 463, 474 | |
| Bundle-Dateien | `<name>.pdf`, `<name> - Lösung.pdf`, `<name> - Klausurbögen.pdf` | 459, 470, 481 | hier Umlaute, in den Enum-Werten `loesung`/`klausurboegen` |
| Ersatz-Basisname | `"Klassenarbeit " + str(ka-id)` | 442 | |
| Footer-Text | `Seite x von y` | 133 | fest deutsch |
| Fonts | Fallback-Kette `(font, "Fira Sans", "New Computer Modern Sans", "DejaVu Sans")`, Mathe `(math-font, "New Computer Modern Sans Math")`; Defaults `"Myriad Pro"`, `"Fira Math"` | 96-99 | dieselbe Logik steht noch einmal in arbeitsblatt.typ (Z. 331-337), dort mit `_liste()` für Arrays |
| Theme-Schlüssel, die entfernt werden | `kopf`, `fuss`, `hintergrund`, `rand`, `header-ascent` | 88 | vier deutsche Schlüssel und ein englischer in einem Dictionary |
| Theme-Schlüssel, die gelesen werden | `schrift.text`, `schrift.mathe` | 92, 96-97 | arbeitsblatt liest zusätzlich `schrift.groesse`, `schrift.titel` |

### 1.11 Validierung und Fehlermeldungen in klassenarbeit

| Zeile | Prüfung | Meldung (wörtlich) | Sprache |
|---|---|---|---|
| 67-70 | `page-numbering in (true, false, "reset", "continuous")` | `klassenarbeit: ungültiger Wert für \`page-numbering\`: <repr> – erlaubt: true, false, "reset", "continuous"` | de |
| 403-406 | `type(erwartungen) in (bool, dictionary)` | `klassenarbeit: \`erwartungen\` muss true, false oder ein Dictionary sein, erhalten: <repr>` | de |
| 493, 519 | unbekannte Variante | `Unbekannte Klassenarbeit-Variante: <repr>` (per `panic`, ohne Präfix `klassenarbeit:`, ohne Liste der erlaubten Werte) | de |

Nicht geprüft werden: Typ von `klausurboegen` (alles außer `false` aktiviert, z. B. auch `"ja"` oder `none`), Schlüssel im `klausurboegen`-Dictionary (erst Typst-Fehler "unexpected argument"), Schlüssel im `erwartungen`-Dictionary (dito in `show-erwartungen`), Typ von `info-table` (`true` ist wirkungslos), Typ von `punkte-template` (falscher Typ wird still ignoriert), Typ von `varianten`, `logo` (unbekannter String wird als Text gesetzt), `name-field`. Unbekannte Top-Level-Optionen prüft erst arbeitsblatt, mit Präfix `arbeitsblatt:`.

Drei Formulierungsmuster für dieselbe Art Fehler: "ungültiger Wert für ... – erlaubt: ...", "... muss ... sein, erhalten: ...", "Unbekannte ...: ...". klausurbögen nutzt ein viertes ("... muss ... sein, nicht ...").

### 1.12 `logos.typ`

| Zeile | Name | Art | Inhalt |
|---|---|---|---|
| 1 | `logos` | dictionary | ein Schlüssel `angela` mit SVG-Quelltext als String (809 x 809 pt). Wird nicht re-exportiert, nur lokal importiert (klassenarbeit.typ Z. 140). Identisch zu 0.3.2. |

### 1.13 `template/ka.typ`

Wörtlich benutzte Optionen: `title: [Klassenarbeit]`, `subtitle: [Untertitel]`, `class: [10a]`, `date: [01.01.2025]`, `teacher: [SLZ]`, `punkte: "alle"`, `loesungen: "keine"`, `erwartungen: (erreicht: true)`, `klausurboegen: (muster: "kariert", korrekturrand: "aussen")`.

Auffälligkeiten:

- Z. 9 Kommentar `// aufgabe, teilaufgabe, alle, keine` - erlaubt sind laut arbeitsblatt.typ Z. 312 `"keine"`, `"aufgaben"`, `"teilaufgaben"`, `"alle"`, `"keine-summe"` (Plural). Die Singularformen aus dem Kommentar führen zum Abbruch.
- Z. 10 Kommentar `//seite, seiten, sofort, folgend, keine` - es fehlen `"nur"`, `"reinquetschen"`, `"false"`.
- Z. 4-8: alle Kopfwerte als content (`[...]`). Mit content-`title` greift der Dateiname im Bundle nicht auf den Titel zurück (klassenarbeit.typ Z. 439 verlangt `type(title) == str`), es entsteht `Klassenarbeit 1.pdf`. Der Kommentar Z. 16-18 verspricht dagegen `"{Titel}.pdf"`.
- Z. 18 Kommentar: "mit klausurboegen: true zusätzlich ..." - im Template ist `klausurboegen` bereits ein Dictionary und damit aktiv.
- Unterschied zu 0.3.2: nur die Importzeile.

### 1.14 Vergleich mit klassenarbeit 0.3.2

Die Signaturen von `klassenarbeit`, `_klassenarbeit-einzeln` und `_klausurboegen-inhalt` sind **unverändert**. Änderungen in 0.4.0:

- Import `arbeitsblatt:0.3.0` -> `0.4.0`.
- Neu: Prüfung von `page-numbering` und `erwartungen`.
- Neu: `theme`/`akzent` aus `..args`, `font`/`math-font` Default `auto` statt fester Namen.
- `page-settings` wird nicht mehr doppelt durchgereicht (in 0.3.2 überschrieb das Original die zusammengebauten Ränder).
- `margin` versteht jetzt auch `y` und `rest` (Z. 201).
- `punkte-template` setzt immer beide Templates zurück.
- Seitenzähler-Reset nach `arbeitsblatt-einzeln`, Erwartungshorizont in eigenem `page({...})`, `new-page` wird verworfen.

---

## 2. klausurboegen 0.0.5

### 2.1 Paketdaten (`typst.toml`)

| Feld | Wert |
|---|---|
| name / version | `klausurboegen` / `0.0.5` |
| entrypoint | `klausurboegen.typ` (im Paketwurzelverzeichnis, kein `src/`) |
| authors | fehlt |
| description | `"Package for klausurboegen"` (Platzhalter) |
| Importe | `@schule/patterns:0.0.1`: `kariert` (Z. 1; aktuell ist patterns 0.0.2, das arbeitsblatt 0.4.0 benutzt); `@preview/tablex:0.0.9` lokal an drei Stellen (Z. 76, 216, 348, 418) |
| Dateien | `logo.svg` (fest eingebunden) |

### 2.2 Top-Level-Bindungen

| Zeile | Name | Art | Öffentlich |
|---|---|---|---|
| 37 | `klausurbögen` | Funktion | ja, **einzige** Bindung des Pakets |

Der Paketname ist `klausurboegen`, die Funktion heißt `klausurbögen` (Umlaut im Bezeichner), der Parameter in klassenarbeit `klausurboegen`, der Variantenwert `"klausurboegen"`, die lokale Funktion `klausurbogen` (Singular, Z. 71).

### 2.3 `klausurbögen` (Z. 37-58)

```typ
#let klausurbögen(
  exam: "",
  subexam: "",
  teacher: "SLZ",
  class: "PH1",
  date: "09.10.2023",
  students: (),
  sek1: false,
  result: false,
  rand: 5cm,
  scale: 1,
  sub: false,
  numbering: "a)",
  mv: (dx: 0cm, dy: 0cm),
  weißer-rand: true,
  result-table: true,
  vorschlag: false,
  line-stroke: 1pt + rgb("FF0613"),
  muster: "kariert",
  linienabstand: 8mm,
  korrekturrand: "aussen",
) = [
```

| Parameter | Art | Default | Werte/Typ | Sprache | Bedeutung |
|---|---|---|---|---|---|
| `exam` | named | `""` | str / content; `""` = völlig leerer Bogen ohne Kopf und ohne Seitenzahlen | en | Titel der Arbeit (in klassenarbeit: `title`) |
| `subexam` | named | `""` | str / content | en (Kunstwort) | Untertitel (in klassenarbeit: `subtitle`) |
| `teacher` | named | `"SLZ"` | str / content | en | Lehrkraft; Default ist ein persönliches Kürzel |
| `class` | named | `"PH1"` | str / content | en | Klasse/Kurs; Default ist ein konkreter Kurs |
| `date` | named | `"09.10.2023"` | str / content | en | Datum; Default ist ein festes altes Datum |
| `students` | named | `()` | Array aus Zeilen (Arrays aus Strings): Zeile 0 = Kopfzeile, Zeile 1 = Maximalpunkte, ab Zeile 2 je Schüler `(Name, Note, Punkte...)`. Leeres Array = ein Blanko-Bogen | en | Ergebnisdaten (CSV). Docstring Z. 20 und Beispiel Z. 11 behaupten "Array mit Schülernamen" - das stimmt nicht (siehe 4.2) |
| `sek1` | named | `false` | bool | Abk | Notenschlüssel 1-6 statt 0-15 Punkte; Teilaufgaben immer `a)` |
| `result` | named | `false` | bool | en | Ergebnisdruck: nur Tabelle/Note zum Überdrucken, kein Schreibfeld, keine Innenseiten |
| `rand` | named | `5cm` | length | de | Breite des Korrekturrands |
| `scale` | named | `1` | int / float | en | skaliert nur die Kästchengröße (`grid-size: scale * 0.5cm`, Z. 130); bei `muster: "liniert"` wirkungslos |
| `sub` | named | `false` | bool | Abk (en) | Bogen ohne Ergebnis-/Notenbereich (kleinerer Kopf) |
| `numbering` | named | `"a)"` | `"a)"` \| alles andere = Ziffern | en | Beschriftung der Teilaufgaben in der Punktetabelle; bei `sek1: true` ignoriert |
| `mv` | named | `(dx: 0cm, dy: 0cm)` | dictionary für `move()` | Abk (en) | Verschiebung des Ergebnisdrucks |
| `weißer-rand` | named | `true` | bool | de, **`ß` im Bezeichner**, kebab | `true`: Korrekturrand bleibt weiß; `false`: Kästchen über die ganze Breite, Rand nur als Linie |
| `result-table` | named | `true` | bool | en, kebab | nur zusammen mit `sub` wirksam: Kopfhöhe 6cm statt 3cm (Z. 108-114) |
| `vorschlag` | named | `false` | `false` \| str / content (wird als Beschriftung `<vorschlag>:` gesetzt, Z. 178) | de | Docstring Z. 30 sagt "bool" - falsch |
| `line-stroke` | named | `1pt + rgb("FF0613")` | stroke | en, kebab | Randlinie, nur bei `weißer-rand: false` |
| `muster` | named | `"kariert"` | `"kariert"` \| `"liniert"` | de | Art des Schreibfelds |
| `linienabstand` | named | `8mm` | length | de | Zeilenabstand bei `"liniert"` |
| `korrekturrand` | named | `"aussen"` | `"aussen"` \| `"innen"`; Alias `"außen"` (Z. 60) | de, `ss` statt `ß` | Lage des Korrekturrands |

20 Parameter, alle named, kein Body. Sprachverteilung: en `exam`, `subexam`, `teacher`, `class`, `date`, `students`, `result`, `scale`, `numbering`, `result-table`, `line-stroke`; de `rand`, `weißer-rand`, `vorschlag`, `muster`, `linienabstand`, `korrekturrand`; Abk `sek1`, `sub`, `mv`.

### 2.4 Lokale Funktionen innerhalb von `klausurbögen`

| Zeile | Wörtliche Signatur | Schreibweise |
|---|---|---|
| 71 | `klausurbogen(result: false, name: "", note-content: [], student-table: [], grade-table: [], mv: mv, sub: sub, vorschlag: vorschlag, line-stroke: line-stroke)` | kebab, gem |
| 74 | `header(title: "", subtitle: "", class: "", date: "", teacher: "", logo: [])` | en; fast identisch zu `header` in klassenarbeit.typ Z. 139 (dort `logo: none`) |
| 118 | `falz-links(seite)` | de, positional |
| 119 | `rand-links(seite)` | de, positional |
| 122 | `schreibfeld(seite, hoehe)` | de, positional, `oe` |
| 135 | `halbseite(seite, oben: 0cm, kopf: none, nummer: true)` | de |
| 215 | `gradeBoundaries(maxPoints: 100)` | **camelCase**, en |
| 297 | `note-display(percentage: 0.9462, note: 6)` | kebab, gem |
| 333 | `studentHeader(name: "Max Mustermann", percentage: 0.8462, note: 6)` | **camelCase**; wird nirgends aufgerufen |
| 347 | `createTable(cols: none, maxPoints: none, achievedPoints: none, result: false)` | **camelCase**, en |

Lokale Variablen in camelCase: `insetPageNumber`, `gradeBordersSek1`, `gradeBordersSek2`, `gradeRegions`, `lastLowerBound`, `gradeBorders`, `seperationLines` (Tippfehler), `calculatedBorder`, `roundedBorder`, `upperBound`, `lowerBound`, `finelinerRed`, `gradeInPercent`, `stringGradeInPercent`, `headerRow`, `subtaskRow`, `numberOfColumns`, `maxPoints`, `achievedPoints`, `headerCell`, `isSubtask`, `mainTask`, `tempPoints`, `isMainTaskWithSubtasks`, `taskName`, `subtaskCount`. In kebab: `real-rand`, `print-color`, `alphabet-i`. Deutsch: `nachkomma`, `kopf`, `links`, `anzahl`. Tippfehler: `heigth` (Z. 108, 160, 198).

### 2.5 String-Enums, feste Werte, CSV-Konvention

| Sache | Werte | Zeile |
|---|---|---|
| `muster` | `"kariert"`, `"liniert"` | 59 |
| `korrekturrand` | `"innen"`, `"aussen"`, Alias `"außen"` | 60-61 |
| `numbering` | `"a)"`, sonst Ziffern | 362 |
| Seitenformat | A3 quer, Rand 0, zwei Hälften je 21cm x 29,7cm | 63, 142, 195 |
| Schrift | `"Myriad Pro"`, 12pt, fest | 64, 75 |
| Kopfhöhe | `sub` und `result-table`: 6cm; nur `sub`: 3cm; sonst 8cm | 108-114 |
| Notenschlüssel Sek I | `(0.875, 0.75, 0.625, 0.5, 0.2, 0)` | 217 |
| Notenschlüssel Sek II | `(0.95, 0.90, ..., 0.20, 0)` 16 Stufen | 218 |
| Notenwörter | "sehr gut" ... "ungenügend", "Punkt"/"Punkte" | 303, 313-315 |
| Tabellentexte | "Aufgabe", "mögliche Punkte", "erreichte Punkte", "Note", "Punktegrenzen", "Punktegrenze >=", "Name:", "Ergebnis:" | 173, 178, 286-288, 397-408 |
| CSV-Spalten | Spalte 0 Name, Spalte 1 Note, ab Spalte 2 Aufgaben | 479, 541-544 |
| Teilaufgaben-Erkennung in der Kopfzeile | `"A1 a)"` (Leerzeichen + `[a-z]\)$`) oder `"A1.1"` (genau ein Punkt, danach Ziffern) | 488-498 |
| Zellen mit Leerzeichen | werden als Nicht-Punktwert übersprungen | 533, 559 |
| leere Zelle | zählt als 0 (nur bei Schülerzeilen) | 561-562 |
| Rote Farben | `rgb("FF0613")` (Randlinie), `rgb("E90817")` (Note) | 54, 299 |

### 2.6 Validierung und Fehlermeldungen in klausurboegen

| Zeile | Prüfung | Meldung (wörtlich) | Sprache |
|---|---|---|---|
| 59 | `muster in ("kariert", "liniert")` | `klausurbögen: muster muss "kariert" oder "liniert" sein, nicht <repr>` | de |
| 61 | `korrekturrand in ("innen", "aussen")` | `klausurbögen: korrekturrand muss "innen" oder "aussen" sein, nicht <repr>` | de |

Präfix ist der Funktionsname mit Umlaut (`klausurbögen:`), in klassenarbeit der Paketname (`klassenarbeit:`). Parameternamen hier ohne Backticks, in klassenarbeit mit. Alles andere ist ungeprüft: `numbering`, `vorschlag`, `students`-Struktur, `mv`-Schlüssel, `scale`, `rand`.

### 2.7 Vergleich mit klausurboegen 0.0.4 (Achtung: kein Vorgänger, sondern Seitenzweig)

Laut Git wurde 0.0.4 **nach** 0.0.5 nachgetragen (`3cd178c` 0.0.5, dann `0cdcf95` "klausurboegen 0.0.4 nachgetragen", dann `197ea96` 0.0.5). 0.0.4 hat 896 Zeilen, 0.0.5 nur 582, und die beiden Versionen haben **verschiedene, sich nicht überdeckende Funktionsumfänge**:

| Merkmal | 0.0.4 | 0.0.5 |
|---|---|---|
| `klausurbögen(...)` Parameter `muster`, `linienabstand`, `korrekturrand` | fehlen | vorhanden |
| `klausurbögen(...)` Parameter `vordruck: false` (`false` \| `"werte"`), `namen: false` | vorhanden | **fehlen** |
| `bogen-seiten(exam, subexam, teacher, class, date, sek1, sub, result-table, vorschlag, numbering, mv, aufgaben: none, tabelle: false, rueckseite: auto, rand: 12mm, unten: 16mm, abstand: 4mm)` (Z. 741) | vorhanden | **fehlt** |
| `klausurbogen-arbeit(..args, body)` (Z. 889) | vorhanden | **fehlt** |
| ausgelagerte Helfer `_bogen-kopf`, `_bogen-namenszeile`, `_bogen-kopfbox`, `_bogen-kopfhoehe`, `_notentabelle`, `_note-anzeige`, `_punktetabelle` (Z. 10-219) | vorhanden (kebab, de) | fehlen; stattdessen die alten lokalen camelCase-Funktionen |
| `rand` | in `klausurbögen` 5cm = Korrekturrand; in `bogen-seiten` 12mm = Seitenrand | nur 5cm |

Für den 0.4.x-Plan heißt das: die saubere Benennung der Helfer existiert bereits in 0.0.4, die neuen Muster-Optionen nur in 0.0.5. Beide Stränge müssen zusammengeführt werden. klassenarbeit 0.4.0 importiert 0.0.5.

---

## 3. Inkonsistenzen (mit Fundstelle)

Pfade abgekürzt: KA = `klassenarbeit/0.4.0/src/klassenarbeit.typ`, KB = `klausurboegen/0.0.5/klausurboegen.typ`, TPL = `klassenarbeit/0.4.0/template/ka.typ`, AB = `arbeitsblatt/0.4.0/src/arbeitsblatt.typ`, AUF = `aufgaben/0.3.1/aufgaben.typ`.

### 3.1 Dieselbe Sache, verschiedene Namen

1. Titel der Arbeit: `title` (KA:80, AB:269) vs. `exam` (KB:38). Übersetzung in KA:31.
2. Untertitel: `subtitle` (KA:385) vs. `subexam` (KB:39). Übersetzung in KA:32.
3. Ergebnisdaten: `ergebnisse` (KA:26) vs. `students` (KB:43) plus `result` (KB:45). Übersetzung in KA:36-37.
4. Paket/Funktion/Parameter/Wert/Datei: Paket `klausurboegen`, Funktion `klausurbögen` (KB:37), Parameter `klausurboegen` (KA:394), Variante `"klausurboegen"` (KA:479), lokale Funktion `klausurbogen` (KB:71), Datei `- Klausurbögen.pdf` (KA:481).
5. Lösung: Variante `"loesung"` (KA:468), Parameter `loesungen` (AB:286), Wert `"nur"` (KA:243), Datei `- Lösung.pdf` (KA:470). Singular/Plural und Umlaut/`oe` gemischt.
6. Teilaufgaben-Nummerierung: `teilaufgabe-numbering` mit `"a)"` \| `"1."` (AB:284, 318) vs. `numbering` mit `"a)"` \| sonst (KB:49, 362).
7. Randlinie/Gitterlinie: `line-stroke` bedeutet in KB:54 die rote Korrekturrand-Linie, in `patterns` die Gitterlinie des Musters.
8. Zeilenabstand: `linienabstand` (KB:56) vs. `lineheight` in `patterns.liniert` (patterns 0.0.1 Z. 77).
9. Kästchengröße: `scale` als Faktor (KB:47, 130) vs. `grid-size` als Länge in `patterns.kariert`.
10. Rand: `rand` = Korrekturrandbreite (KB:46), im Theme-Dictionary `rand` = Seitenrand (KA:88), in arbeitsblatt `page-settings.margin` (KA:195), in KB 0.0.4 `bogen-seiten(rand: 12mm)` = Seitenrand.
11. Kopf: `custom-header` / `header-ascent` (KA:230-231) vs. Theme-Schlüssel `kopf` (KA:88) vs. lokale Variable `kopf-abstand` (KA:188) vs. lokale Funktion `header` (KA:139, KB:74).
12. Punkte-Templates: `punkte-template` mit Unterschlüsseln `aufgabe`/`teilaufgabe` (KA:214-215) vs. Options-Schlüssel `punkte-template-aufgabe`/`punkte-template-teilaufgabe` (KA:218-219, AUF:50-51).
13. Ein/Aus-Schlüssel in Einstellungs-Dictionaries heißt `show` (KA:28, 317, 433), also englisch und zugleich ein Typst-Schlüsselwort (nur als `(show: false)` im Dictionary schreibbar, nicht als Parameter).
14. Ende-Label heißt `ende-arbeitsblatt-id-...` (KA:74), gehört aber zur Klassenarbeit.

### 3.2 de/en-Mischung innerhalb einer Signatur

15. `klassenarbeit(...)` KA:384-402: en `subtitle, date, logo, teacher, student, name-field, name-repeat, info-table, page-numbering`; de `klausurboegen, erwartungen, varianten, variante, dateiname`; gemischt `punkte-template`.
16. `klausurbögen(...)` KB:37-58: en/de/Abk gemischt, siehe 2.3; insbesondere `result-table` neben `weißer-rand`, `line-stroke` neben `linienabstand`.
17. `_klausurboegen-inhalt(...)` KA:15-22: fünf englische Parameter plus `einstellungen`.
18. `show-erwartungen(grouped, new-page, erreicht, alle, teile)` AUF:534, erreichbar über `erwartungen: (...)`.
19. Theme-Schlüssel-Liste `("kopf", "fuss", "hintergrund", "rand", "header-ascent")` KA:88.
20. Docstring von `klassenarbeit` KA:348-383: Zeilen 348-357, 362-365, 378-380 englisch, der Rest deutsch.

### 3.3 Schreibweisen

21. Umlaut/ß im Bezeichner: `klausurbögen` (KB:37), `weißer-rand` (KB:51) - aber `korrekturrand: "aussen"` mit Alias `"außen"` (KB:60), `klausurboegen`, `loesung`, `_theme-aufloesen`, `hoehe` (KB:122).
22. snake_case vs. kebab bei internen Namen: `_state_ka_variante` (KA:8) neben `_ka-counter` (KA:3) und `_klassenarbeit-einzeln` (KA:48).
23. camelCase in KB: `gradeBoundaries` (215), `studentHeader` (333), `createTable` (347), `insetPageNumber` (72), `maxPoints`, `achievedPoints` usw. neben kebab `note-display` (297), `real-rand` (66), `print-color` (209).
24. Abkürzungen als öffentliche Parameter: `sek1`, `sub`, `mv` (KB:44, 48, 50); intern `ka-id`, `th`, `tpl-aufgabe`.

### 3.4 bool vs. String vs. auto vs. Dictionary für gleichartige Schalter

25. `page-numbering: true | false | "reset" | "continuous"` (KA:68), `true` = `"reset"`.
26. `klausurboegen: false | true | dictionary` mit `show` (KA:431-434); `erwartungen: true | false | dictionary` mit `show` (KA:316-318). Bei `erwartungen` wird der Typ geprüft (KA:403), bei `klausurboegen` nicht.
27. `info-table: false | array`, `true` wirkungslos (KA:76-78, 256).
28. `vorschlag: false | content` (KB:53, 178), dokumentiert als bool (KB:30); Abfrage als `not vorschlag == false`.
29. `loesungen` in arbeitsblatt: Default ist der **String** `"false"` (AB:286), erlaubt sind zugleich `"keine"`, `"false"`, `false`, `none` (AB:310); das Template schreibt `"keine"` (TPL:10).
30. `logo: "angela" | content | none` (KA:54, 141) vs. KB: kein Parameter, `logo: []` als "kein Logo" (KB:74, 83).
31. `variante: auto` löst zu `"druck"` auf (KA:500-506), `varianten: auto` zu `("druck", "loesung")` (KA:445); arbeitsblatt löst `varianten: auto` zu `("digital", "loesung")` auf (AB:910).
32. `name-field: str | none` (Abschalten per `none`) vs. `info-table: false` (Abschalten per `false`) vs. `logo: none`.

### 3.5 Singular/Plural

33. `variante` und `varianten` als zwei getrennte Parameter mit einem Buchstaben Unterschied (KA:397-398).
34. Variantenwert `"loesung"` vs. Parameter `loesungen`; Variantenwert `"klausurboegen"` (Plural) vs. `"druck"`, `"loesung"` (Singular).
35. `erwartungen` (Plural) vs. Doku "Erwartungshorizont".
36. `punkte`-Werte `"aufgaben"`, `"teilaufgaben"` (Plural, AB:312) vs. Template-Kommentar `aufgabe, teilaufgabe` (TPL:9) vs. Unterschlüssel `aufgabe`, `teilaufgabe` von `punkte-template` (KA:214).

### 3.6 Verschiedene Defaults für dasselbe

37. `teacher`: `""` (KA:388) vs. `"SLZ"` (KB:40). `class`: `""` (AB:270) vs. `"PH1"` (KB:41). `date`: `""` (KA:386) vs. `"09.10.2023"` (KB:42).
38. Leeres `class`/`teacher`: KA:163 blendet den Trenner aus, KB:88 und KB:96 setzen immer `#class - #teacher`.
39. Ränder: klassenarbeit `(top: 1cm, bottom: 1cm, left: 1.5cm, right: 1.5cm)` fest in KA:191; klausurbögen A3 mit `margin: 0cm` und `rand: 5cm`.
40. Schrift: KA nimmt Theme und `font`/`math-font` (KA:94-99); KB fest `"Myriad Pro"` ohne Fallback (KB:64).

### 3.7 positional vs. named

41. Beide Pakete nutzen durchgehend named plus `body` - in sich konsistent. Abweichung nur bei den Helfern in KB: `schreibfeld(seite, hoehe)`, `halbseite(seite, oben:, ...)` positional vs. `klausurbogen(result:, name:, ...)` alles named.
42. `klassenarbeit` deklariert `title` und `class` nicht, obwohl sie sie liest (KA:412-413); `subtitle`, `date`, `teacher` sind dagegen deklariert. Für den Nutzer sind alle fünf gleichartige Kopfangaben.

### 3.8 Negativ-/Positiv-Schalter

43. Keine `no-x`-Schalter in diesen Dateien. Semantisch invertiert ist aber `weißer-rand: true` (KB:51): `false` bedeutet "Kästchen bis an den Blattrand, dafür Randlinie", was der Name nicht vermuten lässt; intern `if not weißer-rand` (KB:67, 144).
44. `sub: true` schaltet den Ergebnisbereich **ab** (KB:108-114, 178, 187), ist also ein versteckter Negativ-Schalter.
45. `result-table: true` wirkt nur, wenn `sub: true` (KB:108).

### 3.9 Aliase und Doppelwege

46. `"außen"` als Alias für `"aussen"` (KB:60), nirgends sonst gibt es solche Umlaut-Aliase.
47. `page-numbering: true` = `"reset"` (KA:252).
48. `klausurboegen: (ergebnisse: x)` = `klausurboegen: (students: x, result: true)` (KA:36-38).
49. `tasks = teilaufgaben` (AB:1263) wird über klassenarbeit mit re-exportiert.

---

## 4. Fehler und Altlasten

### 4.1 klassenarbeit

1. **Docstring nennt Parameter `table`, den es nicht gibt** (KA:355); `name-field` fehlt im Docstring; `logo` als "content" (KA:352), `info-table` als "boolean" (KA:356) dokumentiert.
2. **Bundle-Dateiname ignoriert content-Titel**: KA:439 verlangt `type(title) == str`. Das eigene Template setzt `title: [Klassenarbeit]` (TPL:4), ergibt `Klassenarbeit 1.pdf`. Zugleich prüft KA:460 `title not in ("", none)`, was für content immer wahr ist.
3. **`klausurboegen` ohne Typprüfung**: `boegen-aktiv` ist für jeden Wert außer `false` wahr (KA:431-434), auch für `none` oder Strings.
4. **`info-table: true` tut nichts** (KA:76-78, 256), obwohl der Docstring genau das als Bedeutung nennt.
5. **`erwartungen.new-page` wird still verworfen** (KA:321).
6. **Nutzerargumente überschreiben feste Werte**: `print`, `custom-header`, `header-ascent`, `scope` (KA:227-246).
7. **Zugriff auf private Namen des Nachbarpakets**: `_theme-aufloesen` (KA:86), `_state_ab_scope` (KA:319).
8. **Doppelte Logik zu arbeitsblatt**: Theme-Auflösung und Font-Fallback (KA:86-99 vs. AB:331-337); Standard-BE-Templates (KA:208-209 vs. AUF:50-51).
9. **Doppelter Namensfeld-Code**: `name-field-block` (KA:101-105) und nochmals ausgeschrieben in KA:274-277.
10. Redundante Bedingungen: `type(info-table) != bool and type(info-table) == array` (KA:76); `type(table) == array and ...` (KA:257), obwohl `table` immer Array ist; `if table-cells.len() > 0` (KA:286) nach vorheriger Prüfung `table != ()`.
11. `header`-Zweig ohne Logo (KA:166-172) ignoriert `subtitle` und nutzt keine einheitliche Schriftgröße für Datum/Klasse.
12. Kommentar "Extract font from args for internal use" (KA:93) als einzelner englischer Kommentar zwischen deutschen.
13. `panic` statt `assert` mit Paketpräfix für unbekannte Varianten (KA:493, 519).
14. Positionale Extra-Argumente in `..args` werden still verworfen (nur `args.named()` wird benutzt).
15. Doku-Beispiel `name-field: "Name:"` (`klassenarbeit/0.4.0/docs/content.typ` Z. 115) ergibt "Name::", weil der Doppelpunkt automatisch gesetzt wird (KA:103).
16. Template-Kommentare mit falschen/unvollständigen Enum-Werten (TPL:9, 10, 18), siehe 1.13.

### 4.2 klausurboegen

17. **Das dokumentierte Beispiel stürzt ab** (per Kompilieren bestätigt): `klausurbögen(exam: "Mathematik", class: "10a", date: "15.03.2025", students: ("Max Mustermann", "Erika Musterfrau"))` aus dem Docstring KB:9-12 bricht ab mit `error: invalid float: i` in KB:534. `students` erwartet CSV-Zeilen (Kopfzeile, Maximalpunkte, Schülerzeilen), nicht Namen. Dieselbe falsche Verwendung steht mehrfach in `klausurboegen/0.0.5/docs/content.typ` (Z. 32, 58, 74, 110, 126, 140).
18. **0.0.5 ist gegenüber 0.0.4 ein Rückschritt im Funktionsumfang** (`bogen-seiten`, `klausurbogen-arbeit`, `vordruck`, `namen` fehlen), siehe 2.7.
19. **Toter Code**: `studentHeader` (KB:333-345) wird nie aufgerufen; auskommentiert `//#set text(12pt, fill: print-color, font: "Myriad Pro")` (KB:213).
20. **Identische Zweige**: `if result { print-color } else { print-color }` (KB:278-282, 391-395, 424-428); `if (int(note) < 10) { grade = note } else { grade = note }` (KB:306-310).
21. **Wirkungslose Bedingungen**: `gradeBoundaries` und `createTable` geben nur bei `result` etwas aus, prüfen innen aber weiter `if result` (KB:261, 272, 289, 384, 402-413); `if students.len() > 0` (KB:477) im `else`-Zweig von `students.len() == 0`.
22. **Dummy-Aufruf**: `createTable(cols: cols, maxPoints: 1, achievedPoints: 1, ...)` (KB:474) mit Zahlen statt Arrays; funktioniert nur, weil ohne `result` nichts gerendert wird. Mit `result: true` und leerem `students` würde `maxPoints.map` scheitern (aus dem Code gelesen, nicht ausgeführt).
23. **Zwei fast identische Tabellenzweige** in `createTable` (KB:386-416 und KB:419-463), dazu redundanter zweiter `import` von tablex (KB:418).
24. **Veraltete Abhängigkeiten**: `@preview/tablex:0.0.9` (seit Typst 0.11 durch eingebaute Tabellen ersetzbar; klassenarbeit nutzt bereits `std.table`), `@schule/patterns:0.0.1` statt 0.0.2. `row: (1fr,) * 2` (KB:79) ist vermutlich ein Tippfehler für `rows` (nicht geprüft, ob tablex das still ignoriert).
25. **`liniert` selbst nachgebaut** (KB:124-128) statt `patterns.liniert` zu nutzen; `kariert` kommt dagegen aus patterns.
26. **Doppelte Kopf-Implementierung**: `header` in KB:74-106 ist eine tablex-Kopie von `header` in KA:139-182.
27. Tippfehler in Bezeichnern: `heigth` (KB:108), `seperationLines` (KB:232).
28. Persönliche Defaults `"SLZ"`, `"PH1"`, `"09.10.2023"` (KB:40-42).
29. `typst.toml` ohne `authors`, mit Platzhalter-Beschreibung, Entrypoint nicht unter `src/` (anders als klassenarbeit/arbeitsblatt).
30. `scale` wirkt nur auf Kästchen, nicht auf Linien oder Layout; Docstring sagt nur "Skalierungsfaktor" (KB:24).
31. Docstring-Fehler: `vorschlag (bool)` (KB:30), `students` "Array mit Schülernamen" (KB:20), `sek1` "kleineres Feld" (KB:21; tatsächlich Notenschlüssel).
32. `result: true` ohne `students` und mit `exam != ""` erzeugt eine fast leere Seite (Kopf per `hide`, keine Tabelle).

### 4.3 Repo-weit aufgefallen

33. `aufgaben/0.3.1/aufgaben.typ.orig` liegt unversioniert im Paketverzeichnis (git status `??`).
34. `arbeitsblatt/0.4.0/src/themes.typ` hat uncommittete Änderungen (git status ` M`).
35. `typstage-geogebra/` unversioniert.
36. Viele Altversionen liegen parallel (klassenarbeit 0.0.1-0.4.0 = 15 Versionen, klausurboegen 0.0.1-0.0.5); klausurboegen 0.0.1 importiert noch `@schule/arbeitsblatt:0.0.6`.
37. Tests zu klassenarbeit vorhanden in `tests/`: `ka-be-zwei-bloecke.typ`, `ka-erwartungen-alle.typ`, `ka-fehler-erwartungen-text.typ`, `ka-punkte-template.typ`, `ka-seitenzahlen-continuous.typ`, `ka-seitenzahlen-zwischentext.typ`. Für klausurboegen gibt es **keinen** Test.

---

## 5. Kopplungen im Überblick

| Von | Nach | Version | Was |
|---|---|---|---|
| klassenarbeit 0.4.0 | arbeitsblatt | 0.4.0 (aktuell) | `import *` (Re-Export der ganzen Oberfläche); Aufruf `arbeitsblatt-einzeln`; privat: `_theme-aufloesen`, `_state_ab_scope` |
| klassenarbeit 0.4.0 | aufgaben | 0.3.1 (transitiv über arbeitsblatt) | `set-options((punkte-template-aufgabe:, punkte-template-teilaufgabe:))`, `show-offene-loesungen()`, `show-erwartungen(..)` |
| klassenarbeit 0.4.0 | klausurboegen | 0.0.5 (aktuell, aber ohne die 0.0.4-Funktionen) | `klausurbögen(exam:, subexam:, teacher:, class:, date:, result:, students:, ..)` |
| klausurboegen 0.0.5 | patterns | **0.0.1 (veraltet, aktuell 0.0.2)** | `kariert(height:, grid-size:)` |
| klausurboegen 0.0.5 | @preview/tablex | **0.0.9 (veraltet)** | `tablex`, `cellx`, `rowspanx`, `colspanx`, `vlinex` |
| klassenarbeit 0.3.2 (Vergleich) | arbeitsblatt | 0.3.0 | wie oben, ohne Theme |

Umbenennungen, die paketübergreifend zusammen erfolgen müssen:

- `title`/`subtitle` (klassenarbeit, arbeitsblatt) und `exam`/`subexam` (klausurboegen).
- `ergebnisse` (klassenarbeit) und `students`/`result` (klausurboegen).
- `teilaufgabe-numbering` (arbeitsblatt) und `numbering` (klausurboegen).
- `punkte-template` (klassenarbeit) und `punkte-template-aufgabe`/`-teilaufgabe` (aufgaben-Optionen).
- `erwartungen`-Dictionary (klassenarbeit) und Signatur von `show-erwartungen` (aufgaben).
- `varianten`/`variante`/`dateiname` und Variantennamen (klassenarbeit und arbeitsblatt).
- `loesungen`-Werte (`"nur"` wird von klassenarbeit fest gesetzt, KA:243).
- Theme-Schlüssel `kopf`, `fuss`, `hintergrund`, `rand`, `header-ascent`, `schrift.text`, `schrift.mathe` (klassenarbeit liest/entfernt sie, arbeitsblatt/themes definiert sie).
- `header-ascent` und `custom-header` (klassenarbeit setzt sie fest, arbeitsblatt muss sie weiter annehmen).
- `linienabstand`/`muster`/`line-stroke`/`scale` (klausurboegen) und `lineheight`/`grid-size`/`line-stroke` (patterns).
